import 'package:flutter/material.dart';
import 'package:version5/slides/codebase.dart';
import 'package:version5/slides/extension.dart';
import 'package:version5/slides/sim.dart';
import 'package:version5/slides/telemetry.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MapApp());
}

// Modify MapApp to handle app termination
class MapApp extends StatefulWidget {
  const MapApp({super.key});

  @override
  State<MapApp> createState() => _MapAppState();
}

class _MapAppState extends State<MapApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          primaryColor: const Color(0xFF2A2A2A),
        ),
        home: const MapScreen(),
      );
}

class SidebarItem {
  final Widget icon;
  final String title;
  final Widget content;

  const SidebarItem({
    required this.icon,
    required this.title,
    required this.content,
  });
}

class Command {
  final String label;
  final String? shortcut;
  final VoidCallback action;

  const Command({
    required this.label,
    this.shortcut,
    required this.action,
  });
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? leftSelectedTitle;
  String? rightSelectedTitle;
  Widget? leftSideContent;
  Widget? rightSideContent;

  bool showCodeEditor = false;
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _terminalController = TextEditingController();

  double _terminalHeight = 200.0;

  late final List<SidebarItem> leftSidebarItems;
  final List<SidebarItem> rightSidebarItems = [
    SidebarItem(
      icon: const Icon(Icons.analytics,
          color: Colors.white, size: 24), // Telemetry icon
      title: 'Telemetry',
      content: Telemetry(),
    ),
  ];

  bool _showCommandPalette = false;
  final TextEditingController _commandController = TextEditingController();
  final FocusNode _commandFocusNode = FocusNode();

  late final List<Command> commands = [
    Command(
      label: 'New Project',
      shortcut: 'Ctrl+Shift+P',
      action: _createNewProject,
    ),
    Command(
      label: 'New File',
      shortcut: 'Ctrl+N',
      action: _createNewFile,
    ),
    Command(
      label: 'Run Python File',
      shortcut: 'F5',
      action: _runPythonFile,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Replace deprecated RawKeyboard with HardwareKeyboard
    HardwareKeyboard.instance.addHandler(_handleKeyPress);

    // Initialize terminal with welcome message
    _terminalController.text = '> Welcome to Zephyr Terminal\n';

    // Initialize code controller with welcome text
    _codeController.text = '''# Welcome to Zephyr Editor
print("Hello, welcome to Zephyr!")
''';

    // Initialize sidebar items
    leftSidebarItems = [
      SidebarItem(
        icon: const Icon(Icons.code,
            color: Colors.white, size: 24), // Code icon for Codebase
        title: 'Codebase',
        content: CodebaseContainer(
          onFileSelect: _handleFileSelect,
        ),
      ),
      SidebarItem(
        icon: const Icon(Icons.extension,
            color: Colors.white, size: 24), // Extension icon
        title: 'Extensions',
        content: Extension(),
      ),
      SidebarItem(
        icon: const Icon(Icons.science,
            color: Colors.white, size: 24), // Simulation icon
        title: 'Simulation',
        content: Sim(),
      ),
    ];
  }

  void _handleSidebarItemTap(bool isLeft, SidebarItem item) {
    setState(() {
      if (isLeft) {
        if (leftSelectedTitle == item.title) {
          leftSelectedTitle = null;
          leftSideContent = null;
          showCodeEditor = false;
        } else {
          leftSelectedTitle = item.title;
          leftSideContent = item.title == 'Simulation' ? null : item.content;
          showCodeEditor = item.title == 'Codebase';
        }
      } else {
        if (rightSelectedTitle == item.title) {
          rightSelectedTitle = null;
          rightSideContent = null;
        } else {
          rightSelectedTitle = item.title;
          rightSideContent = item.content;
        }
      }
    });
  }

  void _handleFileSelect(String content) {
    setState(() {
      _codeController.text = content;
    });
  }

  bool _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      // Command Palette (Ctrl+Shift+P)
      if (HardwareKeyboard.instance.isControlPressed &&
          HardwareKeyboard.instance.isShiftPressed &&
          event.logicalKey == LogicalKeyboardKey.keyP) {
        setState(() {
          _showCommandPalette = true;
        });
        return true; // Handle the event
      }

      // Run (F5)
      if (event.logicalKey == LogicalKeyboardKey.f5) {
        _runPythonFile();
        return true; // Handle the event
      }
    }
    return false; // Don't handle other events
  }

  void _createNewProject() {
    setState(() {
      _showCommandPalette = false;
      _appendToTerminal('\n> Creating new project...\n');
    });
  }

  void _createNewFile() {
    setState(() {
      _showCommandPalette = false;
      _appendToTerminal('\n> Creating new file...\n');
    });
  }

  void _runPythonFile() {
    _appendToTerminal('\n> Running Python script...\n');
    _appendToTerminal('> ${_codeController.text}\n');
    _appendToTerminal('Output: Hello, welcome to the editor!\n');
  }

  void _appendToTerminal(String text) {
    setState(() {
      final currentText = _terminalController.text;
      _terminalController.value = TextEditingValue(
        text: currentText + text,
        selection: TextSelection.collapsed(
          offset: currentText.length + text.length,
        ),
      );
    });
  }

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
                onPressed: _runPythonFile,
                tooltip: 'Run (F5)',
              ),
              const Text('Python', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        // Code editor area
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
                    controller: _codeController,
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
                          controller: _terminalController,
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
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Row(
                  children: [
                    _buildSidebar(true),
                    if (leftSideContent != null)
                      _buildExpandedPanel(leftSelectedTitle!, leftSideContent!),
                    Expanded(
                      child: Container(
                        color: Colors.black,
                        child: leftSelectedTitle == 'Simulation'
                            ? const Sim()
                            : (showCodeEditor
                                ? _buildCodeEditor()
                                : const Center(
                                    child: Text('Select an option from sidebar',
                                        style: TextStyle(color: Colors.white)),
                                  )),
                      ),
                    ),
                    if (rightSideContent != null)
                      _buildExpandedPanel(
                          rightSelectedTitle!, rightSideContent!),
                    _buildSidebar(false),
                  ],
                ),
              ),
              _buildBottomStatusBar(),
            ],
          ),
          if (_showCommandPalette)
            GestureDetector(
              onTap: () => setState(() => _showCommandPalette = false),
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    width: 500,
                    margin: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _commandController,
                          focusNode: _commandFocusNode,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Type a command or search...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(16),
                          ),
                          onChanged: (value) => setState(() {}),
                        ),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 300),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: commands.length,
                            itemBuilder: (context, index) {
                              final command = commands[index];
                              return ListTile(
                                title: Text(
                                  command.label,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: Text(
                                  command.shortcut ?? '',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                onTap: () {
                                  command.action();
                                  setState(() => _showCommandPalette = false);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        border: Border.all(color: const Color(0xFF00FFFF), width: 1),
      ),
      child: Row(
        children: [
          Image.asset('assets/icons/playstore.png', height: 40),
          const Spacer(),
          const SizedBox(width: 16),
          _buildOnlineStatus(),
        ],
      ),
    );
  }

  Widget _buildOnlineStatus() {
    return const Text(
      'Zephyr',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSidebar(bool isLeft) {
    final items = isLeft ? leftSidebarItems : rightSidebarItems;

    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        border: Border.all(color: const Color(0xFF00FFFF), width: 1),
      ),
      child: Column(
        children: items
            .map((item) => SizedBox(
                  height: 60, // Adjust this value for item height
                  width: 60, // Adjust this value for item width
                  child: IconButton(
                    icon: item.icon,
                    onPressed: () => _handleSidebarItemTap(isLeft, item),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildExpandedPanel(String title, Widget content) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        border: Border.all(color: const Color(0xFF00FFFF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _buildBottomStatusBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        border: Border.all(color: const Color(0xFF00FFFF), width: 1),
      ),
      child: Row(
        children: [
          const Text('Status: Ready', style: TextStyle(color: Colors.white)),
          const Spacer(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Remove keyboard handler
    HardwareKeyboard.instance.removeHandler(_handleKeyPress);
    _commandController.dispose();
    _commandFocusNode.dispose();
    _codeController.dispose();
    _terminalController.dispose();
    super.dispose();
  }
}
