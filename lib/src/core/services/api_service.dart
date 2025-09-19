import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<Map<String, dynamic>> generateApiConfig(String apiInput) async {
    // سادہ پارسر (Gemini کی طرح AI لوجیک کا مشاہدہ)
    Map<String, dynamic> config = {};
    if (apiInput.contains('https://')) {
      config['url'] = apiInput.split(' ')[0].trim(); // URL نکالو
      config['method'] = apiInput.contains('POST') ? 'POST' : 'GET'; // میتھڈ کا اندازہ
      config['key'] = apiInput.contains('key=') ? apiInput.split('key=')[1].split(' ')[0] : null; // کی نکالو
    } else {
      throw Exception('Invalid API input');
    }
    return config;
  }

  static Future<Map<String, dynamic>> fetchData(Map<String, dynamic> apiConfig) async {
    final url = apiConfig['url'] as String?;
    if (url == null) throw Exception('URL is required');
    final method = (apiConfig['method'] as String?)?.toUpperCase() ?? 'GET';
    final apiKey = apiConfig['key'] as String?;

    try {
      http.Response response;
      if (method == 'GET') {
        var requestUrl = Uri.parse(url);
        if (apiKey != null && apiKey.isNotEmpty) {
          requestUrl = Uri.parse('$url?key=$apiKey');
        }
        response = await http.get(requestUrl);
      } else if (method == 'POST') {
        response = await http.post(
          Uri.parse(url),
          headers: apiKey != null ? {'Authorization': 'Bearer $apiKey'} : {},
          body: apiKey != null ? jsonEncode({'key': apiKey}) : jsonEncode({}),
        );
      } else {
        throw Exception('Method $method not supported yet');
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          throw Exception('Invalid JSON response');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
