import 'package:flutter/material.dart';

class LoadingSpinner extends StatefulWidget {
  final double size;
  final Color color;

  const LoadingSpinner({
    super.key,
    this.size = 20.0,
    this.color = Colors.white,
  });

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 1),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.rotate(
            angle: value * 2 * 3.14159, // Full rotation
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color,
                  width: 2,
                ),
              ),
              child: CustomPaint(
                painter: LoadingSpinnerPainter(
                  progress: value,
                  color: widget.color,
                ),
              ),
            ),
          );
        },
        onEnd: () {
          // Restart animation
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
  }
}

class LoadingSpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;

  LoadingSpinnerPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 4) / 2;

    // Draw the arc
    final startAngle = -3.14159 / 2; // Start from top
    final sweepAngle = progress * 2 * 3.14159 * 0.75; // 3/4 of a circle

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(LoadingSpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
