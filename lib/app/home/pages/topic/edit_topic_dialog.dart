import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'logic.dart';

class EditTopicDialog extends StatelessWidget {
  final logic = Get.find<TopicLogic>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('编辑题目'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: logic.currentEditTopic.value['topic_text'],
              decoration: InputDecoration(labelText: '问题内容'),
              onChanged: (value) => logic.currentEditTopic.value['topic_text'] = value,
            ),
            TextFormField(
              initialValue: logic.currentEditTopic.value['answer'],
              decoration: InputDecoration(labelText: '答案'),
              onChanged: (value) => logic.currentEditTopic.value['answer'] = value,
            ),
            TextFormField(
              initialValue: logic.currentEditTopic.value['specialty_id'].toString(),
              decoration: InputDecoration(labelText: '专业ID'),
              onChanged: (value) => logic.currentEditTopic.value['specialty_id'] = int.tryParse(value),
            ),
            DropdownButtonFormField<String>(
              value: logic.currentEditTopic.value['topic_type'],
              items: logic.form.columns[3]?.options?.map((option) {
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Text(option['label'] ?? ''), // 提供默认值 ''，确保不为 null
                );
              }).toList(),
              onChanged: (value) => logic.currentEditTopic.value['topic_type'] = value,
              decoration: InputDecoration(labelText: '问题类型'),
            ),
            TextFormField(
              initialValue: logic.currentEditTopic.value['entry_person'],
              decoration: InputDecoration(labelText: '录入人'),
              onChanged: (value) => logic.currentEditTopic.value['entry_person'] = value,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => logic.submitEdit(),
          child: Text('提交'),
        ),
      ],
    );
  }
}
   