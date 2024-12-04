import 'package:admin_flutter/app/home/pages/book/book.dart';
import 'package:admin_flutter/ex/ex_list.dart';
import 'package:admin_flutter/ex/ex_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_flutter/api/job_api.dart';
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
import '../../../../api/major_api.dart';
import '../../../../component/table/table_data.dart';
import '../../../../component/widget.dart';

class JLogic extends GetxController {
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
  var currentEditJob = RxMap<String, dynamic>({}).obs;
  RxList<int> selectedRows = <int>[].obs;

  ValueNotifier<String?> selectedQuestionCate = ValueNotifier<String?>(null);
  ValueNotifier<String?> selectedQuestionLevel = ValueNotifier<String?>(null);
  ValueNotifier<String?> selectedQuestionStatus = ValueNotifier<String?>(null);
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
  Rx<String> selectedMajorId = "0".obs;
  var all = "0";

  final jobCode = ''.obs;
  final jobName = ''.obs;
  final jobCate = ''.obs;
  final jobDesc = ''.obs;
  final companyCode = ''.obs;
  final companyName = ''.obs;
  final enrollmentNum = 0.obs;
  final enrollmentRatio = ''.obs;
  final conditionSource = ''.obs;
  final conditionQualification = "".obs;
  final conditionDegree = "".obs;
  final conditionMajor = "".obs;
  final conditionExam = "".obs;
  final conditionOther = "".obs;
  final jobCity = "".obs;
  final jobPhone = "".obs;

  final uJobCode = ''.obs;
  final uJobName = ''.obs;
  final uJobCate = ''.obs;
  final uJobDesc = ''.obs;
  final uCompanyCode = ''.obs;
  final uCompanyName = ''.obs;
  final uEnrollmentNum = 0.obs;
  final uEnrollmentRatio = ''.obs;
  final uConditionSource = ''.obs;
  final uConditionQualification = "".obs;
  final uConditionDegree = "".obs;
  final uConditionMajor = "".obs;
  final uConditionExam = "".obs;
  final uConditionOther = "".obs;
  final uJobCity = "".obs;
  final uJobPhone = "".obs;

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
    selectedRows.clear();
    loading.value = true;
    // 打印调用堆栈
    try {
      var response = await JobApi.jobList({
        "size": size.value.toString(),
        "page": page.value.toString(),
        "keyword": searchText.value.toString() ?? "",
        "cate": getSelectedCateId() ?? "",
        "level": getSelectedLevelId() ?? "",
        "status": selectedQuestionStatus.value.toString(),
        "major_id": (selectedMajorId.value.toString() ?? ""),
        "all": all ?? "0",
      });

      if (response != null && response["list"] != null) {
        total.value = response["total"] ?? 0;
        list.assignAll((response["list"] as List<dynamic>).toListMap());

        await Future.delayed(const Duration(milliseconds: 300));
        loading.value = false;
        return list;
      } else {
        loading.value = false;
        "未获取到岗位数据".toHint();
        return [];
      }
    } catch (e) {
      loading.value = false;
      print("获取岗位列表失败: $e");
      "获取岗位列表失败: $e".toHint();
      return [];
    }
  }

  Future<void> findForMajor(int majorId) async {
    all = "1";
    selectedMajorId.value = majorId.toString();
    List<Map<String, dynamic>> items = await find(size.value, page.value);
    for (var item in items) {
      if (item['major_sorted'] == 1) {
        print(item['id']);
        toggleSelect(item['id']);
      }
    }
  }

  var columns = <ColumnData>[];

  @override
  void onInit() {
    super.onInit();// Fetch and populate major data on initialization

    columns = [
      ColumnData(title: "ID", key: "id", width: 0),
      ColumnData(title: "岗位编码", key: "code", width: 100),
      ColumnData(title: "岗位名称", key: "name", width: 200),
      ColumnData(title: "岗位类别", key: "cate", width: 120),
      ColumnData(title: "从事工作", key: "desc", width: 150),
      ColumnData(title: "单位编码", key: "company_code", width: 100),
      ColumnData(title: "单位名称", key: "company_name", width: 120),
      ColumnData(title: "录取人数", key: "enrollment_num", width: 60),
      ColumnData(title: "录取比例", key: "enrollment_ratio", width: 0),
      ColumnData(title: "报考条件原文", key: "condition"),
      ColumnData(title: "报考条件", key: "condition_name"),
      ColumnData(title: "城市", key: "city"),
      ColumnData(title: "专业ID", key: "major_id"),
      ColumnData(title: "专业名称", key: "major_name"),
      ColumnData(title: "状态", key: "status"),
      ColumnData(title: "创建时间", key: "create_time"),
      ColumnData(title: "更新时间", key: "update_time"),
    ];

    // 初始化数据
    // find(size.value, page.value);
  }

  @override
  void refresh() {
    find(size.value, page.value);
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
      File('$directory/jobs_selected_$formattedDate.csv')
          .writeAsStringSync(csv);
      "导出选中项成功!".toHint();
    } catch (e) {
      "导出选中项失败: $e".toHint();
    }
  }

  Future<void> exportAllToCSV() async {
    try {
      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) return;

      List<Map<String, dynamic>> allItems = [];
      int currentPage = 1;
      int pageSize = 100;

      while (true) {
        var response = await JobApi.jobList({
          "size": pageSize.toString(),
          "page": currentPage.toString(),
        });

        allItems.addAll((response["list"] as List<dynamic>).toListMap());

        if (allItems.length >= response["total"]) break;
        currentPage++;
      }

      List<List<dynamic>> rows = [];
      rows.add(columns.map((column) => column.title).toList());

      for (var item in allItems) {
        rows.add(columns.map((column) => item[column.key]).toList());
      }

      String csv = const ListToCsvConverter().convert(rows);
      File('$directory/jobs_all_pages.csv').writeAsStringSync(csv);
      "导出全部成功!".toHint();
    } catch (e) {
      "导出全部失败: $e".toHint();
    }
  }

  void importFromCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'xls']);
      if (result != null) {
        PlatformFile file = result.files.first;
        String? filePath = file.path;

        if (filePath != null) {
          // 创建 File 对象
          File excelFile = File(filePath);

          // 检查文件是否为空
          int fileSize = await excelFile.length();
          if (fileSize == 0) {
            "文件内容为空".toHint();
            return;
          }

          // 调用 API 执行批量导入
          await JobApi.jobBatchImport(excelFile).then((value) {
            "导入成功!".toHint();
            refresh();
          }).catchError((error) {
            print("导入失败: $error");
            "导入失败: $error".toHint();
          });
        } else {
          "文件路径为空，无法读取文件".toHint();
        }
      } else {
        "没有选择文件".toHint();
      }
    } catch (e) {
      print("导入失败: $e");
      "导入失败: $e".toHint();
    }
  }

  void delete(Map<String, dynamic> d, int index) {
    try {
      JobApi.jobDelete(d["id"].toString()).then((value) {
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
        "请先选择要删除的试题".toHint();
        return;
      }
      JobApi.jobDelete(idsStr.join(",")).then((value) {
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


  void applyFilters() {
    // 这里可以添加应用过滤逻辑
    // print('Selected Major: ${selectedMajor.value}');
    // print('Selected Sub Major: ${selectedSubMajor.value}');
    // print('Selected Sub Sub Major: ${selectedSubSubMajor.value}');
  }

  void reset() {
    majorDropdownKey.currentState?.reset();
    searchText.value = '';
    selectedRows.clear();

    // 重新初始化数据
    fetchMajors();
    find(size.value, page.value);
  }

  var isRowsSelectable = false.obs; // 控制行是否可被选中

  void enableRowSelection() {
    isRowsSelectable.value = true;
    update();
  }

  void disableRowSelection() {
    isRowsSelectable.value = false;
    update();
    // selectedRows.clear(); // 清除所有选择
  }

}
