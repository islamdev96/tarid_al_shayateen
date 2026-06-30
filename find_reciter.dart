import 'dart:convert';
import 'dart:io';

void main() async {
  final url = Uri.parse('https://api.quran.com/api/v4/resources/recitations?language=ar');
  final request = await HttpClient().getUrl(url);
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  final data = json.decode(responseBody);
  
  final recitations = data['recitations'] as List;
  for (var r in recitations) {
    if (r['reciter_name'].toString().contains('Husary') || r['reciter_name'].toString().contains('حصري') || r['translated_name']['name'].toString().contains('Husary') || r['translated_name']['name'].toString().contains('حصري')) {
      print('ID: ${r['id']} - Name: ${r['reciter_name']} - Style: ${r['style']}');
    }
  }
}
