import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_treeview/flutter_treeview.dart' as treeview;
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'logic.dart';

class PdfPreView extends StatefulWidget {
  final String title;
  final LectureLogic logic;

  const PdfPreView({Key? key, required this.title, required this.logic}) : super(key: key);

  @override
  _PdfPreViewState createState() => _PdfPreViewState();
}

class _PdfPreViewState extends State<PdfPreView> {
  final ValueNotifier<String?> _selectedPdfUrlNotifier = ValueNotifier(null);
  PdfControllerPinch? _pdfController;
  bool _isLoading = false;

  @override
  void dispose() {
    _pdfController?.dispose();
    _selectedPdfUrlNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
        TextButton(
          onPressed: () => _handleNodeTap("some_key"), // 传递一个有效的 key
          child: Text("Select PDF"),
        ),
        Expanded(
          child: ValueListenableBuilder<String?>(
            valueListenable: _selectedPdfUrlNotifier,
            builder: (context, selectedPdfUrl, _) {
              if (selectedPdfUrl == null) {
                return Center(child: Text("Select a PDF to preview"));
              }
              if (_isLoading) {
                return Center(child: CircularProgressIndicator());
              }
              return _buildPdfView();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPdfView() {
    if (_pdfController == null) {
      return Center(child: Text("Loading PDF..."));
    }
    return PdfViewPinch(
      controller: _pdfController!,
      builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
        documentLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
        pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
        errorBuilder: (_, error) => Center(child: Text(error.toString())),
        options: DefaultBuilderOptions(),
      ),
    );
  }

  Future<void> _initializePdfController(String url) async {
    try {
      setState(() => _isLoading = true); // 开始加载 PDF
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final pdfDocument = PdfDocument.openData(response.bodyBytes);
        setState(() {
          _pdfController = PdfControllerPinch(document: pdfDocument);
        });
      } else {
        throw Exception('Failed to load PDF: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _pdfController = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading PDF: $e')),
      );
    } finally {
      setState(() => _isLoading = false); // 加载完成或错误时停止加载状态
    }
  }

  void _handleNodeTap(String key) {
    final url = "http://127.0.0.1:9000/hongshi/lecture/1734167513/var/folders/gj/tp093yps1nv2qxh0g124f8900000gn/T/split-pdf3310929487/%E5%89%8D%E8%A8%80.pdf";
    if (_selectedPdfUrlNotifier.value != url) {
      _selectedPdfUrlNotifier.value = url;
      _initializePdfController(url);
    }
  }
}
