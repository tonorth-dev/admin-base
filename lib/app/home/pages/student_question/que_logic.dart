import 'package:admin_flutter/app/home/pages/book/book.dart';
import 'package:admin_flutter/ex/ex_list.dart';
import 'package:admin_flutter/ex/ex_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_flutter/api/student_api.dart';
import 'package:admin_flutter/ex/ex_hint.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:admin_flutter/component/form/enum.dart';
import 'package:admin_flutter/component/form/form_data.dart';
import 'package:admin_flutter/component/dialog.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../api/classes_api.dart';
import '../../../../api/config_api.dart';
import '../../../../api/institution_api.dart';
import '../../../../api/major_api.dart';
import '../../../../api/question_api.dart';
import '../../../../api/topic_api.dart';
import '../../../../component/table/table_data.dart';
import '../../../../component/widget.dart';

class QueLogic extends GetxController {
  var list = <Map<String, dynamic>>[].obs;
  var total = 0.obs;
  var size = 15.obs;
  var page = 1.obs;
  var loading = false.obs;
  final searchText = ''.obs;

  final GlobalKey<CascadingDropdownFieldState> majorDropdownKey =
  GlobalKey<CascadingDropdownFieldState>();
  final GlobalKey<DropdownFieldState> cateDropdownKey =
  GlobalKey<DropdownFieldState>();
  final GlobalKey<DropdownFieldState> levelDropdownKey =
  GlobalKey<DropdownFieldState>();
  final GlobalKey<DropdownFieldState> statusDropdownKey =
  GlobalKey<DropdownFieldState>();

  // 当前编辑的题目数据
  var currentEditTopic = RxMap<String, dynamic>({}).obs;
  RxList<int> selectedRows = <int>[].obs;

  ValueNotifier<String?> selectedQuestionCate = ValueNotifier<String?>(null);
  ValueNotifier<String?> selectedQuestionLevel = ValueNotifier<String?>(null);
  ValueNotifier<String?> selectedQuestionStatus = ValueNotifier<String?>(null);
  RxList<Map<String, dynamic>> questionCate = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> questionLevel = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> questionStatus = <Map<String, dynamic>>[
    {'id': '0', 'name': '全部'},
    {'id': '1', 'name': '草稿'},
    {'id': '2', 'name': '生效中'},
    {'id': '4', 'name': '审核中'},
  ].obs;

  final ValueNotifier<dynamic> selectedLevel1 = ValueNotifier(null);
  final ValueNotifier<dynamic> selectedLevel2 = ValueNotifier(null);
  final ValueNotifier<dynamic> selectedLevel3 = ValueNotifier(null);

  // 专业列表数据
  List<Map<String, dynamic>> majorList = [];
  Map<String, List<Map<String, dynamic>>> subMajorMap = {};
  Map<String, List<Map<String, dynamic>>> subSubMajorMap = {};
  List<Map<String, dynamic>> level1Items = [];
  Map<String, List<Map<String, dynamic>>> level2Items = {};
  Map<String, List<Map<String, dynamic>>> level3Items = {};
  Rx<String> selectedStudentId = "0".obs;
  var all = "0";

  final topicTitle = ''.obs;
  ValueNotifier<String?> topicSelectedQuestionCate = ValueNotifier<String?>(null);
  ValueNotifier<String?> topicSelectedQuestionLevel = ValueNotifier<String?>(null);
  final topicSelectedMajorId = "".obs;
  final topicAnswer = "".obs;
  final topicAuthor = "".obs;
  final topicTag = "".obs;
  final topicStatus = 0.obs;

  final uTopicTitle = ''.obs;
  final uTopicSelectedQuestionCate = "".obs;
  final uTopicSelectedQuestionLevel = "".obs;
  final uTopicSelectedMajorId = "".obs;
  final uTopicAnswer = "".obs;
  final uTopicAuthor = "".obs;
  final uTopicTag = "".obs;
  final uTopicStatus = 0.obs;

  Future<void> fetchConfigs() async {
    try {
      var configData = await ConfigApi.configList();
      if (configData != null && configData.containsKey("list")) {
        final list = configData["list"] as List<dynamic>;
        final questionCateItem = list.firstWhere(
              (item) => item["name"] == "question_cate",
          orElse: () => null,
        );

        if (questionCateItem != null &&
            questionCateItem.containsKey("attr") &&
            questionCateItem["attr"].containsKey("cates")) {
          questionCate = RxList.from(questionCateItem["attr"]["cates"]);
        } else {
          print("配置数据中未找到 'question_cate' 或其 'cates' 属性");
          questionCate = RxList<Map<String, dynamic>>(); // 作为默认值，防止未初始化
        }

        final questionLevelItem = list.firstWhere(
              (item) => item["name"] == "question_level",
          orElse: () => null,
        );

        if (questionLevelItem != null &&
            questionLevelItem.containsKey("attr") &&
            questionLevelItem["attr"].containsKey("levels")) {
          questionLevel = RxList.from(questionLevelItem["attr"]["levels"]);
        } else {
          print("配置数据中未找到 'question_cate' 或其 'cates' 属性");
          questionLevel = RxList<Map<String, dynamic>>(); // 作为默认值，防止未初始化
        }
      } else {
        print("配置数据中未找到 'config' 或其 'list' 属性");
        questionCate = RxList<Map<String, dynamic>>();
      }
    } catch (e) {
      print('初始化 config 失败: $e');
      questionCate = RxList<Map<String, dynamic>>();
    }
  }

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
        print("questionLevel:$questionLevel");
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

  Future<List<Map<String, dynamic>>> find(int newSize, int newPage) async {
    size.value = newSize;
    page.value = newPage;
    list.clear();
    loading.value = true;
    try {
      var response = await TopicApi.topicList({
        "size": size.value.toString(),
        "page": page.value.toString(),
        "keyword": searchText.value.toString() ?? "",
        "cate": getSelectedCateId() ?? "",
        "level": getSelectedLevelId() ?? "",
        "status": selectedQuestionStatus.value.toString(),
        "major_id": (selectedStudentId.value?.toString() ?? ""),
      });

      if (response != null && response["list"] != null) {
        total.value = response["total"] ?? 0;
        list.assignAll((response["list"] as List<dynamic>).toListMap());
        await Future.delayed(const Duration(milliseconds: 300));
        loading.value = false;
        return (response["list"] as List<dynamic>).cast<Map<String, dynamic>>();
      } else {
        loading.value = false;
        "未获取到题库数据".toHint();
        return [];
      }
    } catch (e) {
      loading.value = false;
      print("获取题库列表失败: $e");
      "获取题库列表失败: $e".toHint();
      return [];
    }
  }

  String? getSelectedCateId() {
    if (selectedQuestionCate.value == '全部题型') {
      return "";
    }
    return selectedQuestionCate.value?.toString() ?? "";
  }

  String? getSelectedLevelId() {
    if (selectedQuestionLevel.value == '全部难度') {
      return "";
    }
    return selectedQuestionLevel.value?.toString() ?? "";
  }

  var columns = <ColumnData>[];

  @override
  void onInit() {
    fetchMajors(); // Fetch and populate major data on initialization
    fetchConfigs();
    ever(
      questionCate,
          (value) {
        if (questionCate.isNotEmpty) {
          // 当 questionCate 被赋值后再执行表单加载逻辑
          super.onInit();
          find(size.value, page.value);
        }
      },
    );

    columns = [
      ColumnData(title: "ID", key: "id", width: 80),
      ColumnData(title: "题型", key: "cate_name", width: 80),
      ColumnData(title: "难度", key: "level_name", width: 80),
      ColumnData(title: "题干", key: "title", width: 120),
      ColumnData(title: "答案", key: "answer", width: 200),
      ColumnData(title: "专业ID", key: "major_id",width: 80),
      ColumnData(title: "专业名称", key: "major_name",width: 80),
      ColumnData(title: "标签", key: "tag"),
      ColumnData(title: "录入人", key: "author"),
      ColumnData(title: "状态", key: "status_name"),
      ColumnData(title: "创建时间", key: "create_time"),
      ColumnData(title: "更新时间", key: "update_time"),
    ];

    // 初始化数据
    // find(size.value, page.value);
  }

  Future<void> findForStudent(int newSize, int newPage) async {
    all = selectedStudentId.value.toInt() > 0 ? "1" : "0";
    List<Map<String, dynamic>> items = await find(newSize, newPage);
    for (var item in items) {
      if (item['class_sorted'] == 1) {
        print(item['id']);
        toggleSelect(item['id']);
      }
    }
  }

  Future<List<String>> fetchInstructions(String query) async {
    print("query:$query");
    try {
      final response = await InstitutionApi.institutionList(params: {
        "pageSize": 10,
        "page": 1,
        "keyword": query ?? "",
      });
      var data = response['list'];
      print("response: $data");
      // 检查数据是否为 List
      if (data is List) {
        final List<String> suggestions = data.map((item) {
          // 检查每个 item 是否包含 'name' 和 'id' 字段
          if (item is Map && item.containsKey('name') &&
              item.containsKey('id')) {
            return "${item['name']}（ID：${item['id']}）";
          } else {
            throw FormatException('Invalid item format: $item');
          }
        }).toList();
        print("suggestions： $suggestions");
        return suggestions;
      } else {
        // Handle the case where data is not a List
        return [];
      }
    } catch (e) {
      // Handle any exceptions that are thrown
      print('Error fetching instructions: $e');
      return [];
    }
  }

  @override
  void refresh() {
    findForStudent(size.value, page.value);
  }

  // 导出选中项到 CSV 文件
  Future<void> exportSelectedItemsToCSV() async {
    try {
      if (selectedRows.isEmpty) {
        "请选择要导出的数据".toHint();
        return;
      }

      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) return;

      List<List<dynamic>> rows = [];
      rows.add(columns.map((column) => column.title).toList());

      for (var item in list) {
        if (selectedRows.contains(item['id'])) {
          rows.add(columns.map((column) => item[column.key]).toList());
        }
      }

      final now = DateTime.now();
      final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(now);
      String csv = const ListToCsvConverter().convert(rows);
      File('$directory/students_selected_$formattedDate.csv')
          .writeAsStringSync(csv);
      "导出选中项成功!".toHint();
    } catch (e) {
      "导出选中项失败: $e".toHint();
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
    searchText.value = '';
    selectedRows.clear();

    // 重新初始化数据
    findForStudent(size.value, page.value);
  }

  var isRowsSelectable = false.obs; // 控制行是否可被选中

  void enableRowSelection() {
    isRowsSelectable.value = true;
  }

  void disableRowSelection() {
    isRowsSelectable.value = false;
  }
}
