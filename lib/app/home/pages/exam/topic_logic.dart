import 'dart:io';

import 'package:admin_flutter/ex/ex_list.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_flutter/api/exam_topic_api.dart';
import 'package:admin_flutter/ex/ex_hint.dart';
import 'package:admin_flutter/component/dialog.dart';
import '../../../../api/major_api.dart';
import '../../../../common/config_util.dart';
import '../../../../component/table/table_data.dart';
import '../../../../component/widget.dart';

class ExamTopicLogic extends GetxController {
  int id; // 添加 id 变量
  ExamTopicLogic(this.id);

  var list = <Map<String, dynamic>>[].obs;
  var total = 0.obs;
  var size = 15.obs;
  var page = 1.obs;
  var loading = false.obs;
  final searchText = ''.obs;
  final RxString selectedKey = ''.obs; // 初始化为空字符串
  final RxList<String> expandedKeys = <String>[].obs;

  final RxString selectedExamTopicId = '0'.obs; // To track which examTopic's directory we are viewing

  var isLoading = false.obs;


  final GlobalKey<CascadingDropdownFieldState> majorDropdownKey =
      GlobalKey<CascadingDropdownFieldState>();

  // 当前编辑的题目数据
  RxList<int> selectedRows = <int>[].obs;
  // 专业列表数据
  List<Map<String, dynamic>> majorList = [];
  Map<String, List<Map<String, dynamic>>> subMajorMap = {};
  Map<String, List<Map<String, dynamic>>> subSubMajorMap = {};
  List<Map<String, dynamic>> level1Items = [];
  Map<String, List<Map<String, dynamic>>> level2Items = {};
  Map<String, List<Map<String, dynamic>>> level3Items = {};
  Rx<String> selectedStudentIde = "0".obs;

  final examTopicId = 0.obs; // 对应 ID
  final examTopicName = ''.obs; // 对应 Name
  final majorId = 0.obs; // 对应 MajorID
  final jobCode = 0.obs; // 对应 JobCode
  final sort = 0.obs; // 对应 Sort
  final creator = ''.obs; // 对应 Creator
  final examTopicCategory = ''.obs; // 对应 Category
  final pageCount = 0.obs; // 对应 PageCount
  final status = 0.obs; // 对应 Status

  final uExamTopicId = 0.obs; // 对应 ID
  final uExamTopicName = ''.obs; // 对应 Name
  final uMajorId = 0.obs; // 对应 MajorID
  final uJobCode = 0.obs; // 对应 JobCode
  final uSort = 0.obs; // 对应 Sort
  final uCreator = ''.obs; // 对应 Creator
  final uExamTopicCategory = ''.obs; // 对应 Category
  final uPageCount = 0.obs; // 对应 PageCount
  final uStatus = 0.obs; // 对应 Status

  // Maps for reverse lookup
  Map<String, String> level3IdToLevel2Id = {};
  Map<String, String> level2IdToLevel1Id = {};

  Future<void> fetchMajors() async {
    try {
      var response =
          await MajorApi.majorList(params: {'pageSize': 3000, 'page': 1});
      if (response != null && response["total"] > 0) {
        var dataList = response["list"] as List<dynamic>;

        // Clear existing data to avoid duplicates
        majorList.clear();
        majorList.add({'id': '0', 'name': '全部专业'});
        subMajorMap.clear();
        subSubMajorMap.clear();
        level1Items.clear();
        level2Items.clear();
        level3Items.clear();

        // Track the generated IDs for first and second levels
        Map<String, String> firstLevelIdMap = {};
        Map<String, String> secondLevelIdMap = {};

        for (var item in dataList) {
          String firstLevelName = item["first_level_category"];
          String secondLevelName = item["second_level_category"];
          String thirdLevelId = item["id"].toString();
          String thirdLevelName = item["major_name"];

          // Generate unique IDs based on name for first-level and second-level categories
          String firstLevelId = firstLevelIdMap.putIfAbsent(
              firstLevelName, () => firstLevelIdMap.length.toString());
          String secondLevelId = secondLevelIdMap.putIfAbsent(
              secondLevelName, () => secondLevelIdMap.length.toString());

          // Add first-level category if it doesn't exist
          if (!majorList.any((m) => m['name'] == firstLevelName)) {
            majorList.add({'id': firstLevelId, 'name': firstLevelName});
            level1Items.add({'id': firstLevelId, 'name': firstLevelName});
            subMajorMap[firstLevelId] = [];
            level2Items[firstLevelId] = [];
          }

          // Add second-level category if it doesn't exist under this first-level category
          if (subMajorMap[firstLevelId]
                  ?.any((m) => m['name'] == secondLevelName) !=
              true) {
            subMajorMap[firstLevelId]!
                .add({'id': secondLevelId, 'name': secondLevelName});
            level2Items[firstLevelId]
                ?.add({'id': secondLevelId, 'name': secondLevelName});
            subSubMajorMap[secondLevelId] = [];
            level3Items[secondLevelId] = [];
            level2IdToLevel1Id[secondLevelId] =
                firstLevelId; // Populate reverse lookup map
          }

          // Add third-level major if it doesn't exist under this second-level category
          if (subSubMajorMap[secondLevelId]
                  ?.any((m) => m['name'] == thirdLevelName) !=
              true) {
            subSubMajorMap[secondLevelId]!
                .add({'id': thirdLevelId, 'name': thirdLevelName});
            level3Items[secondLevelId]
                ?.add({'id': thirdLevelId, 'name': thirdLevelName});
            level3IdToLevel2Id[thirdLevelId] =
                secondLevelId; // Populate reverse lookup map
          }
        }

        // Debug output
        print('majorList: $majorList');
        print('subMajorMap: $subMajorMap');
        print('subSubMajorMap: $subSubMajorMap');
        print('level1Items: $level1Items');
        print('level2Items: $level2Items');
        print('level3Items: $level3Items');
        print('level3IdToLevel2Id: $level3IdToLevel2Id');
        print('level2IdToLevel1Id: $level2IdToLevel1Id');
      } else {
        "获取专业列表失败".toHint();
      }
    } catch (e) {
      "获取专业列表失败: $e".toHint();
    }
  }

  String getLevel2IdFromLevel3Id(String thirdLevelId) {
    return level3IdToLevel2Id[thirdLevelId] ?? '';
  }

  String getLevel1IdFromLevel2Id(String secondLevelId) {
    return level2IdToLevel1Id[secondLevelId] ?? '';
  }

  void find(int newSize, int newPage) {
    size.value = newSize;
    page.value = newPage;
    list.clear();
    selectedRows.clear();
    loading.value = true;
    // 打印调用堆栈
    try {
      ExamTopicApi.examTopicList({
        "size": size.value.toString(),
        "page": page.value.toString(),
        "exam_id": (id.toString() ?? ""),
        "student_id": (selectedStudentIde.value.toString() ?? ""),
        "keyword": searchText.value.toString() ?? "",
      }).then((value) async {
        if (value != null && value["list"] != null) {
          total.value = value["total"] ?? 0;
          list.assignAll((value["list"] as List<dynamic>).toListMap());
          await Future.delayed(const Duration(milliseconds: 300));
          loading.value = false;
        } else {
          loading.value = false;
          "未获取到练习题数据".toHint();
        }
      }).catchError((error) {
        loading.value = false;
        print("获取练习题列表失败: $error");
        "获取练习题列表失败: $error".toHint();
      });
    } catch (e) {
      loading.value = false;
      print("获取练习题列表失败: $e");
      "获取练习题列表失败: $e".toHint();
    }
  }

  var columns = <ColumnData>[];

  @override
  void onInit() {
    super.onInit();// Fetch and populate major data on initialization

    columns = [
      ColumnData(title: "ID", key: "exam_id", width: 80),
      ColumnData(title: "试卷名称", key: "exam_name", width: 100),
      ColumnData(title: "班级ID", key: "class_id", width: 0),
      ColumnData(title: "班级名称", key: "class_name", width: 100),
      ColumnData(title: "考生ID", key: "student_id", width: 0),
      ColumnData(title: "考生名称", key: "student_name", width: 100),
      ColumnData(title: "专业名称", key: "major_name", width: 100),
      ColumnData(title: "试题ID", key: "topic_id", width: 0),
      ColumnData(title: "试题", key: "topic_title", width: 100),
      ColumnData(title: "答案", key: "topic_answer", width: 200),
      ColumnData(title: "状态", key: "status", width: 0),
      ColumnData(title: "练习状态", key: "status_name", width: 100),
      ColumnData(title: "练习时间", key: "practice_time", width: 120),
    ];


    // 初始化数据
    // find(size.value, page.value);
  }

  @override
  void refresh() {
    find(size.value, page.value);
  }

  void delete(Map<String, dynamic> d, int index) {
    try {
      ExamTopicApi.examTopicDelete(d["id"]).then((value) {
        list.removeAt(index);
      }).catchError((error) {
        "删除失败: $error".toHint();
      });
    } catch (e) {
      "删除失败: $e".toHint();
    }
  }

  void batchDelete(List<int> ids) {
    try {
      List<String> idsStr = ids.map((id) => id.toString()).toList();
      if (idsStr.isEmpty) {
        "请先选择要删除的练习题".toHint();
        return;
      }
      ExamTopicApi.examTopicDelete(idsStr.join(",")).then((value) {
        "批量删除成功!".toHint();
        selectedRows.clear();
        refresh();
      }).catchError((error) {
        "批量删除失败: $error".toHint();
      });
    } catch (e) {
      "批量删除失败: $e".toHint();
    }
  }

  void toggleSelectAll() {
    if (selectedRows.length == list.length) {
      // 当前所有行都被选中，清空选中状态
      selectedRows.clear();
    } else {
      // 当前不是所有行都被选中，选择所有行
      selectedRows.assignAll(list.map((item) => item['id']));
    }
  }

  void toggleSelect(int id) {
    if (selectedRows.contains(id)) {
      // 当前行已被选中，取消选中
      selectedRows.remove(id);
    } else {
      // 当前行未被选中，选中
      selectedRows.add(id);
    }
  }

  void reset() {
    majorDropdownKey.currentState?.reset();
    searchText.value = '';
    selectedRows.clear();

    // 重新初始化数据
    fetchMajors();
    find(size.value, page.value);
  }
}
