// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:archf/model/DecreeArchive.dart';
import 'package:archf/page/Details.dart';
import 'package:archf/page/TryOut.dart';
import 'package:archf/page/arPage.dart';
import 'package:archf/page/archivePage.dart';
import 'package:archf/page/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ارشيف قرارات وزارة الاقتصاد',
      theme: ThemeData(
        //fontFamily: 'Poppins',
        primaryColor: Color.fromARGB(248, 248, 243, 240),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 0,
          foregroundColor: Color.fromARGB(248, 248, 243, 240),
        ),

        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 22.0, color: Colors.redAccent),
          headline2: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
            color: Colors.lightBlue,
          ),
          bodyText1: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: Colors.blueAccent,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home:  SearchPage(),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new SearchPage(),
        '/login': (BuildContext context) => new loginPage(),

      },
    );
  }
}
