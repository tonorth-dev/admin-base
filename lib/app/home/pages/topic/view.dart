import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:admin_flutter/component/pagination/view.dart';
import 'package:admin_flutter/component/table/ex.dart';
import 'package:admin_flutter/app/home/sidebar/logic.dart';
import 'package:admin_flutter/component/widget.dart';
import 'logic.dart';
import 'package:admin_flutter/theme/theme_util.dart';
import 'package:provider/provider.dart'; // 添加这一行

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
              SizedBox(width: 8), // 添加一些间距
              SizedBox(
                width: 100, // 设置一个固定的宽度
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: '已选中 ${logic.selectedRows.length} 项',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(width: 8), // 添加一些间距
              CustomButton(
                onPressed: logic.add,
                text: '新增',
                width: 90, // 自定义宽度
                height: 38, // 自定义高度
              ),
              SizedBox(width: 8), // 添加一些间距
              CustomButton(
                onPressed: () => logic.batchDelete(logic.selectedRows),
                text: '批量删除',
                width: 100, // 自定义宽度
                height: 38, // 自定义高度
              ),
              SizedBox(width: 8), // 添加一些间距
              CustomButton(
                onPressed: logic.exportCurrentPageToCSV,
                text: '导出选中项',
                width: 120, // 自定义宽度
                height: 38, // 自定义高度
              ),
              SizedBox(width: 8), // 添加一些间距
              CustomButton(
                onPressed: logic.exportAllToCSV,
                text: '导出全部',
                width: 120, // 自定义宽度
                height: 38, // 自定义高度
              ),
              SizedBox(width: 8), // 添加一些间距
              CustomButton(
                onPressed: logic.exportAllToCSV,
                text: '从CSV导入',
                width: 120, // 自定义宽度
                height: 38, // 自定义高度
              ),
              SizedBox(width: 400), // 添加一些间距
              DropdownField(
                items: logic.majorList.toList(),
                // 传递选项数据
                hint: '岗位类别筛选',
                width: 200,
                // 设置宽度
                height: 38,
                // 设置高度
                onChanged: (String? newValue) {
                  logic.selectedTopicType.value = newValue;
                  logic.applyFilters();
                },
              ),
              ThemeUtil.width(),
              CascadingDropdownField(
                width: 200,
                height: 38,
                hint1: '专业类别',
                hint2: '专业',
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
              ThemeUtil.width(),
              SearchAndButtonWidget(
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
                        headerGridLinesVisibility: GridLinesVisibility.vertical,
                        columnWidthMode: ColumnWidthMode.fill,
                        headerRowHeight: 50,
                        columns: [
                          GridColumn(
                            columnName: 'Select',
                            label: Container(
                              padding: const EdgeInsets.all(8.0),
                              alignment: Alignment.center,
                              child: Checkbox(
                                value: logic.selectedRows.length ==
                                    logic.list.length,
                                onChanged: (value) => logic.toggleSelectAll(),
                              ),
                            ),
                          ),
                          GridColumn(
                            columnName: 'ID',
                            label: Center(child: Text('ID')),
                          ),
                          ...logic.columns.map((column) => GridColumn(
                                columnName: column.key,
                                label: Center(
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
                            label: Center(child: Text('操作')),
                          ),
                        ],
                      ),
                    ),
                  )),
          ),
          Obx(() => PaginationPage(
                total: logic.total.value,
                changed: (size, page) => logic.find(size, page),
              )),
        ],
      ),
    );
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
                DataGridCell(columnName: 'ID', value: item['id']),
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
      color: rowIndex.isEven ? Colors.blueGrey[50] : Colors.white,
      cells: [
        Checkbox(
          value: isSelected,
          onChanged: (value) => logic.toggleSelect(rowIndex),
        ),
        ...row.getCells().skip(1).take(row.getCells().length - 2).map(
              (cell) => Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.centerLeft,
                child: Text(
                  cell.value?.toString() ?? '',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black54),
              onPressed: () => logic.edit(item),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.orange),
              onPressed: () => logic.delete(item, rowIndex),
            ),
          ],
        ),
      ],
    );
  }
}
