import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;

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
  final LectureLogic pdfLogic = Get.put(LectureLogic());
  PdfControllerPinch? _pdfController;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    pdfLogic.selectedPdfUrl.listen((url) async {
      if (url != null) {
        await _initializePdf(url);
      }
    });
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _initializePdf(String url) async {
    if (_currentUrl == url) {
      debugPrint("Same URL, skipping reinitialization.");
      return;
    }

    debugPrint('Initializing PDF with URL: $url');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final pdfDocument = PdfDocument.openData(response.bodyBytes);

        // Dispose of the old controller and set it to null before creating a new one
        _pdfController?.dispose();
        setState(() {
          _pdfController = null; // Ensure that the widget rebuilds without a controller first.
        });

        // Update the controller and state
        await Future.delayed(Duration(milliseconds: 100)); // Give some time for the widget to rebuild without a controller
        setState(() {
          _currentUrl = url;
          _pdfController = PdfControllerPinch(document: pdfDocument);
        });

        debugPrint('PDF loaded successfully');
      } else {
        debugPrint('Failed to load PDF. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load PDF: ${response.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('Error initializing PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading PDF: $e')),
      );
    }
  }

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
          if (selectedPdfUrl!.isEmpty) {
            return Center(child: Text("请选择一个文件"));
          }
          return Expanded(
            child: _pdfController != null
                ? PdfViewPinch(controller: _pdfController!)
                : Center(child: CircularProgressIndicator()),
          );
        }),
      ],
    );
  }
}