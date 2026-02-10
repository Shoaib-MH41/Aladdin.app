// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/universal_ai_service.dart';
import '../services/github_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _githubController = TextEditingController();
  final _customUrlController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _isSaving = false;
  bool _isTestingAI = false;
  bool _isTestingGitHub = false;
  String _statusMessage = '';

  late UniversalAIService _aiService;
  final GitHubService _githubService = GitHubService();
  
  AIProvider _selectedProvider = AIProvider.gemini;
  bool _showCustomUrlField = false;

  @override
  void initState() {
    super.initState();
    _aiService = UniversalAIService();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // Load AI Provider
      final savedProvider = await _storage.read(key: 'ai_provider');
      if (savedProvider != null) {
        _selectedProvider = _parseProvider(savedProvider);
      }
      
      // Load API Key
      final apiKey = await _storage.read(key: 'ai_api_key');
      _apiKeyController.text = apiKey ?? '';
      
      // Load Custom URL for local provider
      final customUrl = await _storage.read(key: 'ai_custom_url');
      _customUrlController.text = customUrl ?? 'http://localhost:11434';
      
      // Load GitHub Token
      final githubToken = await _storage.read(key: 'github_token');
      _githubController.text = githubToken ?? '';
      
      setState(() {
        _showCustomUrlField = _selectedProvider == AIProvider.local;
      });
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  AIProvider _parseProvider(String provider) {
    switch (provider.toLowerCase()) {
      case 'deepseek':
        return AIProvider.deepseek;
      case 'openai':
        return AIProvider.openai;
      case 'local':
        return AIProvider.local;
      default:
        return AIProvider.gemini;
    }
  }

  // 🔹 Save Settings with new AI Provider
  Future<void> _saveSettings() async {
    if (_selectedProvider != AIProvider.local && _apiKeyController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = '❌ براہ کرم پہلے API key درج کریں';
      });
      return;
    }

    if (_selectedProvider == AIProvider.local && _customUrlController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = '❌ براہ کرم لوکل API URL درج کریں';
      });
      return;
    }

    bool? shouldSave = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings محفوظ کریں'),
        content: Text('کیا آپ واقعی یہ settings محفوظ کرنا چاہتے ہیں؟\n\nProvider: ${_selectedProvider.name.toUpperCase()}'),
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

    if (shouldSave == true) {
      setState(() {
        _isSaving = true;
        _statusMessage = '';
      });

      try {
        // Save AI Provider and API Key
        await _aiService.changeProvider(
          _selectedProvider,
          apiKey: _selectedProvider != AIProvider.local ? _apiKeyController.text.trim() : null,
          customUrl: _selectedProvider == AIProvider.local ? _customUrlController.text.trim() : null,
        );
        
        // Save GitHub Token if provided
        if (_githubController.text.trim().isNotEmpty) {
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
          _statusMessage = '✅ تمام Settings کامیابی سے محفوظ ہو گئیں!';
        });
      } catch (e) {
        setState(() {
          _isSaving = false;
          _statusMessage = '❌ Settings محفوظ نہیں ہو سکیں: $e';
        });
      }
    }
  }

  // 🔹 Remove Settings
  Future<void> _removeSettings() async {
    bool? shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تمام Settings حذف کریں'),
        content: const Text('کیا آپ واقعی تمام API keys اور settings حذف کرنا چاہتے ہیں؟'),
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

    if (shouldDelete == true) {
      await _aiService.removeApiKey();
      await _githubService.removeToken();
      await _storage.delete(key: 'ai_provider');
      await _storage.delete(key: 'ai_custom_url');
      
      setState(() {
        _apiKeyController.clear();
        _githubController.clear();
        _customUrlController.clear();
        _selectedProvider = AIProvider.gemini;
        _showCustomUrlField = false;
        _statusMessage = '🗑️ تمام Settings حذف کر دی گئیں۔';
      });
    }
  }

  // 🔹 Test AI Connection
  Future<void> _testAIConnection() async {
    if (_selectedProvider != AIProvider.local && _apiKeyController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = '❌ براہ کرم پہلے API key درج کریں';
      });
      return;
    }

    if (_selectedProvider == AIProvider.local && _customUrlController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = '❌ براہ کرم لوکل API URL درج کریں';
      });
      return;
    }

    setState(() => _isTestingAI = true);
    
    try {
      // Temporary service for testing
      UniversalAIService testService;
      
      if (_selectedProvider == AIProvider.gemini) {
        testService = UniversalAIService.gemini(apiKey: _apiKeyController.text.trim());
      } else if (_selectedProvider == AIProvider.deepseek) {
        testService = UniversalAIService.deepseek(apiKey: _apiKeyController.text.trim());
      } else if (_selectedProvider == AIProvider.openai) {
        testService = UniversalAIService.openai(apiKey: _apiKeyController.text.trim());
      } else {
        testService = UniversalAIService.local(baseUrl: _customUrlController.text.trim());
      }
      
      final success = await testService.testConnection();
      setState(() {
        _isTestingAI = false;
        _statusMessage = success
            ? '✅ ${_selectedProvider.name.toUpperCase()} کنکشن کامیاب ہے!'
            : '❌ ${_selectedProvider.name.toUpperCase()} کنکشن ناکام۔';
      });
    } catch (e) {
      setState(() {
        _isTestingAI = false;
        _statusMessage = '❌ کنکشن چیک میں مسئلہ: $e';
      });
    }
  }

  // 🔹 Test GitHub Connection
  Future<void> _testGitHubConnection() async {
    if (_githubController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = '❌ براہ کرم پہلے GitHub Token درج کریں';
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
            : '❌ GitHub کنکشن ناکام۔';
      });
    } catch (e) {
      setState(() {
        _isTestingGitHub = false;
        _statusMessage = '❌ GitHub کنکشن چیک میں مسئلہ: $e';
      });
    }
  }

  Future<bool> _validateGitHubToken(String token) async {
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
            _buildSectionTitle('🤖 AI Provider'),
            _buildAIProviderDropdown(),
            const SizedBox(height: 20),

            if (!_showCustomUrlField) _buildSectionTitle('🔑 API Key'),
            if (!_showCustomUrlField)
              _buildTextField(_apiKeyController, '${_selectedProvider.name.toUpperCase()} API Key درج کریں'),
            
            if (_showCustomUrlField) _buildSectionTitle('🌐 Local API URL'),
            if (_showCustomUrlField)
              _buildTextField(_customUrlController, 'لوکل API URL (مثال: http://localhost:11434)'),

            const SizedBox(height: 8),
            _buildTestButton(
              onPressed: _testAIConnection,
              isLoading: _isTestingAI,
              label: 'AI کنکشن چیک کریں',
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

            // 🔘 Save Settings Button
            _buildMainButton(
              onPressed: _isSaving ? null : _saveSettings,
              label: _isSaving ? 'محفوظ ہو رہا ہے...' : 'Settings محفوظ کریں',
              icon: Icons.save,
              color: Colors.blue,
            ),

            const SizedBox(height: 10),

            // 🗑️ Remove Settings Button
            _buildMainButton(
              onPressed: _removeSettings,
              label: 'تمام Settings حذف کریں',
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

  Widget _buildAIProviderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<AIProvider>(
        value: _selectedProvider,
        isExpanded: true,
        underline: const SizedBox(),
        items: AIProvider.values.map((provider) {
          return DropdownMenuItem<AIProvider>(
            value: provider,
            child: Row(
              children: [
                _getProviderIcon(provider),
                const SizedBox(width: 10),
                Text(
                  provider.name.toUpperCase(),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (AIProvider? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedProvider = newValue;
              _showCustomUrlField = newValue == AIProvider.local;
              _statusMessage = '';
            });
          }
        },
      ),
    );
  }

  Widget _getProviderIcon(AIProvider provider) {
    switch (provider) {
      case AIProvider.gemini:
        return const Icon(Icons.g_mobiledata, color: Colors.blue);
      case AIProvider.deepseek:
        return const Icon(Icons.code, color: Colors.purple);
      case AIProvider.openai:
        return const Icon(Icons.chat_bubble, color: Colors.green);
      case AIProvider.local:
        return const Icon(Icons.computer, color: Colors.orange);
      default:
        return const Icon(Icons.auto_awesome);
    }
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'رہنمائی',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('• Gemini: Google کے Gemini API کے لیے (مفت)'),
            Text('• DeepSeek: DeepSeek AI کے لیے (مفت)'),
            Text('• OpenAI: ChatGPT API کے لیے (ادائیگی)'),
            Text('• Local: Ollama یا دوسرے لوکل APIs کے لیے'),
            const SizedBox(height: 8),
            Text('• لوکل API چلانے کے لیے Ollama انسٹال کریں'),
            Text('• GitHub Token: repositories بنانے کے لیے'),
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
      obscureText: hint.contains('API') || hint.contains('Token'),
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
