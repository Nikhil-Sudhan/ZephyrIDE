
import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';
import 'dart:io';

class Sim extends StatefulWidget {
  const Sim({super.key});

  @override
  State<Sim> createState() => _SimState();
}

class _SimState extends State<Sim> {
  FlutterNativeView? _nativeView;
  Process? _process;
  final NativeViewController _controller = NativeViewController(handle: 0);

  @override
  void initState() {
    super.initState();
    _initializeNativeView();
  }

  Future<void> _initializeNativeView() async {
    try {
      // Create a new native view instance.
      _nativeView = FlutterNativeView();
      debugPrint("Native view initialized.");

      // Kill any existing process if still running.
      if (_process != null) {
        _process!.kill();
        _process = null;
        debugPrint("Previous process killed.");
      }

      // Start the external process.
      _process = await Process.start(
        'F://ZephyrIDE updated//lib//Airsim//MyProject.exe',
        [],
        mode: ProcessStartMode.detached,
      );
      debugPrint("Started myproject.exe, PID: ${_process!.pid}");

      setState(() {});

      // Listen for process exit and log the exit code.
      _process?.exitCode.then((code) {
        debugPrint('Process exited with code $code');
      });
    } catch (e, stack) {
      debugPrint('Error initializing native view: $e\n$stack');
    }
  }

  @override
  void dispose() {
    _process?.kill();
    // Note: Dispose of _nativeView if needed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: const Color(0xFF2D2D2D),
          child: Row(
            children: [
              const Text(
                'Simulation View', // Added missing title text
                style: TextStyle(color: Colors.white70),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70),
                onPressed: () async {
                  debugPrint("Restart Simulation pressed.");
                  await _initializeNativeView();
                },
                tooltip: 'Restart Simulation',
              ),
            ],
          ),
        ),
        Expanded(
          child: _nativeView != null
              ? NativeView(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 40,
                  controller: _controller,
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ],
    );
  }
}
