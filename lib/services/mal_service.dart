import 'package:http/http.dart' as http;

class MALService {
  final String clientId = 'YOUR_CLIENT_ID';
  final String clientSecret = 'YOUR_CLIENT_SECRET';

  Future<http.Response> fetchAnimeList() async {
       final url = Uri.parse('https://api.myanimelist.net/v2/anime/ranking?ranking_type=all&limit=70');
    final response = await http.get(
      url,
      headers: {
        'X-MAL-CLIENT-ID': "910961e10229e0b2f7e627e945f4f012",
        'Content-Type': 'application/json',
      },
    );

   
    if (response.statusCode == 200) {
  
      return response;
    } else {
      throw Exception('Failed to load anime list');
    }
  }
} 