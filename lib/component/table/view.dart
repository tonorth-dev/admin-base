import 'package:app_template/component/table/table.dart';
import 'package:app_template/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class TablePage extends StatelessWidget {
  TablePage({Key? key}) : super(key: key);

  final logic = Get.put(TableLogic());
  final state = Get.find<TableLogic>().state;

  Map<String, dynamic> _data(int i) {
    return {
      "name": "张三$i",
      "age": "张三$i",
      "sex": "张三$i",
      "tel": "张三$i",
    };
  }

  @override
  Widget build(BuildContext context) {
    var tableData = TableData(isIndex: true, columns: [
      ColumnData(title: "姓名", key: "name"),
      ColumnData(title: "年龄", key: "age"),
      ColumnData(title: "性别", key: "sex"),
      ColumnData(title: "手机", key: "tel"),
    ], rows: [
      for (int i = 0; i < 100; i++) _data(i)
    ]);
    return Column(
      children: [
        _table(tableData),
        Expanded(
          child: ListView(
            children: [
              for (var i = 0; i < tableData.rows.length; i++)
                Container(
                  color: tableData.isZebra && i % 2 == 0
                      ? Colors.grey.shade100
                      : Colors.white,
                  height: tableData.cellHeight,
                  child: Row(
                    children: [
                      Visibility(
                          visible: tableData.isIndex,
                          child: Expanded(
                            child: Align(
                                alignment: Alignment.center,
                                child: Text("${i + 1}")),
                          )),
                      for (var column in tableData.columns)
                        Expanded(
                            child: Align(
                          alignment: column.alignment,
                          child: column.render != null
                              ? column.render!(tableData.rows[i][column.key],
                                  tableData.rows[i], i)
                              : Text(tableData.rows[i][column.key].toString()),
                        ))
                    ],
                  ),
                )
            ],
          ),
        )
      ],
    );
  }

  // 表头
  Widget _table(TableData table) {
    return Column(
      children: [
        SizedBox(
          height: table.headerHeight,
          child: Row(
            children: [
              Visibility(
                  visible: table.isIndex,
                  child: const Expanded(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "序号",
                          style: TextStyle(fontSize: 18),
                        )),
                  )),
              for (var item in table.columns)
                Expanded(
                    child: Align(
                  alignment: item.alignment,
                  child: Text(
                    item.title,
                    style: const TextStyle(fontSize: 18),
                  ),
                ))
            ],
          ),
        ),
        ThemeUtil.lineH()
      ],
    );
  }
}
