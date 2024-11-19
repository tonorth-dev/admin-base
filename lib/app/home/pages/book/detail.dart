import 'package:flutter/material.dart';
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
                      fontFamily: 'OPPOSans',
                      color: Color(0xFF003F91)))
              : Text("题本详情",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'OPPOSans',
                      color: Color(0xFF051923)))),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildContent(),
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
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFff6700))),
                  Text(' ${_data?['major_name']}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
                ],
              )),
              Expanded(
                  child: Row(
                children: [
                  Text('难度：',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFff6700))),
                  Text(' ${_data?['level_name']}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
                ],
              )),
              Expanded(
                  child: Row(
                children: [
                  Text('试题套数：',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFff6700))),
                  Text(' ${_data?['unit_number']}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
                ],
              )),
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
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFff6700))),
                Text(' ${_data?['questions_number']}',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
              ],
            )),
            Expanded(
                child: Row(
              children: [
                Text('试题组成：',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFff6700))),
                ...((_data?['component_desc'] as List?) ?? [])
                    .map((desc) => Text(desc, style: TextStyle(fontSize: 15))),
              ],
            )),
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
            '章节: ${section['title']}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Table(
            border: TableBorder.all(color: Colors.grey, width: 1), // 设置全线框并避免重叠
            columnWidths: {
              0: FixedColumnWidth(80),
              1: FixedColumnWidth(150),
              2: FixedColumnWidth(300),
              3: FixedColumnWidth(800),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Colors.grey[200]), // 标题行背景色
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
          style: TextStyle(fontWeight: FontWeight.bold),
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
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

}
