import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../api/book_api.dart';

class QuestionDetailPage extends StatefulWidget {
  final int id;

  const QuestionDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  _QuestionDetailPageState createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends State<QuestionDetailPage> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _fetchQuestionDetail(widget.id);
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "加载失败：$e";
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchQuestionDetail(int id) async {
    final response = await BookApi.bookDetail(id);
    if (response != 0) {
      return response;
    } else {
      throw Exception('Failed to fetch question detail: ${response['msg']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _data != null
            ? Text(_data!['name'],
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w400,
                // fontFamily: 'OPPOSans',
                color: Color(0xFF003F91)))
            : Text("题本详情",
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w400,
                // fontFamily: 'OPPOSans',
                color: Color(0xFF051923))),
        actions: [
          IconButton(
            icon: Icon(Icons.save_alt),
            tooltip: '导出教师版',
            onPressed: () => _exportPdf(isTeacherVersion: true),
          ),
          IconButton(
            icon: Icon(Icons.save),
            tooltip: '导出学生版',
            onPressed: () => _exportPdf(isTeacherVersion: false),
          ),
          SizedBox(width: 300,)
        ],
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1440),
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_data == null) return SizedBox.shrink();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text('专业：',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            // fontFamily: 'OPPOSans',
                            color: Color(0xFF102b3f))),
                    Text(' ${_data?['major_name']}',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF102b3f))),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text('难度：',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            // fontFamily: 'OPPOSans',
                            color: Color(0xFF102b3f))),
                    Text(' ${_data?['level_name']}',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF102b3f))),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text('试题套数：',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            // fontFamily: 'OPPOSans',
                            color: Color(0xFF102b3f))),
                    Text(' ${_data?['unit_number']}',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF102b3f))),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Row(
                children: [
                  Text('试题总数：',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          // fontFamily: 'OPPOSans',
                          color: Color(0xFF102b3f))),
                  Text(' ${_data?['questions_number']}',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF102b3f))),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Text('试题组成：',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          // fontFamily: 'OPPOSans',
                          color: Color(0xFF102b3f))),
                  ...((_data?['component_desc'] as List?) ?? [])
                      .map((desc) => Text(desc + "，",
                      style: TextStyle(
                          fontSize: 15, color: Color(0xFF102b3f)))),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [],
              ),
            ),
          ]),
          Divider(height: 20),
          ...(_buildTables()),
        ],
      ),
    );
  }

  List<Widget> _buildTables() {
    final questionsDesc = _data?['questions_desc'] as List?;
    if (questionsDesc == null || questionsDesc.isEmpty) return [];

    return questionsDesc.map((section) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20), // 分隔不同章节
          Text(
            '章节：${section['title']}',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                // fontFamily: 'OPPOSans',
                color: Color(0xFFf3722c)),
          ),
          SizedBox(height: 10),
          Table(
            border: TableBorder.all(color: Colors.grey, width: 1), // 设置全线框并避免重叠
            columnWidths: {
              0: FixedColumnWidth(60),
              1: FixedColumnWidth(110),
              2: FixedColumnWidth(290),
              3: FixedColumnWidth(840),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Color(0xFF68b0ab)), // 标题行背景色
                children: [
                  _buildTableHeader('序号'),
                  _buildTableHeader('试题分类'),
                  _buildTableHeader('试题标题'),
                  _buildTableHeader('试题答案'),
                ],
              ),
              for (var detail in (section['questions_detail'] as List? ?? []))
                for (var i = 0; i < (detail['list'] as List? ?? []).length; i++)
                  TableRow(
                    children: [
                      _buildTableCell((i + 1).toString()), // 显示序号
                      _buildTableCell(detail['list'][i]['cate_name'] ?? ''),
                      _buildTableCell(detail['list'][i]['title'] ?? ''),
                      _buildTableCell(detail['list'][i]['answer'] ?? ''),
                    ],
                  ),
            ],
          ),
          SizedBox(height: 20), // 分隔不同章节
        ],
      );
    }).toList();
  }

  Widget _buildTableHeader(String text) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 40),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              // fontFamily: 'OPPOSans',
              color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 40),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Future<void> _exportPdf({required bool isTeacherVersion}) async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return <pw.Widget>[
          pw.Header(level: 0, child: pw.Text(_data!['name'])),
          pw.Paragraph(text: '专业：${_data?['major_name']}'),
          pw.Paragraph(text: '难度：${_data?['level_name']}'),
          pw.Paragraph(text: '试题套数：${_data?['unit_number']}'),
          pw.Divider(),
          pw.Paragraph(text: '试题总数：${_data?['questions_number']}'),
          pw.Paragraph(text: '试题组成：${(_data?['component_desc'] as List?)?.join(", ")}'),
          pw.Divider(),
          ...(_buildPdfTables(isTeacherVersion: isTeacherVersion)),
        ];
      },
    ));

    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${_data!['name']}.pdf');
    await file.writeAsBytes(bytes);

    OpenFile.open(file.path);
  }

  List<pw.Widget> _buildPdfTables({required bool isTeacherVersion}) {
    final questionsDesc = _data?['questions_desc'] as List?;
    if (questionsDesc == null || questionsDesc.isEmpty) return [];

    return questionsDesc.map((section) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 20), // 分隔不同章节
          pw.Text(
            '章节：${section['title']}',
            style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.orange),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey, width: 1), // 设置全线框并避免重叠
            columnWidths: {
              0: pw.FixedColumnWidth(60),
              1: pw.FixedColumnWidth(110),
              2: pw.FixedColumnWidth(290),
              3: pw.FixedColumnWidth(840),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColor.fromHex('#68b0ab')), // 标题行背景色
                children: [
                  _buildPdfTableHeader('序号'),
                  _buildPdfTableHeader('试题分类'),
                  _buildPdfTableHeader('试题标题'),
                  _buildPdfTableHeader('试题答案'),
                ],
              ),
              for (var detail in (section['questions_detail'] as List? ?? []))
                for (var i = 0; i < (detail['list'] as List? ?? []).length; i++)
                  pw.TableRow(
                    children: [
                      _buildPdfTableCell((i + 1).toString()), // 显示序号
                      _buildPdfTableCell(detail['list'][i]['cate_name'] ?? ''),
                      _buildPdfTableCell(detail['list'][i]['title'] ?? ''),
                      _buildPdfTableCell(
                          isTeacherVersion ? (detail['list'][i]['answer'] ?? '') : ' ' * 200),
                    ],
                  ),
            ],
          ),
          pw.SizedBox(height: 20), // 分隔不同章节
        ],
      );
    }).toList();
  }

  pw.Widget _buildPdfTableHeader(String text) {
    return pw.ConstrainedBox(
      constraints: pw.BoxConstraints(minHeight: 40),
      child: pw.Padding(
        padding: pw.EdgeInsets.all(8.0),
        child: pw.Text(
          text,
          style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  pw.Widget _buildPdfTableCell(String text) {
    return pw.ConstrainedBox(
      constraints: pw.BoxConstraints(minHeight: 40),
      child: pw.Padding(
        padding: pw.EdgeInsets.all(8.0),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.left,
        ),
      ),
    );
  }
}