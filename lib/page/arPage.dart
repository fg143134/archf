import 'dart:convert';
import 'dart:io';

import 'package:archf/model/DecreeArchive.dart';
import 'package:archf/page/PdfP.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final storage = const FlutterSecureStorage();
  int? sortColumnIndex;
  bool isAscending = false;
  int CurrentPage = 0;
  List<DecreeArchive> arch = [];
  List<DecreeArchive> archFiltered = [];
  TextEditingController controller = TextEditingController();
  String _searchResult = '';
  String searchResult = '';
  bool downloading = false;
  var progress = "";
  var path = "No Data";
  var platformVersion = "Unknown";
  var _onPressed;
  late Directory externalDir;
  var pdf;
  List<Widget> itemsData = [];
  int totalPages = 1;
  final RefreshController refreshController =
      RefreshController(initialRefresh: true);

  Future<bool> GetDataArch({bool isrefresh = false}) async {
    if (isrefresh) {
      CurrentPage = 0;
    } else {
      if (CurrentPage >= totalPages) {
        refreshController.loadNoData();
        return false;
      }
    }
    final Uri uri;
    if (searchResult == "") {
      uri = Uri.parse(
          "http://pc.eidc.gov.ly:8080/api/decrees?page=$CurrentPage&size=20&sort=id,asc");
    } else {
      totalPages = 1;
      uri = Uri.parse(
          "http://pc.eidc.gov.ly:8080/api/decrees?decreeNo.contains=$searchResult&title.contains=$searchResult&decreeDate.contains=$searchResult&notes.contains=$searchResult&keywords.contains=$searchResult&page=$CurrentPage&size=20&sort=id,asc");
    }

    final tokenJwt = await storage.read(key: 'jwt');

    final response = await http.get(uri, headers: {
      //'Content-Type': 'application/json',
      //'Accept': 'application/json',
      'Authorization': 'Bearer $tokenJwt',
    });
    if (response.statusCode == 200) {
      final result = DecreeArchiveFromJson(response.bodyBytes);
      if (isrefresh) {
        arch = result;
      } else {
        arch = result;
      }

      CurrentPage++;
      var s = response.headers.values.toList().asMap();
      if (totalPages > 10) {
      } else {
        int Nu = int.parse(s[12] ?? "20");
        totalPages = (Nu / 20).ceil();
      }
      getPostsData();

      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  void getPostsData() {
    List<DecreeArchive> responseList = arch;
    List<Widget> listItems = [];
    responseList.forEach((post) {
      listItems.add(GestureDetector(
          onTap: () {
            print("${post.id}");
          },
          child: Container(
              height: 150,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(100), blurRadius: 10.0),
                  ]),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            post.title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 188, 139, 70),
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            post.decreeNo,
                            style: const TextStyle(
                                fontSize: 17, color: Colors.blueGrey),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            post.minister.name,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))));
    });
    setState(() {
      itemsData = listItems;
    });
  }

  @override
  void initState() {
    super.initState();

    getPostsData();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double categoryHeight = size.height * 0.30;
    return SafeArea(
      child: SmartRefresher(
        controller: refreshController,
        enablePullUp: true,
        onRefresh: () async {
          final resualt = await GetDataArch(isrefresh: true);
          if (resualt) {
            refreshController.refreshCompleted();
          } else {
            refreshController.refreshFailed();
          }
        },
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color.fromARGB(255, 253, 253, 253),
            leading: Icon(
              Icons.menu,
              color: Colors.black,
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search,
                    color: Color.fromARGB(255, 188, 139, 70)),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.person,
                    color: Color.fromARGB(255, 188, 139, 70)),
                onPressed: () {},
              )
            ],
          ),
          body: Container(
            height: size.height,
            child: Expanded(
              child: ListView.builder(
                  itemCount: itemsData.length,
                  itemBuilder: (context, index) {
                    return Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Align(
                            alignment: Alignment.topCenter,
                            child: itemsData[index]));
                  }),
            ),
          ),
        ),
      ),
    );
  }

  String convertCurrentDateTimeToString() {
    String formattedDateTime =
        DateFormat('yyyyMMdd_kkmmss').format(DateTime.now()).toString();
    return formattedDateTime;
  }

  void OpenPdf(String pdfUrl) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfP(
            pDfF: pdfUrl,
          ),
        ));
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
            onReceiveProgress: (receivedBytes, totalBytes) {
          print('here 1');
          setState(() {
            downloading = true;
            progress =
                ((receivedBytes / totalBytes) * 100).toStringAsFixed(0) + "%";
            print(progress);
          });
          print('here 2');
        });
      } catch (e) {
        print('catch catch catch');
        print(e);
      }

      setState(() {
        downloading = false;
        progress = "Download Completed.";
        path = dirloc + convertCurrentDateTimeToString() + ".pdf";
      });
      print(path);
      print('here give alert-->completed');
    } else {
      setState(() {
        progress = "Permission Denied!";
      });
    }
  }
}
