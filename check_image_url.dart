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
  await checkUrl('https://android.quran.com/data/width_1024/page001.png');
  await checkUrl('https://quran.com/images/page/604.png');
}
