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

  void _unlock() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) return;

    final ok = await widget.securityService.verifyPin(pin);
    if (ok) {
      widget.onUnlocked();
    } else {
      setState(() => _message = '❌ غلط PIN، دوبارہ کوشش کریں');
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
                const Text(
                  '🔐 PIN درج کریں',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    labelText: '4-digit PIN',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _unlock,
                  child: const Text('انلاک کریں'),
                ),
                const SizedBox(height: 8),
                Text(_message, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

