import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:admin_flutter/component/pagination/view.dart';
import 'package:admin_flutter/component/table/ex.dart';
import '../../sidebar/logic.dart';
import 'logic.dart';
import 'package:admin_flutter/theme/theme_util.dart';

class MajorPage extends StatelessWidget {
  final logic = Get.put(MajorLogic());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableEx.actions(
          children: [
            ThemeUtil.width(width: 50),
            SizedBox(
              width: 260,
              child: TextField(
                key: Key('search_box'),
                decoration: InputDecoration(
                  hintText: '搜索',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) => logic.search(value),
              ),
            ),
            ThemeUtil.width(),
            ElevatedButton(
              onPressed: () => logic.search(""),
              child: Text("搜索"),
            ),
            Spacer(),
            FilledButton(
                onPressed: logic.add,
                child: Text("新增")),
            FilledButton(
                onPressed: () => logic.batchDelete(logic.selectedRows),
                child: Text("批量删除")),
            FilledButton(
                onPressed: logic.exportCurrentPageToCSV,
                child: Text("导出当前页")),
            FilledButton(
                onPressed: logic.exportAllToCSV,
                child: Text("导出全部")),
            FilledButton(
                onPressed: logic.importFromCSV,
                child: Text("从 CSV 导入")),
          ],
        ),
        ThemeUtil.lineH(),
        ThemeUtil.height(),
        Expanded(
          child: Obx(() => logic.loading.value
              ? Center(child: CircularProgressIndicator())
              : SfDataGrid(
            source: MajorDataSource(logic: logic),
            columns: [
              GridColumn(
                columnName: 'Select',
                label: Checkbox(
                  value: logic.selectedRows.length == logic.list.length,
                  onChanged: (value) => logic.toggleSelectAll(),
                ),
              ),
              ...logic.columns.map((column) => GridColumn(
                columnName: column.key,
                label: Text(column.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800])),
              )),
              GridColumn(
                columnName: 'Actions',
                label: Text('操作',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800])),
              ),
            ],
          )),
        ),
        Obx(() {
          return PaginationPage(
            total: logic.total.value,
            changed: (size, page) => logic.find(size, page),
          );
        })
      ],
    );
  }

  static SidebarTree newThis() {
    return SidebarTree(
      name: "专业列表", // 侧边栏名称
      icon: Icons.deblur, // 侧边栏图标
      page: MajorPage(), // 对应的页面
    );
  }
}

class MajorDataSource extends DataGridSource {
  final MajorLogic logic;
  List<DataGridRow> _rows = [];

  MajorDataSource({required this.logic}) {
    _buildRows();
  }

  void _buildRows() {
    _rows = logic.list
        .map((item) => DataGridRow(
      cells: [
        DataGridCell(
            columnName: 'Select',
            value: logic.selectedRows.contains(item['id'])),
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

    return DataGridRowAdapter(
      cells: [
        Checkbox(
          value: isSelected,
          onChanged: (value) => logic.toggleSelect(rowIndex),
        ),
        ...row.getCells().skip(1).take(row.getCells().length - 2).map(
              (cell) => Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(cell.value?.toString() ?? ''),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black54),
              onPressed: () => logic.modify(row.getCells().last.value, rowIndex),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.orange),
              onPressed: () => logic.delete(row.getCells().last.value, rowIndex),
            ),
          ],
        ),
      ],
    );
  }
}
