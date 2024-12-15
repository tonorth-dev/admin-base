import 'dart:io';

import 'package:admin_flutter/ex/ex_list.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_flutter/api/lecture_api.dart';
import 'package:admin_flutter/ex/ex_hint.dart';
import 'package:admin_flutter/component/dialog.dart';
import '../../../../api/major_api.dart';
import '../../../../component/table/table_data.dart';
import '../../../../component/widget.dart';
import 'lecture_add_form.dart';
import 'lecture_edit_form.dart';

class LectureLogic extends GetxController {
  var list = <Map<String, dynamic>>[].obs;
  var total = 0.obs;
  var size = 15.obs;
  var page = 1.obs;
  var loading = false.obs;
  final searchText = ''.obs;
  final RxString selectedKey = ''.obs; // 初始化为空字符串
  final RxList<String> expandedKeys = <String>[].obs;

  final RxString selectedLectureId = '0'.obs; // To track which lecture's directory we are viewing
  final RxList<DirectoryNode> directoryTree = RxList<DirectoryNode>([]);

  var isLoading = false.obs;


  final GlobalKey<CascadingDropdownFieldState> majorDropdownKey =
      GlobalKey<CascadingDropdownFieldState>();

  // 当前编辑的题目数据
  var currentEditLecture = RxMap<String, dynamic>({}).obs;
  RxList<int> selectedRows = <int>[].obs;

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

  final lectureId = 0.obs; // 对应 ID
  final lectureName = ''.obs; // 对应 Name
  final majorId = 0.obs; // 对应 MajorID
  final jobCode = 0.obs; // 对应 JobCode
  final sort = 0.obs; // 对应 Sort
  final creator = ''.obs; // 对应 Creator
  final lectureCategory = ''.obs; // 对应 Category
  final pageCount = 0.obs; // 对应 PageCount
  final status = 0.obs; // 对应 Status

  final uLectureId = 0.obs; // 对应 ID
  final uLectureName = ''.obs; // 对应 Name
  final uMajorId = 0.obs; // 对应 MajorID
  final uJobCode = 0.obs; // 对应 JobCode
  final uSort = 0.obs; // 对应 Sort
  final uCreator = ''.obs; // 对应 Creator
  final uLectureCategory = ''.obs; // 对应 Category
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
      LectureApi.lectureList({
        "size": size.value.toString(),
        "page": page.value.toString(),
        "keyword": searchText.value.toString() ?? "",
        "major_id": (selectedMajorId.value.toString() ?? ""),
      }).then((value) async {
        if (value != null && value["list"] != null) {
          total.value = value["total"] ?? 0;
          list.assignAll((value["list"] as List<dynamic>).toListMap());
          await Future.delayed(const Duration(milliseconds: 300));
          loading.value = false;
        } else {
          loading.value = false;
          "未获取到讲义数据".toHint();
        }
      }).catchError((error) {
        loading.value = false;
        print("获取讲义列表失败: $error");
        "获取讲义列表失败: $error".toHint();
      });
    } catch (e) {
      loading.value = false;
      print("获取讲义列表失败: $e");
      "获取讲义列表失败: $e".toHint();
    }
  }

  var columns = <ColumnData>[];

  @override
  void onInit() {
    super.onInit();// Fetch and populate major data on initialization

    columns = [
      ColumnData(title: "ID", key: "id", width: 80),
      ColumnData(title: "讲义名称", key: "name", width:100),
      ColumnData(title: "专业", key: "major_id", width:100),
      ColumnData(title: "讲义编码", key: "job_code", width:100),
      ColumnData(title: "排序", key: "sort", width:50),
      ColumnData(title: "创建者", key: "creator"),
      ColumnData(title: "讲义类别", key: "category"),
      ColumnData(title: "大小", key: "size"),
      ColumnData(title: "页数", key: "pagecount"),
      ColumnData(title: "状态", key: "status"),
      ColumnData(title: "创建时间", key: "created_time"),
    ];

    // 初始化数据
    // find(size.value, page.value);
  }

  void add(BuildContext context) {
    DynamicInputDialog.show(
      context: context,
      title: '录入讲义',
      child: LectureAddForm(),
      onSubmit: (formData) {
        print('提交的数据: $formData');
      },
    );
  }

  void edit(BuildContext context, Map<String, dynamic> lecture) {
    currentEditLecture.value = RxMap<String, dynamic>(lecture);

    DynamicInputDialog.show(
      context: context,
      title: '录入讲义',
      child: LectureEditForm(
        lectureId: lecture["id"],
        lectureName: lecture["name"],
        majorId: lecture["major_id"], // 假设 major_id 是存在的
        jobCode: lecture["job_code"], // 假设 job_code 是存在的
        sort: lecture["sort"], // 假设 sort 是存在的
        creator: lecture["creator"], // 假设 creator 是存在的
        lectureCategory: lecture["category"], // 假设 category 是存在的
        pageCount: lecture["page_count"], // 假设 page_count 是存在的
        status: lecture["status"], // 假设 status 是存在的
      ),
      onSubmit: (formData) {
        print('提交的数据: $formData');
        // 处理新的字段
        final updatedLecture = {
          "id": formData['lectureId'],
          "name": formData['lectureName'],
          "major_id": formData['majorId'],
          "job_code": formData['jobCode'],
          "sort": formData['sort'],
          "creator": formData['creator'],
          "category": formData['lectureCategory'],
          "page_count": formData['pageCount'],
          "status": formData['status'],
        };
        print('更新后的讲义数据: $updatedLecture');
      },
    );
  }

  Future<bool> saveLecture() async {
    // 生成题本的逻辑
    final lectureNameSubmit = lectureName.value;
    final majorIdSubmit = majorId.value;
    final jobCodeSubmit = jobCode.value;
    final sortSubmit = sort.value;
    final creatorSubmit = creator.value;
    final lectureCategorySubmit = lectureCategory.value;
    final sizeSubmit = size.value;
    final pageCountSubmit = pageCount.value;
    final statusSubmit = status.value;

    bool isValid = true;
    String errorMessage = "";

    if (lectureNameSubmit.isEmpty) {
      isValid = false;
      errorMessage += "职位名称不能为空\n";
    }
    if (majorIdSubmit <= 0) {
      isValid = false;
      errorMessage += "专业ID必须大于0\n";
    }
    if (jobCodeSubmit <= 0) {
      isValid = false;
      errorMessage += "工作代码必须大于0\n";
    }
    if (sortSubmit <= 0) {
      isValid = false;
      errorMessage += "排序必须大于0\n";
    }
    if (creatorSubmit.isEmpty) {
      isValid = false;
      errorMessage += "创建者不能为空\n";
    }
    if (lectureCategorySubmit.isEmpty) {
      isValid = false;
      errorMessage += "职位类别不能为空\n";
    }
    if (sizeSubmit <= 0) {
      isValid = false;
      errorMessage += "大小必须大于0\n";
    }
    if (pageCountSubmit <= 0) {
      isValid = false;
      errorMessage += "页数必须大于0\n";
    }
    if (statusSubmit <= 0) {
      isValid = false;
      errorMessage += "状态必须大于0\n";
    }

    if (isValid) {
      try {
        Map<String, dynamic> params = {
          "name": lectureNameSubmit,
          "major_id": majorIdSubmit,
          "job_code": jobCodeSubmit,
          "sort": sortSubmit,
          "creator": creatorSubmit,
          "category": lectureCategorySubmit,
          "size": sizeSubmit,
          "pagecount": pageCountSubmit,
          "status": statusSubmit,
        };

        dynamic result = await LectureApi.lectureCreate(params);
        if (result['id'] > 0) {
          "创建职位成功".toHint();
          return true;
        } else {
          "创建职位失败".toHint();
          return false;
        }
      } catch (e) {
        print('Error: $e');
        "创建职位时发生错误：$e".toHint();
        return false;
      }
    } else {
      // 显示错误提示
      errorMessage.toHint();
      return false;
    }
  }

  Future<bool> updateLecture(int lectureId) async {
    // 生成职位的逻辑
    final lectureNameSubmit = uLectureName.value;
    final majorIdSubmit = uMajorId.value;
    final jobCodeSubmit = uJobCode.value;
    final sortSubmit = uSort.value;
    final creatorSubmit = uCreator.value;
    final lectureCategorySubmit = uLectureCategory.value;
    final pageCountSubmit = uPageCount.value;
    final statusSubmit = uStatus.value;

    bool isValid = true;
    String errorMessage = "";

    if (lectureNameSubmit.isEmpty) {
      isValid = false;
      errorMessage += "职位名称不能为空\n";
    }
    if (majorIdSubmit <= 0) {
      isValid = false;
      errorMessage += "专业ID必须大于0\n";
    }
    if (jobCodeSubmit <= 0) {
      isValid = false;
      errorMessage += "工作代码必须大于0\n";
    }
    if (sortSubmit <= 0) {
      isValid = false;
      errorMessage += "排序必须大于0\n";
    }
    if (creatorSubmit.isEmpty) {
      isValid = false;
      errorMessage += "创建者不能为空\n";
    }
    if (lectureCategorySubmit.isEmpty) {
      isValid = false;
      errorMessage += "职位类别不能为空\n";
    }
    if (pageCountSubmit <= 0) {
      isValid = false;
      errorMessage += "页数必须大于0\n";
    }
    if (statusSubmit <= 0) {
      isValid = false;
      errorMessage += "状态必须大于0\n";
    }

    if (isValid) {
      try {
        Map<String, dynamic> params = {
          "name": lectureNameSubmit,
          "major_id": majorIdSubmit,
          "job_code": jobCodeSubmit,
          "sort": sortSubmit,
          "creator": creatorSubmit,
          "category": lectureCategorySubmit,
          "pagecount": pageCountSubmit,
          "status": statusSubmit,
        };

        print("提交的数据：$params");
        dynamic result = await LectureApi.lectureUpdate(lectureId, params);
        "更新职位成功".toHint();
        return true;
      } catch (e) {
        print('Error: $e');
        "更新职位时发生错误：$e".toHint();
        return false;
      }
    } else {
      // 显示错误提示
      errorMessage.toHint();
      return false;
    }
  }


  @override
  void refresh() {
    find(size.value, page.value);
  }

  void delete(Map<String, dynamic> d, int index) {
    try {
      LectureApi.lectureDelete(d["id"]).then((value) {
        list.removeAt(index);
      }).catchError((error) {
        "删除失败: $error".toHint();
      });
    } catch (e) {
      "删除失败: $e".toHint();
    }
  }

  void deleteDirectory(int id) {
    try {
      LectureApi.deleteDirectory(id.toString()).then((value) {
        loadDirectoryTree(selectedLectureId.value, true);
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
        "请先选择要删除的讲义".toHint();
        return;
      }
      LectureApi.lectureDelete(idsStr.join(",")).then((value) {
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

  void addNewDirectory(String name, int parentId) async {
    try {
      await LectureApi.addDirectory(selectedLectureId.value, {
        'parent_id': parentId,
        'name': name,
      });
      loadDirectoryTree(selectedLectureId.value, true); // Refresh the directory tree
    } catch (e) {
      print("Failed to add directory: $e");
      // Handle error
    }
  }

  void loadDirectoryTree(String lectureId, bool isRefresh) async {
    if(selectedLectureId.value == lectureId && !isRefresh) {
      return; // No need to reload if the selected lecture hasn't changed'
    }

    selectedLectureId.value = lectureId;
    try {
      final treeData = await LectureApi.getLectureDirectoryTree(lectureId);
      print(treeData);
      directoryTree.value = _buildTreeFromAPIResponse(treeData);
      updatePdfUrl("");
    } catch (e) {
      print("Failed to load directory tree: $e");
      // Handle error, possibly show to user or log
    }
  }

  List<DirectoryNode> _buildTreeFromAPIResponse(dynamic data) {
    // 转换为 Map，以 id 为键
    final Map<int, DirectoryNode> nodeMap = {
      for (var item in data)
        item['id']: DirectoryNode.fromJson(item),
    };

    final List<DirectoryNode> tree = [];

    for (var node in nodeMap.values) {
      if (node.parentId != null && nodeMap.containsKey(node.parentId)) {
        // 如果有父节点，加入父节点的 children
        nodeMap[node.parentId]?.children.add(node);
      } else {
        // 如果没有父节点，说明是根节点
        tree.add(node);
      }
    }

    return tree;
  }

  void importFileToNode(File file, int nodeId) async {
    try {
      await LectureApi.importFileToNode(nodeId, file);
      loadDirectoryTree(selectedLectureId.value, true); // Refresh the directory tree after import
    } catch (e) {
      print("Failed to import file: $e");
      // Handle error
    }
  }

Future<void> importFileToDir(File file, int lectureId, int nodeId) async {
    isLoading.value = true; // 操作开始前设置 isLoading 为 true
    try {
      await LectureApi.importFileToDir(lectureId, nodeId, file);
    } catch (e) {
      // 处理错误
      print('Error importing file to directory: $e');
    } finally {
      isLoading.value = false; // 操作完成后设置 isLoading 为 false
    }
  }

  final selectedPdfUrl = RxnString("");

  void updatePdfUrl(String url) {
    if(url.isEmpty) {
      selectedPdfUrl.value = "";
      debugPrint('Selected PDF URL updated: ${selectedPdfUrl.value}');
      return;
    }
    if (selectedPdfUrl.value != "http://127.0.0.1:9000/hongshi$url") {
      selectedPdfUrl.value = "http://127.0.0.1:9000/hongshi$url";
      debugPrint('Selected PDF URL updated: ${selectedPdfUrl.value}');
    }
  }
}


class DirectoryNode {
  final int id;
  final int? parentId;
  final int level;
  final String name;
  final String? filePath;
  RxList<DirectoryNode> children;

  DirectoryNode({required this.id, this.parentId, required this.level, required this.name, this.filePath, List<DirectoryNode>? children})
      : children = RxList(children ?? []);

  factory DirectoryNode.fromJson(Map<String, dynamic> json) {
    return DirectoryNode(
      id: json['id'],
      parentId: json['parent_id'],
      level: json['level'],
      name: json['name'],
      filePath: json['file_path'],
      children: (json['children'] as List<dynamic>?)
          ?.map((child) => DirectoryNode.fromJson(child))
          .toList() ?? [],
    );
  }
}
