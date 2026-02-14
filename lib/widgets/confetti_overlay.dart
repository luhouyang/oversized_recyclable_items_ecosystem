import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool isPlaying;

  const ConfettiOverlay({super.key, required this.child, required this.isPlaying});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _controller.addListener(() => setState(() {
          for (var p in _particles) {
            p.update();
          }
        }));
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _spawnParticles();
      _controller.forward(from: 0);
    }
  }

  void _spawnParticles() {
    _particles.clear();
    for (int i = 0; i < 50; i++) {
      _particles.add(_Particle(_random));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isPlaying)
          IgnorePointer(
            child: CustomPaint(
              painter: _ConfettiPainter(_particles),
              size: Size.infinite,
            ),
          ),
      ],
    );
  }
}

class _Particle {
  double x = 0;
  double y = 0;
  double speedY = 0;
  double speedX = 0;
  Color color = Colors.red;
  double size = 0;

  _Particle(Random random) {
    x = random.nextDouble() * 400; // Random width start
    y = -10; // Start above screen
    speedY = random.nextDouble() * 5 + 2;
    speedX = (random.nextDouble() - 0.5) * 2;
    size = random.nextDouble() * 8 + 4;
    color = Color.fromARGB(
      255,
      random.nextInt(255),
      random.nextInt(255),
      random.nextInt(255),
    );
  }

  void update() {
    y += speedY;
    x += speedX;
    speedY += 0.1; // gravity
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      // Remap particle x to screen width
      double screenX = (p.x / 400) * size.width;
      final paint = Paint()..color = p.color;
      canvas.drawCircle(Offset(screenX, p.y), p.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}