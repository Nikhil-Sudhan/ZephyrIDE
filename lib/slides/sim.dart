import 'package:flutter/material.dart';

class Sim extends StatelessWidget {
  const Sim({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: const Color(0xFF2D2D2D),
            child: const Row(
              children: [
                Text('Simulation', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Simulation Content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
