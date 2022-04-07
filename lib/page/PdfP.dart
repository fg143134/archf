import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfP extends StatelessWidget {
  final String pDfF;

  const PdfP({Key? key, required this.pDfF}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: SfPdfViewer.network(pDfF)),
    );
  }
}
