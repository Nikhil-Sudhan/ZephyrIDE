import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class TelemetryHUD extends StatefulWidget {
  @override
  _TelemetryHUDState createState() => _TelemetryHUDState();
}

class _TelemetryHUDState extends State<TelemetryHUD> {
  double _heading = 0.0;
  double _speed = 0.0;
  double _altitude = 0.0;
  int _battery = 0;
  String _gpsSignal = "NO GPS";
  bool _isArmed = false;

  @override
  void initState() {
    super.initState();
    // Start periodic timer to fetch data
    Timer.periodic(const Duration(milliseconds: 100), _updateHUDData);
  }

  Future<void> _updateHUDData(Timer timer) async {
    try {
      final file = File('lib/backend/airsim_data.json');
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString);

      setState(() {
        // Update HUD data from JSON
        _altitude = -data['position']['z'].toDouble();
        _speed = _calculateGroundSpeed(
          data['velocity']['x'].toDouble(),
          data['velocity']['y'].toDouble()
        );
        _heading = _calculateHeading(data['orientation']);
        _battery = data['battery'];
        _isArmed = data['armed'];
        _gpsSignal = _isArmed ? "GPS LOCK" : "NO GPS";
      });
    } catch (e) {
      print('Error reading HUD data: $e');
    }
  }

  double _calculateGroundSpeed(double vx, double vy) {
    return sqrt(vx * vx + vy * vy);
  }

  double _calculateHeading(Map<String, dynamic> orientation) {
    final w = orientation['w'].toDouble();
    final z = orientation['z'].toDouble();
    return (2 * acos(w) * 180 / pi) * z.sign;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border.all(color: Colors.cyan, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(8),
      child: Stack(
        children: [
          Center(
            child: Container(
              height: 250,
              width: 350,
              child: HorizonWidget()
            )
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(5),
              ),
              child: CompassWidget(heading: _heading),
            ),
          ),
          Positioned(
            left: 20,
            top: 20,
            child: SpeedIndicator(speed: _speed),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: AltitudeIndicator(altitude: _altitude),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: BatteryStatus(battery: _battery),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GPSStatus(gpsSignal: _gpsSignal),
          ),
        ],
      ),
    );
  }
}

class HorizonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HorizonPainter(),
      size: Size(350, 250),
    );
  }
}

class HorizonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint skyPaint = Paint()..color = Colors.blue[700]!;
    Paint groundPaint = Paint()..color = Colors.brown[600]!;
    Paint linePaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw sky and ground
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height/2), skyPaint);
    canvas.drawRect(Rect.fromLTWH(0, size.height/2, size.width, size.height/2), groundPaint);
    
    // Draw horizon line
    canvas.drawLine(
      Offset(0, size.height/2),
      Offset(size.width, size.height/2),
      linePaint,
    );

    // Draw attitude reference lines
    for (int i = -2; i <= 2; i++) {
      if (i == 0) continue;
      canvas.drawLine(
        Offset(size.width/2 - 50, size.height/2 + (i * 30)),
        Offset(size.width/2 + 50, size.height/2 + (i * 30)),
        linePaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CompassWidget extends StatelessWidget {
  final double heading;
  CompassWidget({required this.heading});
  
  @override
  Widget build(BuildContext context) {
    return Text(
      "${heading.toStringAsFixed(0)}°",
      style: TextStyle(
        color: Colors.cyan,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Colors.cyanAccent, blurRadius: 5),
        ],
      ),
    );
  }
}

class SpeedIndicator extends StatelessWidget {
  final double speed;
  SpeedIndicator({required this.speed});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.cyan.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SPEED",
            style: TextStyle(color: Colors.cyan, fontSize: 12),
          ),
          Text(
            "${speed.toStringAsFixed(1)} m/s",
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AltitudeIndicator extends StatelessWidget {
  final double altitude;
  AltitudeIndicator({required this.altitude});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.cyan),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "ALTITUDE",
            style: TextStyle(color: Colors.cyan, fontSize: 12),
          ),
          Text(
            "${altitude.toStringAsFixed(1)} m",
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class BatteryStatus extends StatelessWidget {
  final int battery;
  
  BatteryStatus({required this.battery});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: battery > 20 ? Colors.cyan : Colors.red,
        ),
      ),
      child: Text(
        "Battery: $battery%",
        style: TextStyle(
          color: battery > 20 ? Colors.cyan : Colors.red,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: battery > 20 ? Colors.cyanAccent : Colors.redAccent,
              blurRadius: 5,
            ),
          ],
        ),
      ),
    );
  }
}

class GPSStatus extends StatelessWidget {
  final String gpsSignal;
  
  GPSStatus({required this.gpsSignal});
  
  @override
  Widget build(BuildContext context) {
    final bool hasGPS = gpsSignal == "GPS LOCK";
    
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: hasGPS ? Colors.cyan : Colors.red,
        ),
      ),
      child: Text(
        gpsSignal,
        style: TextStyle(
          color: hasGPS ? Colors.cyan : Colors.red,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: hasGPS ? Colors.cyanAccent : Colors.redAccent,
              blurRadius: 5,
            ),
          ],
        ),
      ),
    );
  }
}