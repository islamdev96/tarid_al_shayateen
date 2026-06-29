import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

import '../app_theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool _hasPermissions = false;
  Position? _currentPosition;
  double? _qiblaBearing;
  bool _isLocating = true;

  final double _kaabaLat = 21.422487;
  final double _kaabaLng = 39.826206;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLocating = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLocating = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLocating = false);
      return;
    }

    setState(() => _hasPermissions = true);
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final bearing = Geolocator.bearingBetween(
        position.latitude, position.longitude, _kaabaLat, _kaabaLng,
      );

      setState(() {
        _currentPosition = position;
        _qiblaBearing = bearing;
        _isLocating = false;
      });
    } catch (e) {
      setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('القبلة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.secondaryColor.withValues(alpha: 0.8), AppTheme.darkBackground],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLocating)
                const Center(child: CircularProgressIndicator(color: Colors.white))
              else if (!_hasPermissions)
                _buildErrorWidget('يرجى تفعيل تصريح الموقع لتحديد اتجاه القبلة.')
              else if (_currentPosition == null)
                _buildErrorWidget('لم نتمكن من تحديد موقعك الحالي.')
              else
                _buildCompass(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.location_slash, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: _checkLocationPermission,
            child: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) return _buildErrorWidget('جهازك لا يدعم البوصلة.');
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.white));

        double? direction = snapshot.data?.heading;
        if (direction == null) return _buildErrorWidget('جهازك لا يدعم البوصلة.');

        final qiblaDirection = _qiblaBearing ?? 0.0;
        final compassRotation = -1 * (direction * (math.pi / 180));
        final kaabaRotation = (qiblaDirection - direction) * (math.pi / 180);

        return Column(
          children: [
            const Text('أنت الآن تتجه نحو', style: TextStyle(color: Colors.white70, fontFamily: 'Cairo', fontSize: 16)),
            Text('${direction.toStringAsFixed(0)}°', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32)),
            const SizedBox(height: 48),
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: compassRotation,
                  child: Container(
                    width: 300, height: 300,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.secondaryColor, width: 4), color: AppTheme.primaryColor.withValues(alpha: 0.8)),
                    child: Stack(
                      children: const [
                        Align(alignment: Alignment.topCenter, child: Padding(padding: EdgeInsets.all(8.0), child: Text('N', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)))),
                        Align(alignment: Alignment.centerRight, child: Padding(padding: EdgeInsets.all(8.0), child: Text('E', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 18)))),
                        Align(alignment: Alignment.bottomCenter, child: Padding(padding: EdgeInsets.all(8.0), child: Text('S', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 18)))),
                        Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.all(8.0), child: Text('W', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 18)))),
                      ],
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: kaabaRotation,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 150, alignment: Alignment.topCenter,
                      child: const Icon(CupertinoIcons.arrow_up_circle_fill, color: AppTheme.secondaryColor, size: 40),
                    ),
                  ),
                ),
                Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ],
            ),
            const SizedBox(height: 48),
            Text('زاوية القبلة: ${qiblaDirection.toStringAsFixed(2)}°', style: const TextStyle(color: Colors.white70, fontFamily: 'Cairo', fontSize: 16)),
          ],
        );
      },
    );
  }
}
