import 'dart:async';
import 'package:flutter/material.dart';
import 'data/mock_bisindo_data.dart';

/// SLICING MODE - Pure UI, no camera / no flutter_vision / no fetching
/// Semua detection adalah mock data dari [MockBisindoData]
class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  static const Color primaryTeal = Color(0xFF004D40);

  // === SLICING STATE ===
  bool _isAlphabetMode = true;
  bool isDetecting = false;
  bool debugMode = false;
  double displayConfThreshold = 0.40;

  int _currentScenarioIndex = 0;
  List<MockDetection> _mockResults = [];
  Timer? _mockTimer;

  // Untuk animasi smoothing box (opsional slicing)
  final Map<String, List<double>> _prevDisplayBoxes = {};

  List<List<MockDetection>> get _activeScenarios => _isAlphabetMode
      ? MockBisindoData.alphabetScenarios
      : MockBisindoData.wordScenarios;

  @override
  void dispose() {
    _mockTimer?.cancel();
    super.dispose();
  }

  // === MOCK LOGIC ===

  void _startMockDetection() {
    if (isDetecting) return;
    setState(() {
      isDetecting = true;
      _currentScenarioIndex = 0;
      _mockResults = _filterByThreshold(_activeScenarios[0]);
    });
    _mockTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      _cycleMock();
    });
  }

  void _stopMockDetection() {
    _mockTimer?.cancel();
    _mockTimer = null;
    setState(() {
      isDetecting = false;
      _mockResults = [];
      _prevDisplayBoxes.clear();
    });
  }

  void _cycleMock() {
    if (!isDetecting || !mounted) return;
    setState(() {
      _currentScenarioIndex = (_currentScenarioIndex + 1) % _activeScenarios.length;
      _mockResults = _filterByThreshold(_activeScenarios[_currentScenarioIndex]);
    });
  }

  List<MockDetection> _filterByThreshold(List<MockDetection> input) {
    return input.where((e) => e.conf >= displayConfThreshold).toList();
  }

  void _toggleMode() {
    setState(() {
      _isAlphabetMode = !_isAlphabetMode;
      _currentScenarioIndex = 0;
      _prevDisplayBoxes.clear();
      if (isDetecting) {
        _mockResults = _filterByThreshold(_activeScenarios[0]);
      } else {
        _mockResults = [];
      }
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isAlphabetMode ? "Mode ABJAD (Hanya Huruf)" : "Mode KATA (Hanya Kata)"),
        duration: const Duration(seconds: 1),
        backgroundColor: primaryTeal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMockCameraInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Slicing mode — camera dimock, tidak ada fetching"),
        backgroundColor: primaryTeal,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // === UI HELPERS ===

  void _showBisindoLibrary() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: primaryTeal,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text("ABJAD BISINDO",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Flexible(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset('assets/abjad.jfif', fit: BoxFit.contain),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mock preview - ganti CameraPreview
  Widget _buildMockPreview(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade900, Colors.grey.shade800, Colors.grey.shade900],
        ),
      ),
      child: Stack(
        children: [
          // Grid pattern tipis biar keliatan kayak viewfinder
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),
          // Center placeholder
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                  ),
                  child: Icon(
                    isDetecting ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                    size: 56,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Text(
                    isDetecting ? "MOCK PREVIEW • SLICING MODE" : "PREVIEW DIMOCK",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isDetecting ? "Deteksi berjalan dengan mock data" : "Tekan play untuk simulasi deteksi",
                  style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
                ),
              ],
            ),
          ),
          // Corner brackets (viewfinder)
          Positioned.fill(child: CustomPaint(painter: _ViewfinderPainter())),
          // Mode badge top-left
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDetecting ? Colors.greenAccent : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isDetecting ? "LIVE • MOCK" : "IDLE • MOCK",
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                  ),
                ],
              ),
            ),
          ),
          // Scenario indicator top-right
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: primaryTeal.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "SCENARIO ${_currentScenarioIndex + 1}/${_activeScenarios.length}",
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBoxes(BoxConstraints constraints) {
    if (_mockResults.isEmpty) return [];
    return _mockResults.map((det) {
      // box normalized 0-1 => convert to absolute
      final double l = det.box[0] * constraints.maxWidth;
      final double t = det.box[1] * constraints.maxHeight;
      final double r = det.box[2] * constraints.maxWidth;
      final double b = det.box[3] * constraints.maxHeight;

      double left = l;
      double top = t;
      double right = r;
      double bottom = b;

      // simple smoothing (slicing aesthetic)
      final key = det.tag;
      if (_prevDisplayBoxes.containsKey(key)) {
        final prev = _prevDisplayBoxes[key]!;
        const double a = 0.7;
        left = prev[0] + (left - prev[0]) * a;
        top = prev[1] + (top - prev[1]) * a;
        right = prev[2] + (right - prev[2]) * a;
        bottom = prev[3] + (bottom - prev[3]) * a;
      }
      _prevDisplayBoxes[key] = [left, top, right, bottom];

      final Color borderColor = det.conf >= 0.75 ? Colors.greenAccent.shade400 : Colors.yellow.shade600;
      const double radius = 8;

      return Positioned(
        left: left,
        top: top,
        width: (right - left).abs(),
        height: (bottom - top).abs(),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2.5),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: const BoxDecoration(
                color: primaryTeal,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius - 1),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Text(
                "${det.tag} ${(det.conf * 100).toStringAsFixed(0)}%",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildStatusIndicator() {
    final detectedTags = _mockResults.map((r) => r.tag).join(', ');
    final displayText = detectedTags.isEmpty ? (isDetecting ? "Mencari..." : "Siap — tekan Play") : detectedTags.toUpperCase();
    final color = detectedTags.isEmpty ? Colors.grey.shade700 : Colors.green.shade600;

    final String modeLabel = _isAlphabetMode ? "MODE: ABJAD" : "MODE: KATA";
    final Color modeColor = _isAlphabetMode ? Colors.orange.shade800 : primaryTeal;

    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: modeColor.withOpacity(0.95), borderRadius: BorderRadius.circular(20)),
            child: Text(modeLabel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: color.withOpacity(0.92), borderRadius: BorderRadius.circular(30)),
            child: Text(displayText,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ),
          if (isDetecting && _mockResults.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "Mock scenario kosong — simulasi tidak ada tangan terdeteksi",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDebugPanel() {
    return Positioned(
      bottom: 200,
      left: 20,
      right: 20,
      child: Card(
        color: Colors.black.withOpacity(0.55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bug_report, color: Colors.white70, size: 16),
                  const SizedBox(width: 6),
                  const Text("Debug • Slicing Mock", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Text("Scenarios: ${_activeScenarios.length}", style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text("Threshold: ${displayConfThreshold.toStringAsFixed(2)} • Hasil: ${_mockResults.length}",
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Slider(
                value: displayConfThreshold,
                min: 0.1,
                max: 0.9,
                activeColor: primaryTeal,
                inactiveColor: Colors.white24,
                onChanged: (v) {
                  setState(() {
                    displayConfThreshold = v;
                    if (isDetecting) {
                      _mockResults = _filterByThreshold(_activeScenarios[_currentScenarioIndex]);
                    }
                  });
                },
              ),
              const Text("Geser threshold untuk filter mock conf (slicing demo)",
                  style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BISINDO Detector"),
        actions: [
          IconButton(
            icon: Icon(
              _isAlphabetMode ? Icons.abc : Icons.chat_bubble_outline,
              color: _isAlphabetMode ? Colors.amber.shade700 : primaryTeal,
              size: 28,
            ),
            tooltip: "Ganti Mode (Mock)",
            onPressed: _toggleMode,
          ),
          IconButton(icon: const Icon(Icons.menu_book_rounded), onPressed: _showBisindoLibrary, color: primaryTeal),
          IconButton(icon: const Icon(Icons.cameraswitch_outlined), onPressed: _showMockCameraInfo, color: primaryTeal),
          IconButton(
            icon: Icon(debugMode ? Icons.bug_report : Icons.bug_report_outlined),
            onPressed: () => setState(() => debugMode = !debugMode),
            color: primaryTeal,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              _buildMockPreview(constraints),
              Positioned.fill(child: Stack(children: _buildBoxes(constraints))),
              if (debugMode) _buildDebugPanel(),
              _buildStatusIndicator(),
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Prev scenario
                      if (isDetecting)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: FloatingActionButton.small(
                            heroTag: "fab_prev",
                            backgroundColor: Colors.white,
                            foregroundColor: primaryTeal,
                            onPressed: () {
                              setState(() {
                                _currentScenarioIndex =
                                    (_currentScenarioIndex - 1 + _activeScenarios.length) % _activeScenarios.length;
                                _mockResults = _filterByThreshold(_activeScenarios[_currentScenarioIndex]);
                              });
                            },
                            child: const Icon(Icons.skip_previous_rounded),
                          ),
                        ),
                      FloatingActionButton(
                        heroTag: "fab_action",
                        onPressed: isDetecting ? _stopMockDetection : _startMockDetection,
                        backgroundColor: isDetecting ? Colors.red.shade700 : primaryTeal,
                        foregroundColor: Colors.white,
                        child: Icon(isDetecting ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 32),
                      ),
                      if (isDetecting)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: FloatingActionButton.small(
                            heroTag: "fab_next",
                            backgroundColor: Colors.white,
                            foregroundColor: primaryTeal,
                            onPressed: _cycleMock,
                            child: const Icon(Icons.skip_next_rounded),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.6;
    const double step = 40;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const double len = 28;
    const double inset = 14;
    // top-left
    canvas.drawPath(
      Path()
        ..moveTo(inset, inset + len)
        ..lineTo(inset, inset)
        ..lineTo(inset + len, inset),
      paint,
    );
    // top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - inset - len, inset)
        ..lineTo(size.width - inset, inset)
        ..lineTo(size.width - inset, inset + len),
      paint,
    );
    // bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(inset, size.height - inset - len)
        ..lineTo(inset, size.height - inset)
        ..lineTo(inset + len, size.height - inset),
      paint,
    );
    // bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - inset - len, size.height - inset)
        ..lineTo(size.width - inset, size.height - inset)
        ..lineTo(size.width - inset, size.height - inset - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
