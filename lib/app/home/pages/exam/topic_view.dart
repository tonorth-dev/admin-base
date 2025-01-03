import 'package:admin_flutter/app/home/pages/exam/topic_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:admin_flutter/component/pagination/view.dart';
import 'package:admin_flutter/component/table/ex.dart';
import 'package:admin_flutter/app/home/sidebar/logic.dart';
import 'package:admin_flutter/component/widget.dart';
import 'package:admin_flutter/component/dialog.dart';
import 'logic.dart';
import 'package:admin_flutter/theme/theme_util.dart';
import 'package:provider/provider.dart';

class ExamTopicView extends StatelessWidget {
  final String title;
  final int id;

  const ExamTopicView({Key? key, required this.id, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("ExamTopicView id: $id");
    Get.replace<ExamTopicLogic>(ExamTopicLogic(id));
    final logic = Get.find<ExamTopicLogic>();

    return Scaffold( // 使用 Scaffold 包裹
        appBar: AppBar(
          title: Text(title),
        ),
        body:ChangeNotifierProvider<ButtonState>(
      create: (_) => ButtonState(),
      child: Column(
        children: [
          TableEx.actions(
            children: [
              SizedBox(width: 30), // 添加一些间距
              SearchBoxWidget(
                key: Key('keywords'),
                hint: '岗位代码、岗位名称、单位序号、单位名称',
                onTextChanged: (String value) {
                  logic.searchText.value = value;
                },
                searchText: logic.searchText,
              ),
              SizedBox(width: 10),
              SearchButtonWidget(
                key: Key('search'),
                onPressed: () {
                  logic.selectedRows.clear();
                  logic.find(logic.size.value, logic.page.value);
                },
              ),
              SizedBox(width: 8),
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
                width: 1700,
                child: SfDataGrid(
                  source: ExamTopicDataSource(logic: logic, context: context),
                  headerGridLinesVisibility:
                  GridLinesVisibility.values[1],
                  gridLinesVisibility: GridLinesVisibility.values[1],
                  columnWidthMode: ColumnWidthMode.fill,
                  headerRowHeight: 50,
                  rowHeight: 60,
                  columns: [
                    GridColumn(
                      columnName: 'Select',
                      width: 100,
                      label: Container(
                        color: Color(0xFFF3F4F8),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8.0),
                        child: Checkbox(
                          value: (logic.selectedRows.length ==
                              logic.list.length &&
                              logic.selectedRows.isNotEmpty),
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
                      width: column.width,
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
                  uniqueId: 'examTopic_pagination',
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
    ));
  }
}

class ExamTopicDataSource extends DataGridSource {
  final ExamTopicLogic logic;
  final BuildContext context; // 增加 BuildContext 成员变量
  List<DataGridRow> _rows = [];

  ExamTopicDataSource({required this.logic, required this.context}) {
    // 构造函数中添加 context 参数
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
            onChanged: (value) => logic.toggleSelect(item['id']),
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

          if (columnName == 'condition_name') {
            return Tooltip(
              message: "点击右侧复制或查看全文",
              verticalOffset: 25.0,
              showDuration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 使用TextPainter来检查文本是否会在给定宽度内溢出
                  final textPainter = TextPainter(
                    text: TextSpan(text: value, style: TextStyle(fontSize: 14)),
                    maxLines: 2,
                    textDirection: TextDirection.ltr,
                  )..layout(
                      maxWidth: constraints.maxWidth - 10); // 减去Padding的宽度

                  final isOverflowing = textPainter.didExceedMaxLines;
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            value,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      isOverflowing
                          ? TextButton(
                        onPressed: () {
                          CopyDialog.show(context, value);
                        },
                        child: Text("全文"),
                      )
                          : TextButton(
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
          mainAxisAlignment: MainAxisAlignment.center, // 将按钮左对齐
          children: [
            HoverTextButton(
              text: "删除",
              onTap: () async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("确认删除"),
                      content: Text("你确定要删除这项吗？"),
                      actions: [
                        TextButton(
                          child: Text("取消"),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        TextButton(
                          child: Text("确定"),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    );
                  },
                );

                if (shouldDelete == true) {
                  logic.delete(item, rowIndex);
                }
              },
            ),
            SizedBox(width: 5), // 控制按钮之间的间距
          ],
        )
      ],
    );
  }
}
