import 'dart:io';

Future<void> checkUrl(String urlString) async {
  final url = Uri.parse(urlString);
  try {
    final request = await HttpClient().headUrl(url);
    final response = await request.close();
    print('URL: $urlString -> Status: ${response.statusCode}');
  } catch (e) {
    print('URL: $urlString -> Error: $e');
  }
}

void main() async {
  await checkUrl('https://audio.quran.com/Alafasy/mp3/001001.mp3');
  await checkUrl('https://verses.quran.com/Alafasy/mp3/001001.mp3');
}
