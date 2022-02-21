// To parse this JSON data, do
//
//     final loginM = loginMFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

LoginM loginMFromJson(String str) => LoginM.fromJson(json.decode(str));

String loginMToJson(LoginM data) => json.encode(data.toJson());

class LoginResponse {
  final String? token;
  final String? error;

  LoginResponse({this.token, this.error});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json["id_token"] != null ? json["id_token"] : "",
      error: json["message"] ?? "",
    );
  }
}

class LoginM {
  LoginM({
    this.username,
    this.password,
    this.rememberMe = false,
  });

  String? username;
  String? password;
  bool rememberMe;

  factory LoginM.fromJson(Map<String, dynamic> json) => LoginM(
        username: json["username"],
        password: json["password"],
        rememberMe: json["rememberMe"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "password": password,
        "rememberMe": rememberMe,
      };
}
