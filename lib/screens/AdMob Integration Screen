// lib/screens/admob_integration_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/admob_service.dart';

class AdMobIntegrationScreen extends StatefulWidget {
  final Function(String appId, Map<String, String> adUnitIds)? onAdMobSubmitted;

  const AdMobIntegrationScreen({
    super.key,
    this.onAdMobSubmitted,
  });

  @override
  State<AdMobIntegrationScreen> createState() => _AdMobIntegrationScreenState();
}

class _AdMobIntegrationScreenState extends State<AdMobIntegrationScreen> {
  final TextEditingController _appIdController = TextEditingController();
  final TextEditingController _bannerIdController = TextEditingController();
  final TextEditingController _interstitialIdController = TextEditingController();
  final TextEditingController _rewardedIdController = TextEditingController();
  
  bool _isSubmitting = false;
  bool _isValidating = false;
  String _validationMessage = '';
  bool _isValid = false;
  final AdMobService _adMobService = AdMobService();

  @override
  void initState() {
    super.initState();
    _appIdController.addListener(_validateFields);
    _bannerIdController.addListener(_validateFields);
  }

  void _validateFields() {
    final appId = _appIdController.text.trim();
    final bannerId = _bannerIdController.text.trim();
    
    setState(() {
      _isValid = _adMobService.validateAppId(appId) && 
                 _adMobService.validateAdUnitId(bannerId);
      
      if (_isValid) {
        _validationMessage = '✅ AdMob IDs درست ہیں';
      } else if (appId.isNotEmpty || bannerId.isNotEmpty) {
        _validationMessage = '❌ فارمیٹ غلط ہے (ca-app-pub-...)';
      } else {
        _validationMessage = '';
      }
    });
  }

  Future<void> _openAdMobConsole() async {
    await _adMobService.openAdMobConsole();
  }

  Future<void> _validateAdMobIds() async {
    setState(() {
      _isValidating = true;
      _validationMessage = 'جانچ ہو رہی ہے...';
    });
    
    final appId = _appIdController.text.trim();
    final bannerId = _bannerIdController.text.trim();
    final interstitialId = _interstitialIdController.text.trim();
    final rewardedId = _rewardedIdController.text.trim();
    
    final isValid = await _adMobService.validateAllIds(
      appId: appId,
      bannerId: bannerId,
      interstitialId: interstitialId,
      rewardedId: rewardedId,
    );
    
    setState(() {
      _isValid = isValid;
      _isValidating = false;
      _validationMessage = isValid 
          ? '✅ تمام AdMob IDs درست ہیں' 
          : '❌ کچھ IDs غلط ہیں';
    });
  }

  void _submitAdMobIds() async {
    final appId = _appIdController.text.trim();
    final bannerId = _bannerIdController.text.trim();
    
    if (appId.isEmpty || bannerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ App ID اور Banner ID ضروری ہیں'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));

    final adUnitIds = _adMobService.prepareAdUnitIds(
      bannerId: bannerId,
      interstitialId: _interstitialIdController.text.trim(),
      rewardedId: _rewardedIdController.text.trim(),
    );

    widget.onAdMobSubmitted?.call(appId, adUnitIds);
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isValid ? '✅ AdMob محفوظ' : '⚠️ AdMob محفوظ (غیر تصدیق شدہ)'),
        backgroundColor: _isValid ? Colors.green : Colors.orange,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdMob Integration'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'AdMob Console',
            onPressed: _openAdMobConsole,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildInstructionsCard(),
            const SizedBox(height: 20),
            _buildInputCard(),
            const SizedBox(height: 20),
            _buildValidationCard(),
            const SizedBox(height: 20),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      color: Colors.orange[50],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.monetization_on, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Google AdMob',
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        'App میں ads دکھا کر کمائیں',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.help_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Setup Steps:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStep('1', 'admob.google.com پر جائیں'),
            _buildStep('2', 'Sign in with Google'),
            _buildStep('3', 'Apps → Add App → Android/iOS'),
            _buildStep('4', 'App ID copy کریں'),
            _buildStep('5', 'Ad Units بنائیں (Banner/Interstitial/Rewarded)'),
            _buildStep('6', 'سب IDs یہاں paste کریں'),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blue,
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings_applications, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'AdMob IDs درج کریں:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // App ID
            TextField(
              controller: _appIdController,
              decoration: InputDecoration(
                labelText: 'App ID * (ضروری)',
                hintText: 'ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone_android, color: Colors.orange),
                helperText: 'Android & iOS دونوں کے لیے',
              ),
            ),
            const SizedBox(height: 12),
            
            // Banner ID
            TextField(
              controller: _bannerIdController,
              decoration: const InputDecoration(
                labelText: 'Banner Ad Unit ID * (ضروری)',
                hintText: 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.rectangle_outlined, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 12),
            
            // Interstitial ID
            TextField(
              controller: _interstitialIdController,
              decoration: const InputDecoration(
                labelText: 'Interstitial Ad Unit ID (اختیاری)',
                hintText: 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fullscreen, color: Colors.purple),
              ),
            ),
            const SizedBox(height: 12),
            
            // Rewarded ID
            TextField(
              controller: _rewardedIdController,
              decoration: const InputDecoration(
                labelText: 'Rewarded Ad Unit ID (اختیاری)',
                hintText: 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.card_giftcard, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationCard() {
    if (_validationMessage.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isValid ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _isValid ? Colors.green : Colors.orange),
      ),
      child: Row(
        children: [
          _isValidating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _isValid ? Icons.check_circle : Icons.warning,
                  color: _isValid ? Colors.green : Colors.orange,
                  size: 20,
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _validationMessage,
              style: TextStyle(
                color: _isValid ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.verified_user),
            label: const Text('IDs کی تصدیق کریں'),
            onPressed: _isValidating ? null : _validateAdMobIds,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : const Icon(Icons.save),
            onPressed: _isSubmitting ? null : _submitAdMobIds,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            label: Text(
              _isSubmitting ? 'محفوظ ہو رہا ہے...' : 'AdMob محفوظ کریں',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _appIdController.dispose();
    _bannerIdController.dispose();
    _interstitialIdController.dispose();
    _rewardedIdController.dispose();
    super.dispose();
  }
}
