import 'package:admin_flutter/ex/ex_hint.dart';
import 'package:admin_flutter/ex/ex_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:admin_flutter/component/table/table_data.dart';
import 'package:admin_flutter/api/topic_api.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:admin_flutter/component/form/enum.dart';
import 'package:admin_flutter/component/form/form_data.dart';

import 'edit_topic_dialog.dart';

class TopicLogic extends GetxController {
  var list = <Map<String, dynamic>>[].obs;
  var total = 0.obs;
  var size = 0;
  var page = 0;
  var loading = false.obs;
  // 当前编辑的题目数据
  var currentEditTopic = RxMap<String, dynamic>({}).obs;
  RxList<int> selectedRows = <int>[].obs;
  Rx<String?> selectedTopicType = '全部题型'.obs;
  List<String> topicTypeList = ['全部题型', '综合', '专业方向', '基础方向'];  // 根据实际情况填充

  final List<String> majorList = ['全部专业', '计算机科学与技术', '国际关系', '教育学'];  // 根据实际情况填充
  final Map<String, List<String>> subMajorMap = {
    '全部专业': ['二级分类1-1', '二级分类1-2'],
    '计算机科学与技术': ['二级分类2-1', '二级分类2-2'],
    '国际关系': ['二级分类3-1', '二级分类3-2'],
    '教育学': ['二级分类3-3', '二级分类3-4'],
  };
  final Map<String, List<String>> subSubMajorMap = {
    '二级分类1-1': ['三级分类1-1-1', '三级分类1-1-2'],
    '二级分类1-2': ['三级分类1-2-1', '三级分类1-2-2'],
    '二级分类2-1': ['三级分类2-1-1', '三级分类2-1-2'],
    '二级分类2-2': ['三级分类2-2-1', '三级分类2-2-2'],
    '二级分类3-1': ['三级分类3-1-1', '三级分类3-1-2'],
    '二级分类3-2': ['三级分类3-2-1', '三级分类3-2-2'],
    '二级分类3-3': ['三级分类3-3-1', '三级分类3-3-2'],
    '二级分类3-4': ['三级分类3-4-1', '三级分类3-4-2'],
  };

  final ValueNotifier<String?> selectedMajor = ValueNotifier('全部专业');
  final ValueNotifier<String?> selectedSubMajor = ValueNotifier(null);
  final ValueNotifier<String?> selectedSubSubMajor = ValueNotifier(null);

  void applyFilters() {
    // 这里可以添加应用过滤逻辑
    print('Selected Major: ${selectedMajor.value}');
    print('Selected Sub Major: ${selectedSubMajor.value}');
    print('Selected Sub Sub Major: ${selectedSubSubMajor.value}');
  }

  void find(int size, int page) {
    this.size = size;
    this.page = page;
    list.clear();
    loading.value = true;
    TopicApi.topicList(params: {
      "size": size,
      "page": page,
    }).then((value) async {
      total.value = value["total"];
      list.addAll((value["list"] as List<dynamic>).toListMap());
      list.refresh();
      print('topic Data loaded: ${list}');
      await Future.delayed(const Duration(milliseconds: 300));
      loading.value = false;
    });
  }

  var columns = <ColumnData>[];

  @override
  void onInit() {
    super.onInit();
    columns = [
      ColumnData(title: "问题ID", key: "id", width: 80),
      ColumnData(title: "问题内容", key: "topic_text"),
      ColumnData(title: "答案", key: "answer"),
      ColumnData(title: "专业ID", key: "specialty_id"),
      ColumnData(title: "问题类型", key: "topic_type"),
      ColumnData(title: "录入人", key: "entry_person"),
      ColumnData(title: "创建时间", key: "created_time"),
    ];
  }

  var form = FormDto(labelWidth: 80, columns: [
    FormColumnDto(
      label: "问题内容",
      key: "topic_text",
      placeholder: "请输入问题内容",
    ),
    FormColumnDto(
      label: "答案",
      key: "answer",
      placeholder: "请输入答案",
    ),
    FormColumnDto(
      label: "专业ID",
      key: "specialty_id",
      placeholder: "请输入专业ID",
    ),
    FormColumnDto(
      label: "问题类型",
      key: "topic_type",
      placeholder: "请选择问题类型",
      type: FormColumnEnum.select,
      options: [
        {"label": "简答题", "value": "简答题"},
        {"label": "选择题", "value": "选择题"},
        {"label": "判断题", "value": "判断题"},
      ],
    ),
    FormColumnDto(
      label: "录入人",
      key: "entry_person",
      placeholder: "请输入录入人",
    ),
  ]);

  void add() {
    form.add(
        reset: true,
        submit: (data) => {
          TopicApi.topicCreate(params: data).then((value) {
            "创建成功!".toHint();
            find(size, page);
            Get.back();
          }).catchError((error) {
            "创建失败: $error".toHint();
          })
        });
  }

  void edit(Map<String, dynamic> topic) {
    currentEditTopic.value = RxMap<String, dynamic>(topic);
    Get.dialog(EditTopicDialog());
  }

  void submitEdit() async {
    try {
      loading.value = true;
      await TopicApi.topicUpdate(params: currentEditTopic.value);
      find(size, page);
      Get.back(); // 关闭对话框
      "更新成功!".toHint();
    } catch (e) {
      "更新失败: $e".toHint();
    } finally {
      loading.value = false;
    }
  }

  void modify(Map<String, dynamic> d, int index) {
    form.data = d;
    form.edit(
        submit: (data) => {
          TopicApi.topicUpdate(params: data).then((value) {
            "更新成功!".toHint();
            list.removeAt(index);
            list.insert(index, data);
            Get.back();
          }).catchError((error) {
            "更新失败: $error".toHint();
          })
        });
  }

  void delete(Map<String, dynamic> d, int index) {
    TopicApi.topicDelete(id: d["id"].toString()).then((value) {
      list.removeAt(index);
    }).catchError((error) {
      "删除失败: $error".toHint();
    });
  }

  void search(String key) {
    TopicApi.topicList(params: {"key": key}).then((value) {
      refresh();
    }).catchError((error) {
      "搜索失败: $error".toHint();
    });
  }

  void refresh() {
    find(size, page);
  }

  Future<void> exportCurrentPageToCSV() async {
    final directory = await FilePicker.platform.getDirectoryPath();
    if (directory == null) return;

    List<List<dynamic>> rows = [];
    rows.add(columns.map((column) => column.title).toList());

    for (var item in list) {
      rows.add(columns.map((column) => item[column.key]).toList());
    }

    String csv = const ListToCsvConverter().convert(rows);
    File('$directory/topics_current_page.csv').writeAsStringSync(csv);
    "导出当前页成功!".toHint();
  }

  Future<void> exportAllToCSV() async {
    final directory = await FilePicker.platform.getDirectoryPath();
    if (directory == null) return;

    List<Map<String, dynamic>> allItems = [];
    int currentPage = 1;
    int pageSize = 100;

    while (true) {
      var response = await TopicApi.topicList(params: {
        "size": pageSize,
        "page": currentPage,
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
    File('$directory/topics_all_pages.csv').writeAsStringSync(csv);
    "导出全部成功!".toHint();
  }

  void importFromCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result != null) {
      PlatformFile file = result.files.first;
      String content = utf8.decode(file.bytes!);

      List<List<dynamic>> rows = const CsvToListConverter().convert(content);
      rows.removeAt(0); // 移除表头

      for (var row in rows) {
        Map<String, dynamic> data = {};
        for (int i = 0; i < columns.length; i++) {
          data[columns[i].key] = row[i];
        }
        TopicApi.topicBatchImport(params: {"file": file.bytes}).then((value) {
          "导入成功!".toHint();
          find(size, page);
        }).catchError((error) {
          "导入失败: $error".toHint();
        });
      }
    }
  }

  void batchDelete(List<int> ids) {
    List<String> idsStr = ids.map((id) => id.toString()).toList();
    TopicApi.topicDelete(id: idsStr.join(",")).then((value) {
      "批量删除成功!".toHint();
      refresh();
    }).catchError((error) {
      "批量删除失败: $error".toHint();
    });
  }

  void toggleSelectAll() {
    if (selectedRows.length == list.length) {
      selectedRows.clear();
    } else {
      selectedRows.addAll(list.map((item) => item['id']));
    }
  }

  void toggleSelect(int index) {
    if (selectedRows.contains(index)) {
      selectedRows.remove(index);
    } else {
      selectedRows.add(index);
    }
  }
}
