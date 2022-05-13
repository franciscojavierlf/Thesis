import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

abstract class RestConnection {
  static String _url = '';
  
  static final _db = FirebaseFirestore.instance;

  /// Loads the connection info from the database because
  /// it can change.
  static init() async {
    final snapshot = await _db.collection('environment').doc('rest').get();
    final data = snapshot.data()!;
    _url = data['url'];
  }

  static get(String path) async {
    print('$_url$path');
    try {
    final res = await http.get(Uri.parse('$_url$path'));
    if (res.statusCode == 200)
      return jsonDecode(res.body);
    else
      throw Exception('Failed to get path ' + path);
    }
    catch(ex) {
      print(ex);
    }
  }

  static post(String path, Map<String, dynamic> data) async {
    final res = await http.post(Uri.parse('$_url$path'), body: data);
    if (res.statusCode == 200)
      return res.body;
    else
      throw Exception('Failed to get path ' + path);
  }
}
