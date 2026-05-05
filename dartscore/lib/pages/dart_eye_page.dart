import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../theme.dart';

class DartEyePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const DartEyePage({super.key, required this.cameras});

  @override
  State<DartEyePage> createState() => _DartEyePageState();
}

class _DartEyePageState extends State<DartEyePage> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(controller),
          
          // Cyber Grid Overlay
          CustomPaint(
            painter: _CyberGridPainter(),
          ),
          
          // UI Overlays
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(),
                _buildControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DART-EYE AR',
                style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                'KINETIC GUIDANCE ACTIVE',
                style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1),
              ),
            ],
          ),
          const Spacer(),
          const _PulseDot(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(icon: Icons.filter_center_focus, label: 'CALIBRATE', onTap: () {}),
          _ActionButton(icon: Icons.camera_alt, label: 'CAPTURE', onTap: () {}, isPrimary: true),
          _ActionButton(icon: Icons.settings_overscan, label: 'SCAN', onTap: () {}),
        ],
      ),
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw grid lines
    for (var i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }
    for (var i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }

    // Draw central reticle
    final centerPaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 40, centerPaint);
    canvas.drawLine(
      Offset(size.width / 2 - 60, size.height / 2),
      Offset(size.width / 2 + 60, size.height / 2),
      centerPaint,
    );
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2 - 60),
      Offset(size.width / 2, size.height / 2 + 60),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isPrimary ? AppTheme.primary : Colors.white10,
            shape: BoxShape.circle,
            boxShadow: isPrimary ? [
              BoxShadow(color: AppTheme.primary.withValues(alpha: 0.5), blurRadius: 20)
            ] : [],
          ),
          child: IconButton(
            icon: Icon(icon, color: isPrimary ? Colors.black : Colors.white),
            onPressed: onTap,
            iconSize: isPrimary ? 32 : 24,
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.8, end: 1.2).animate(_controller),
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
