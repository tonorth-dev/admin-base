import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:admin_flutter/component/pagination/view.dart';
import 'package:admin_flutter/component/table/ex.dart';
import 'package:admin_flutter/app/home/sidebar/logic.dart';
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
              CustomButton(
                onPressed: logic.add,
                text: '新增',
              ),
              FilledButton(onPressed: () => logic.batchDelete(logic.selectedRows), child: const Text("批量删除")),
              FilledButton(onPressed: logic.exportCurrentPageToCSV, child: const Text("导出当前页")),
              FilledButton(onPressed: logic.exportAllToCSV, child: const Text("导出全部")),
              FilledButton(onPressed: logic.importFromCSV, child: const Text("从 CSV 导入")),
              Obx(() => DropdownButton<String?>(
                value: logic.selectedMajor.value,
                hint: const Text('选择专业'),
                onChanged: (String? newValue) {
                  logic.selectedMajor.value = newValue;
                  logic.applyFilters();
                },
                items: [
                  DropdownMenuItem(value: null, child: const Text('全部专业')),
                  ...logic.majorList.map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  )),
                ],
              )),
              ThemeUtil.width(),
              Obx(() => DropdownButton<String?>(
                value: logic.selectedTopicType.value,
                hint: const Text('选择题型'),
                onChanged: (String? newValue) {
                  logic.selectedTopicType.value = newValue;
                  logic.applyFilters();
                },
                items: [
                  DropdownMenuItem(value: null, child: const Text('全部题型')),
                  ...logic.topicTypeList.map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  )),
                ],
              )),
              ThemeUtil.width(),
              SizedBox(
                width: 260,
                child: TextField(
                  key: const Key('search_box'),
                  decoration: const InputDecoration(
                    hintText: '搜索',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: logic.search,
                ),
              ),
              ThemeUtil.width(),
              ElevatedButton(onPressed: () => logic.search(""), child: const Text("搜索")),
              const Spacer(),
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
                          value: logic.selectedRows.length == logic.list.length,
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

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonState = Provider.of<ButtonState>(context);

    return MouseRegion(
      onEnter: (_) => buttonState.setHovered(true),
      onExit: (_) => buttonState.setHovered(false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 95, // 固定宽度
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: buttonState.isHovered ? Color(0xFF25B7E8) : Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(21),
          boxShadow: [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 2,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            )
          ],
        ),
        child: TextButton(
          onPressed: onPressed,
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            foregroundColor: WidgetStateProperty.all(Colors.transparent),
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: buttonState.isHovered ? Colors.white : Color(0xFF383838),
                  fontSize: 16,
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w300,
                  height: 0.08,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ButtonState with ChangeNotifier {
  bool _isHovered = false;

  bool get isHovered => _isHovered;

  void setHovered(bool value) {
    _isHovered = value;
    notifyListeners();
  }
}