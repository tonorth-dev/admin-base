import 'package:admin_flutter/ex/ex_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:admin_flutter/api/topic_api.dart';
import 'package:admin_flutter/ex/ex_hint.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:admin_flutter/component/form/enum.dart';
import 'package:admin_flutter/component/form/form_data.dart';
import 'package:admin_flutter/component/dialog.dart';
import 'package:admin_flutter/sources/form/topic_add_form.dart';
import '../../../../api/major_api.dart';
import '../../../../component/pagination/logic.dart';
import '../../../../component/table/table_data.dart';
import 'edit_topic_dialog.dart';

class TopicLogic extends GetxController {
  var list = <Map<String, dynamic>>[].obs;
  var total = 0.obs;
  var size = 15.obs;
  var page = 1.obs;
  var loading = false.obs;
  final searchText = ''.obs;

  // 当前编辑的题目数据
  var currentEditTopic = RxMap<String, dynamic>({}).obs;
  RxList<int> selectedRows = <int>[].obs;
  Rx<String?> selectedTopicType = '全部题型'.obs;
  List<String> topicTypeList = ['全部题型', '专业知识', '求职动机', '适岗能力'];  // 根据实际情况填充

  final List<String> majorList = ['全部专业'];
  final Map<String, List<String>> subMajorMap = {'全部专业': []};
  final Map<String, List<String>> subSubMajorMap = {};

  void fetchMajors() async {
    try {
      var response = await MajorApi.majorList(params: {'size': 3000, 'page': 1});
      if (response != null && response["total"] > 0) {
        var dataList = response["list"] as List<dynamic>;

        // 清空数据以避免重复
        majorList.clear();
        majorList.add('全部专业');
        subMajorMap.clear();
        subMajorMap['全部专业'] = [];
        subSubMajorMap.clear();

        for (var item in dataList) {
          String firstLevel = item["first_level_category"];
          String secondLevel = item["second_level_category"];
          String thirdLevel = item["major_name"];

          // 添加一级类目
          if (!majorList.contains(firstLevel)) {
            majorList.add(firstLevel);
            subMajorMap[firstLevel] = [];
          }

          // 检查并添加二级类目
          if (!subMajorMap[firstLevel]!.contains(secondLevel)) {
            subMajorMap[firstLevel]!.add(secondLevel);
            subSubMajorMap[secondLevel] = []; // 初始化三级类目列表
          }

          // 检查并添加三级类目
          if (!subSubMajorMap[secondLevel]!.contains(thirdLevel)) {
            subSubMajorMap[secondLevel]!.add(thirdLevel);
          }
        }
      } else {
        "获取专业列表失败".toHint();
      }
    } catch (e) {
      "获取专业列表失败: $e".toHint();
    }
  }

  void applyFilters() {
    // 这里可以添加应用过滤逻辑
    // print('Selected Major: ${selectedMajor.value}');
    // print('Selected Sub Major: ${selectedSubMajor.value}');
    // print('Selected Sub Sub Major: ${selectedSubSubMajor.value}');
  }

  void find(int newSize, int newPage) {
    size.value = newSize;
    page.value = newPage;
    list.clear();
    loading.value = true;
    // 打印调用堆栈
    try {
      TopicApi.topicList({
        "size": size.value.toString(),
        "page": page.value.toString(),
        "search": searchText.value,
        "cate": selectedTopicType.value.toString(),
      }).then((value) async {
        if (value != null) {
          total.value = value["total"] ?? 0;
          list.addAll((value["list"] as List<dynamic>).toListMap());
          await Future.delayed(const Duration(milliseconds: 300));
          loading.value = false;

          // 更新 PaginationLogic 的总条数
          final paginationLogic = Get.find<PaginationLogic>();
          paginationLogic.updateTotal(total.value);
        } else {
          loading.value = false;
          "获取题库列表失败: 服务器返回为空".toHint();
        }
      }).catchError((error) {
        loading.value = false;
        "获取题库列表失败: $error".toHint();
      });
    } catch (e) {
      loading.value = false;
      "获取题库列表失败: $e".toHint();
    }
  }

  var columns = <ColumnData>[];

  @override
  void onInit() {
    super.onInit();
    fetchMajors(); // Fetch and populate major data on initialization

    columns = [
      ColumnData(title: "ID", key: "id", width: 80),
      ColumnData(title: "题型", key: "cate"),
      ColumnData(title: "题干", key: "title"),
      ColumnData(title: "答案", key: "answer"),
      ColumnData(title: "专业ID", key: "major_id"),
      ColumnData(title: "专业名称", key: "major_name"),
      ColumnData(title: "录入人", key: "author"),
      ColumnData(title: "创建时间", key: "create_time"),
      ColumnData(title: "更新时间", key: "update_time"),
    ];

    // 初始化数据
    // find(size.value, page.value);
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

  void add(BuildContext context) {
    DynamicInputDialog.show(
      context: context,
      title: '录入试题',
      child: TopicAddForm(),
      onSubmit: (formData) {
        print('提交的数据: $formData');
      },
    );
  }

  void edit(Map<String, dynamic> topic) {
    currentEditTopic.value = RxMap<String, dynamic>(topic);
    Get.dialog(EditTopicDialog());
  }

  void submitEdit() async {
    try {
      loading.value = true;
      await TopicApi.topicUpdate(
        id: currentEditTopic.value['id'].toString(),
        title: currentEditTopic.value['title'] ?? '',
        content: currentEditTopic.value['content'] ?? '',
        category: currentEditTopic.value['category'] ?? '',
        difficulty: currentEditTopic.value['difficulty']?.toInt() ?? 0,
        options: currentEditTopic.value['options']?.cast<String>() ?? [],
        answer: currentEditTopic.value['answer'] ?? '',
      );
      find(size.value, page.value);
      Get.back(); // 关闭对话框
      "更新成功!".toHint();
    } catch (e) {
      "更新失败: $e".toHint();
    } finally {
      loading.value = false;
    }
  }

  void delete(Map<String, dynamic> d, int index) {
    try {
      TopicApi.topicDelete(d["id"].toString()).then((value) {
        list.removeAt(index);
      }).catchError((error) {
        "删除失败: $error".toHint();
      });
    } catch (e) {
      "删除失败: $e".toHint();
    }
  }

  void search(String key) {
    try {
      TopicApi.topicList({"search": key}).then((value) {
        refresh();
      }).catchError((error) {
        "搜索失败: $error".toHint();
      });
    } catch (e) {
      "搜索失败: $e".toHint();
    }
  }

  @override
  void refresh() {
    find(size.value, page.value);
  }

  Future<void> exportCurrentPageToCSV() async {
    try {
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
    } catch (e) {
      "导出当前页失败: $e".toHint();
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
        var response = await TopicApi.topicList({
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
      File('$directory/topics_all_pages.csv').writeAsStringSync(csv);
      "导出全部成功!".toHint();
    } catch (e) {
      "导出全部失败: $e".toHint();
    }
  }

  void importFromCSV() async {
    try {
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
          await TopicApi.topicBatchImport(File.fromRawPath(file.bytes!)).then((value) {
            "导入成功!".toHint();
            refresh();
          }).catchError((error) {
            "导入失败: $error".toHint();
          });
        }
      }
    } catch (e) {
      "导入失败: $e".toHint();
    }
  }

  void batchDelete(List<int> ids) {
    try {
      List<String> idsStr = ids.map((id) => id.toString()).toList();
      TopicApi.topicDelete(idsStr.join(",")).then((value) {
        "批量删除成功!".toHint();
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

  void resetFilters() {
    selectedTopicType.value = '';
    searchText.value = '';
    // 重置其他筛选条件
    // 例如：重置专业选择
    // majorSelected.value = null;
    // subMajorSelected.value = null;
    // subSubMajorSelected.value = null;

    // 重新查询
    find(page.value, size.value);
  }
}
