import 'dart:convert';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        arch.addAll(result);
      }

      CurrentPage++;
      var s = response.headers.values.toList().asMap();
      if (totalPages > 10) {
      } else {
        int Nu = int.parse(s[12] ?? "20");
        totalPages = (Nu / 20).ceil();
      }

      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  int compareString(bool ascending, String value1, String value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);

  @override
  Widget build(BuildContext context) => TabBarWidget(
        title: 'وزارة الاقتصاد',
        tabs: const [
          Tab(text: 'ارشيف قرارات'),
          Tab(text: 'بحث'),
        ],
        children: [
          Scaffold(
            body: SmartRefresher(
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
              onLoading: () async {
                final resualt = await GetDataArch();
                if (resualt) {
                  refreshController.loadComplete();
                } else {
                  refreshController.loadFailed();
                }
              },
              child: ScrollableWidget(child: buildDataTable()),
            ),
          ),
          Scaffold(
            body: BuildCard(),
          ),
        ],
      );

  Widget BuildCard() {
    return Card(
      child: ListTile(
        leading: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () async {
            searchResult = _searchResult;
          },
        ),
        title: TextField(
            controller: controller,
            decoration: const InputDecoration(
                hintText: 'بحث', border: InputBorder.none),
            onChanged: (value) {
              setState(() {
                _searchResult = value;
              },
              );
            }),
        trailing: IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () async => {
            setState(() {
              controller.clear();
              _searchResult = '';
              searchResult = '';
            }),
          },
        ),
      ),
    );
  }

  Widget buildDataTable() {
    final columns = [
      'سنة القرار',
      'رقم القرار',
      'العنوان ',
      'كلمات مفتاحية',
      'ملف القرار PDF ',
      'الوزير',
      'الحكومة '
    ];

    return DataTable(
      sortAscending: isAscending,
      sortColumnIndex: sortColumnIndex,
      columns: getColumns(columns),
      rows: getRows(arch),
    );
  }

  List<DataColumn> getColumns(List<String> columns) => columns
      .map((String column) => DataColumn(
            label: Text(column),
            onSort: onSort,
          ))
      .toList();

  List<DataRow> getRows(List<DecreeArchive> arch) =>
      arch.map((DecreeArchive archive) {
        final cells = [
          archive.year,
          archive.decreeNo,
          archive.title,
          archive.keywords,
          archive.pdfFileUrl,
          archive.government.name,
          archive.minister.name
        ];

        return DataRow(cells: getCells(cells));
      }).toList();

  List<DataCell> getCells(List<dynamic> cells) => cells
      .map((data) => DataCell(
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: data.toString().contains(".pdf")
                    ? const Icon(
                        Icons.picture_as_pdf,
                      )
                    : Text('$data'),
              ), onTap: (() async {
            print('$data');
            if (data.toString().contains(".pdf")) {
              downloadFile(
                  'http://pc.eidc.gov.ly:8080/api/public/file/download/$data');
              OpenPdf(
                  'http://pc.eidc.gov.ly:8080/api/public/file/download/$data');
            }
          })))
      .toList();

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

  void onSort(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      arch.sort((arch1, arch2) =>
          compareString(ascending, '${arch1.year}', '${arch2.year}'));
    } else if (columnIndex == 1) {
      arch.sort((arch1, arch2) =>
          compareString(ascending, arch1.decreeNo, arch2.decreeNo));
    } else if (columnIndex == 2) {
      arch.sort(
          (arch1, arch2) => compareString(ascending, arch1.title, arch2.title));
    } else if (columnIndex == 3) {
      arch.sort((arch1, arch2) =>
          compareString(ascending, arch1.keywords, arch2.keywords));
    } else if (columnIndex == 4) {
      arch.sort((arch1, arch2) =>
          compareString(ascending, arch1.pdfFileUrl, arch2.pdfFileUrl));
    } else if (columnIndex == 5) {
      arch.sort((arch1, arch2) => compareString(
          ascending, arch1.government.name, arch2.government.name));
    } else if (columnIndex == 6) {
      arch.sort((arch1, arch2) =>
          compareString(ascending, arch1.minister.name, arch2.minister.name));
    }

    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;
    });
  }
}
