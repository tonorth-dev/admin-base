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
      nodeBuilder: (BuildContext context, treeview.Node<dynamic> node) {
        return _buildTreeNode(context, node as treeview.Node<DirectoryNode>);
      },
      onExpansionChanged: (key, expanded) {
        // Handle expansion changes if needed
      },
    );
  }

  Widget _buildTreeNode(BuildContext context, treeview.Node<DirectoryNode> node) {
    final DirectoryNode dirNode = node.data!;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _toggleExpansion(node.key),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(dirNode.name),
            ),
          ),
        ),
        SizedBox(width: 8), // Some spacing between text and buttons
        TextButton(
          onPressed: () => _addSubdirectory(context, dirNode),
          child: Text('+', style: TextStyle(fontSize: 16)),
        ),
        TextButton(
          onPressed: () => _importFile(context, dirNode),
          child: Text('↑', style: TextStyle(fontSize: 16)), // Upload symbol
        ),
        TextButton(
          onPressed: () => logic.importFileAsSubdirectory(context, dirNode),
          child: Text('📁', style: TextStyle(fontSize: 16)), // Folder open symbol
        ),
        TextButton(
          onPressed: () => _confirmDelete(context, dirNode),
          child: Text('-', style: TextStyle(fontSize: 16, color: Colors.red)), // Delete symbol
        ),
      ],
    );
  }

  void _toggleExpansion(String key) {
    // Assuming you have access to the TreeViewController
    // You may need to pass it down or use a stateful widget to manage the controller.
    // For simplicity, here we just print the key for now.
    print('Toggle expansion for key: $key');
  }

  void _confirmDelete(BuildContext context, DirectoryNode node) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete '${node.name}'?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              logic.deleteDirectory(node.id); // Call your delete method here
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  List<treeview.Node<DirectoryNode>> _buildTreeNodes(List<DirectoryNode> nodes) {
    return nodes.map((node) {
      return treeview.Node<DirectoryNode>(
        key: node.id.toString(),
        label: node.name, // Use string label here
        children: _buildTreeNodes(node.children),
        data: node,
      );
    }).toList();
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