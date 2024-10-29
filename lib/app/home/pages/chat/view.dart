import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.orangeAccent),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "面试模拟系统服务端",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.orangeAccent,
          centerTitle: true,
        ),
        body: Row(
          children: [
            // 左侧菜单栏
            Container(
              width: 200,
              color: Colors.grey[200],
              child: ListView(
                children: [
                  _buildMenuItem(Icons.settings, '系统设置'),
                  _buildMenuItem(Icons.format_list_numbered, '抽取试题'),
                  _buildMenuItem(Icons.play_arrow, '计时开始'),
                  _buildMenuItem(Icons.assignment_turned_in, '答题完毕'),
                  _buildMenuItem(Icons.save, '保存成绩'),
                  Divider(),
                  _buildMenuItem(Icons.logout, '退出系统'),
                ],
              ),
            ),
            // 主体内容
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 顶部答题计时和日志区域
                    Row(
                      children: [
                        _buildTimerSection(),
                        SizedBox(width: 20),
                        Expanded(child: _buildLogSection()),
                      ],
                    ),
                    SizedBox(height: 20),
                    // 考生信息与试题内容
                    Expanded(
                      child: Row(
                        children: [
                          _buildCandidateInfo(),
                          SizedBox(width: 20),
                          _buildQuestionContent(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 左侧菜单项构建
  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.orangeAccent),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: () {},
    );
  }

  // 顶部计时区域
  Widget _buildTimerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "答题时间",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "15:00",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
          ),
          onPressed: () {},
          child: Text("分段计时"),
        ),
      ],
    );
  }

  // 日志区域
  Widget _buildLogSection() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "系统日志",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                "[172.16.64.132:60143]：试题信息。\n[面试终端] 发送信息。\n[面试终端] 发送信息。\n[面试终端] 发送信息。",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 考生信息区域
  Widget _buildCandidateInfo() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "考生信息",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            Text("考生姓名: 房产1"),
            Text("岗位代码: 2024007013"),
            Text("岗位类别: 工程"),
            Text("岗位名称: 助理工程师"),
            Text("从事工作: 装饰质量监督"),
          ],
        ),
      ),
    );
  }

  // 试题内容区域
  Widget _buildQuestionContent() {
    return Expanded(
      flex: 2,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "试题内容",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            Text(
              "1、怎么看待党对军队的绝对领导？",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  "这里是试题内容的详细解释。可以放置长段落文本。" * 4,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
