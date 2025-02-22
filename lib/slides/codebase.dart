import 'package:flutter/material.dart';

class FileItem {
  final String name;
  final bool isDirectory;
  final List<FileItem> children;
  bool isExpanded;

  FileItem({
    required this.name, 
    this.isDirectory = false, 
    this.children = const [],
    this.isExpanded = false,
  });
}

class CodebaseContainer extends StatefulWidget {
  final Function(String content)? onFileSelect;
  
  const CodebaseContainer({Key? key, this.onFileSelect}) : super(key: key);

  @override
  _CodebaseContainerState createState() => _CodebaseContainerState();
}

class _CodebaseContainerState extends State<CodebaseContainer> {
  final List<FileItem> files = [
    FileItem(
      name: 'src',
      isDirectory: true,
      children: [
        FileItem(
          name: 'main.py',
          isDirectory: false,
        ),
        FileItem(
          name: 'utils.py',
          isDirectory: false,
        ),
      ],
    ),
    FileItem(
      name: 'tests',
      isDirectory: true,
      children: [
        FileItem(
          name: 'test_main.py',
          isDirectory: false,
        ),
      ],
    ),
    FileItem(
      name: 'README.md',
      isDirectory: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF252526),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Explorer header with actions
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  'EXPLORER',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.create_new_folder, size: 16, color: Colors.grey),
                  onPressed: () {
                    // Add new folder functionality
                  },
                  tooltip: 'New Folder',
                ),
                IconButton(
                  icon: const Icon(Icons.note_add, size: 16, color: Colors.grey),
                  onPressed: () {
                    // Add new file functionality
                  },
                  tooltip: 'New File',
                ),
              ],
            ),
          ),
          // File tree
          Expanded(
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                return _buildFileItem(files[index], 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(FileItem item, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (item.isDirectory) {
                item.isExpanded = !item.isExpanded;
              } else {
                // Handle file selection
                if (widget.onFileSelect != null) {
                  widget.onFileSelect!(_getFileContent(item.name));
                }
              }
            });
          },
          child: Container(
            padding: EdgeInsets.only(
              left: 8.0 * (level + 1),
              right: 8.0,
              top: 4.0,
              bottom: 4.0,
            ),
            child: Row(
              children: [
                if (item.isDirectory)
                  Icon(
                    item.isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    size: 16,
                    color: Colors.grey,
                  ),
                const SizedBox(width: 4),
                Icon(
                  item.isDirectory
                      ? (item.isExpanded ? Icons.folder_open : Icons.folder)
                      : _getFileIcon(item.name),
                  size: 16,
                  color: item.isDirectory ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  item.name,
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (item.isDirectory && item.isExpanded)
          ...item.children.map((child) => _buildFileItem(child, level + 1)),
      ],
    );
  }

  IconData _getFileIcon(String fileName) {
    if (fileName.endsWith('.py')) {
      return Icons.code;
    } else if (fileName.endsWith('.md')) {
      return Icons.description;
    }
    return Icons.insert_drive_file;
  }

  String _getFileContent(String fileName) {
    // Simulate file content
    switch (fileName) {
      case 'main.py':
        return '''# Main Python file
def main():
    print("Hello from main!")

if __name__ == "__main__":
    main()
''';
      case 'utils.py':
        return '''# Utility functions
def helper():
    return "I'm a helper function"
''';
      default:
        return '# New File\n';
    }
  }
}