import 'package:admin_flutter/ex/ex_hint.dart';
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
import '../execute/view.dart';
import 'logic.dart';
import 'package:admin_flutter/theme/theme_util.dart';
import 'package:provider/provider.dart';

class ExamPage extends StatefulWidget {
  final logic = Get.put(ExamLogic());

  @override
  _ExamPageState createState() => _ExamPageState();

  static SidebarTree newThis() {
    return SidebarTree(
      name: "试卷管理",
      icon: Icons.document_scanner,
      page: ExamPage(),
    );
  }
}

class _ExamPageState extends State<ExamPage> {
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ButtonState>(
      create: (_) => ButtonState(),
      child: Column(
        children: [
          Container(
            height: 420,
            color: Color(0xFFF7F7F9),
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "生成试卷",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildInteractiveCardLeft("通过模板创建", 400, 320),
                    SizedBox(width: 40),
                    _buildInteractiveCardRight("生成试卷", 1200, 320),
                  ],
                ),
              ],
            ),
          ),
          TableEx.actions(
            children: [
              SizedBox(width: 16),
              Text(
                "管理试卷",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 30),
              CustomButton(
                onPressed: () =>
                    widget.logic.batchDelete(widget.logic.selectedRows),
                text: '批量删除',
                width: 90,
                height: 32,
              ),
              SizedBox(width: 240),
              DropdownField(
                key: widget.logic.levelDropdownKey,
                items: widget.logic.questionLevel.toList(),
                hint: '选择难度',
                width: 120,
                height: 34,
                selectedValue: widget.logic.selectedQuestionLevel,
                onChanged: (dynamic newValue) {
                  widget.logic.selectedQuestionLevel.value =
                      newValue.toString();
                  widget.logic.applyFilters();
                },
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: FutureBuilder<void>(
                  future: widget.logic.fetchMajors(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('加载失败: ${snapshot.error}');
                    } else {
                      return CascadingDropdownField(
                        key: widget.logic.majorDropdownKey,
                        width: 160,
                        height: 34,
                        hint1: '专业类目一',
                        hint2: '专业类目二',
                        hint3: '专业名称',
                        level1Items: widget.logic.level1Items,
                        level2Items: widget.logic.level2Items,
                        level3Items: widget.logic.level3Items,
                        selectedLevel1:  ValueNotifier(null),
                        selectedLevel2:  ValueNotifier(null),
                        selectedLevel3:  ValueNotifier(null),
                        onChanged:
                            (dynamic level1, dynamic level2, dynamic level3) {
                          widget.logic.selectedMajorId.value =
                              level3.toString();
                        },
                      );
                    }
                  },
                ),
              ),
              SearchBoxWidget(
                key: Key('keywords'),
                hint: '试卷名称、作者',
                onTextChanged: (String value) {
                  widget.logic.searchText.value = value;
                  widget.logic.applyFilters();
                },
                searchText: widget.logic.searchText,
              ),
              SizedBox(width: 26),
              SearchButtonWidget(
                key: Key('search'),
                onPressed: () => widget.logic
                    .find(widget.logic.size.value, widget.logic.page.value),
              ),
              SizedBox(width: 10),
              ResetButtonWidget(
                key: Key('reset'),
                onPressed: () {
                  widget.logic.reset();
                  widget.logic
                      .find(widget.logic.size.value, widget.logic.page.value);
                },
              ),
            ],
          ),
          ThemeUtil.lineH(),
          ThemeUtil.height(),
          Expanded(
            child: Obx(() => widget.logic.loading.value
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1500,
                child: SfDataGrid(
                  source: ExamDataSource(
                      logic: widget.logic, context: context),
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
                          value: widget.logic.selectedRows.length ==
                              widget.logic.list.length,
                          onChanged: (value) =>
                              widget.logic.toggleSelectAll(),
                          fillColor:
                          WidgetStateProperty.resolveWith<Color>(
                                  (states) {
                                if (states.contains(WidgetState.selected)) {
                                  return Color(0xFFD43030);
                                }
                                return Colors.white;
                              }),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ),
                    ...widget.logic.columns.map((column) => GridColumn(
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
                  uniqueId: 'exam_pagination',
                  total: widget.logic.total.value,
                  changed: (int newSize, int newPage) {
                    widget.logic.find(newSize, newPage);
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
        return 100;
    }
  }

  Widget _buildInteractiveCardLeft(
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
                  key: widget.logic.selectableListKey,
                  items: widget.logic.templateList,
                  onDelete: (Map<String, dynamic> item) async {
                    try {
                      await TemplateApi.templateDelete(item["id"]);
                      "删除成功".toHint();
                    } catch (error) {
                      "删除失败: $error".toHint();
                      throw error;
                    }
                  },
                  onSelected: (Map<String, dynamic> item) {
                    print("Item with ID ${item['id']} and $item is selected");
                    widget.logic.fillTemplate(item);
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
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800]),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 240,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "试卷名称：",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 8),
                      TextInputWidget(
                        width: 240,
                        height: 34,
                        hint: "输入试卷名称",
                        text: widget.logic.examName,
                        // 直接传递 RxString
                        onTextChanged: (value) {
                          widget.logic.examName.value = value; // 更新逻辑
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 120),
                SizedBox(
                  width: 500,
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
                        level1Items: widget.logic.level1Items,
                        level2Items: widget.logic.level2Items,
                        level3Items: widget.logic.level3Items,
                        selectedLevel1: widget.logic.majorSelectedLevel1,
                        selectedLevel2: widget.logic.majorSelectedLevel2,
                        selectedLevel3: widget.logic.majorSelectedLevel3,
                        onChanged:
                            (dynamic level1, dynamic level2, dynamic level3) {
                          widget.logic.examSelectedMajorId.value = level3.toString();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 550,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "题型数量：",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Row(
                        children: widget.logic.questionCate.map((item) {
                          final selectValue = widget.logic.cateSelectedValues[item["id"]]!;
                          print(item["id"]);
                          print(selectValue);
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
                                  key: UniqueKey(),
                                  hint: '',
                                  selectedValue: selectValue,
                                  width: 80,
                                  height: 34,
                                  onValueChanged: (value) {
                                    final key = item['id'];
                                    widget.logic.questionCate.value = widget
                                        .logic.questionCate.value
                                        .map((e) {
                                      if (e['id'] == key) {
                                        return {
                                          ...e,
                                          'value': value,
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
                        items: widget.logic.questionLevel.toList(),
                        hint: '选择难度',
                        width: 120,
                        height: 34,
                        onChanged: (dynamic newValue) {
                          widget.logic.examSelectedQuestionLevel.value = newValue.toString();
                          widget.logic.applyFilters();
                        },
                        selectedValue: widget.logic.examSelectedQuestionLevel,
                      ),
                    ],
                  ),
                ),
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
                        key: Key("exam_count"),
                        width: 90,
                        height: 34,
                        hint: "0",
                        selectedValue: widget.logic.examQuestionCount,
                        onValueChanged: (value) {
                          widget.logic.examQuestionCount.value = value.toInt();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await widget.logic.saveTemplate();
                    if(result) {
                      await widget.logic.fetchTemplates();
                      refresh();
                    }
                  },
                  child: Text("保存模板"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await widget.logic.saveExam();
                  },
                  child: Text("生成试卷"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExamDataSource extends DataGridSource {
  final ExamLogic logic;
  final BuildContext context;
  List<DataGridRow> _rows = [];

  ExamDataSource({required this.logic, required this.context}) {
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
          var value = item[column.key];
          if (column.key == 'component_desc' && value is List) {
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
            onChanged: (value) => logic.toggleSelect(item['id']),
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              return states.contains(WidgetState.selected)
                  ? Color(0xFFD43030)
                  : Colors.white;
            }),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        ...row.getCells().skip(1).take(row.getCells().length - 2).map((cell) {
          final columnName = cell.columnName;
          final value = cell.value.toString();

          if (columnName == 'title' || columnName == 'answer') {
            return Tooltip(
              message: "点击右侧复制或查看全文",
              verticalOffset: 25.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isOverflowing = value.length > 100;
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
                              duration: Duration(seconds: 2),
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
              onPressed: () => logic.deleteExam(item, rowIndex),
              child: Text("删除", style: TextStyle(color: Color(0xFFFD941D))),
            ),
            TextButton(
              onPressed: () {
              //   Navigator.push(
              //     context,
              //   //   MaterialPageRoute(
              //   //   //   builder: (context) =>
              //   //   //       ExecutePage(id: item['id']), // 替换为实际的 ID
              //   //   // ),
              //   // );
              },
              child: Text("查看试卷", style: TextStyle(color: Color(0xFFFD941D))),
            ),
          ],
        ),
      ],
    );
  }
}