import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../component/table/ex.dart';
import '../../../../theme/theme_util.dart';
import 'logic.dart';

class PdfPreView extends StatefulWidget {
  final String title;

  const PdfPreView({Key? key, required this.title}) : super(key: key);

  @override
  _PdfPreViewState createState() => _PdfPreViewState();
}

class _PdfPreViewState extends State<PdfPreView> {
  final NoteLogic pdfLogic = Get.put(NoteLogic());
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableEx.actions(
          children: [
            SizedBox(width: 30), // 添加一些间距
            Container(
              height: 50,
              width: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade300],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "文件预览",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        ThemeUtil.lineH(),
        ThemeUtil.height(),
        Obx(() {
          final selectedPdfUrl = pdfLogic.selectedPdfUrl.value;
          if (selectedPdfUrl == null || selectedPdfUrl.isEmpty) {
            return Center(child: Text("请选择一个文件"));
          }
          return Expanded(
            child: SfPdfViewer.network(
              selectedPdfUrl!,
              key: _pdfViewerKey,
              onDocumentLoadFailed: (details) {
                debugPrint('Failed to load PDF: ${details.error}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('加载 PDF 时出错: ${details.description}')),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}

