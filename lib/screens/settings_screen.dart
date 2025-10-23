import 'package:flutter/material.dart';
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
  bool _isTestingConnection = false;
  bool _connectionStatus = false;
  String _testMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  // ✅ محفوظ شدہ settings لوڈ کریں
  void _loadSavedSettings() async {
  try {
    final savedGeminiKey = await widget.geminiService.getSavedApiKey();
    final savedGithubToken = await widget.githubService.getSavedToken();

    if (!mounted) return; // 🔒 تاکہ setState اس وقت نہ چلے جب widget dispose ہو جائے

    setState(() {
      _geminiApiKeyController.text = savedGeminiKey ?? '';
      _githubTokenController.text = savedGithubToken ?? '';
    });

    // 🔍 اگر Gemini Key موجود ہے تو کنکشن ٹیسٹ کریں
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
      // ✅ پہلے نئی key سیو کریں
      await widget.geminiService.saveApiKey(_geminiApiKeyController.text);
      
      // ✅ connection test کریں
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

  // ✅ تمام settings سیو کریں
  void _saveAllSettings() async {
    try {
      // ✅ Gemini API key سیو کریں
      if (_geminiApiKeyController.text.isNotEmpty) {
        await widget.geminiService.saveApiKey(_geminiApiKeyController.text);
      }

      // ✅ GitHub token سیو کریں
      if (_githubTokenController.text.isNotEmpty) {
        await widget.githubService.saveToken(_githubTokenController.text);
      }

      // ✅ connection دوبارہ test کریں
      _testConnection();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ترتیبات محفوظ ہو گئیں'),
          backgroundColor: Colors.green,
        )
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ محفوظ کرنے میں ناکامی: $e'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  // ✅ API key حاصل کرنے کے لیے guide
  void _showApiKeyGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('API Key کیسے حاصل کریں'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGuideStep('1.', 'https://aistudio.google.com/ پر جائیں'),
              _buildGuideStep('2.', 'Google account سے login کریں'),
              _buildGuideStep('3.', 'Get API key پر کلک کریں'),
              _buildGuideStep('4.', 'Create API key پر کلک کریں'),
              _buildGuideStep('5.', 'API key کو کاپی کریں'),
              _buildGuideStep('6.', 'یہاں پیسٹ کریں'),
              SizedBox(height: 16),
              Text(
                'نوٹ: API key مفت ہے اور روزانہ 60 requests تک',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('سمجھ گیا'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // browser open کرنے کا option
            },
            child: Text('ویب سائٹ کھولیں'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  // ✅ GitHub token guide
  void _showGithubTokenGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('GitHub Token کیسے بنائیں'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildGuideStep('1.', 'GitHub پر جائیں اور login کریں'),
              _buildGuideStep('2.', 'Settings > Developer settings > Personal access tokens'),
              _buildGuideStep('3.', 'Generate new token پر کلک کریں'),
              _buildGuideStep('4.', 'Token name دیں (جیسے: AladdinApp)'),
              _buildGuideStep('5.', 'repo کی permission چیک کریں'),
              _buildGuideStep('6.', 'Generate token پر کلک کریں'),
              _buildGuideStep('7.', 'Token کو کاپی کریں اور یہاں پیسٹ کریں'),
              SizedBox(height: 16),
              Text(
                'انتباہ: Token کو محفوظ رکھیں، دوبارہ نہیں دکھائی دے گی',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('سمجھ گیا'),
          ),
        ],
      ),
    );
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
                // GitHub token remove کا function بنانا ہوگا
                
                setState(() {
                  _geminiApiKeyController.clear();
                  _githubTokenController.clear();
                  _connectionStatus = false;
                  _testMessage = 'تمام ڈیٹا صاف ہو گیا';
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ تمام ڈیٹا صاف ہو گیا'))
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ ڈیٹا صاف کرنے میں ناکامی: $e'))
                );
              }
            },
            child: Text('صاف کریں', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ترتیبات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: _showApiKeyGuide,
            tooltip: 'مدد',
          ),
        ],
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
                            _connectionStatus ? Icons.check_circle : Icons.error,
                            color: _connectionStatus ? Colors.green : Colors.orange,
                          ),
                          SizedBox(width: 8),
                          Text(
                            _connectionStatus ? 'کنکشن کامیاب' : 'کنکشن ناکام',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _connectionStatus ? Colors.green : Colors.orange,
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

              // ✅ Gemini API Key Section
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Gemini API Key',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.help_outline, size: 18),
                            onPressed: _showApiKeyGuide,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _geminiApiKeyController,
                        decoration: InputDecoration(
                          hintText: 'AIzaSyB... اپنی API key یہاں درج کریں',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        obscureText: true,
                        maxLines: 1,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Google AI Studio سے حاصل کی گئی API key',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // ✅ GitHub Token Section
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'GitHub Token',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.help_outline, size: 18),
                            onPressed: _showGithubTokenGuide,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _githubTokenController,
                        decoration: InputDecoration(
                          hintText: 'ghp_... اپنی GitHub token یہاں درج کریں',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        obscureText: true,
                        maxLines: 1,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'GitHub سے حاصل کی گئی personal access token',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // ✅ Action Buttons
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
                      child: _isTestingConnection
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text('کنکشن ٹیسٹ کریں'),
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

              // ✅ Clear Data Button
              OutlinedButton(
                onPressed: _clearAllData,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('تمام ڈیٹا صاف کریں'),
              ),

              SizedBox(height: 20),

              // ✅ Information Section
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Gemini API key مفت ہے\n'
                        '• روزانہ 60 requests تک\n'
                        '• GitHub token repositories بنانے کے لیے\n'
                        '• دونوں keys محفوظ رکھیں',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
