import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:admin_flutter/component/pagination/view.dart';
import 'package:admin_flutter/component/table/ex.dart';
import 'package:admin_flutter/app/home/sidebar/logic.dart';
import 'package:admin_flutter/component/widget.dart';
import 'logic.dart';
import 'package:admin_flutter/theme/theme_util.dart';
import 'package:provider/provider.dart';

class TopicPage extends StatelessWidget {
  final logic = Get.put(TopicLogic());

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ButtonState>(
      create: (_) => ButtonState(),
      child: Column(
        children: [
          TableEx.actions(
            children: [
              SizedBox(width: 30), // 添加一些间距
              CustomButton(
                onPressed: logic.add,
                text: '新增',
                width: 70, // 自定义宽度
                height: 32, // 自定义高度
              ),
              SizedBox(width: 8), // 添加一些间距
              CustomButton(
                onPressed: () => logic.batchDelete(logic.selectedRows),
                text: '批量删除',
                width: 90, // 自定义宽度
                height: 32, // 自定义高度
              ),
              SizedBox(width: 8), // 添加一些间距
              CustomButton(
                onPressed: logic.exportCurrentPageToCSV,
                text: '导出选中',
                width: 90, // 自定义宽度
                height: 32, // 自定义高度
              ),
              SizedBox(width: 8), // 添加一些间距
              CustomButton(
                onPressed: logic.exportAllToCSV,
                text: '导出全部',
                width: 90, // 自定义宽度
                height: 32, // 自定义高度
              ),
              SizedBox(width: 8), // 添加一些间距
              CustomButton(
                onPressed: logic.exportAllToCSV,
                text: '从CSV导入',
                width: 110, // 自定义宽度
                height: 32, // 自定义高度
              ),
              SizedBox(width: 120), // 添加一些间距
              DropdownField(
                items: logic.topicTypeList.toList(),
                // 传递选项数据
                hint: '选择题型',
                width: 120,
                // 设置宽度
                height: 34,
                // 设置高度
                onChanged: (String? newValue) {
                  logic.selectedTopicType.value = newValue;
                  logic.applyFilters();
                },
              ),
              SizedBox(width: 12), // 添加一些间距
              CascadingDropdownField(
                width: 160,
                height: 34,
                hint1: '选择专业',
                hint2: '选择XX',
                hint3: '从事工作',
                level1Items: [...logic.majorList],
                level2Items: {
                  ...logic.subMajorMap,
                },
                level3Items: {
                  ...logic.subSubMajorMap,
                },
                onChanged: (level1, level2, level3) {
                  print('选择的: $level1, 市: $level2, 区: $level3');
                },
              ),
              SizedBox(width: 8), // 添加一些间距
              SearchAndButtonWidget(
                hint: '题干、答案、标签',
                onSearch: () => logic.search(""),
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
                    child: Container(
                      width: 1700,
                      child: SfDataGrid(
                        source: TopicDataSource(logic: logic),
                        headerGridLinesVisibility:
                            GridLinesVisibility.values[1],
                        gridLinesVisibility: GridLinesVisibility.values[1],
                        columnWidthMode: ColumnWidthMode.fill,
                        headerRowHeight: 50,
                        rowHeight: 60,
                        // 设置行高
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
                                    MaterialStateProperty.resolveWith<Color>(
                                        (states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Color(
                                        0xFFD43030); // Red background when checked
                                  }
                                  return Colors
                                      .white; // Optional color for unchecked state
                                }),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(4), // Rounded edges
                                ),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              )),
                          GridColumn(
                            columnName: 'Actions',
                            width: 160,
                            label: Container(
                              color: Color(0xFFF3F4F8),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '操作',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
          ),
          Obx(() => Padding(
                padding: EdgeInsets.only(right: 50), // 添加右侧内边距
                child: PaginationPage(
                  total: logic.total.value,
                  changed: (size, page) => logic.find(size, page),
                  // style: PaginationStyle(
                  //   color: Colors.grey[200],
                  //   selectedColor: Colors.red,
                  //   textStyle: TextStyle(color: Colors.black87),
                  // ),
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
        return 80;
      case 'cate':
        return 100;
      case 'title':
        return 300;
      case 'answer':
        return 400;
      case 'major_id':
        return 100;
      case 'major_name':
        return 100;
      case 'create_time':
        return 0;
      case 'major_desc':
        return 200;
      default:
        return 150; // 默认宽度
    }
  }

  static SidebarTree newThis() {
    return SidebarTree(
      name: "题库管理",
      icon: Icons.deblur,
      page: TopicPage(),
    );
  }
}

class TopicDataSource extends DataGridSource {
  final TopicLogic logic;
  List<DataGridRow> _rows = [];

  TopicDataSource({required this.logic}) {
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
                ...logic.columns.map((column) => DataGridCell(
                      columnName: column.key,
                      value: item[column.key],
                    )),
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
            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
              return states.contains(MaterialState.selected)
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
              message: value,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isOverflowing =
                      value.length > 100; // Adjust length condition
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
                              child: Text("全文"),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text('全部内容'),
                                    content: SelectableText(value),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Clipboard.setData(
                                            ClipboardData(text: value),
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: Text("复制"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : TextButton(
                              child: Text("复制"),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: value));
                              },
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
              onPressed: () => logic.edit(item),
              child: Text("编辑", style: TextStyle(color: Color(0xFFFD941D))),
            ),
            TextButton(
              onPressed: () => logic.delete(item, rowIndex),
              child: Text("删除", style: TextStyle(color: Color(0xFFFD941D))),
            ),
          ],
        ),
      ],
    );
  }
}
