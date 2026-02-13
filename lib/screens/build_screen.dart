import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

// ✅ درست imports
import '../services/github_service.dart';
import '../services/gemini_service.dart';
import 'publish_guide_screen.dart';

class BuildScreen extends StatefulWidget {
  final String generatedCode;
  final String projectName;
  final String? framework;
  final String? repoUrl; // ✅ GitHub repo URL

  const BuildScreen({
    super.key,
    required this.generatedCode,
    required this.projectName,
    this.framework = 'Flutter',
    this.repoUrl,
  });

  @override
  State<BuildScreen> createState() => _BuildScreenState();
}

class _BuildScreenState extends State<BuildScreen> {
  final GitHubService _githubService = GitHubService();
  final GeminiService _geminiService = GeminiService();

  bool _isCopying = false;
  bool _isSettingUpBuild = false;
  bool _isCheckingStatus = false;
  
  String _copyResult = '';
  String _buildMessage = '';
  String _buildStatus = ''; // queued, in_progress, completed, failed
  
  Map<String, dynamic>? _latestBuildInfo;

  @override
  void initState() {
    super.initState();
    // اگر repo پہلے سے بنی ہے تو اسٹیٹس چیک کریں
    if (widget.repoUrl != null) {
      _checkBuildStatus();
    }
  }

  // ✅ کوڈ کاپی کریں
  void _copyCodeToClipboard() async {
    setState(() {
      _isCopying = true;
      _copyResult = '';
    });

    try {
      await Clipboard.setData(ClipboardData(text: widget.generatedCode));
      setState(() {
        _isCopying = false;
        _copyResult = '✅ کوڈ کاپی ہو گیا!';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _copyResult = '');
      });
    } catch (e) {
      setState(() {
        _isCopying = false;
        _copyResult = '❌ ناکامی: $e';
      });
    }
  }

  // ✅ GitHub Actions سیٹ اپ کریں (نیا فنکشن)
  void _setupGitHubActions() async {
    setState(() {
      _isSettingUpBuild = true;
      _buildMessage = '🔧 GitHub Actions workflow بنائی جا رہی ہے...';
    });

    try {
      // Workflow push کریں
      await _githubService.createBuildWorkflow(
        repoName: widget.projectName,
        framework: widget.framework ?? 'Flutter',
      );

      setState(() {
        _isSettingUpBuild = false;
        _buildMessage = '✅ Workflow push ہو گئی! بلڈ شروع ہو رہی ہے...';
        _buildStatus = 'queued';
      });

      // پولنگ شروع کریں
      _startPolling();

    } catch (e) {
      setState(() {
        _isSettingUpBuild = false;
        _buildMessage = '❌ سیٹ اپ ناکام: $e';
      });
    }
  }

  // ✅ بلڈ اسٹیٹس چیک کریں
  Future<void> _checkBuildStatus() async {
    if (widget.projectName.isEmpty) return;
    
    setState(() => _isCheckingStatus = true);

    try {
      final status = await _githubService.checkBuildStatus(
        repoName: widget.projectName,
      );
      
      setState(() {
        _latestBuildInfo = status;
        _buildStatus = status['status'] ?? 'unknown';
        _isCheckingStatus = false;
      });

      // اگر ابھی چل رہی ہے تو پولنگ جاری رکھیں
      if (_buildStatus == 'in_progress' || _buildStatus == 'queued') {
        _startPolling();
      }

    } catch (e) {
      setState(() {
        _isCheckingStatus = false;
        _buildMessage = '⚠️ اسٹیٹس چیک ناکام: $e';
      });
    }
  }

  // ✅ پولنگ (ہر 10 سیکنڈ بعد چیک)
  void _startPolling() async {
    int attempts = 0;
    const maxAttempts = 36; // 6 منٹ تک
    
    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 10));
      
      try {
        final status = await _githubService.checkBuildStatus(
          repoName: widget.projectName,
        );
        
        final runStatus = status['status'];
        final conclusion = status['conclusion'];
        final url = status['html_url'];
        
        setState(() {
          _latestBuildInfo = status;
          _buildStatus = runStatus;
        });

        if (runStatus == 'completed') {
          if (conclusion == 'success') {
            setState(() {
              _buildMessage = '✅ بلڈ کامیاب!\n📥 APK ڈاؤنلوڈ کریں';
              _buildStatus = 'success';
            });
          } else {
            setState(() {
              _buildMessage = '❌ بلڈ ناکام!\n🔍 لاگز چیک کریں: $url';
              _buildStatus = 'failed';
            });
          }
          return; // پولنگ ختم
        } else {
          setState(() {
            _buildMessage = runStatus == 'queued' 
                ? '⏳ قطار میں ہے...' 
                : '🔨 بلڈ جاری ہے... (${attempts + 1}/$maxAttempts)';
          });
        }
        
      } catch (e) {
        setState(() {
          _buildMessage = '⚠️ خرابی: $e';
        });
      }
      
      attempts++;
    }
    
    setState(() {
      _buildMessage = '⏰ ٹائم آؤٹ! دستی طور پر چیک کریں';
      _buildStatus = 'timeout';
    });
  }

  // ✅ بلڈ آرٹیفیکٹ ڈاؤنلوڈ کریں
  void _downloadBuild() async {
    if (_latestBuildInfo == null) return;
    
    final runId = _latestBuildInfo!['run_id'];
    final repoUrl = widget.repoUrl ?? await _githubService.getRepoUrl(widget.projectName);
    
    // GitHub Actions artifacts کا لنک
    final artifactsUrl = '$repoUrl/actions/runs/$runId';
    
    if (await canLaunchUrl(Uri.parse(artifactsUrl))) {
      await launchUrl(Uri.parse(artifactsUrl), mode: LaunchMode.externalApplication);
    }
  }

  // ✅ Termux کھولیں
  void _openTermux() async {
    const url = 'termux://';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Termux انسٹال نہیں ہے')),
      );
    }
  }

  // ✅ پلے اسٹور گائیڈ
  void _prepareForPlayStore() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublishGuideScreen(
          appName: widget.projectName,
          generatedCode: widget.generatedCode,
          framework: widget.framework ?? 'Flutter',
        ),
      ),
    );
  }

  // ✅ بلڈ اسٹیٹس کا کلر
  Color _getStatusColor() {
    switch (_buildStatus) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'in_progress':
        return Colors.orange;
      case 'queued':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // ✅ بلڈ اسٹیٹس کا آئیکن
  IconData _getStatusIcon() {
    switch (_buildStatus) {
      case 'success':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      case 'in_progress':
        return Icons.build_circle;
      case 'queued':
        return Icons.hourglass_top;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text('🚀 ${widget.projectName}'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 🎯 بلڈ اسٹیٹس کارڈ (نیا)
            if (_buildStatus.isNotEmpty)
              _buildStatusCard(),

            const SizedBox(height: 16),

            // ⚡ ایکشن بٹنز
            _buildActionButtons(),

            const SizedBox(height: 20),

            // 📋 کوڈ سیکشن
            _buildCodeSection(),

            const SizedBox(height: 20),

            // 📱 ہدایات
            _buildInstructionsCard(),
          ],
        ),
      ),
    );
  }

  // 🎯 بلڈ اسٹیٹس کارڈ
  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        border: Border.all(color: _getStatusColor()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            _buildStatus == 'success' ? '✅ بلڈ تیار ہے!' 
                : _buildStatus == 'failed' ? '❌ بلڈ ناکام'
                : _buildStatus == 'in_progress' ? '🔨 بلڈ جاری ہے...'
                : '⏳ قطار میں...',
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_buildMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _buildMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
          if (_buildStatus == 'success') ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('APK ڈاؤنلوڈ کریں'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _downloadBuild,
            ),
          ],
        ],
      ),
    );
  }

  // ⚡ ایکشن بٹنز
  Widget _buildActionButtons() {
    return Column(
      children: [
        // GitHub Actions بلڈ بٹن
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            icon: _isSettingUpBuild
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.play_circle_fill, size: 28),
            label: Text(
              _isSettingUpBuild ? 'سیٹ اپ ہو رہا ہے...' 
                  : _buildStatus == 'success' ? 'دوبارہ بلڈ کریں'
                  : '⚡ GitHub Actions سے بلڈ کریں',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSettingUpBuild ? null : _setupGitHubActions,
          ),
        ),

        const SizedBox(height: 12),

        // دستی طریقہ بٹن
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.terminal),
                label: const Text('Termux'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _openTermux,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.shop),
                label: const Text('پلے اسٹور'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white30),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _prepareForPlayStore,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 📋 کوڈ سیکشن
  Widget _buildCodeSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ہیڈر
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.code, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 8),
                Text(
                  'جنریٹ شدہ کوڈ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    '${widget.generatedCode.split('\n').length} لائنیں',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.white.withOpacity(0.1),
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          
          // کوڈ
          Container(
            height: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                widget.generatedCode,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📱 ہدایات کارڈ
  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'کیا کرنا ہے؟',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionStep('1', '⚡ بلڈ کریں دبائیں', 'GitHub Actions شروع ہو گی'),
          _buildInstructionStep('2', '5-10 منٹ انتظار کریں', 'آٹو بلڈ چلے گی'),
          _buildInstructionStep('3', '✅ کامیابی پر ڈاؤنلوڈ کریں', 'APK/AAB فائل ملے گی'),
          _buildInstructionStep('4', 'پلے اسٹور پر اپلوڈ کریں', 'یا فون میں انسٹال کریں'),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
