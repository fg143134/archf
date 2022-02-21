import 'package:archf/model/LoginM.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginService {
  Future<LoginResponse> login(LoginM loginM) async {
    Uri url = Uri.parse("http://pc.eidc.gov.ly:8080/api/authenticate");
    Map<String, dynamic> Lgn = loginM.toJson();
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: json.encode(Lgn));
    if (response.statusCode == 200 ||
        response.statusCode == 400 ||
        response.statusCode == 401) {
      final S = json.decode(response.body);
      final M = LoginResponse.fromJson(S);
      return M;
    } else {
      throw Exception('failed to load data');
    }
  }
}
