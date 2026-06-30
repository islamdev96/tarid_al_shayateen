import 'dart:io';

void main() async {
  final url = Uri.parse('https://corsproxy.io/?https://android.quran.com/data/width_1024/page001.png');
  try {
    final request = await HttpClient().getUrl(url);
    final response = await request.close();
    print('Status code: ${response.statusCode}');
    print('Content length: ${response.contentLength}');
  } catch (e) {
    print('Error: $e');
  }
}
