import 'dart:io';

Future<void> checkProxy(String name, String urlString) async {
  final url = Uri.parse(urlString);
  try {
    final request = await HttpClient().getUrl(url);
    final response = await request.close();
    print('$name: Status code: ${response.statusCode}, Content-Length: ${response.contentLength}');
  } catch (e) {
    print('$name error: $e');
  }
}

void main() async {
  final target = 'https://android.quran.com/data/width_1024/page001.png';
  final encodedTarget = Uri.encodeComponent(target);
  await checkProxy('allorigins', 'https://api.allorigins.win/raw?url=$encodedTarget');
  await checkProxy('codetabs', 'https://api.codetabs.com/v1/proxy?quest=$encodedTarget');
}
