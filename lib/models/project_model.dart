import 'ad_model.dart'; // ✅ یہ ایمپورٹ شامل کریں
class Project {
  final String id;
  String name;
  String framework;
  List<String> platforms;
  Map<String, dynamic> assets;
  Map<String, String> features;
  
  // ✅ نیا: اشتہار مہموں کی فہرست
  List<AdCampaign>? adCampaigns;
  
  // ✅ نیا: اشتہار بجٹ کی معلومات
  double? adBudget;
  bool? adEnabled;
  DateTime? lastAdCampaignDate;
  
  String? generatedCode;
  String? apkLink;
  String? githubRepoUrl;
  String? geminiPrompt;
  String? status;
  DateTime createdAt;
  DateTime? lastUpdated;

  Project({
    required this.id,
    required this.name,
    required this.framework,
    required this.platforms,
    required this.assets,
    this.features = const {},
    
    // ✅ نیا: اشتہار سے متعلق پیرامیٹرز
    this.adCampaigns,
    this.adBudget = 0.0,
    this.adEnabled = false,
    this.lastAdCampaignDate,
    
    this.generatedCode,
    this.apkLink,
    this.githubRepoUrl,
    this.geminiPrompt,
    this.status = 'draft',
    required this.createdAt,
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'framework': framework,
      'platforms': platforms,
      'assets': assets,
      'features': features,
      
      // ✅ نیا: اشتہار ڈیٹا
      'adCampaigns': adCampaigns?.map((campaign) => campaign.toJson()).toList(),
      'adBudget': adBudget,
      'adEnabled': adEnabled,
      'lastAdCampaignDate': lastAdCampaignDate?.toIso8601String(),
      
      'generatedCode': generatedCode,
      'apkLink': apkLink,
      'githubRepoUrl': githubRepoUrl,
      'geminiPrompt': geminiPrompt,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      framework: map['framework'],
      platforms: List<String>.from(map['platforms']),
      assets: Map<String, dynamic>.from(map['assets']),
      features: Map<String, String>.from(map['features'] ?? {}),
      
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
      
      generatedCode: map['generatedCode'],
      apkLink: map['apkLink'],
      githubRepoUrl: map['githubRepoUrl'],
      geminiPrompt: map['geminiPrompt'],
      status: map['status'] ?? 'draft',
      createdAt: DateTime.parse(map['createdAt']),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : null,
    );
  }

  // ✅ نیا: اشتہار مہمیں شامل کرنے کا طریقہ
  void addAdCampaign(AdCampaign campaign) {
    adCampaigns ??= []; // اگر null ہے تو خالی لسٹ بنائیں
    adCampaigns!.add(campaign);
    lastAdCampaignDate = DateTime.now();
    adEnabled = true;
    
    // بجٹ اپ ڈیٹ کریں
    if (adBudget != null) {
      adBudget = adBudget! + campaign.dailyBudget;
    } else {
      adBudget = campaign.dailyBudget;
    }
  }

  // ✅ نیا: فعال اشتہار مہمیں حاصل کرنے کا طریقہ
  List<AdCampaign> get activeAdCampaigns {
    if (adCampaigns == null) return [];
    return adCampaigns!.where((campaign) =>
      campaign.status == AdCampaignStatus.active
    ).toList();
  }

  // ✅ نیا: کل اشتہار اخراجات
  double get totalAdSpent {
    if (adCampaigns == null) return 0.0;
    double total = 0.0;
    for (var campaign in adCampaigns!) {
      total += campaign.totalSpent;
    }
    return total;
  }

  // ✅ نیا: اشتہار کارکردگی حاصل کریں
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

  bool get isGenerated => generatedCode != null && generatedCode!.isNotEmpty;
  bool get hasError => status == 'error';
  bool get isOnGitHub => githubRepoUrl != null && githubRepoUrl!.isNotEmpty;
  
  // ✅ نیا: کیا اشتہار فعال ہے؟
  bool get hasActiveAds => adEnabled == true && activeAdCampaigns.isNotEmpty;
  
  // ✅ نیا: اشتہار کے لیے باقی بجٹ
  double get remainingAdBudget {
    if (adBudget == null) return 0.0;
    return adBudget! - totalAdSpent;
  }
}
