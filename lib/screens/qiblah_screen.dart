import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/glassy_background.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';

class QiblahScreen extends StatefulWidget {
  const QiblahScreen({super.key});

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

class _QiblahScreenState extends State<QiblahScreen> {
  bool _showMap = false;
  Position? _userPosition;
  bool _isLoadingLocation = false;

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('خدمات الموقع غير مفعلة في الهاتف.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('تم رفض الوصول إلى موقعك الجغرافي.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('تم رفض صلاحيات الموقع بشكل دائم. يرجى تفعيلها من إعدادات النظام.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      setState(() {
        _userPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _hasHapticFeedbackTriggered = false;

  // Spherical trigonometry calculation of Qiblah direction from Makkah
  double _calculateQiblah(double latitude, double longitude) {
    const double makkahLat = 21.422487;
    const double makkLng = 39.826206;

    final double phi = latitude * math.pi / 180.0;
    final double lambda = longitude * math.pi / 180.0;
    final double phiM = makkahLat * math.pi / 180.0;
    final double lambdaM = makkLng * math.pi / 180.0;

    final double deltaLambda = lambdaM - lambda;

    final double y = math.sin(deltaLambda);
    final double x = math.cos(phi) * math.tan(phiM) - math.sin(phi) * math.cos(deltaLambda);

    double qiblahRad = math.atan2(y, x);
    double qiblahDeg = qiblahRad * 180.0 / math.pi;

    return (qiblahDeg + 360.0) % 360.0;
  }

  // Calculate distance to Kaaba in kilometers
  double _calculateDistanceToKaaba(double lat, double lng) {
    const double r = 6371.0; // Earth radius in km
    const double makkahLat = 21.422487;
    const double makkahLng = 39.826206;

    final double dLat = (makkahLat - lat) * math.pi / 180.0;
    final double dLng = (makkahLng - lng) * math.pi / 180.0;

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat * math.pi / 180.0) *
            math.cos(makkahLat * math.pi / 180.0) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final city = provider.selectedCity;

    final double userLat = _userPosition?.latitude ?? city.latitude;
    final double userLng = _userPosition?.longitude ?? city.longitude;
    final String locationName = _userPosition != null ? 'موقعي الفعلي' : city.nameAr;

    final double qiblahAngle = _calculateQiblah(userLat, userLng);
    final double distance = _calculateDistanceToKaaba(userLat, userLng);

    return Scaffold(
      body: GlassyBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom Navigation Top Bar
              _buildTopBar(theme),

              // Top Segment Switch
              _buildTopSegmentControl(theme, isDark),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        
                        // Header with city info
                        _buildCityHeader(locationName, qiblahAngle, distance, theme, isDark),
                        
                        const SizedBox(height: 30),

                        if (_showMap)
                          _isLoadingLocation
                              ? const SizedBox(
                                  height: 380,
                                  child: Center(
                                    child: CupertinoActivityIndicator(radius: 14),
                                  ),
                                )
                              : _buildMapUI(userLat, userLng, theme, isDark)
                        else ...[
                          // Interactive Compass stream
                          StreamBuilder<CompassEvent>(
                            stream: FlutterCompass.events,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return _buildFallbackCompass(qiblahAngle, theme, isDark, error: 'حدث خطأ في قراءة المستشعر');
                              }

                              // If compass sensor is not supported, or returned null data
                              final data = snapshot.data;
                              if (data == null || data.heading == null) {
                                return _buildFallbackCompass(qiblahAngle, theme, isDark);
                              }

                              final double heading = data.heading!;
                              
                              // The compass rotation is -heading (to orient dial with north)
                              final double compassRotation = -heading * math.pi / 180.0;
                              // The Qiblah offset in screen space: Qiblah angle - heading
                              final double relativeQiblah = (qiblahAngle - heading + 360.0) % 360.0;
                              
                              // Check if phone is aligned with Qiblah (within 5 degrees)
                              final bool isAligned = (relativeQiblah < 5 || relativeQiblah > 355);

                              if (isAligned) {
                                if (!_hasHapticFeedbackTriggered) {
                                  HapticFeedback.mediumImpact();
                                  _hasHapticFeedbackTriggered = true;
                                }
                              } else {
                                _hasHapticFeedbackTriggered = false;
                              }

                              return Column(
                                children: [
                                  _buildCompassUI(
                                    compassRotation: compassRotation,
                                    qiblahAngleRad: qiblahAngle * math.pi / 180.0,
                                    isAligned: isAligned,
                                    theme: theme,
                                    isDark: isDark,
                                    relativeQiblah: relativeQiblah,
                                  ),
                                  const SizedBox(height: 32),
                                  _buildAlignmentIndicator(isAligned, relativeQiblah, theme),
                                ],
                              );
                            },
                          ),
                          
                          const SizedBox(height: 30),

                          // Compass calibration tips
                          _buildCalibrationCard(theme, isDark),
                        ],
                        const SizedBox(height: 120), // Padding to avoid overlap with mini player
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSegmentControl(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: CupertinoSegmentedControl<bool>(
        groupValue: _showMap,
        borderColor: theme.colorScheme.primary,
        selectedColor: theme.colorScheme.primary,
        unselectedColor: Colors.transparent,
        pressedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        children: {
          false: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.compass, size: 18),
                const SizedBox(width: 6),
                Text('البوصلة', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: _showMap ? FontWeight.normal : FontWeight.bold)),
              ],
            ),
          ),
          true: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.map, size: 18),
                const SizedBox(width: 6),
                Text('الخريطة التفاعلية', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: _showMap ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
        },
        onValueChanged: (val) {
          setState(() {
            _showMap = val;
          });
          if (val && _userPosition == null) {
            _determinePosition();
          }
        },
      ),
    );
  }

  Widget _buildMapUI(double userLat, double userLng, ThemeData theme, bool isDark) {
    final MapController mapController = MapController();
    return Column(
      children: [
        GlassCard(
          clipBehavior: Clip.antiAlias,
          height: 380,
          width: double.infinity,
          child: Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: LatLng(userLat, userLng),
                  initialZoom: 4.5,
                  maxZoom: 18,
                  minZoom: 2,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.islamglab.tarid_al_shayateen',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          LatLng(userLat, userLng),
                          LatLng(21.422487, 39.826206),
                        ],
                        color: isDark ? AppTheme.gold : AppTheme.primaryGreen,
                        strokeWidth: 4.0,
                        isDotted: true,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      // User Location Marker
                      Marker(
                        point: LatLng(userLat, userLng),
                        width: 50,
                        height: 50,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 6),
                                ],
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(CupertinoIcons.person_fill, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ),
                      // Makkah Kaaba Marker
                      Marker(
                        point: LatLng(21.422487, 39.826206),
                        width: 50,
                        height: 50,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppTheme.gold : AppTheme.lightGold,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 6),
                                ],
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.mosque, color: Colors.black, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Map Zoom / Recenter Buttons on top of map
              Positioned(
                bottom: 12,
                right: 12,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoom_in',
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      onPressed: () => mapController.move(mapController.camera.center, mapController.camera.zoom + 1),
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoom_out',
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      onPressed: () => mapController.move(mapController.camera.center, mapController.camera.zoom - 1),
                      child: const Icon(Icons.remove),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'recenter',
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                      onPressed: () => mapController.move(LatLng(userLat, userLng), 5),
                      child: const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Locate me button to request geolocation manually
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _determinePosition,
          icon: const Icon(CupertinoIcons.location_solid, size: 16),
          label: const Text('تحديث الموقع الفعلي عبر GPS', style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(CupertinoIcons.back, color: theme.colorScheme.primary),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'اتجاه القبلة',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
          const SizedBox(width: 48), // Spacer to balance back button
        ],
      ),
    );
  }

  Widget _buildCityHeader(String cityName, double qiblahAngle, double distance, ThemeData theme, bool isDark) {
    return GlassCard(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Icon(CupertinoIcons.location_solid, color: theme.colorScheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            'موقعك الحالي: $cityName',
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHeaderStat(
                icon: CupertinoIcons.compass,
                label: 'انحراف القبلة',
                value: '${qiblahAngle.toStringAsFixed(1)}°',
                theme: theme,
                isDark: isDark,
              ),
              Container(width: 0.5, height: 32, color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.15)),
              _buildHeaderStat(
                icon: CupertinoIcons.map,
                label: 'المسافة للكعبة',
                value: '${distance.toStringAsFixed(0)} كم',
                theme: theme,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: isDark ? AppTheme.textMuted : AppTheme.lightTextMuted, fontSize: 11, fontFamily: 'Cairo'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: theme.colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
      ],
    );
  }

  Widget _buildCompassUI({
    required double compassRotation,
    required double qiblahAngleRad,
    required bool isAligned,
    required ThemeData theme,
    required bool isDark,
    required double relativeQiblah,
  }) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark 
                ? const Color(0xFF0C1921).withValues(alpha: 0.45) 
                : Colors.white.withValues(alpha: 0.45),
            border: Border.all(
              color: isAligned
                  ? AppTheme.successGreen.withValues(alpha: 0.6)
                  : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.35)),
              width: isAligned ? 2.5 : 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isAligned
                    ? AppTheme.successGreen.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: isAligned ? 30 : 16,
                spreadRadius: isAligned ? 2 : 0,
              )
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating Compass Card (North, South, East, West marks)
              Transform.rotate(
                angle: compassRotation,
                child: CustomPaint(
                  size: const Size(240, 240),
                  painter: CompassPainter(isDark: isDark, theme: theme),
                ),
              ),

              // Glowing Pointer to Kaaba/Qiblah
              Transform.rotate(
                angle: compassRotation + qiblahAngleRad,
                child: CustomPaint(
                  size: const Size(220, 220),
                  painter: QiblahPointerPainter(isAligned: isAligned, theme: theme),
                ),
              ),

              // Central mosque/Kaaba icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isAligned ? AppTheme.successGreen : theme.colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: (isAligned ? AppTheme.successGreen : theme.colorScheme.primary).withValues(alpha: 0.4),
                      blurRadius: 12,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlignmentIndicator(bool isAligned, double relativeQiblah, ThemeData theme) {
    if (isAligned) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        borderRadius: BorderRadius.circular(30),
        color: AppTheme.successGreen.withValues(alpha: 0.18),
        border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.6), width: 1.5),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.checkmark_circle_fill, color: AppTheme.successGreen, size: 20),
            SizedBox(width: 8),
            Text(
              'أنت تتجه نحو القبلة الآن',
              style: TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Cairo'),
            ),
          ],
        ),
      );
    } else {
      // Guide user on which direction to turn
      final bool turnLeft = relativeQiblah > 180;
      final double difference = turnLeft ? 360.0 - relativeQiblah : relativeQiblah;
      
      return GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              turnLeft ? CupertinoIcons.rotate_left : CupertinoIcons.rotate_right,
              color: theme.colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'أدر هاتفك ${turnLeft ? "يساراً" : "يميناً"} بمقدار ${difference.toStringAsFixed(0)}°',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFallbackCompass(double qiblahAngle, ThemeData theme, bool isDark, {String? error}) {
    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          borderRadius: BorderRadius.circular(16),
          color: Colors.orange.withValues(alpha: 0.15),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.4), width: 0.5),
          child: Row(
            children: [
              const Icon(CupertinoIcons.bell_slash, color: Colors.orange, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error ?? 'جهازك الحالي لا يدعم مستشعر البوصلة. نعرض لك زاوية اتجاه القبلة الثابتة لموقعك الحالي.',
                  style: const TextStyle(color: Colors.orange, fontSize: 13, height: 1.5, fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
        ),
        // Draw static compass showing North and the Qiblah angle pointer
        _buildCompassUI(
          compassRotation: 0.0, // Static compass, North is at top
          qiblahAngleRad: qiblahAngle * math.pi / 180.0,
          isAligned: false,
          theme: theme,
          isDark: isDark,
          relativeQiblah: qiblahAngle,
        ),
        const SizedBox(height: 24),
        Text(
          'القبلة تنحرف بمقدار ${qiblahAngle.toStringAsFixed(0)}° من اتجاه الشمال (باتجاه الشرق)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildCalibrationCard(ThemeData theme, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.lightbulb, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'نصائح لمعايرة البوصلة ودقة التوجيه:',
                style: TextStyle(color: theme.colorScheme.primary, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('ضع الهاتف في وضع أفقي مسطح تماماً على راحة يدك أو على سطح مستوٍ.', theme, isDark),
          _buildTipItem('ابتعد عن الأجهزة الإلكترونية الكبيرة، الأسطح المعدنية، أو الحوافظ الممغنطة لتجنب التشويش المغناطيسي.', theme, isDark),
          _buildTipItem('إذا كانت البوصلة غير دقيقة، أدر الهاتف في الهواء برسم رقم ثمانية (8) باللغة الإنجليزية لمعايرة الحساس.', theme, isDark),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, left: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                fontSize: 12,
                height: 1.5,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Painter for drawing the compass dial (marks, text for N, S, E, W)
class CompassPainter extends CustomPainter {
  final bool isDark;
  final ThemeData theme;

  CompassPainter({required this.isDark, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1);

    // Draw outer circle
    canvas.drawCircle(center, radius - 10, paint);

    // Draw dial markings
    final tickPaint = Paint()
      ..strokeWidth = 1.0
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15);

    for (int i = 0; i < 360; i += 5) {
      final double angle = i * math.pi / 180.0;
      final double tickLength = (i % 30 == 0) ? 10.0 : 5.0;

      final start = Offset(
        center.dx + (radius - 10 - tickLength) * math.cos(angle),
        center.dy + (radius - 10 - tickLength) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 10) * math.cos(angle),
        center.dy + (radius - 10) * math.sin(angle),
      );

      canvas.drawLine(start, end, tickPaint);
    }

    // Draw main cardinal direction texts (N, S, E, W)
    _drawText(canvas, center, radius - 30, 'ش', 0.0); // North (0 / 360 degrees) - at top
    _drawText(canvas, center, radius - 30, 'ق', math.pi / 2);  // East (90 degrees)
    _drawText(canvas, center, radius - 30, 'ج', math.pi);      // South (180 degrees)
    _drawText(canvas, center, radius - 30, 'غ', -math.pi / 2); // West (270 degrees)
  }

  void _drawText(Canvas canvas, Offset center, double offsetDistance, String text, double angle) {
    final double rad = angle - math.pi / 2;
    final position = Offset(
      center.dx + offsetDistance * math.cos(rad),
      center.dy + offsetDistance * math.sin(rad),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: text == 'ش' ? AppTheme.gold : (isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
          fontSize: text == 'ش' ? 16 : 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
      textDirection: TextDirection.rtl,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter for drawing the Qiblah direction arrow/pointer
class QiblahPointerPainter extends CustomPainter {
  final bool isAligned;
  final ThemeData theme;

  QiblahPointerPainter({required this.isAligned, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Direction pointer
    final pointerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isAligned ? AppTheme.successGreen : AppTheme.gold;

    final path = Path();
    path.moveTo(center.dx, center.dy - radius + 15);
    path.lineTo(center.dx - 12, center.dy - radius + 38);
    path.lineTo(center.dx + 12, center.dy - radius + 38);
    path.close();

    canvas.drawPath(path, pointerPaint);

    // Draw dashed lines linking center to pointer
    final linePaint = Paint()
      ..color = (isAligned ? AppTheme.successGreen : AppTheme.gold).withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final dashPath = Path();
    dashPath.moveTo(center.dx, center.dy - 26);
    dashPath.lineTo(center.dx, center.dy - radius + 38);

    double dashWidth = 5.0, dashSpace = 4.0, distance = 0.0;
    final pathMetrics = dashPath.computeMetrics();
    for (final metric in pathMetrics) {
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          linePaint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant QiblahPointerPainter oldDelegate) {
    return oldDelegate.isAligned != isAligned;
  }
}
