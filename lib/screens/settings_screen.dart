import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/github_service.dart';
import '../services/gemini_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _geminiController = TextEditingController();
  final _githubController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _isSaving = false;
  bool _isTestingGemini = false;
  bool _isTestingGitHub = false;
  String _statusMessage = '';

  final GeminiService _geminiService = GeminiService();
  final GitHubService _githubService = GitHubService();

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    final geminiKey = await _storage.read(key: 'gemini_api_key');
    final githubToken = await _storage.read(key: 'github_token');
    setState(() {
      _geminiController.text = geminiKey ?? '';
      _githubController.text = githubToken ?? '';
    });
  }

  // 🔹 درست: محفوظ کریں بٹن - کنفرمیشن کے ساتھ
  Future<void> _saveKeys() async {
    // ✅ پہلے چیک کریں کہ کوئی key تو ہے
    if (_geminiController.text.trim().isEmpty && _githubController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = '❌ براہ کرم پہلے کوئی API key درج کریں';
      });
      return;
    }

    // ✅ کنفرمیشن ڈائیلاگ
    bool? shouldSave = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Keys محفوظ کریں'),
        content: const Text('کیا آپ واقعی یہ API keys محفوظ کرنا چاہتے ہیں؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('منسوخ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('محفوظ کریں'),
          ),
        ],
      ),
    );

    // ✅ صرف confirm پر محفوظ کریں
    if (shouldSave == true) {
      setState(() {
        _isSaving = true;
        _statusMessage = '';
      });

      try {
        if (_geminiController.text.trim().isNotEmpty) {
          // ✅ Gemini key کی validation
          final bool isGeminiValid = await _validateGeminiKey(_geminiController.text.trim());
          if (isGeminiValid) {
            await _geminiService.saveApiKey(_geminiController.text.trim());
          } else {
            setState(() {
              _isSaving = false;
              _statusMessage = '❌ Gemini API key درست نہیں ہے';
            });
            return;
          }
        }
        
        if (_githubController.text.trim().isNotEmpty) {
          // ✅ GitHub token کی validation
          final bool isGitHubValid = await _validateGitHubToken(_githubController.text.trim());
          if (isGitHubValid) {
            await _githubService.saveToken(_githubController.text.trim());
          } else {
            setState(() {
              _isSaving = false;
              _statusMessage = '❌ GitHub Token درست نہیں ہے';
            });
            return;
          }
        }

        setState(() {
          _isSaving = false;
          _statusMessage = '✅ تمام Keys کامیابی سے محفوظ ہو گئیں!';
        });
      } catch (e) {
        setState(() {
          _isSaving = false;
          _statusMessage = '❌ Keys محفوظ نہیں ہو سکیں: $e';
        });
      }
    }
  }

  // 🔹 درست: حذف کریں بٹن - کنفرمیشن کے ساتھ
  Future<void> _removeKeys() async {
    // ✅ پہلے چیک کریں کہ کچھ ہے بھی ڈیلیٹ کرنے کے لیے
    final geminiKey = await _storage.read(key: 'gemini_api_key');
    final githubToken = await _storage.read(key: 'github_token');
    
    if ((geminiKey == null || geminiKey.isEmpty) && 
        (githubToken == null || githubToken.isEmpty)) {
      setState(() {
        _statusMessage = 'ℹ️ ڈیلیٹ کرنے کے لیے کوئی Keys موجود نہیں ہیں';
      });
      return;
    }

    // ✅ Warning ڈائیلاگ
    bool? shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تمام Keys حذف کریں'),
        content: const Text('کیا آپ واقعی تمام API keys حذف کرنا چاہتے ہیں؟ یہ عمل واپس نہیں ہو سکتا۔'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('منسوخ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف کریں'),
          ),
        ],
      ),
    );

    // ✅ صرف confirm پر ڈیلیٹ کریں
    if (shouldDelete == true) {
      await _geminiService.removeApiKey();
      await _githubService.removeToken();
      setState(() {
        _geminiController.clear();
        _githubController.clear();
        _statusMessage = '🗑️ تمام Keys حذف کر دی گئیں۔';
      });
    }
  }

  // 🔹 بہتر: Gemini کنکشن ٹیسٹ - پہلے validation
  Future<void> _testGeminiConnection() async {
    if (_geminiController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = '❌ براہ کرم پہلے Gemini API key درج کریں';
      });
      return;
    }

    // ✅ پہلے key کی validation چیک کریں
    final bool isValidFormat = _validateGeminiFormat(_geminiController.text.trim());
    if (!isValidFormat) {
      setState(() {
        _statusMessage = '❌ Gemini API key کا فارمیٹ غلط ہے';
      });
      return;
    }

    setState(() => _isTestingGemini = true);
    
    try {
      final success = await _geminiService.testConnection();
      setState(() {
        _isTestingGemini = false;
        _statusMessage = success
            ? '✅ Gemini کنکشن کامیاب ہے! API key درست ہے'
            : '❌ Gemini کنکشن ناکام۔ براہ کرم اپنی API key چیک کریں۔';
      });
    } catch (e) {
      setState(() {
        _isTestingGemini = false;
        _statusMessage = '❌ Gemini کنکشن چیک میں مسئلہ: $e';
      });
    }
  }

  // 🔹 بہتر: GitHub کنکشن ٹیسٹ - پہلے validation
  Future<void> _testGitHubConnection() async {
    if (_githubController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = '❌ براہ کرم پہلے GitHub Token درج کریں';
      });
      return;
    }

    // ✅ پہلے token کی validation چیک کریں
    final bool isValidFormat = _validateGitHubFormat(_githubController.text.trim());
    if (!isValidFormat) {
      setState(() {
        _statusMessage = '❌ GitHub Token کا فارمیٹ غلط ہے';
      });
      return;
    }

    setState(() => _isTestingGitHub = true);
    
    try {
      final success = await _githubService.checkConnection();
      setState(() {
        _isTestingGitHub = false;
        _statusMessage = success
            ? '✅ GitHub کنکشن کامیاب ہے! Token درست ہے'
            : '❌ GitHub کنکشن ناکام۔ براہ کرم انٹرنیٹ یا Token چیک کریں۔';
      });
    } catch (e) {
      setState(() {
        _isTestingGitHub = false;
        _statusMessage = '❌ GitHub کنکشن چیک میں مسئلہ: $e';
      });
    }
  }

  // 🔹 نیا: Gemini Key Format Validation
  bool _validateGeminiFormat(String apiKey) {
    // ✅ Gemini keys عام طور پر 39 حروف کی ہوتی ہیں اور 'AIza' سے شروع ہوتی ہیں
    if (apiKey.length < 20) return false;
    if (!apiKey.startsWith('AIza')) return false;
    return true;
  }

  // 🔹 نیا: GitHub Token Format Validation
  bool _validateGitHubFormat(String token) {
    // ✅ GitHub tokens عام طور پر 40 حروف کے ہوتے ہیں
    if (token.length < 10) return false;
    return true;
  }

  // 🔹 نیا: Gemini Key کی مکمل validation
  Future<bool> _validateGeminiKey(String apiKey) async {
    if (!_validateGeminiFormat(apiKey)) return false;
    
    try {
      return await _geminiService.testConnection();
    } catch (e) {
      return false;
    }
  }

  // 🔹 نیا: GitHub Token کی مکمل validation
  Future<bool> _validateGitHubToken(String token) async {
    if (!_validateGitHubFormat(token)) return false;
    
    try {
      return await _githubService.checkConnection();
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('🔑 Gemini API Key'),
            _buildTextField(_geminiController, 'Gemini API Key درج کریں'),
            const SizedBox(height: 8),
            _buildTestButton(
              onPressed: _testGeminiConnection,
              isLoading: _isTestingGemini,
              label: 'Gemini کنکشن چیک کریں',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('🐙 GitHub Token'),
            _buildTextField(_githubController, 'GitHub Personal Access Token درج کریں'),
            const SizedBox(height: 8),
            _buildTestButton(
              onPressed: _testGitHubConnection,
              isLoading: _isTestingGitHub,
              label: 'GitHub کنکشن چیک کریں',
            ),

            const SizedBox(height: 30),

            // 🔘 Save Keys Button - اب کنفرمیشن مانگے گا
            _buildMainButton(
              onPressed: _isSaving ? null : _saveKeys,
              label: _isSaving ? 'محفوظ ہو رہا ہے...' : 'Keys محفوظ کریں',
              icon: Icons.save,
              color: Colors.blue,
            ),

            const SizedBox(height: 10),

            // 🗑️ Remove Keys Button - اب کنفرمیشن مانگے گا
            _buildMainButton(
              onPressed: _removeKeys,
              label: 'تمام Keys حذف کریں',
              icon: Icons.delete,
              color: Colors.red,
            ),

            const SizedBox(height: 20),

            // ℹ️ معلومات کارڈ
            _buildInfoCard(),

            const SizedBox(height: 20),

            if (_statusMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('✅')
                      ? Colors.green[50]
                      : _statusMessage.contains('❌')
                          ? Colors.red[50]
                          : _statusMessage.contains('ℹ️')
                              ? Colors.blue[50]
                              : Colors.orange[50],
                  border: Border.all(
                    color: _statusMessage.contains('✅')
                        ? Colors.green
                        : _statusMessage.contains('❌')
                            ? Colors.red
                            : _statusMessage.contains('ℹ️')
                                ? Colors.blue
                                : Colors.orange,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _statusMessage.contains('✅')
                          ? Icons.check_circle
                          : _statusMessage.contains('❌')
                              ? Icons.error
                              : _statusMessage.contains('ℹ️')
                                  ? Icons.info
                                  : Icons.warning,
                      color: _statusMessage.contains('✅')
                          ? Colors.green
                          : _statusMessage.contains('❌')
                              ? Colors.red
                              : _statusMessage.contains('ℹ️')
                                  ? Colors.blue
                                  : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_statusMessage)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🔹 نیا: معلومات کارڈ
  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'رہنمائی',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('• Gemini API key "AIza" سے شروع ہونی چاہیے'),
            Text('• GitHub Token کم از کم 10 حروف کا ہونا چاہیے'),
            Text('• Keys محفوظ کرنے سے پہلے خودبخود validate ہوں گی'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      );

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.vpn_key),
      ),
      obscureText: true,
    );
  }

  Widget _buildTestButton({
    required VoidCallback onPressed,
    required bool isLoading,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.wifi),
        label: Text(isLoading ? 'چیک ہو رہا ہے...' : label),
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required VoidCallback? onPressed,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
