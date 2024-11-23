import 'package:admin_flutter/app/home/pages/book/book.dart';
import 'package:admin_flutter/ex/ex_list.dart';
import 'package:admin_flutter/ex/ex_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:intl/intl.dart';
import '../../../../api/config_api.dart';
import '../../../../api/major_api.dart';
import '../../../../component/pagination/logic.dart';
import '../../../../component/table/table_data.dart';
import '../../../../component/widget.dart';
import '../../config/logic.dart';
import 'topic_add_form.dart';
import 'edit_topic_dialog.dart';

class TopicLogic extends GetxController {
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

  // 当前编辑的题目数据
  var currentEditTopic = RxMap<String, dynamic>({}).obs;
  RxList<int> selectedRows = <int>[].obs;

  Rx<String?> selectedQuestionCate = '全部题型'.obs;
  Rx<String?> selectedQuestionLevel = '全部难度'.obs;
  RxList<Map<String, dynamic>> questionCate = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> questionLevel = <Map<String, dynamic>>[].obs;

  // 专业列表数据
  List<Map<String, dynamic>> majorList = [];
  Map<String, List<Map<String, dynamic>>> subMajorMap = {};
  Map<String, List<Map<String, dynamic>>> subSubMajorMap = {};
  List<Map<String, dynamic>> level1Items = [];
  Map<String, List<Map<String, dynamic>>> level2Items = {};
  Map<String, List<Map<String, dynamic>>> level3Items = {};
  Rx<String> selectedMajorId = "0".obs;

  final topicTitle = ''.obs;
  final topicSelectedQuestionCate = "".obs;
  final topicSelectedQuestionLevel = "".obs;
  final topicSelectedMajorId = "".obs;
  final topicAnswer = "".obs;
  final topicAuthor = "".obs;
  final topicTag = "".obs;
  final topicStatus = 0.obs;

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
          if (!subMajorMap[firstLevelId]!
              .any((m) => m['name'] == secondLevelName)) {
            subMajorMap[firstLevelId]!
                .add({'id': secondLevelId, 'name': secondLevelName});
            level2Items[firstLevelId]
                ?.add({'id': secondLevelId, 'name': secondLevelName});
            subSubMajorMap[secondLevelId] = [];
            level3Items[secondLevelId] = [];
          }

          // Add third-level major if it doesn't exist under this second-level category
          if (!subSubMajorMap[secondLevelId]!
              .any((m) => m['name'] == thirdLevelName)) {
            subSubMajorMap[secondLevelId]!
                .add({'id': thirdLevelId, 'name': thirdLevelName});
            level3Items[secondLevelId]
                ?.add({'id': thirdLevelId, 'name': thirdLevelName});
          }
        }

        // Debug output
        print('majorList: $majorList');
        print('subMajorMap: $subMajorMap');
        print('subSubMajorMap: $subSubMajorMap');
        print('level1Items: $level1Items');
        print('level2Items: $level2Items');
        print('level3Items: $level3Items');
      } else {
        "获取专业列表失败".toHint();
      }
    } catch (e) {
      "获取专业列表失败: $e".toHint();
    }
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
        "keyword": searchText.value.toString() ?? "",
        "cate": getSelectedCateId() ?? "",
        "level": getSelectedLevelId() ?? "",
        "major_id": (selectedMajorId.value?.toString() ?? ""),
      }).then((value) async {
        if (value != null && value["list"] != null) {
          total.value = value["total"] ?? 0;
          list.addAll((value["list"] as List<dynamic>).toListMap());
          await Future.delayed(const Duration(milliseconds: 300));
          loading.value = false;

          // 更新 PaginationLogic 的总条数
          final paginationLogic = Get.find<PaginationLogic>();
          paginationLogic.updateTotal(total.value);
        } else {
          loading.value = false;
          "未获取到题库数据".toHint();
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
      ColumnData(title: "题型", key: "cate_name"),
      ColumnData(title: "难度", key: "level_name"),
      ColumnData(title: "题干", key: "title"),
      ColumnData(title: "答案", key: "answer"),
      ColumnData(title: "专业ID", key: "major_id"),
      ColumnData(title: "专业名称", key: "major_name"),
      ColumnData(title: "标签", key: "tag"),
      ColumnData(title: "录入人", key: "author"),
      ColumnData(title: "状态", key: "status_name"),
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

  Future<bool> saveTopic() async {
    // 生成题本的逻辑
    final topicTitleSubmit = topicTitle.value;
    final int? topicSelectedMajorIdSubmit =
        int.tryParse(topicSelectedMajorId.value);
    final topicSelectedQuestionCateSubmit = topicSelectedQuestionCate.value;
    final topicSelectedQuestionLevelSubmit = topicSelectedQuestionLevel.value;
    final topicAnswerSubmit = topicAnswer.value;
    final topicAuthorSubmit = topicAuthor.value;
    final topicTagSubmit = topicTag.value;
    final topicStatusSubmit = topicStatus.value;

    print("生成问题：");
    print("题干: $topicTitleSubmit");
    print("选择题型: $topicSelectedQuestionCateSubmit");
    print("选择难度: $topicSelectedQuestionLevelSubmit");
    print("选择专业: $topicSelectedMajorIdSubmit");
    print("问题答案: $topicAnswerSubmit");
    print("作者: $topicAuthorSubmit");
    print("标签: $topicTagSubmit");
    print("状态: $topicStatusSubmit");

    bool isValid = true;
    String errorMessage = "";

    if (topicTitleSubmit.isEmpty) {
      isValid = false;
      errorMessage += "问题提干不能为空\n";
    }
    if (topicSelectedMajorIdSubmit == null || topicSelectedMajorIdSubmit <= 0) {
      isValid = false;
      errorMessage += "请选择专业\n";
    }
    if (topicSelectedQuestionCateSubmit.isEmpty) {
      isValid = false;
      errorMessage += "请选择题型\n";
    }
    if (topicSelectedQuestionLevelSubmit.isEmpty) {
      isValid = false;
      errorMessage += "请选择难度\n";
    }
    if (topicAnswerSubmit.isEmpty) {
      isValid = false;
      errorMessage += "请填入问题答案\n";
    }
    if (topicStatusSubmit == 0) {
      isValid = false;
      errorMessage += "请选择问题状态\n";
    }

    if (isValid) {
      // 提交表单
      print("生成问题：");
      print("题干: $topicTitleSubmit");
      print("选择题型: $topicSelectedQuestionCateSubmit");
      print("选择难度: $topicSelectedQuestionLevelSubmit");
      print("选择专业: $topicSelectedMajorIdSubmit");
      print("问题答案: $topicAnswerSubmit");
      print("作者: $topicAuthorSubmit");
      print("标签: $topicTagSubmit");
      try {
        Map<String, dynamic> params = {
          "title": topicTitleSubmit,
          "cate": topicSelectedQuestionCateSubmit,
          "level": topicSelectedQuestionLevelSubmit,
          "answer": topicAnswerSubmit,
          "author": "杜立东",
          "major_id": topicSelectedMajorIdSubmit,
          "tag": topicTagSubmit,
          "status": topicStatusSubmit,
        };

        dynamic result = await TopicApi.topicCreate(params);
        print(result['id']);
        if (result['id'] > 0) {
          "创建试题成功".toHint();
          return true;
        } else {
          "创建试题失败".toHint();
          return false;
        }
      } catch (e) {
        print('Error: $e');
        "创建试题时发生错误".toHint();
        return false;
      }
    } else {
      // 显示错误提示
      errorMessage.toHint();
      return false;
    }
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

  // void search(String key) {
  //   try {
  //     TopicApi.topicList({"search": key}).then((value) {
  //       refresh();
  //     }).catchError((error) {
  //       "搜索失败: $error".toHint();
  //     });
  //   } catch (e) {
  //     "搜索失败: $e".toHint();
  //   }
  // }

  @override
  void refresh() {
    find(size.value, page.value);
  }

  // 导出选中项到 CSV 文件
  Future<void> exportSelectedItemsToCSV() async {
    try {
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
      File('$directory/topics_selected_$formattedDate.csv')
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
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
      if (result != null) {
        PlatformFile file = result.files.first;
        String content;

        // 使用文件路径读取内容
        if (file.path != null) {
          content = await File(file.path!).readAsString(encoding: utf8);

          // 检查文件内容是否为空
          if (content.isEmpty) {
            "文件内容为空".toHint();
            return;
          }

          // 检查 BOM 并移除
          if (content.startsWith('\uFEFF')) {
            content = content.substring(1);
          }

          // 解析 CSV 内容
          List<List<dynamic>> rows = const CsvToListConverter().convert(content);
          rows.removeAt(0); // 移除表头

          // 调用 API 执行批量导入
          await TopicApi.topicBatchImport(File(file.path!))
              .then((value) {
            "导入成功!".toHint();
            refresh();
          }).catchError((error) {
            "导入失败: $error".toHint();
          });
        } else {
          "文件路径为空，无法读取文件".toHint();
        }
      } else {
        "没有选择文件".toHint();
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
    cateDropdownKey.currentState?.reset();
    levelDropdownKey.currentState?.reset();
    searchText.value = '';
    selectedRows.clear();

    // 重新初始化数据
    fetchConfigs();
    fetchMajors();
    find(size.value, page.value);
  }
}
