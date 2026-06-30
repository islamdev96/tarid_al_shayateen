import 'dart:convert';
import 'dart:io';

void main() async {
  final url = Uri.parse('https://pub.dev/api/search?q=page+turn');
  try {
    final request = await HttpClient().getUrl(url);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    final data = json.decode(responseBody);
    final packages = data['packages'] as List;
    for (var p in packages.take(5)) {
      print(p['package']);
    }
  } catch(e) {
    print(e);
  }
}
