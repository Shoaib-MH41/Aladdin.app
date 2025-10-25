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

  Future<void> _saveKeys() async {
    setState(() {
      _isSaving = true;
      _statusMessage = '';
    });

    try {
      if (_geminiController.text.trim().isNotEmpty) {
        await _geminiService.saveApiKey(_geminiController.text.trim());
      }
      if (_githubController.text.trim().isNotEmpty) {
        await _githubService.saveToken(_githubController.text.trim());
      }

      setState(() {
        _isSaving = false;
        _statusMessage = '✅ Keys محفوظ کر لی گئیں!';
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
        _statusMessage = '❌ Key محفوظ نہیں ہو سکی: $e';
      });
    }
  }

  Future<void> _removeKeys() async {
    await _geminiService.removeApiKey();
    await _githubService.removeToken();
    setState(() {
      _geminiController.clear();
      _githubController.clear();
      _statusMessage = '🗑️ تمام Keys حذف کر دی گئیں۔';
    });
  }

  Future<void> _testGeminiConnection() async {
    setState(() => _isTestingGemini = true);
    final success = await _geminiService.testConnection();
    setState(() {
      _isTestingGemini = false;
      _statusMessage = success
          ? '✅ Gemini کنکشن کامیاب ہے!'
          : '❌ Gemini کنکشن ناکام۔ براہ کرم اپنی API key چیک کریں۔';
    });
  }

  Future<void> _testGitHubConnection() async {
    setState(() => _isTestingGitHub = true);
    final success = await _githubService.checkConnection();
    setState(() {
      _isTestingGitHub = false;
      _statusMessage = success
          ? '✅ GitHub کنکشن کامیاب ہے!'
          : '❌ GitHub کنکشن ناکام۔ براہ کرم انٹرنیٹ یا Token چیک کریں۔';
    });
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

            // 🔘 Save Keys Button
            _buildMainButton(
              onPressed: _isSaving ? null : _saveKeys,
              label: _isSaving ? 'محفوظ ہو رہا ہے...' : 'Keys محفوظ کریں',
              icon: Icons.save,
              color: Colors.blue,
            ),

            const SizedBox(height: 10),

            // 🗑️ Remove Keys Button
            _buildMainButton(
              onPressed: _removeKeys,
              label: 'تمام Keys حذف کریں',
              icon: Icons.delete,
              color: Colors.red,
            ),

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
                          : Colors.blue[50],
                  border: Border.all(
                    color: _statusMessage.contains('✅')
                        ? Colors.green
                        : _statusMessage.contains('❌')
                            ? Colors.red
                            : Colors.blue,
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
                              : Icons.info,
                      color: _statusMessage.contains('✅')
                          ? Colors.green
                          : _statusMessage.contains('❌')
                              ? Colors.red
                              : Colors.blue,
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
