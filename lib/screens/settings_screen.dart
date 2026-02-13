// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/gemini_service.dart';
import '../services/github_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ============= 📝 Text Controllers =============
  late final TextEditingController _apiKeyController;
  late final TextEditingController _githubController;
  late final TextEditingController _customUrlController;
  
  // ============= 🎯 State Variables =============
  late final FlutterSecureStorage _storage;
  late final GeminiService _aiService;
  late final GitHubService _githubService;
  
  // Settings State
  AIProvider _selectedProvider = AIProvider.gemini;
  bool _showCustomUrlField = false;
  
  // UI State
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isTestingAI = false;
  bool _isTestingGitHub = false;
  
  // Messages
  String _statusMessage = '';
  String _aiStatusMessage = '';
  String _githubStatusMessage = '';
  
  // Colors
  static const Color _primaryColor = Color(0xFF2563EB);
  static const Color _successColor = Color(0xFF059669);
  static const Color _errorColor = Color(0xFFDC2626);
  static const Color _warningColor = Color(0xFFD97706);
  static const Color _infoColor = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  // ============= 🚀 Initialization =============
  
  Future<void> _initializeServices() async {
    _storage = const FlutterSecureStorage();
    _aiService = GeminiService();
    _githubService = GitHubService();
    _apiKeyController = TextEditingController();
    _githubController = TextEditingController();
    _customUrlController = TextEditingController(text: 'http://localhost:11434');
    
    await _loadSettings();
    
    setState(() => _isLoading = false);
  }

  // ============= 📥 Load Settings =============
  
  Future<void> _loadSettings() async {
    try {
      // Load AI Provider
      final savedProvider = await _storage.read(key: 'ai_provider');
      if (savedProvider != null) {
        _selectedProvider = _parseProvider(savedProvider);
      }
      
      // Load API Key (masked)
      final apiKey = await _storage.read(key: 'ai_api_key');
      _apiKeyController.text = apiKey ?? '';
      
      // Load Custom URL
      final customUrl = await _storage.read(key: 'ai_custom_url');
      _customUrlController.text = customUrl ?? 'http://localhost:11434';
      
      // Load GitHub Token (masked)
      final githubToken = await _storage.read(key: 'github_token');
      _githubController.text = githubToken ?? '';
      
      _showCustomUrlField = _selectedProvider == AIProvider.local;
      
      // Check saved status
      await _checkSavedStatus();
      
    } catch (e) {
      _showError('Settings لوڈ کرنے میں مسئلہ: $e');
    }
  }

  Future<void> _checkSavedStatus() async {
    // Check AI status
    final isAIInitialized = await _aiService.isInitialized();
    _aiStatusMessage = isAIInitialized 
        ? '✅ ${_selectedProvider.name} فعال ہے'
        : '⚠️ ${_selectedProvider.name} سیٹ نہیں ہے';
    
    // Check GitHub status
    final githubToken = await _githubService.getSavedToken();
    _githubStatusMessage = githubToken != null
        ? '✅ GitHub Token محفوظ ہے'
        : '⚠️ GitHub Token سیٹ نہیں ہے';
  }

  // ============= 🔧 Helper Methods =============
  
  AIProvider _parseProvider(String provider) {
    switch (provider.toLowerCase()) {
      case 'deepseek': return AIProvider.deepseek;
      case 'openai': return AIProvider.openai;
      case 'local': return AIProvider.local;
      default: return AIProvider.gemini;
    }
  }

  String _maskApiKey(String key) {
    if (key.length < 8) return key;
    return '${key.substring(0, 4)}...${key.substring(key.length - 4)}';
  }

  // ============= 💾 Save Settings =============
  
  Future<void> _saveSettings() async {
    if (!_validateInputs()) return;

    final confirm = await _showConfirmDialog(
      title: 'Settings محفوظ کریں',
      content: 'کیا آپ ${_selectedProvider.name} کے ساتھ settings محفوظ کرنا چاہتے ہیں؟',
      confirmText: 'محفوظ کریں',
      isDestructive: false,
    );

    if (confirm != true) return;

    setState(() {
      _isSaving = true;
      _statusMessage = '';
    });

    try {
      // Save AI Settings
      await _aiService.changeProvider(
        _selectedProvider,
        apiKey: _selectedProvider != AIProvider.local ? _apiKeyController.text.trim() : null,
        customUrl: _selectedProvider == AIProvider.local ? _customUrlController.text.trim() : null,
      );
      
      // Save GitHub Token
      if (_githubController.text.trim().isNotEmpty) {
        final isValid = await _validateGitHubToken(_githubController.text.trim());
        if (!isValid) {
          throw Exception('GitHub Token درست نہیں ہے');
        }
        await _githubService.saveToken(_githubController.text.trim());
      }

      await _checkSavedStatus();
      
      _showSuccess('✅ تمام Settings محفوظ ہو گئیں!');
      
    } catch (e) {
      _showError('Settings محفوظ نہیں ہو سکیں: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  bool _validateInputs() {
    if (_selectedProvider != AIProvider.local) {
      if (_apiKeyController.text.trim().isEmpty) {
        _showError('❌ براہ کرم API Key درج کریں');
        return false;
      }
    }

    if (_selectedProvider == AIProvider.local) {
      if (_customUrlController.text.trim().isEmpty) {
        _showError('❌ براہ کرم Local API URL درج کریں');
        return false;
      }
    }

    return true;
  }

  // ============= 🗑️ Remove Settings =============
  
  Future<void> _removeSettings() async {
    final confirm = await _showConfirmDialog(
      title: 'تمام Settings حذف کریں',
      content: 'کیا آپ واقعی تمام API keys اور settings حذف کرنا چاہتے ہیں؟\nیہ عمل واپس نہیں ہو سکتا۔',
      confirmText: 'حذف کریں',
      isDestructive: true,
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);

    try {
      // Clear all services
      await _aiService.removeApiKey();
      await _githubService.removeToken();
      
      // Clear storage
      await _storage.delete(key: 'ai_provider');
      await _storage.delete(key: 'ai_custom_url');
      
      // Clear controllers
      _apiKeyController.clear();
      _githubController.clear();
      _customUrlController.text = 'http://localhost:11434';
      
      // Reset state
      setState(() {
        _selectedProvider = AIProvider.gemini;
        _showCustomUrlField = false;
        _aiStatusMessage = '⚠️ AI سیٹ نہیں ہے';
        _githubStatusMessage = '⚠️ GitHub سیٹ نہیں ہے';
      });
      
      _showSuccess('🗑️ تمام Settings حذف کر دی گئیں');
      
    } catch (e) {
      _showError('Settings حذف کرنے میں مسئلہ: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // ============= 🧪 Test Connections =============
  
  Future<void> _testAIConnection() async {
    if (!_validateInputs()) return;

    setState(() => _isTestingAI = true);

    try {
      GeminiService testService;
      
      switch (_selectedProvider) {
        case AIProvider.gemini:
          testService = GeminiService.gemini(apiKey: _apiKeyController.text.trim());
          break;
        case AIProvider.deepseek:
          testService = GeminiService.deepseek(apiKey: _apiKeyController.text.trim());
          break;
        case AIProvider.openai:
          testService = GeminiService.openai(apiKey: _apiKeyController.text.trim());
          break;
        case AIProvider.local:
          testService = GeminiService.local(baseUrl: _customUrlController.text.trim());
          break;
      }
      
      final success = await testService.testConnection();
      
      setState(() {
        _isTestingAI = false;
        _aiStatusMessage = success
            ? '✅ ${_selectedProvider.name} کنکشن کامیاب'
            : '❌ ${_selectedProvider.name} کنکشن ناکام';
      });
      
    } catch (e) {
      setState(() {
        _isTestingAI = false;
        _aiStatusMessage = '❌ کنکشن میں خرابی: ${e.toString().substring(0, 50)}...';
      });
    }
  }

  Future<void> _testGitHubConnection() async {
    if (_githubController.text.trim().isEmpty) {
      _showError('❌ براہ کرم GitHub Token درج کریں');
      return;
    }

    setState(() => _isTestingGitHub = true);

    try {
      final success = await _githubService.checkConnection();
      
      setState(() {
        _isTestingGitHub = false;
        _githubStatusMessage = success
            ? '✅ GitHub کنکشن کامیاب'
            : '❌ GitHub کنکشن ناکام';
      });
      
    } catch (e) {
      setState(() {
        _isTestingGitHub = false;
        _githubStatusMessage = '❌ GitHub کنکشن میں خرابی';
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

  // ============= 📋 Dialog Helpers =============
  
  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    required bool isDestructive,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'منسوخ',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? _errorColor : _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // ============= 📢 Message Helpers =============
  
  void _showSuccess(String message) {
    setState(() => _statusMessage = message);
    _autoDismissMessage();
  }

  void _showError(String message) {
    setState(() => _statusMessage = message);
    _autoDismissMessage();
  }

  void _autoDismissMessage() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          if (_statusMessage == _statusMessage) {
            _statusMessage = '';
          }
        });
      }
    });
  }

  // ============= 🔗 Link Helpers =============
  
  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ============= 🎨 UI Build =============

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '⚙️ Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[50]!, Colors.white],
          ),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🤖 AI Provider Section
          _buildSection(
            icon: Icons.auto_awesome,
            title: 'AI Provider',
            status: _aiStatusMessage,
            statusColor: _aiStatusMessage.contains('✅') 
                ? _successColor 
                : _warningColor,
            child: Column(
              children: [
                _buildAIProviderDropdown(),
                const SizedBox(height: 16),
                if (!_showCustomUrlField) _buildAPIKeyField(),
                if (_showCustomUrlField) _buildCustomUrlField(),
                const SizedBox(height: 12),
                _buildTestButton(
                  onPressed: _testAIConnection,
                  isLoading: _isTestingAI,
                  label: 'ٹیسٹ کنکشن',
                  icon: Icons.wifi,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 🐙 GitHub Section
          _buildSection(
            icon: Icons.code,
            title: 'GitHub Integration',
            status: _githubStatusMessage,
            statusColor: _githubStatusMessage.contains('✅') 
                ? _successColor 
                : _warningColor,
            child: Column(
              children: [
                _buildGitHubTokenField(),
                const SizedBox(height: 12),
                _buildTestButton(
                  onPressed: _testGitHubConnection,
                  isLoading: _isTestingGitHub,
                  label: 'ٹیسٹ کنکشن',
                  icon: Icons.wifi,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 📚 Info Section
          _buildInfoSection(),

          const SizedBox(height: 24),

          // 🔘 Action Buttons
          _buildActionButtons(),

          const SizedBox(height: 20),

          // 📢 Status Message
          if (_statusMessage.isNotEmpty) _buildStatusMessage(),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String status,
    required Color statusColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: _primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildAIProviderDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AIProvider>(
          value: _selectedProvider,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          items: AIProvider.values.map((provider) {
            return DropdownMenuItem<AIProvider>(
              value: provider,
              child: Row(
                children: [
                  _buildProviderIcon(provider),
                  const SizedBox(width: 12),
                  Text(
                    provider.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _buildProviderBadge(provider),
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
      ),
    );
  }

  Widget _buildProviderIcon(AIProvider provider) {
    final iconData = switch (provider) {
      AIProvider.gemini => Icons.auto_awesome,
      AIProvider.deepseek => Icons.smart_toy,
      AIProvider.openai => Icons.chat,
      AIProvider.local => Icons.computer,
    };
    
    final color = switch (provider) {
      AIProvider.gemini => Colors.blue,
      AIProvider.deepseek => Colors.purple,
      AIProvider.openai => Colors.green,
      AIProvider.local => Colors.orange,
    };
    
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  Widget _buildProviderBadge(AIProvider provider) {
    String badgeText;
    Color badgeColor;
    
    switch (provider) {
      case AIProvider.gemini:
        badgeText = 'FREE';
        badgeColor = Colors.green;
        break;
      case AIProvider.deepseek:
        badgeText = 'FREE';
        badgeColor = Colors.green;
        break;
      case AIProvider.openai:
        badgeText = 'PAID';
        badgeColor = Colors.amber;
        break;
      case AIProvider.local:
        badgeText = 'OFFLINE';
        badgeColor = Colors.orange;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildAPIKeyField() {
    return TextFormField(
      controller: _apiKeyController,
      decoration: InputDecoration(
        labelText: '${_selectedProvider.name} API Key',
        hintText: 'sk-...',
        prefixIcon: const Icon(Icons.vpn_key_outlined),
        suffixIcon: _apiKeyController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _apiKeyController.clear()),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      obscureText: true,
      obscuringCharacter: '•',
    );
  }

  Widget _buildCustomUrlField() {
    return TextFormField(
      controller: _customUrlController,
      decoration: InputDecoration(
        labelText: 'Local API URL',
        hintText: 'http://localhost:11434',
        prefixIcon: const Icon(Icons.link),
        suffixIcon: _customUrlController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => 
                  _customUrlController.text = 'http://localhost:11434'
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildGitHubTokenField() {
    return TextFormField(
      controller: _githubController,
      decoration: InputDecoration(
        labelText: 'GitHub Personal Access Token',
        hintText: 'ghp_...',
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: _githubController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => _githubController.clear()),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      obscureText: true,
      obscuringCharacter: '•',
    );
  }

  Widget _buildTestButton({
    required VoidCallback onPressed,
    required bool isLoading,
    required String label,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _infoColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _infoColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: _infoColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'API Keys & Tokens',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            '🤖 Gemini',
            'Get API Key',
            'https://makersuite.google.com/app/apikey',
          ),
          _buildInfoRow(
            '🦋 DeepSeek',
            'Get API Key',
            'https://platform.deepseek.com/api_keys',
          ),
          _buildInfoRow(
            '🧠 OpenAI',
            'Get API Key',
            'https://platform.openai.com/api-keys',
          ),
          _buildInfoRow(
            '💻 Local',
            'Install Ollama',
            'https://ollama.ai',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            '🐙 GitHub',
            'Generate Token',
            'https://github.com/settings/tokens',
            description: 'repo, workflow scopes',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String action, String url, {String? description}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (description != null)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => _openLink(url),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: Text(action),
            style: TextButton.styleFrom(
              foregroundColor: _primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            onPressed: _isSaving ? null : _saveSettings,
            label: _isSaving ? 'محفوظ ہو رہا ہے...' : 'محفوظ کریں',
            icon: Icons.save_outlined,
            color: _primaryColor,
            isLoading: _isSaving,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            onPressed: _removeSettings,
            label: 'حذف کریں',
            icon: Icons.delete_outline,
            color: _errorColor,
            isLoading: false,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required String label,
    required IconData icon,
    required Color color,
    required bool isLoading,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed == null ? Colors.grey : color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildStatusMessage() {
    final isSuccess = _statusMessage.contains('✅');
    final isError = _statusMessage.contains('❌');
    
    Color bgColor;
    Color borderColor;
    IconData icon;
    
    if (isSuccess) {
      bgColor = _successColor.withOpacity(0.1);
      borderColor = _successColor;
      icon = Icons.check_circle_outline;
    } else if (isError) {
      bgColor = _errorColor.withOpacity(0.1);
      borderColor = _errorColor;
      icon = Icons.error_outline;
    } else {
      bgColor = _warningColor.withOpacity(0.1);
      borderColor = _warningColor;
      icon = Icons.warning_amber_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: borderColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: borderColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: borderColor,
            onPressed: () => setState(() => _statusMessage = ''),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _githubController.dispose();
    _customUrlController.dispose();
    super.dispose();
  }
}
