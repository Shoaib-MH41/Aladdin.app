// lib/models/project_model.dart
import 'ad_model.dart'; // ✅ اشتہار ماڈل ایمپورٹ

class Project {
  final String id;
  String name;
  String framework;
  List<String> platforms;
  Map<String, dynamic> assets;
  
  // ⚠️ **یہاں تبدیلی: Map<String, dynamic> کیا**
  Map<String, dynamic> features;  // ✅ اب dynamic ہے، String نہیں
  
  // ✅ نیا: اشتہار مہموں کی فہرست
  List<AdCampaign>? adCampaigns;
  
  // ✅ نیا: اشتہار بجٹ کی معلومات
  double? adBudget;
  bool? adEnabled;
  DateTime? lastAdCampaignDate;
  
  // ✅ نیا: AdMob Integration کے لیے
  String? adMobAppId;
  Map<String, String>? adMobAdUnitIds;
  
  String? generatedCode;
  String? apkLink;
  
  // ⚠️ **githubRepoUrl - یہ درست ہے**
  String? githubRepoUrl;  // ✅ یہ استعمال ہو رہا ہے
  
  String? geminiPrompt;
  String? status;
  DateTime createdAt;
  DateTime? lastUpdated;

  // ============= 🔄 RESUME/DRAFT STATE =============
  
  /// ✅ نیا: Chat messages کا draft
  List<Map<String, dynamic>>? draftMessages;
  
  /// ✅ نیا: Last generated code
  String? draftGeneratedCode;
  
  /// ✅ نیا: کیا AI سوچ رہا تھا؟
  bool? wasGenerating;
  
  /// ✅ نیا: Last session time
  DateTime? lastSessionTime;
  
  /// ✅ نیا: Pending file updates
  List<Map<String, dynamic>>? pendingFileUpdates;
  
  /// ✅ نیا: کیا session incomplete ہے؟
  bool get hasIncompleteSession {
    if (draftMessages == null || draftMessages!.isEmpty) return false;
    if (lastSessionTime == null) return false;
    
    // 24 گھنٹے پرانا session consider نہیں کریں گے
    final difference = DateTime.now().difference(lastSessionTime!);
    return difference.inHours < 24;
  }

  // ============= 📌 GETTERS =============
  
  /// 🔥 **repoUrl getter - project_service.dart اسے استعمال کرتا ہے**
  String? get repoUrl => githubRepoUrl;
  
  /// 🔥 **isOnGitHub چیک کریں**
  bool get isOnGitHub => githubRepoUrl?.isNotEmpty ?? false;

  bool get isGenerated => generatedCode != null && generatedCode!.isNotEmpty;
  bool get hasError => status == 'error';
  
  // ✅ نیا: کیا اشتہار فعال ہے؟
  bool get hasActiveAds => adEnabled == true && activeAdCampaigns.isNotEmpty;
  
  // ✅ نیا: کیا AdMob setup ہے؟
  bool get hasAdMobSetup => adMobAppId != null && adMobAppId!.isNotEmpty;
  
  // ✅ نیا: اشتہار کے لیے باقی بجٹ
  double get remainingAdBudget {
    if (adBudget == null) return 0.0;
    return adBudget! - totalAdSpent;
  }

  // ============= 🏗️ CONSTRUCTOR =============
  
  Project({
    required this.id,
    required this.name,
    required this.framework,
    required this.platforms,
    required this.assets,
    this.features = const {},  // ✅ اب Map<String, dynamic>
    
    // ✅ نیا: اشتہار سے متعلق پیرامیٹرز
    this.adCampaigns,
    this.adBudget = 0.0,
    this.adEnabled = false,
    this.lastAdCampaignDate,
    
    // ✅ نیا: AdMob پیرامیٹرز
    this.adMobAppId,
    this.adMobAdUnitIds,
    
    this.generatedCode,
    this.apkLink,
    this.githubRepoUrl,  // ✅ یہ استعمال کریں
    this.geminiPrompt,
    this.status = 'draft',
    required this.createdAt,
    this.lastUpdated,
    
    // ✅ نیا: Resume state پیرامیٹرز
    this.draftMessages,
    this.draftGeneratedCode,
    this.wasGenerating,
    this.lastSessionTime,
    this.pendingFileUpdates,
  });

  // ============= 💾 TO MAP =============
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'framework': framework,
      'platforms': platforms,
      'assets': assets,
      'features': features,  // ✅ اب Map<String, dynamic>
      
      // ✅ نیا: اشتہار ڈیٹا
      'adCampaigns': adCampaigns?.map((campaign) => campaign.toJson()).toList(),
      'adBudget': adBudget,
      'adEnabled': adEnabled,
      'lastAdCampaignDate': lastAdCampaignDate?.toIso8601String(),
      
      // ✅ نیا: AdMob ڈیٹا
      'adMobAppId': adMobAppId,
      'adMobAdUnitIds': adMobAdUnitIds,
      
      'generatedCode': generatedCode,
      'apkLink': apkLink,
      'githubRepoUrl': githubRepoUrl,  // ✅ یہ استعمال کریں
      'geminiPrompt': geminiPrompt,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      
      // ✅ نیا: Resume state save کریں
      'draftMessages': draftMessages,
      'draftGeneratedCode': draftGeneratedCode,
      'wasGenerating': wasGenerating,
      'lastSessionTime': lastSessionTime?.toIso8601String(),
      'pendingFileUpdates': pendingFileUpdates,
    };
  }

  // ============= 📖 FROM MAP =============
  
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      framework: map['framework'],
      platforms: List<String>.from(map['platforms']),
      assets: Map<String, dynamic>.from(map['assets']),
      
      // ✅ **یہاں تبدیلی: Map<String, dynamic>.from**
      features: Map<String, dynamic>.from(map['features'] ?? {}),
      
      // ✅ نیا: اشتہار ڈیٹا لوڈ کریں
      adCampaigns: map['adCampaigns'] != null
          ? (map['adCampaigns'] as List)
              .map((item) => AdCampaign.fromJson(item))
              .toList()
          : null,
      adBudget: (map['adBudget'] ?? 0.0).toDouble(),
      adEnabled: map['adEnabled'] ?? false,
      lastAdCampaignDate: map['lastAdCampaignDate'] != null
          ? DateTime.parse(map['lastAdCampaignDate'])
          : null,
      
      // ✅ نیا: AdMob ڈیٹا لوڈ کریں
      adMobAppId: map['adMobAppId'],
      adMobAdUnitIds: map['adMobAdUnitIds'] != null 
          ? Map<String, String>.from(map['adMobAdUnitIds']) 
          : null,
      
      generatedCode: map['generatedCode'],
      apkLink: map['apkLink'],
      githubRepoUrl: map['githubRepoUrl'],  // ✅ یہ استعمال کریں
      geminiPrompt: map['geminiPrompt'],
      status: map['status'] ?? 'draft',
      createdAt: DateTime.parse(map['createdAt']),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : null,
      
      // ✅ نیا: Resume state لوڈ کریں
      draftMessages: map['draftMessages'] != null 
          ? List<Map<String, dynamic>>.from(map['draftMessages']) 
          : null,
      draftGeneratedCode: map['draftGeneratedCode'],
      wasGenerating: map['wasGenerating'],
      lastSessionTime: map['lastSessionTime'] != null
          ? DateTime.parse(map['lastSessionTime'])
          : null,
      pendingFileUpdates: map['pendingFileUpdates'] != null
          ? List<Map<String, dynamic>>.from(map['pendingFileUpdates'])
          : null,
    );
  }

  // ============= 🔄 RESUME METHODS =============
  
  /// ✅ نیا: Session save کریں
  void saveSession({
    required List<Map<String, dynamic>> messages,
    String? generatedCode,
    bool? isGenerating,
    List<Map<String, dynamic>>? pendingFiles,
  }) {
    draftMessages = messages;
    draftGeneratedCode = generatedCode;
    wasGenerating = isGenerating;
    lastSessionTime = DateTime.now();
    pendingFileUpdates = pendingFiles;
  }
  
  /// ✅ نیا: Session clear کریں
  void clearSession() {
    draftMessages = null;
    draftGeneratedCode = null;
    wasGenerating = null;
    lastSessionTime = null;
    pendingFileUpdates = null;
  }

  // ============= 🎯 AD CAMPAIGN METHODS =============
  
  /// ✅ نیا: اشتہار مہمیں شامل کرنے کا طریقہ
  void addAdCampaign(AdCampaign campaign) {
    adCampaigns ??= [];
    adCampaigns!.add(campaign);
    lastAdCampaignDate = DateTime.now();
    adEnabled = true;
    
    if (adBudget != null) {
      adBudget = adBudget! + campaign.dailyBudget;
    } else {
      adBudget = campaign.dailyBudget;
    }
  }

  /// ✅ نیا: فعال اشتہار مہمیں حاصل کرنے کا طریقہ
  List<AdCampaign> get activeAdCampaigns {
    if (adCampaigns == null) return [];
    return adCampaigns!.where((campaign) =>
      campaign.status == AdCampaignStatus.active
    ).toList();
  }

  /// ✅ نیا: کل اشتہار اخراجات
  double get totalAdSpent {
    if (adCampaigns == null) return 0.0;
    double total = 0.0;
    for (var campaign in adCampaigns!) {
      total += campaign.totalSpent;
    }
    return total;
  }

  /// ✅ نیا: اشتہار کارکردگی حاصل کریں
  Map<String, dynamic> get adPerformance {
    if (adCampaigns == null || adCampaigns!.isEmpty) {
      return {
        'totalCampaigns': 0,
        'activeCampaigns': 0,
        'totalBudget': 0.0,
        'totalSpent': 0.0,
        'averageCTR': 0.0,
      };
    }
    
    double totalCTR = 0.0;
    int campaignsWithCTR = 0;
    
    for (var campaign in adCampaigns!) {
      final ctr = campaign.clickThroughRate;
      if (ctr > 0) {
        totalCTR += ctr;
        campaignsWithCTR++;
      }
    }
    
    return {
      'totalCampaigns': adCampaigns!.length,
      'activeCampaigns': activeAdCampaigns.length,
      'totalBudget': adBudget ?? 0.0,
      'totalSpent': totalAdSpent,
      'averageCTR': campaignsWithCTR > 0 ? totalCTR / campaignsWithCTR : 0.0,
    };
  }

  // ============= 🎯 ADMOB METHODS =============
  
  /// ✅ نیا: AdMob IDs سیٹ کرنے کا طریقہ
  void setAdMobIds(String appId, Map<String, String> adUnitIds) {
    adMobAppId = appId;
    adMobAdUnitIds = adUnitIds;
    lastUpdated = DateTime.now();
  }

  /// ✅ نیا: AdMob IDs حاصل کرنے کا طریقہ
  Map<String, dynamic> get adMobInfo {
    return {
      'appId': adMobAppId,
      'adUnitIds': adMobAdUnitIds,
      'hasSetup': hasAdMobSetup,
    };
  }

  // ============= 🎯 FEATURE METHODS =============
  
  /// ✅ نیا: features میں value ڈالنے کا طریقہ
  void setFeature(String key, dynamic value) {
    features[key] = value;
    lastUpdated = DateTime.now();
  }
  
  /// ✅ نیا: features سے value حاصل کرنے کا طریقہ
  dynamic getFeature(String key, {dynamic defaultValue}) {
    return features[key] ?? defaultValue;
  }
  
  /// ✅ نیا: چیک کریں کہ feature موجود ہے یا نہیں
  bool hasFeature(String key) {
    return features.containsKey(key);
  }

  // ============= 🛠️ UTILITY METHODS =============
  
  /// 🔥 **GitHub repo URL سیٹ کرنے کا طریقہ**
  void setGitHubRepoUrl(String url) {
    if (url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true) {
      githubRepoUrl = url;
      lastUpdated = DateTime.now();
    }
  }
  
  /// 🔥 **copyWith method**
  Project copyWith({
    String? id,
    String? name,
    String? framework,
    List<String>? platforms,
    Map<String, dynamic>? assets,
    Map<String, dynamic>? features,  // ✅ اب Map<String, dynamic>
    List<AdCampaign>? adCampaigns,
    double? adBudget,
    bool? adEnabled,
    DateTime? lastAdCampaignDate,
    String? adMobAppId,
    Map<String, String>? adMobAdUnitIds,
    String? generatedCode,
    String? apkLink,
    String? githubRepoUrl,
    String? geminiPrompt,
    String? status,
    DateTime? createdAt,
    DateTime? lastUpdated,
    
    // ✅ نیا: Resume state parameters
    List<Map<String, dynamic>>? draftMessages,
    String? draftGeneratedCode,
    bool? wasGenerating,
    DateTime? lastSessionTime,
    List<Map<String, dynamic>>? pendingFileUpdates,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      framework: framework ?? this.framework,
      platforms: platforms ?? this.platforms,
      assets: assets ?? this.assets,
      features: features ?? this.features,  // ✅ اب Map<String, dynamic>
      adCampaigns: adCampaigns ?? this.adCampaigns,
      adBudget: adBudget ?? this.adBudget,
      adEnabled: adEnabled ?? this.adEnabled,
      lastAdCampaignDate: lastAdCampaignDate ?? this.lastAdCampaignDate,
      adMobAppId: adMobAppId ?? this.adMobAppId,
      adMobAdUnitIds: adMobAdUnitIds ?? this.adMobAdUnitIds,
      generatedCode: generatedCode ?? this.generatedCode,
      apkLink: apkLink ?? this.apkLink,
      githubRepoUrl: githubRepoUrl ?? this.githubRepoUrl,
      geminiPrompt: geminiPrompt ?? this.geminiPrompt,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? DateTime.now(),
      
      // ✅ نیا: Resume state copy
      draftMessages: draftMessages ?? this.draftMessages,
      draftGeneratedCode: draftGeneratedCode ?? this.draftGeneratedCode,
      wasGenerating: wasGenerating ?? this.wasGenerating,
      lastSessionTime: lastSessionTime ?? this.lastSessionTime,
      pendingFileUpdates: pendingFileUpdates ?? this.pendingFileUpdates,
    );
  }
}
