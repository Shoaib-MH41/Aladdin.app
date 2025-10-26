import 'package:flutter/material.dart';
import '../services/security_service.dart';

class PinScreen extends StatefulWidget {
  final SecurityService securityService;
  final VoidCallback onUnlocked;

  const PinScreen({
    super.key,
    required this.securityService,
    required this.onUnlocked,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _message = '';
  bool _isSettingUp = false;

  @override
  void initState() {
    super.initState();
    _checkExistingPin();
  }

  void _checkExistingPin() async {
    final hasPin = await widget.securityService.hasPin();
    setState(() {
      _isSettingUp = !hasPin; // اگر PIN نہیں ہے تو setup mode میں جائیں
    });
  }

  void _handlePin() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      setState(() => _message = '❌ PIN 4 ہندسوں کی ہونی چاہیے');
      return;
    }

    if (_isSettingUp) {
      // نیا PIN سیٹ کریں
      await widget.securityService.savePin(pin);
      widget.onUnlocked();
    } else {
      // موجودہ PIN چیک کریں
      final ok = await widget.securityService.verifyPin(pin);
      if (ok) {
        widget.onUnlocked();
      } else {
        setState(() => _message = '❌ غلط PIN، دوبارہ کوشش کریں');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isSettingUp ? '🔐 نیا PIN سیٹ کریں' : '🔐 PIN درج کریں',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: '4-digit PIN',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _handlePin,
                  child: Text(_isSettingUp ? 'PIN سیٹ کریں' : 'انلاک کریں'),
                ),
                SizedBox(height: 8),
                Text(_message, style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
