import 'package:flutter/material.dart';

class CodeEditor extends StatefulWidget {
  final TextEditingController codeController;
  final TextEditingController terminalController;
  final VoidCallback onRun;
  
  const CodeEditor({
    super.key,
    required this.codeController,
    required this.terminalController,
    required this.onRun,
  });

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  double _terminalHeight = 200.0;

  Widget _buildCodeEditor() {
    return Column(
      children: [
        // Editor toolbar
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: const Color(0xFF2D2D2D),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.green),
                onPressed: widget.onRun,
                tooltip: 'Run (F5)',
              ),
              const Text('Python', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        // Main content area
        Expanded(
          child: Column(
            children: [
              // Main editor
              Expanded(
                flex: 3,
                child: Container(
                  color: const Color(0xFF1E1E1E),
                  child: TextField(
                    controller: widget.codeController,
                    maxLines: null,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Consolas',
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              // Resizable divider
              MouseRegion(
                cursor: SystemMouseCursors.resizeRow,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      _terminalHeight = (_terminalHeight - details.delta.dy)
                          .clamp(100.0, 400.0);
                    });
                  },
                  child: Container(
                    height: 4,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
              // Terminal
              SizedBox(
                height: _terminalHeight,
                child: Container(
                  color: const Color(0xFF1E1E1E),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: const Color(0xFF2D2D2D),
                        child: const Text(
                          'TERMINAL',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: widget.terminalController,
                          maxLines: null,
                          readOnly: true,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Consolas',
                            fontSize: 12,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildCodeEditor();
  }
}