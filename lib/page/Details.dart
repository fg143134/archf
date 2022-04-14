import 'dart:io';

import 'package:archf/model/DecreeArchive.dart';
import 'package:archf/page/PdfP.dart';
import 'package:flutter/material.dart';
import 'package:archf/widgets/tabbar_widget.dart';
import 'package:archf/widgets/scrollable_widget.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class DetailPage extends StatelessWidget {
  final DecreeArchive PostPdf;

  const DetailPage({Key? key, required this.PostPdf}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void OpenPdf(String pdfUrl) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfP(
              pDfF: pdfUrl,
            ),
          ));
    }

    String convertCurrentDateTimeToString() {
      String formattedDateTime =
          DateFormat('yyyyMMdd_kkmmss').format(DateTime.now()).toString();
      return formattedDateTime;
    }

    Future<void> downloadFile(String pdfUrl) async {
      Dio dio = Dio();

      final status = await Permission.storage.request();
      if (status.isGranted) {
        String dirloc = "";
        if (Platform.isAndroid) {
          dirloc = "/storage/emulated/0/Download/";
        } else {
          dirloc = (await getApplicationDocumentsDirectory()).path;
        }

        try {
          //FileUtils.mkdir([dirloc]);
          await dio.download(
              pdfUrl, dirloc + convertCurrentDateTimeToString() + ".pdf",
              onReceiveProgress: (receivedBytes, totalBytes) {});
        } catch (e) {
          print('catch catch catch');
          print(e);
        }
        print(dirloc + convertCurrentDateTimeToString() + ".pdf");
      } else {}
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
                padding: EdgeInsets.all(40.0),
                width: MediaQuery.of(context).size.width,
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 188, 139, 70)),
                child: Center(),
              ),
              Positioned(
                left: 8.0,
                top: 60.0,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back,
                      color: Color.fromARGB(255, 255, 241, 234)),
                ),
              )
            ],
          ),
          Directionality(
            textDirection: ui.TextDirection.rtl,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(100), blurRadius: 10.0),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              PostPdf.title,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              PostPdf.decreeNo,
                              style: const TextStyle(
                                  fontSize: 17,
                                  color: Color.fromRGBO(58, 66, 86, 1.0)),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              PostPdf.minister.name,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              PostPdf.decreeStatus,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              PostPdf.pdfFileContentType,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),

                            Text(
                              DateFormat('yyyy-MM-dd')
                                  .format(PostPdf.decreeDate)
                                  .toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              PostPdf.government.name,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              PostPdf.keywords,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              PostPdf.details != null ? PostPdf.details.toString() :"",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),

                            Text(
                              PostPdf.notes != null ? PostPdf.notes.toString() :"",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () => {
                downloadFile(
                    'http://pc.eidc.gov.ly:8080/api/public/file/download/${PostPdf.pdfFileUrl}'),
                OpenPdf(
                    'http://pc.eidc.gov.ly:8080/api/public/file/download/${PostPdf.pdfFileUrl}')
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromRGBO(58, 66, 86, 1.0),
              ),
              child: Text("فتح الملف", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
