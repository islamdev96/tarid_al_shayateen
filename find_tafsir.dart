import 'dart:convert';
import 'dart:io';

void main() async {
  final url = Uri.parse('https://api.quran.com/api/v4/resources/tafsirs?language=ar');
  final request = await HttpClient().getUrl(url);
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  final data = json.decode(responseBody);
  
  final tafsirs = data['tafsirs'] as List;
  for (var t in tafsirs) {
    if (t['language_name'] == 'arabic') {
      print('ID: ${t['id']} - Name: ${t['name']} - Author: ${t['author_name']}');
    }
  }
}
