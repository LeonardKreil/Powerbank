import 'package:http/http.dart' as http;
import 'dart:convert';

Future<dynamic> sendGetRequest() async {
  final response = await http.get(Uri.parse(
      'https://5uf7jiapgb.execute-api.eu-central-1.amazonaws.com/dev'));
  return json.decode(response.body);
}
