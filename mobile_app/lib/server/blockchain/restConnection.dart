import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class RestConnection {
  static final _host = 'http://localhost';
  static final _port = 4567;

  static get(String path) async {
    final res = await http.get(Uri.parse('$_host:$_port$path'));
    if (res.statusCode == 200)
      return jsonDecode(res.body);
    else
      throw Exception('Failed to get path ' + path);
  }

  static post(String path, Map<String, dynamic> data) async {
    final res = await http.post(Uri.parse('$_host:$_port$path'), body: data);
    if (res.statusCode == 200)
      return res.body;
    else
      throw Exception('Failed to get path ' + path);
  }
}
