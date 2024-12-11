import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../sidebar/logic.dart';
import 'file_view.dart';
import 'lecture_view.dart';
import 'logic.dart';


class LecturePage extends StatelessWidget {
  final logic = Get.put(LectureLogic());

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LectureTableView(
                key: const Key("lectureT_table"), title: "讲义列表", logic: logic),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LectureFileView(
                key: const Key("file_table"), title: "文件管理", logic: logic),
          ),
        ),
        // Expanded(
        //   child: Padding(
        //     padding: const EdgeInsets.all(16.0),
        //     child: LectureFilePreview(
        //         key: const Key("student_table"), title: "考生列表", logic: logic),
        //   ),
        // ),
      ],
    );
  }

  static SidebarTree newThis() {
    return SidebarTree(
      name: "讲义管理",
      icon: Icons.deblur,
      page: LecturePage(),
    );
  }
}