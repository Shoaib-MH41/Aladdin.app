import '../models/api_template_model.dart';

class ApiService {
  final List<ApiTemplate> _apiTemplates = [
    ApiTemplate(
      id: '1',
      name: 'موسم کی معلومات',
      provider: 'WeatherAPI.com',
      url: 'https://www.weatherapi.com/',
      description: 'حالیہ موسم کی معلومات حاصل کریں',
      keyRequired: true,
      freeTierInfo: 'روزانہ 1,000,000 requests تک مفت',
      category: 'Weather',
    ),
    ApiTemplate(
      id: '2',
      name: 'نیوز ڈیٹا',
      provider: 'NewsAPI.org',
      url: 'https://newsapi.org/',
      description: 'تازہ ترین خبریں حاصل کریں',
      keyRequired: true,
      freeTierInfo: 'روزانہ 100 requests تک مفت',
      category: 'News',
    ),
    ApiTemplate(
      id: '3',
      name: 'کرپٹو قیمتیں',
      provider: 'CoinGecko',
      url: 'https://www.coingecko.com/en/api',
      description: 'کرپٹو کرنسیوں کی قیمتیں',
      keyRequired: false,
      freeTierInfo: 'مکمل مفت - کوئی key درکار نہیں',
      category: 'Crypto',
    ),
    ApiTemplate(
      id: '4',
      name: 'لوکیشن ڈیٹا',
      provider: 'OpenCage Geocoding',
      url: 'https://opencagedata.com/',
      description: 'لوکیشن اور جیوکوڈنگ ڈیٹا',
      keyRequired: true,
      freeTierInfo: 'روزانہ 2,500 requests تک مفت',
      category: 'Location',
    ),
  ];

  List<ApiTemplate> getApiTemplates() => _apiTemplates;

  List<ApiTemplate> getApiTemplatesByCategory(String category) {
    return _apiTemplates.where((api) => api.category == category).toList();
  }

  ApiTemplate? getApiTemplateById(String id) {
    try {
      return _apiTemplates.firstWhere((api) => api.id == id);
    } catch (e) {
      return null;
    }
  }
}
