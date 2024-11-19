import 'package:admin_flutter/ex/ex_hint.dart';
import 'package:admin_flutter/ex/ex_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:admin_flutter/component/pagination/view.dart';
import 'package:admin_flutter/component/table/ex.dart';
import 'package:admin_flutter/app/home/sidebar/logic.dart';
import 'package:admin_flutter/component/widget.dart';
import 'package:admin_flutter/component/dialog.dart';
import '../../../../api/template_api.dart';
import 'detail.dart';
import 'logic.dart';
import 'package:admin_flutter/theme/theme_util.dart';
import 'package:provider/provider.dart';

class BookPage extends StatelessWidget {
  final logic = Get.put(BookLogic());

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ButtonState>(
      create: (_) => ButtonState(),
      child: Column(
        children: [
          Container(
            // width: 1600, // 灰色区域宽度
            height: 420, // 灰色区域高度
            color: Color(0xFFF7F7F9), // 灰色背景
            padding: EdgeInsets.all(16.0), // 内边距
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  "生成题本",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16), // 间距
                // 蓝色区域
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildInteractiveCardLeft("通过模板创建", 400, 320),
                    SizedBox(width: 40),
                    _buildInteractiveCardRight("生成题本", 1200, 320),
                  ],
                ),
              ],
            ),
          ),
          TableEx.actions(
            children: [
              SizedBox(width: 16),
              Text(
                "管理题本",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 30),
              CustomButton(
                onPressed: () => logic.batchDelete(logic.selectedRows),
                text: '批量删除',
                width: 90, // 自定义宽度
                height: 32, // 自定义高度
              ),
              SizedBox(width: 240), // 添加一些间距
              DropdownField(
                key: logic.levelDropdownKey,
                items: logic.questionLevel.toList(),
                hint: '选择难度',
                width: 120,
                height: 34,
                onChanged: (dynamic newValue) {
                  logic.selectedQuestionLevel.value = newValue.toString();
                  logic.applyFilters();
                },
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: FutureBuilder<void>(
                  future: logic.fetchMajors(), // 调用 fetchMajors 方法
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator()); // 加载中显示进度条
                    } else if (snapshot.hasError) {
                      return Text('加载失败: ${snapshot.error}');
                    } else {
                      return CascadingDropdownField(
                        key: logic.majorDropdownKey,
                        width: 160,
                        height: 34,
                        hint1: '专业类目一',
                        hint2: '专业类目二',
                        hint3: '专业名称',
                        level1Items: logic.level1Items,
                        level2Items: logic.level2Items,
                        level3Items: logic.level3Items,
                        onChanged:
                            (dynamic level1, dynamic level2, dynamic level3) {
                          logic.selectedMajorId.value = level3.toString();
                          // 这里可以处理选择的 id
                        },
                      );
                    }
                  },
                ),
              ),
              SearchBoxWidget(
                key: Key('keywords'),
                hint: '题本名称、作者',
                onTextChanged: (String value) {
                  logic.searchText.value = value;
                  logic.applyFilters();
                },
                searchText: logic.searchText,
              ),
              SizedBox(width: 26),
              SearchButtonWidget(
                key: Key('search'),
                onPressed: () => logic.find(logic.size.value, logic.page.value),
              ),
              SizedBox(width: 10),
              ResetButtonWidget(
                key: Key('reset'),
                onPressed: () {
                  logic.reset();
                  logic.find(logic.size.value, logic.page.value);
                },
              ),
            ],
          ),
          ThemeUtil.lineH(),
          ThemeUtil.height(),
          Expanded(
            child: Obx(() => logic.loading.value
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1500,
                      child: SfDataGrid(
                        source: BookDataSource(logic: logic, context: context),
                        headerGridLinesVisibility:
                            GridLinesVisibility.values[1],
                        gridLinesVisibility: GridLinesVisibility.values[1],
                        columnWidthMode: ColumnWidthMode.fill,
                        headerRowHeight: 50,
                        rowHeight: 100,
                        columns: [
                          GridColumn(
                            columnName: 'Select',
                            width: 100,
                            label: Container(
                              color: Color(0xFFF3F4F8),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8.0),
                              child: Checkbox(
                                value: logic.selectedRows.length ==
                                    logic.list.length,
                                onChanged: (value) => logic.toggleSelectAll(),
                                fillColor:
                                    WidgetStateProperty.resolveWith<Color>(
                                        (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return Color(
                                        0xFFD43030); // Red background when checked
                                  }
                                  return Colors
                                      .white; // Optional color for unchecked state
                                }),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                          ),
                          ...logic.columns.map((column) => GridColumn(
                                columnName: column.key,
                                width: _getColumnWidth(column.key),
                                label: Container(
                                  color: Color(0xFFF3F4F8),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    column.title,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800]),
                                  ),
                                ),
                              )),
                          GridColumn(
                            columnName: 'Actions',
                            width: 140,
                            label: Container(
                              color: Color(0xFFF3F4F8),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '操作',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
          ),
          Obx(() => Padding(
                padding: EdgeInsets.only(right: 50),
                child: Column(
                  children: [
                    PaginationPage(
                      total: logic.total.value,
                      changed: (int newSize, int newPage) {
                        logic.find(newSize, newPage);
                      },
                    ),
                  ],
                ),
              )),
          ThemeUtil.height(height: 30),
        ],
      ),
    );
  }

  double _getColumnWidth(String key) {
    switch (key) {
      case 'id':
        return 65;
      case 'name':
        return 120;
      case 'level_name':
        return 120;
      case 'major_name':
        return 100;
      case 'component_desc':
        return 150;
      case 'unit_number':
        return 80;
      case 'questions_number':
        return 80;
      case 'creator':
        return 120;
      case 'update_time':
        return 150;
      default:
        return 100; // 默认宽度
    }
  }

  Widget _buildInteractiveCardLeft(String title, double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color(0xFFE6F0FF),
        borderRadius: BorderRadius.circular(3.0),
        border: Border.all(color: Color(0xFFE6F0FF), width: 1),
      ),
      padding: EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3.0),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800]),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Center(
                child: SelectableList(
                  items: logic.templateList,
                  onDelete: (Map<String, dynamic> item) async {
                    try {
                      await TemplateApi.templateDelete(item["id"]);
                      "删除成功".toHint();
                      setState(() {
                        logic.templateList.removeWhere((template) => template["id"] == item["id"]);
                      });
                    } catch (error) {
                      "删除失败: $error".toHint();
                      throw error;
                    }
                  },
                  onSelected: (Map<String, dynamic> item) {
                    print("Item with ID ${item['id']} and name ${item['name']} is selected");
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveCardRight(
      String title, double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color(0xFFE6F0FF),
        borderRadius: BorderRadius.circular(3.0),
        border: Border.all(color: Color(0xFFE6F0FF), width: 1),
      ),
      padding: EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3.0),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800]),
            ),
            SizedBox(height: 16),
            // 第一行：题本名称、选择专业
            Row(
              children: [
                // 题本名称
                SizedBox(
                  width: 240, // 设置固定宽度
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "题本名称：",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      TextInputWidget(
                        width: 240,
                        height: 34,
                        hint: "输入题本名称",
                        text: logic.bookName,
                        onTextChanged: (value) {
                          logic.bookName.value = value; // 保存题本名称
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 120), // 减少间距
                // 选择专业
                SizedBox(
                  width: 500, // 设置固定宽度
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "选择专业：",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      CascadingDropdownField(
                        width: 160,
                        height: 34,
                        hint1: '专业类目一',
                        hint2: '专业类目二',
                        hint3: '专业名称',
                        level1Items: logic.level1Items,
                        level2Items: logic.level2Items,
                        level3Items: logic.level3Items,
                        onChanged:
                            (dynamic level1, dynamic level2, dynamic level3) {
                          logic.bookSelectedMajorId.value = level3.toString();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 第二行：选择题型、选择难度、生成套数
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // 题型数量
                SizedBox(
                  width: 550, // 固定宽度
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "题型数量：",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Row(
                        children: logic.questionCate.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  "${item['name']}：",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                NumberInputWidget(
                                  key: Key(item['id']),
                                  width: 90,
                                  height: 34,
                                  hint: "${item['value']}",
                                  selectedValue: 0.obs,
                                  onValueChanged: (value) {
                                    final key = item['id'];
                                    logic.questionCate.value =
                                        logic.questionCate.value.map((e) {
                                      if (e['id'] == key) {
                                        return {
                                          ...e, // 保留所有原始字段
                                          'value': value, // 更新 value 字段
                                        };
                                      }
                                      return e;
                                    }).toList();
                                  },
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                // 选择难度
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "选择难度：",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      DropdownField(
                        items: logic.questionLevel.toList(),
                        hint: '选择难度',
                        width: 120,
                        height: 34,
                        onChanged: (dynamic newValue) {
                          logic.bookSelectedQuestionLevel.value =
                              newValue.toString();
                          logic.applyFilters();
                        },
                      ),
                    ],
                  ),
                ),
                // 生成套数
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "生成套数：",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      NumberInputWidget(
                        key: Key("book_count"),
                        width: 90,
                        height: 34,
                        hint: "0",
                        selectedValue: 0.obs,
                        onValueChanged: (value) {
                          logic.bookQuestionCount.value =
                              value.toInt(); // 保存生成套数
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 第三行：按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 保存模板的逻辑
                    logic.saveTemplate();
                  },
                  child: Text("保存模板"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 生成题本的逻辑
                    logic.saveBook();
                  },
                  child: Text("生成题本"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static SidebarTree newThis() {
    return SidebarTree(
      name: "题本管理",
      icon: Icons.deblur,
      page: BookPage(),
    );
  }
}

class BookDataSource extends DataGridSource {
  final BookLogic logic;
  final BuildContext context;
  List<DataGridRow> _rows = [];

  BookDataSource({required this.logic, required this.context}) {
    _buildRows();
  }

  void _buildRows() {
    _rows = logic.list
        .map((item) => DataGridRow(
              cells: [
                DataGridCell(
                  columnName: 'Select',
                  value: logic.selectedRows.contains(item['id']),
                ),
                ...logic.columns.map((column) {
                  // 特殊处理 component_desc 列
                  var value = item[column.key];
                  if (column.key == 'component_desc' && value is List) {
                    // 将列表转化为多行字符串
                    value = value.join("\n");
                  }
                  return DataGridCell(
                    columnName: column.key,
                    value: value,
                  );
                }),
                DataGridCell(columnName: 'Actions', value: item),
              ],
            ))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final isSelected = row.getCells().first.value as bool;
    final rowIndex = _rows.indexOf(row);
    final item = row.getCells().last.value;

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Color(0x50F1FDFC) : Colors.white,
      cells: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Checkbox(
            value: isSelected,
            onChanged: (value) => logic.toggleSelect(rowIndex),
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              return states.contains(WidgetState.selected)
                  ? Color(0xFFD43030)
                  : Colors.white;
            }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        ...row.getCells().skip(1).take(row.getCells().length - 2).map((cell) {
          final columnName = cell.columnName;
          final value = cell.value.toString();

          if (columnName == 'title' || columnName == 'answer') {
            // Use LayoutBuilder to get the actual width and determine if text exceeds
            return Tooltip(
              message: "点击右侧复制或查看全文",
              verticalOffset: 25.0,
              // 可以调整垂直偏移量
              showDuration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isOverflowing = value.length > 100; // 调整长度条件
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      isOverflowing
                          ? TextButton(
                              style: ButtonStyle(
                                textStyle: WidgetStateProperty.all(
                                    TextStyle(fontSize: 14)),
                                foregroundColor:
                                    WidgetStateProperty.all(Color(0xFF25B7E8)),
                              ),
                              onPressed: () {
                                CopyDialog.show(context, value);
                              },
                              child: Text("全文"),
                            )
                          : TextButton(
                              style: ButtonStyle(
                                textStyle: WidgetStateProperty.all(
                                    TextStyle(fontSize: 14)),
                                foregroundColor:
                                    WidgetStateProperty.all(Color(0xFF25B7E8)),
                              ),
                              onPressed: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: value));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("复制成功"),
                                    duration: Duration(seconds: 2), // 显示2秒钟
                                  ),
                                );
                              },
                              child: Text("复制"),
                            ),
                    ],
                  );
                },
              ),
            );
          } else {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                value,
                style: TextStyle(fontSize: 14),
              ),
            );
          }
        }),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => logic.deleteBook(item, rowIndex),
              child: Text("删除", style: TextStyle(color: Color(0xFFFD941D))),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionDetailPage(id: item['id']), // 替换为实际的 ID
                  ),
                );
              },
              child: Text("查看题本", style: TextStyle(color: Color(0xFFFD941D))),
            ),
          ],
        ),
      ],
    );
  }
}
