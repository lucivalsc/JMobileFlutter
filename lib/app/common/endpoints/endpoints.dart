import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Endpoints {
  String host = '';
  String porta = '';
  // PRD:
  static const apiAddress = "";
  static const environment = "";
  static const socketAddress = "";

  Future<String> basicAuth() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('user') ?? '';
    String password = prefs.getString('password') ?? '';
    host = prefs.getString('host') ?? 'localhost';
    porta = prefs.getString('port') ?? '8082';

    return 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
  }
}
