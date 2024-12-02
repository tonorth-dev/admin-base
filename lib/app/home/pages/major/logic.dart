import 'package:admin_flutter/app/home/pages/book/book.dart';
import 'package:admin_flutter/ex/ex_list.dart';
import 'package:admin_flutter/ex/ex_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_flutter/api/major_api.dart';
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
import 'major_add_form.dart';
import 'major_edit_form.dart';

class MajorLogic extends GetxController {
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
  var currentEditMajor = RxMap<String, dynamic>({}).obs;
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
  Rx<String> selectedMajorId = "0".obs;

  final majorTitle = ''.obs;
  ValueNotifier<String?> majorSelectedQuestionCate = ValueNotifier<String?>(null);
  ValueNotifier<String?> majorSelectedQuestionLevel = ValueNotifier<String?>(null);
  final majorSelectedMajorId = "".obs;
  final majorAnswer = "".obs;
  final majorAuthor = "".obs;
  final majorTag = "".obs;
  final majorStatus = 0.obs;

  final uMajorTitle = ''.obs;
  final uMajorSelectedQuestionCate = "".obs;
  final uMajorSelectedQuestionLevel = "".obs;
  final uMajorSelectedMajorId = "".obs;
  final uMajorAnswer = "".obs;
  final uMajorAuthor = "".obs;
  final uMajorTag = "".obs;
  final uMajorStatus = 0.obs;

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

  void find(int newSize, int newPage) {
    size.value = newSize;
    page.value = newPage;
    list.clear();
    loading.value = true;
    // 打印调用堆栈
    try {
      MajorApi.majorList().then((value) async {
        if (value != null && value["list"] != null) {
          total.value = value["total"] ?? 0;
          list.assignAll((value["list"] as List<dynamic>).toListMap());
          await Future.delayed(const Duration(milliseconds: 300));
          loading.value = false;
        } else {
          loading.value = false;
          "未获取到岗位数据".toHint();
        }
      }).catchError((error) {
        loading.value = false;
        print("获取岗位列表失败: $error");
        "获取岗位列表失败: $error".toHint();
      });
    } catch (e) {
      loading.value = false;
      print("获取岗位列表失败: $e");
      "获取岗位列表失败: $e".toHint();
    }
  }

  var columns = <ColumnData>[];

  @override
  void onInit() {
    fetchMajors(); // Fetch and populate major data on initialization
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
      ColumnData(title: "岗位编码", key: "code"),
      ColumnData(title: "岗位名称", key: "name"),
      ColumnData(title: "岗位类别", key: "cate"),
      ColumnData(title: "单位编码", key: "company_code"),
      ColumnData(title: "单位名称", key: "company_name"),
      ColumnData(title: "录取人数", key: "enrollment_num"),
      ColumnData(title: "录取比例", key: "enrollment_ratio"),
      ColumnData(title: "来源", key: "source"),
      ColumnData(title: "课程描述", key: "course_desc"),
      ColumnData(title: "城市", key: "city"),
      ColumnData(title: "专业ID", key: "major_id"),
      ColumnData(title: "专业名称", key: "major_name"),
      ColumnData(title: "扩展信息", key: "ext"),
      ColumnData(title: "状态", key: "status"),
      ColumnData(title: "创建时间", key: "create_time"),
      ColumnData(title: "更新时间", key: "update_time"),
    ];

    // 初始化数据
    // find(size.value, page.value);
  }

  var form = FormDto(labelWidth: 80, columns: [
    FormColumnDto(
      label: "问题内容",
      key: "major_text",
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
      key: "major_type",
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
      child: MajorAddForm(),
      onSubmit: (formData) {
        print('提交的数据: $formData');
      },
    );
  }

  void edit(BuildContext context, Map<String, dynamic> major) {
    currentEditMajor.value = RxMap<String, dynamic>(major);
    var level2MajorId = getLevel2IdFromLevel3Id(major["major_id"].toString());
    var level3MajorId = getLevel1IdFromLevel2Id(level2MajorId);

    DynamicInputDialog.show(
      context: context,
      title: '录入试题',
      child: MajorEditForm(
          majorId: major["id"],
          initialTitle: major["title"],
          initialAnswer: major["answer"],
          initialQuestionCate: major["cate"],
          initialQuestionLevel: major["level"],
          initialLevel1MajorId: level3MajorId,
          initialLevel2MajorId: level2MajorId,
          initialMajorId: major["major_id"].toString(),
          initialAuthor: major["author"],
          initialTag: major["tag"],
          initialStatus: major["status"]),
      onSubmit: (formData) {
        print('提交的数据: $formData');
      },
    );
  }

  Future<bool> saveMajor() async {
    // 生成题本的逻辑
    final majorTitleSubmit = majorTitle.value;
    final int majorSelectedMajorIdSubmit = majorSelectedMajorId.value.toInt();
    final majorSelectedQuestionCateSubmit = majorSelectedQuestionCate.value;
    final majorSelectedQuestionLevelSubmit = majorSelectedQuestionLevel.value;
    final majorAnswerSubmit = majorAnswer.value;
    final majorAuthorSubmit = majorAuthor.value;
    final majorTagSubmit = majorTag.value;
    final majorStatusSubmit = majorStatus.value;

    bool isValid = true;
    String errorMessage = "";

    if (majorTitleSubmit.isEmpty) {
      isValid = false;
      errorMessage += "问题提干不能为空\n";
    }
    if (majorSelectedMajorIdSubmit == 0 || majorSelectedMajorIdSubmit <= 0) {
      isValid = false;
      errorMessage += "请选择专业\n";
    }
    if (majorSelectedQuestionCateSubmit == null || majorSelectedQuestionCateSubmit.isEmpty) {
      isValid = false;
      errorMessage += "请选择题型\n";
    }
    if (majorSelectedQuestionLevelSubmit == null || majorSelectedQuestionLevelSubmit.isEmpty) {
      isValid = false;
      errorMessage += "请选择难度\n";
    }
    if (majorAnswerSubmit.isEmpty && majorStatusSubmit == 2) {
      isValid = false;
      errorMessage += "完成状态下的问题，答案不能为空\n";
    }
    if (majorStatusSubmit == 0) {
      isValid = false;
      errorMessage += "请选择问题状态\n";
    }

    if (isValid) {
      try {
        Map<String, dynamic> params = {
          "title": majorTitleSubmit,
          "cate": majorSelectedQuestionCateSubmit,
          "level": majorSelectedQuestionLevelSubmit,
          "answer": majorAnswerSubmit,
          "author": "杜立东",
          "major_id": majorSelectedMajorIdSubmit,
          "tag": majorTagSubmit,
          "status": majorStatusSubmit,
        };

        dynamic result = await MajorApi.majorCreate(params);
        if (result['id'] > 0) {
          "创建试题成功".toHint();
          return true;
        } else {
          "创建试题失败".toHint();
          return false;
        }
      } catch (e) {
        print('Error: $e');
        "创建试题时发生错误：$e".toHint();
        return false;
      }
    } else {
      // 显示错误提示
      errorMessage.toHint();
      return false;
    }
  }

  Future<bool> updateMajor(int majorId) async {
    // 生成题本的逻辑
    final majorTitleSubmit = uMajorTitle.value;
    final majorSelectedMajorIdSubmit = uMajorSelectedMajorId.value.toInt();
    final majorSelectedQuestionCateSubmit = uMajorSelectedQuestionCate.value;
    final majorSelectedQuestionLevelSubmit = uMajorSelectedQuestionLevel.value;
    final majorAnswerSubmit = uMajorAnswer.value;
    final majorAuthorSubmit = uMajorAuthor.value;
    final majorTagSubmit = uMajorTag.value;
    final majorStatusSubmit = uMajorStatus.value;

    bool isValid = true;
    String errorMessage = "";

    if (majorId == 0) {
      isValid = false;
      errorMessage += "问题ID为0，请检查\n";
    }

    if (majorTitleSubmit.isEmpty) {
      isValid = false;
      errorMessage += "问题提干不能为空\n";
    }
    if (majorSelectedMajorIdSubmit <= 0) {
      isValid = false;
      errorMessage += "请选择专业\n";
    }
    if (majorSelectedQuestionCateSubmit.isEmpty) {
      isValid = false;
      errorMessage += "请选择题型\n";
    }
    if (majorSelectedQuestionLevelSubmit.isEmpty) {
      isValid = false;
      errorMessage += "请选择难度\n";
    }
    if (majorAnswerSubmit.isEmpty && majorStatusSubmit == 2) {
      isValid = false;
      errorMessage += "完成状态下的问题，答案不能为空\n";
    }
    if (majorStatusSubmit == 0) {
      isValid = false;
      errorMessage += "请选择问题状态\n";
    }

    if (isValid) {
      try {
        Map<String, dynamic> params = {
          "title": majorTitleSubmit,
          "cate": majorSelectedQuestionCateSubmit,
          "level": majorSelectedQuestionLevelSubmit,
          "answer": majorAnswerSubmit,
          "author": "杜立东",
          "major_id": majorSelectedMajorIdSubmit,
          "tag": majorTagSubmit,
          "status": majorStatusSubmit,
        };

        dynamic result = await MajorApi.majorUpdate(majorId, params);
        "更新试题成功".toHint();
        return true;
      } catch (e) {
        print('Error: $e');
        "更新试题时发生错误：$e".toHint();
        return false;
      }
    } else {
      // 显示错误提示
      errorMessage.toHint();
      return false;
    }
  }

  void delete(Map<String, dynamic> d, int index) {
    try {
      MajorApi.majorDelete(d["id"].toString()).then((value) {
        list.removeAt(index);
      }).catchError((error) {
        "删除失败: $error".toHint();
      });
    } catch (e) {
      "删除失败: $e".toHint();
    }
  }

  Future<void> audit(int majorId, int status) async {
    try {
      await MajorApi.auditMajor(majorId, status);
      "审核完成".toHint();
      find(size.value, page.value);
    } catch (e) {
      "审核失败: $e".toHint();
    }
  }

  void generateAndOpenLink(
      BuildContext context, Map<String, dynamic> item) async {
    final url =
        Uri.parse('http://localhost:8888/static/h5/?majorId=${item['id']}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('无法打开链接')));
    }
  }

  // void search(String key) {
  //   try {
  //     MajorApi.majorList({"search": key}).then((value) {
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
      File('$directory/majors_selected_$formattedDate.csv')
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
        var response = await MajorApi.majorList();

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
      File('$directory/majors_all_pages.csv').writeAsStringSync(csv);
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
          List<List<dynamic>> rows =
              const CsvToListConverter().convert(content);
          rows.removeAt(0); // 移除表头

          // 调用 API 执行批量导入
          await MajorApi.majorBatchImport(File(file.path!)).then((value) {
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
      if (idsStr.isEmpty) {
        "请先选择要删除的试题".toHint();
        return;
      }
      MajorApi.majorDelete(idsStr.join(",")).then((value) {
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
    statusDropdownKey.currentState?.reset();
    searchText.value = '';
    selectedRows.clear();

    // 重新初始化数据
    fetchMajors();
    find(size.value, page.value);
  }
}
