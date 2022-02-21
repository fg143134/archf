// To parse this JSON data, do
//
//     final DecreeArchive = DecreeArchiveFromJson(jsonString);

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'dart:convert';

List<DecreeArchive> DecreeArchiveFromJson(Uint8List str) =>
    List<DecreeArchive>.from(
        json.decode(utf8.decode(str)).map((x) => DecreeArchive.fromJson(x)));

String DecreeArchiveToJson(List<DecreeArchive> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DecreeArchive {
  DecreeArchive({
    required this.id,
    this.documentNo,
    required this.decreeNo,
    required this.title,
    this.details,
    required this.keywords,
    required this.pages,
    required this.decreeDate,
    required this.year,
    this.notes,
    this.pdfFile,
    required this.pdfFileContentType,
    required this.pdfFileUrl,
    this.wordFile,
    this.wordFileContentType,
    this.wordFileUrl,
    required this.decreeStatus,
    this.decreeType,
    this.decreeCategory,
    required this.minister,
    required this.government,
  });

  int id;
  dynamic documentNo;
  String decreeNo;
  String title;
  dynamic details;
  String keywords;
  int pages;
  DateTime decreeDate;
  int year;
  dynamic notes;
  dynamic pdfFile;
  String pdfFileContentType;
  String pdfFileUrl;
  dynamic wordFile;
  dynamic wordFileContentType;
  dynamic wordFileUrl;
  String decreeStatus;
  dynamic decreeType;
  dynamic decreeCategory;
  Government minister;
  Government government;

  factory DecreeArchive.fromJson(Map<String, dynamic> json) => DecreeArchive(
        id: json["id"],
        documentNo: json["documentNo"],
        decreeNo: json["decreeNo"] ?? "",
        title: json["title"] ?? "",
        details: json["details"],
        keywords: json["keywords"] ?? "",
        pages: json["pages"] ?? 0,
        decreeDate: DateTime.parse(json["decreeDate"] ?? "2021-01-06"),
        year: json["year"] ?? 2000,
        notes: json["notes"],
        pdfFile: json["pdfFile"],
        pdfFileContentType: json["pdfFileContentType"] ?? "",
        pdfFileUrl: json["pdfFileUrl"] ?? "",
        wordFile: json["wordFile"],
        wordFileContentType: json["wordFileContentType"],
        wordFileUrl: json["wordFileUrl"],
        decreeStatus: json["decreeStatus"] ?? "",
        decreeType: json["decreeType"],
        decreeCategory: json["decreeCategory"],
        minister: Government.fromJson(json["minister"]),
        government: Government.fromJson(json["government"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "documentNo": documentNo,
        "decreeNo": decreeNo,
        "title": title,
        "details": details,
        "keywords": keywords,
        "pages": pages,
        "decreeDate":
            "${decreeDate.year.toString().padLeft(4, '0')}-${decreeDate.month.toString().padLeft(2, '0')}-${decreeDate.day.toString().padLeft(2, '0')}",
        "year": year,
        "notes": notes,
        "pdfFile": pdfFile,
        "pdfFileContentType":
            pdfFileContentType == "" ? "" : pdfFileContentType,
        "pdfFileUrl": pdfFileUrl,
        "wordFile": wordFile,
        "wordFileContentType": wordFileContentType,
        "wordFileUrl": wordFileUrl,
        "decreeStatus": decreeStatus,
        "decreeType": decreeType,
        "decreeCategory": decreeCategory,
        "minister": minister.toJson(),
        "government": government.toJson(),
      };
}

class Government {
  Government({
    required this.id,
    required this.name,
    this.serialNo,
    this.jobTitle,
  });

  int id;
  String name;
  dynamic serialNo;
  dynamic jobTitle;

  factory Government.fromJson(Map<String, dynamic> json) => Government(
        id: json["id"],
        name: json["name"],
        serialNo: json["serialNo"],
        jobTitle: json["jobTitle"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "serialNo": serialNo,
        "jobTitle": jobTitle,
      };
}
