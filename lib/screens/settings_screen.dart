import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/github_service.dart';
import '../utils/security_helper.dart'; // ✅ secure helper import

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

  bool _isTestingConnection = false;
  bool _connectionStatus = false;
  String _testMessage = '';
  bool _isAuthenticated = false; // ✅ biometric status

  @override
  void initState() {
    super.initState();
    _authenticateAndLoad();
  }

  // ✅ Biometric authentication اور secure settings load کریں
  void _authenticateAndLoad() async {
    final isAuth = await SecurityHelper.authenticateUser();
    if (!mounted) return;

    if (isAuth) {
      setState(() => _isAuthenticated = true);
      _loadSavedSettings();
    } else {
      setState(() {
        _isAuthenticated = false;
        _testMessage = '🔒 رسائی محدود ہے، بایومیٹرک تصدیق درکار ہے';
      });
    }
  }

  // ✅ محفوظ شدہ settings لوڈ کریں
  void _loadSavedSettings() async {
    try {
      final savedGeminiKey = await widget.geminiService.getSavedApiKey();
      final savedGithubToken = await widget.githubService.getSavedToken();

      if (!mounted) return;

      setState(() {
        _geminiApiKeyController.text = savedGeminiKey ?? '';
        _githubTokenController.text = savedGithubToken ?? '';
      });

      if ((savedGeminiKey ?? '').isNotEmpty) {
        _testConnection();
      }
    } catch (e, stack) {
      debugPrint('⚠️ Settings load error: $e');
      debugPrintStack(stackTrace: stack);
    }
  }

  // ✅ API connection test کریں
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

  // ✅ محفوظ کریں (biometric confirmation + secure save)
  void _saveAllSettings() async {
    final isAuth = await SecurityHelper.authenticateUser();
    if (!isAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🔒 تصدیق ناکام۔ ڈیٹا محفوظ نہیں کیا گیا')),
      );
      return;
    }

    try {
      if (_geminiApiKeyController.text.isNotEmpty) {
        await widget.geminiService.saveApiKey(_geminiApiKeyController.text);
      }

      if (_githubTokenController.text.isNotEmpty) {
        await widget.githubService.saveToken(_githubTokenController.text);
      }

      _testConnection();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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

  // ✅ تمام ڈیٹا clear کریں
  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ڈیٹا صاف کریں'),
        content: Text('کیا آپ واقعی تمام API keys اور tokens صاف کرنا چاہتے ہیں؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('منسوخ'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await widget.geminiService.removeApiKey();
                await widget.githubService.removeToken();

                setState(() {
                  _geminiApiKeyController.clear();
                  _githubTokenController.clear();
                  _connectionStatus = false;
                  _testMessage = 'تمام ڈیٹا صاف ہو گیا';
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ تمام ڈیٹا صاف ہو گیا')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ ڈیٹا صاف کرنے میں ناکامی: $e')),
                );
              }
            },
            child: Text('صاف کریں', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ✅ UI Build
  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: Text('ترتیبات'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(
            _testMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('ترتیبات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ✅ Connection Status
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            _connectionStatus
                                ? Icons.check_circle
                                : Icons.link_off,
                            color:
                                _connectionStatus ? Colors.green : Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Text(
                            _connectionStatus
                                ? 'کنکشن کامیاب'
                                : 'اپنا کنکشن جوڑیں',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _connectionStatus
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        _testMessage,
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      if (_isTestingConnection)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // ✅ Gemini API Key Field
              _buildTextFieldCard(
                title: 'Gemini API Key',
                controller: _geminiApiKeyController,
                hint: 'AIzaSy... اپنی API key درج کریں',
              ),

              SizedBox(height: 16),

              // ✅ GitHub Token Field
              _buildTextFieldCard(
                title: 'GitHub Token',
                controller: _githubTokenController,
                hint: 'ghp_... اپنی GitHub token درج کریں',
              ),

              SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _testConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('کنکشن ٹیسٹ کریں'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveAllSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('محفوظ کریں'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              OutlinedButton(
                onPressed: _clearAllData,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('تمام ڈیٹا صاف کریں'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldCard({
    required String title,
    required TextEditingController controller,
    required String hint,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
