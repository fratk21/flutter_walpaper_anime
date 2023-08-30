import 'dart:convert';
import 'package:http/http.dart' as http;

class api1 {
  static Future<List<String>> fetchImages(String selectedCategory) async {
    final response = await http.post(
      Uri.parse('https://api.waifu.pics/many/sfw/$selectedCategory'),
      body: {
        'type': 'sfw',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final files = List<String>.from(data['files']);
      return files;
    } else {
      throw Exception('Failed to load images');
    }
  }

  static Future<List<int>> fetchImageBytes(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final imageBytes = response.bodyBytes;
    return imageBytes;
  }
}

class api2 {
  static Future<Map<String, dynamic>> fetchWaifus() async {
    const apiUrl = 'https://api.waifu.im/search';

    final response = await http.get(Uri.parse(apiUrl));
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception(
          'Request failed with status code: ${response.statusCode}');
    }
  }

  static Future<List<int>> fetchImageBytes(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final imageBytes = response.bodyBytes;
    return imageBytes;
  }
}
