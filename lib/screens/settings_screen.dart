import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/gemini_service.dart';
import '../services/github_service.dart';

class SettingsScreen extends StatefulWidget {
  final GeminiService geminiService;
  final GitHubService githubService;

  const SettingsScreen({
    super.key,
    required this.geminiService,
    required this.githubService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _geminiApiKeyController = TextEditingController();
  final TextEditingController _githubTokenController = TextEditingController();

  final _secureStorage = const FlutterSecureStorage();
  bool _useSecureStorage = true;

  bool _isTestingConnection = false;
  bool _connectionStatus = false;
  String _testMessage = '';
  bool _isSecureStorageActive = true;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  // 🔹 Settings لوڈ کریں
  void _loadSavedSettings() async {
    try {
      String? savedGeminiKey;
      String? savedGithubToken;

      try {
        // پہلے secure storage سے کوشش
        savedGeminiKey = await _secureStorage.read(key: 'gemini_api_key');
        savedGithubToken = await _secureStorage.read(key: 'github_token');
      } catch (_) {
        // fallback SharedPreferences پر
        savedGeminiKey = await widget.geminiService.getSavedApiKey();
        savedGithubToken = await widget.githubService.getSavedToken();
        _useSecureStorage = false;
      }

      if (!mounted) return;

      setState(() {
        _geminiApiKeyController.text = savedGeminiKey ?? '';
        _githubTokenController.text = savedGithubToken ?? '';
        _isSecureStorageActive = _useSecureStorage;
      });

      if ((savedGeminiKey ?? '').isNotEmpty) {
        _testConnection();
      }
    } catch (e) {
      setState(() {
        _testMessage = '⚠️ ترتیبات لوڈ کرنے میں مسئلہ: $e';
      });
    }
  }

  // 🔹 Gemini Connection Test
  void _testConnection() async {
    if (_geminiApiKeyController.text.isEmpty) {
      setState(() {
        _testMessage = 'براہ کرم پہلے API key درج کریں';
        _connectionStatus = false;
      });
      return;
    }

    setState(() {
      _isTestingConnection = true;
      _testMessage = 'کنکشن ٹیسٹ ہو رہا ہے...';
    });

    try {
      await widget.geminiService.saveApiKey(_geminiApiKeyController.text);
      final isConnected = await widget.geminiService.testConnection();

      setState(() {
        _isTestingConnection = false;
        _connectionStatus = isConnected;
        _testMessage = isConnected
            ? '✅ کنکشن کامیاب! Gemini API کام کر رہی ہے'
            : '❌ کنکشن ناکام! براہ کرم key چیک کریں';
      });
    } catch (e) {
      setState(() {
        _isTestingConnection = false;
        _connectionStatus = false;
        _testMessage = '❌ ٹیسٹ ناکام: $e';
      });
    }
  }

  // 🔹 Save All Settings (Secure + Fallback)
  void _saveAllSettings() async {
    try {
      if (_geminiApiKeyController.text.isNotEmpty) {
        if (_useSecureStorage) {
          await _secureStorage.write(
            key: 'gemini_api_key',
            value: _geminiApiKeyController.text.trim(),
          );
        } else {
          await widget.geminiService.saveApiKey(_geminiApiKeyController.text);
        }
      }

      if (_githubTokenController.text.isNotEmpty) {
        if (_useSecureStorage) {
          await _secureStorage.write(
            key: 'github_token',
            value: _githubTokenController.text.trim(),
          );
        } else {
          await widget.githubService.saveToken(_githubTokenController.text);
        }
      }

      _testConnection();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ ترتیبات محفوظ ہو گئیں'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ محفوظ کرنے میں ناکامی: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔹 Clear All Data
  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ڈیٹا صاف کریں'),
        content: const Text('کیا آپ واقعی تمام API keys اور tokens صاف کرنا چاہتے ہیں؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('منسوخ'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _secureStorage.deleteAll();
                await widget.geminiService.removeApiKey();
                await widget.githubService.removeToken();

                setState(() {
                  _geminiApiKeyController.clear();
                  _githubTokenController.clear();
                  _connectionStatus = false;
                  _testMessage = 'تمام ڈیٹا صاف ہو گیا';
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ تمام ڈیٹا صاف ہو گیا')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ ڈیٹا صاف کرنے میں ناکامی: $e')),
                );
              }
            },
            child: const Text('صاف کریں', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 🔹 API Key Guide
  void _showApiKeyGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Key کیسے حاصل کریں'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('1. https://aistudio.google.com/ پر جائیں'),
              Text('2. Google account سے login کریں'),
              Text('3. Get API key پر کلک کریں'),
              Text('4. API key کو کاپی کریں اور یہاں پیسٹ کریں'),
              SizedBox(height: 12),
              Text(
                'نوٹ: یہ key encrypted form میں محفوظ کی جاتی ہے 🔒',
                style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('سمجھ گیا'),
          ),
        ],
      ),
    );
  }

  // 🔹 GitHub Token Guide
  void _showGithubTokenGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GitHub Token کیسے بنائیں'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('1. GitHub → Settings → Developer settings → Personal access tokens'),
              Text('2. "Generate new token" پر کلک کریں'),
              Text('3. repo permissions دیں'),
              Text('4. Token کو کاپی کریں اور یہاں پیسٹ کریں'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('سمجھ گیا'),
          ),
        ],
      ),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ترتیبات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showApiKeyGuide,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔹 Secure Storage Indicator
              Card(
                color: Colors.blue.shade50,
                child: ListTile(
                  leading: Icon(
                    _isSecureStorageActive ? Icons.lock : Icons.lock_open,
                    color: _isSecureStorageActive ? Colors.green : Colors.red,
                  ),
                  title: Text(
                    _isSecureStorageActive
                        ? 'Secure Storage فعال 🔐'
                        : '⚠️ Secure Storage غیر فعال',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'API keys encrypted form میں محفوظ کی جاتی ہیں',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Connection Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _connectionStatus ? Icons.check_circle : Icons.error_outline,
                            color: _connectionStatus ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _connectionStatus ? 'کنکشن کامیاب' : 'API جوڑے',
                            style: TextStyle(
                              color: _connectionStatus ? Colors.green : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _testMessage,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      if (_isTestingConnection)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _buildKeyCard(
                title: 'Gemini API Key',
                controller: _geminiApiKeyController,
                hint: 'AIzaSyB... اپنی API key درج کریں',
                help: _showApiKeyGuide,
              ),

              const SizedBox(height: 16),

              _buildKeyCard(
                title: 'GitHub Token',
                controller: _githubTokenController,
                hint: 'ghp_... اپنی GitHub token درج کریں',
                help: _showGithubTokenGuide,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _testConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: _isTestingConnection
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('کنکشن ٹیسٹ کریں'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAllSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('محفوظ کریں'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: _clearAllData,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('تمام ڈیٹا صاف کریں'),
              ),

              const SizedBox(height: 12),

              // 🔹 Future PIN Lock Button
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔒 PIN Lock فیچر جلد آرہا ہے'),
                    ),
                  );
                },
                icon: const Icon(Icons.lock_outline),
                label: const Text('PIN Lock فعال کریں'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Key Card Builder
  Widget _buildKeyCard({
    required String title,
    required TextEditingController controller,
    required String hint,
    required VoidCallback help,
  }) {
    return Card(
      child: Padding(
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.help_outline, size: 18), onPressed: help),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _geminiApiKeyController.dispose();
    _githubTokenController.dispose();
    super.dispose();
  }
}
