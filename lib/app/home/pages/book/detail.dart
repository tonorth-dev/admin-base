import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:get/get.dart';
import '../../../../api/book_api.dart';
import '../../../../common/config_util.dart';
import '../../../../component/widget.dart';
import 'logic.dart';

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
  late Map<int, int?> _selectedQuestions;
  final logic = Get.put(BookLogic());

  @override
  void initState() {
    super.initState();
    _selectedQuestions = {};
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
                fontFamily: 'OPPOSans',
                color: Color(0xFF003F91)))
            : Text("题本详情",
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w400,
                fontFamily: 'OPPOSans',
                color: Color(0xFF051923))),
        actions: [
          OutlinedButton.icon(
            icon: Icon(Icons.save_alt),
            label: Text('导出教师版'),
            onPressed: () => _exportPdf(isTeacherVersion: true),
            style: ButtonStyle(
              side: MaterialStateProperty.all<BorderSide>(
                BorderSide(color: Colors.redAccent, width: 2.0),
              ),
              foregroundColor:
              MaterialStateProperty.all<Color>(Colors.redAccent),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
            ),
          ),
          SizedBox(width: 16),
          OutlinedButton.icon(
            icon: Icon(Icons.save),
            label: Text('导出考生版'),
            onPressed: () => _exportPdf(isTeacherVersion: false),
            style: ButtonStyle(
              side: MaterialStateProperty.all<BorderSide>(
                BorderSide(color: Colors.blueAccent, width: 2.0),
              ),
              foregroundColor:
              MaterialStateProperty.all<Color>(Colors.blueAccent),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
            ),
          ),
          SizedBox(
            width: 300,
          )
        ],
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1660),
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
          // ... (previous content)
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
          SizedBox(height: 20),
          Text(
            '章节：${section['title']}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              fontFamily: 'OPPOSans',
              color: Color(0xFFf3722c),
            ),
          ),
          SizedBox(height: 10),
          Table(
            border: TableBorder.all(color: Colors.grey, width: 1),
            columnWidths: {
              0: FixedColumnWidth(60),
              1: FixedColumnWidth(120),
              2: FixedColumnWidth(110),
              3: FixedColumnWidth(290),
              4: FixedColumnWidth(840),
              5: FixedColumnWidth(120),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Color(0xFF68b0ab)),
                children: [
                  _buildTableHeader('序号'),
                  _buildTableHeader('试题ID'),
                  _buildTableHeader('试题分类'),
                  _buildTableHeader('试题标题'),
                  _buildTableHeader('试题答案'),
                  _buildTableHeader('操作'),
                ],
              ),
              for (var detail in (section['questions_detail'] as List? ?? []))
                for (var i = 0; i < (detail['list'] as List? ?? []).length; i++)
                  TableRow(
                    children: [
                      _buildTableCell(Text((i + 1).toString())),
                      _buildTableCell(Text(detail['list'][i]['id'].toString())),
                      _buildTableCell(
                          Text(detail['list'][i]['category_name'] ?? "")),
                      _buildTableCell(Text(detail['list'][i]['title'] ?? "")),
                      _buildTableCell(Text(detail['list'][i]['answer'] ?? "")),
                      _buildTableCell(_buildChangeOrSaveButton(detail['list'][i])),
                    ],
                  ),
            ],
          ),
        ],
      );
    }).toList();
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFFf5f5f5)),
      ),
    );
  }

  Widget _buildTableCell(Widget child) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: child,
    );
  }

  Widget _buildChangeOrSaveButton(Map<String, dynamic> question) {
    final isEditing = _selectedQuestions.containsKey(question['id']);

    if (isEditing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () => _onSaveButtonPressed(question),
            child: Text('保存'),
          ),
          ElevatedButton(
            onPressed: () => _onCancelButtonPressed(question),
            child: Text('取消'),
          ),
        ],
      );
    } else {
      return ElevatedButton(
        onPressed: () => _onChangeButtonPressed(question),
        child: Text('换题'),
      );
    }
  }

  Future<void> _onChangeButtonPressed(dynamic question) async {
    setState(() {
      _selectedQuestions[question['id']] = null;
    });

    await Get.defaultDialog(
      title: "更换题目",
      content: Container(
        width: 1000,
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SuggestionTextField(
              width: 200,
              height: 34,
              labelText: '筛选题目',
              hintText: '输入题目标题或ID',
              key: logic.topicTextFieldKey,
              fetchSuggestions: logic.fetchTopics,
              initialValue: ValueNotifier<Map<dynamic, dynamic>?>({
                'name': question["title"],
                'id': question["id"],
              }),
              onSelected: (value) {
                if (value.isEmpty) {
                  logic.newTopicId.value = 0;
                  return;
                }
                logic.newTopicId.value = int.parse(value['id']);
              },
              onChanged: (value) {
                if (value == null || value.isEmpty) {
                  logic.newTopicId.value = 0;
                }
                print(
                    "onChanged selectedInstitutionId value: ${logic.newTopicId.value}");
              },
            ),
          ],
        ),
      ),
      onCancel: () => _onCancelButtonPressed(question),
      onConfirm: () async {
        final newQuestionId = logic.newTopicId.value;

        if (newQuestionId > 0) {
          await _onSaveButtonPressed(question, newQuestionId);
        } else {
          _onCancelButtonPressed(question);
        }
      },
    );
  }

  Future<void> _onSaveButtonPressed(dynamic question, [int? newId]) async {
    if (newId != null) {
      _selectedQuestions[question['id']] = newId;
    }
    await logic.changeTopic(question['id'], _selectedQuestions[question['id']]!);
    setState(() {
      _selectedQuestions.remove(question['id']);
    });
  }

  void _onCancelButtonPressed(dynamic question) {
    setState(() {
      _selectedQuestions.remove(question['id']);
    });
  }

  Future<void> _exportPdf({required bool isTeacherVersion}) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Center(child: pw.Text('导出PDF功能，教师版: $isTeacherVersion'));
      },
    ));
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/export.pdf");
    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }
}