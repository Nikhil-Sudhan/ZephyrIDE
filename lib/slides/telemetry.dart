import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'telemetry_hud.dart'; // Added to import TelemetryHUD

class Telemetry extends StatefulWidget {
  const Telemetry({super.key});

  @override
  _TelemetryState createState() => _TelemetryState();
}

class _TelemetryState extends State<Telemetry> {
  final Map<String, double> telemetryData = {
    'Altitude': 0.0,
    'Ground Speed': 0.0,
    'Distance': 0.0,
    'Yaw': 0.0,
    'Vertical Speed': 0.0,
    'Distance to Home': 0.0,
  };

  // Add new variables to store additional data
  bool _isArmed = false;
  int _batteryLevel = 0;

  @override
  void initState() {
    super.initState();
    // Change timer duration to 1 second
    Timer.periodic(const Duration(seconds: 1), _updateTelemetryData);
  }

  Future<void> _updateTelemetryData(Timer timer) async {
    try {
      final file = File('lib\\backend\\airsim_data.json');
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString);

      setState(() {
        // Update telemetry data from JSON
        telemetryData['Altitude'] = -data['position']['z'].toDouble();
        telemetryData['Ground Speed'] = _calculateGroundSpeed(
          data['velocity']['x'].toDouble(),
          data['velocity']['y'].toDouble()
        );
        telemetryData['Distance'] = _calculateDistance(
          data['position']['x'].toDouble(),
          data['position']['y'].toDouble()
        );
        telemetryData['Yaw'] = _calculateYaw(data['orientation']);
        telemetryData['Vertical Speed'] = -data['velocity']['z'].toDouble();
        telemetryData['Distance to Home'] = _calculateDistance(
          data['position']['x'].toDouble(),
          data['position']['y'].toDouble()
        );

        // Update status panel data
        _isArmed = data['armed'];
        _batteryLevel = data['battery'];
      });
    } catch (e) {
      print('Error reading telemetry data: $e');
    }
  }

  // Helper functions for calculations
  double _calculateGroundSpeed(double vx, double vy) {
    return sqrt(vx * vx + vy * vy);
  }

  double _calculateDistance(double x, double y) {
    return sqrt(x * x + y * y);
  }

  double _calculateYaw(Map<String, dynamic> orientation) {
      final w = orientation['w'].toDouble();
      final z = orientation['z'].toDouble();
      return (2 * acos(w) * 180 / pi) * z.sign;
    }

  // Update the status panel to use the real armed status and battery level
  Widget _buildStatusPanel() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.cyan, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isArmed ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _isArmed ? Colors.green : Colors.red,
                width: 2,
              ),
            ),
            child: Text(
              _isArmed ? 'ARMED' : 'DISARMED',
              style: TextStyle(
                color: _isArmed ? Colors.green : Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: _isArmed ? Colors.green : Colors.red,
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          Text(
            'Battery: $_batteryLevel%',
            style: TextStyle(
              color: _batteryLevel > 20 ? Colors.cyan : Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: _batteryLevel > 20 ? Colors.cyan : Colors.red,
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: telemetryData.length,
      itemBuilder: (context, index) {
        final key = telemetryData.keys.elementAt(index);
        final value = telemetryData[key]!;
        return _buildTelemetryCard(key, value.toStringAsFixed(1));
      },
    );
  }

  Widget _buildTelemetryCard(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border.all(color: Colors.cyan.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.cyan,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
              shadows: [
                Shadow(
                  color: Colors.cyan.withOpacity(0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TelemetryHUD(),
            _buildStatusPanel(),
            _buildTelemetryGrid(),
            
          ],
        ),
      ),
    );
  }
}