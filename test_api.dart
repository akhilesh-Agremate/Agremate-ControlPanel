import 'dart:convert';
import 'dart:io';

void main() async {
  var request = await HttpClient().getUrl(Uri.parse('http://localhost:3000/api/v1/Property/all'));
  var response = await request.close();
  var responseBody = await response.transform(utf8.decoder).join();
  print(responseBody);
}
