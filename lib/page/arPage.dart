import 'dart:convert';
import 'dart:io';

import 'package:archf/model/DecreeArchive.dart';
import 'package:archf/page/Details.dart';
import 'package:archf/page/PdfP.dart';
import 'package:flutter/material.dart';
import 'package:archf/widgets/tabbar_widget.dart';
import 'package:archf/widgets/scrollable_widget.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int? sortColumnIndex;
  bool isAscending = false;
  int CurrentPage = 0;
  List<DecreeArchive> arch = [];
  List<DecreeArchive> archFiltered = [];
  TextEditingController controller = TextEditingController();
  String _searchResult = '';
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
  final TextEditingController _controller = TextEditingController();

  Future<bool> GetDataArch(
      {bool isrefresh = false, bool isBack = false}) async {
    if (isrefresh) {
      setState(() {
        CurrentPage = 0;

        _searchResult = "";
      });
    } else {
      if (isBack) {
        setState(() {
          CurrentPage = CurrentPage - 1;

          _searchResult = "";
        });
      } else {
        setState(() {
          CurrentPage++;
        });
      }
    }

    final Uri uri;
    if (_searchResult == "") {
      print(CurrentPage.toString() + 'in');
      uri = Uri.parse(
          "http://pc.eidc.gov.ly:8080/api/decrees?page=$CurrentPage&size=20&sort=id,asc");
    } else {
      totalPages = 1;
      uri = Uri.parse(
          "http://pc.eidc.gov.ly:8080/api/decrees?decreeNo.contains=$_searchResult&title.contains=$_searchResult&decreeDate.contains=$_searchResult&notes.contains=$_searchResult&keywords.contains=$_searchResult&page=$CurrentPage&size=20&sort=id,asc");
    }

    final tokenJwt = (await SharedPreferences.getInstance()).getString("jwt");

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

      var s = response.headers.values.toList().asMap();
      if (totalPages > 10) {
      } else {
        int Nu = int.parse(s[12] ?? "20");
        totalPages = (Nu / 20).ceil();
      }
      print(totalPages);
      if (result != []) {
        getPostsData();
      }

      setState(() {

      });
      return true;
    } else {
      print('notworking');
      Navigator.of(context).pushReplacementNamed('/login');
      return false;
    }
  }

  void getPostsData() {
    List<DecreeArchive> responseList = arch;
    List<Widget> listItems = [];
    responseList.forEach((post) {
      listItems.add(GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(
                    PostPdf: post,
                  ),
                ));
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
        enablePullDown: true,
        onRefresh: () async {
          final resualt = await GetDataArch(isrefresh: true);
          if (resualt) {
            refreshController.refreshCompleted();
          } else {
            refreshController.refreshFailed();
          }
          setState(() {
            _controller.text = "";
          });
        },
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color.fromARGB(255, 253, 253, 253),
            leading: IconButton(
              icon: Icon(
                Icons.logout_rounded,
                color: Color.fromARGB(255, 188, 139, 70),
              ),
              onPressed: () async {
                (await SharedPreferences.getInstance()).remove('jwt');
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.refresh_rounded,
                    color: Color.fromARGB(255, 188, 139, 70)),
                onPressed: () {
                  setState(() {
                    CurrentPage = 0;
                    print(_searchResult);
                      _controller.text = "";
                  });

                  GetDataArch(isrefresh: true);
                },
              ),
            ],
          ),
          body: Container(
              height: size.height,
              margin: EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black38.withAlpha(10),
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Directionality(
                          textDirection: ui.TextDirection.rtl,
                          child: TextField(
                            controller: _controller,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: "بحث",
                              hintStyle: TextStyle(
                                color: Colors.black.withAlpha(120),
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchResult = value;
                                print(_searchResult);
                              });
                            },
                            onSubmitted: (value) {
                              setState(() {
                                CurrentPage = -1;
                                _searchResult = value;
                                print(_searchResult);
                              });

                              GetDataArch();
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search,
                            color: Color.fromARGB(255, 188, 139, 70)),
                        onPressed: () {
                          setState(() {
                            CurrentPage = -1;

                            print(_searchResult);
                          });

                          GetDataArch();
                        },
                      ),
                    ],
                  ),
                  Expanded(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CurrentPage > 0
                          ? IconButton(
                              onPressed: () {},
                              icon: IconButton(
                                icon: const Icon(Icons.arrow_circle_left_sharp),
                                color: Color.fromARGB(255, 188, 139, 70),
                                onPressed: () {
                                  print(CurrentPage.toString() + 'asdas');
                                  print(CurrentPage);
                                  GetDataArch(isBack: true);
                                  print(CurrentPage);
                                },
                              ))
                          : const SizedBox(),
                      IconButton(
                        onPressed: () {},
                        icon: IconButton(
                          icon: const Icon(Icons.arrow_circle_right_sharp),
                          color: Color.fromARGB(255, 188, 139, 70),
                          onPressed: () {
                            GetDataArch();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              )),
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
