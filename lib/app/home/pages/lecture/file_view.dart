import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_treeview/flutter_treeview.dart' as treeview;
import 'package:file_picker/file_picker.dart';

import 'logic.dart';

class LectureFileView extends StatelessWidget {
  final String title;
  final LectureLogic logic;

  const LectureFileView({Key? key, required this.title, required this.logic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        Expanded(
          child: Obx(() {
            if (logic.directoryTree.isEmpty) {
              return Center(child: Text("No directories yet"));
            } else {
              return _buildTreeView(context);
            }
          }),
        ),
      ],
    );
  }

  treeview.TreeView _buildTreeView(BuildContext context) {
    return treeview.TreeView(
      controller: treeview.TreeViewController(
        children: _buildTreeNodes(logic.directoryTree),
      ),
      onNodeTap: (key) {
        final node = _findNodeByKey(key, logic.directoryTree);
        if (node != null) {
          _showContextMenu(context, node);
        }
      },
    );
  }

  List<treeview.Node<DirectoryNode>> _buildTreeNodes(List<DirectoryNode> nodes) {
    return nodes.map((node) {
      return treeview.Node<DirectoryNode>(
        key: node.id.toString(),
        label: _buildNodeLabel(node),
        children: _buildTreeNodes(node.children),
        data: node,
      );
    }).toList();
  }

  Widget _buildNodeLabel(DirectoryNode node) {
    return Row(
      children: [
        Expanded(
          child: Text(node.name),
        ),
        IconButton(
          icon: Icon(Icons.add),
          tooltip: 'Add Subdirectory',
          onPressed: () => _addSubdirectory(Get.context!, node),
        ),
        IconButton(
          icon: Icon(Icons.file_upload),
          tooltip: 'Upload File',
          onPressed: () => _importFile(Get.context!, node),
        ),
        IconButton(
          icon: Icon(Icons.folder_open),
          tooltip: 'Import File as Subdirectory',
          onPressed: () => logic.importFileAsSubdirectory(Get.context!, node),
        ),
      ],
    );
  }

  treeview.Node<DirectoryNode>? _findNodeByKey(String key, List<DirectoryNode> nodes) {
    for (var node in nodes) {
      if (node.id.toString() == key) {
        return treeview.Node<DirectoryNode>(
          key: node.id.toString(),
          label: node.name,
          children: _buildTreeNodes(node.children),
          data: node,
        );
      }
      final foundNode = _findNodeByKey(key, node.children);
      if (foundNode != null) {
        return foundNode;
      }
    }
    return null;
  }

  void _showContextMenu(BuildContext context, treeview.Node<DirectoryNode> node) {
    final DirectoryNode dirNode = node.data!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            _buildListTile(
              icon: Icons.create_new_folder,
              text: 'Add Subdirectory',
              onTap: () {
                Navigator.pop(context);
                _addSubdirectory(context, dirNode);
              },
            ),
            _buildListTile(
              icon: Icons.file_upload,
              text: 'Import File',
              onTap: () {
                Navigator.pop(context);
                _importFile(context, dirNode);
              },
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildListTile({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }

  void _addSubdirectory(BuildContext context, DirectoryNode parent) {
    String? newDirName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Directory"),
        content: TextField(
          onChanged: (value) => newDirName = value,
          decoration: InputDecoration(hintText: "Directory Name"),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Add"),
            onPressed: () {
              if (newDirName != null && newDirName!.isNotEmpty) {
                logic.addNewDirectory(newDirName!, parent.id);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _importFile(BuildContext context, DirectoryNode node) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      logic.importFileToDirectory(file, node.id);
    }
  }
}
