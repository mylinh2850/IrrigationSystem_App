import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveProgressIndicator extends StatefulWidget {
  final double value;
  final double size;
  final double borderWidth;
  final Color color;

  WaveProgressIndicator({
    required this.value,
    required this.size,
    required this.borderWidth,
    required this.color,
  });

  @override
  _WaveProgressIndicatorState createState() => _WaveProgressIndicatorState();
}

class _WaveProgressIndicatorState extends State<WaveProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ClipPath(
              clipper: WaveClipper(widget.value, _waveAnimation.value),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: widget.borderWidth,
                    color: widget.color.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                '${(widget.value * 100).toInt()}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double value;
  final double wavePhase;

  WaveClipper(this.value, this.wavePhase);

  @override
  Path getClip(Size size) {
    final path = Path();
    final waveHeight = size.height * (1 - value);
    final waveWidth = size.width;

    path.moveTo(0, waveHeight);
    for (double i = 0; i <= waveWidth; i++) {
      path.lineTo(i, waveHeight + math.sin((i / waveWidth * 2 * math.pi) + wavePhase) * 8);
    }
    path.lineTo(waveWidth, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) {
    return oldClipper.value != value || oldClipper.wavePhase != wavePhase;
  }
}
