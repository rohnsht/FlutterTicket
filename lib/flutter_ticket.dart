library flutter_ticket;

import 'package:flutter/material.dart';

class TicketCard extends StatefulWidget {
  final EdgeInsets margin;
  final TicketDecoration _decoration;
  final TicketDivider? _divider;
  final Widget topChild, bottomChild;
  final GestureTapCallback? onTap;

  TicketCard({Key? key, 
    this.margin = const EdgeInsets.all(5),
    TicketDecoration? decoration,
    TicketDivider? divider,
    required this.topChild,
    required this.bottomChild,
    this.onTap,
  })  : _decoration = decoration ?? TicketDecoration(),
        _divider = divider, super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TicketCard();
  }
}

class _TicketCard extends State<TicketCard> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.8,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ScaleTransition(
        scale: _animation,
        child: Padding(
          padding: widget.margin,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                painter: _TopPainter(widget._decoration),
                child: widget.topChild,
              ),
              CustomPaint(
                painter: _BottomPainter(widget._decoration),
                foregroundPainter: widget._divider != null
                    ? _DividerPainter(widget._divider!)
                    : null,
                child: widget.bottomChild,
              ),
            ],
          ),
        ),
      ),
      onTapDown: (details) {
        if (widget.onTap != null) {
          _controller.reverse();
        }
      },
      onTapUp: (details) {
        if (widget.onTap != null) {
          _controller.forward();
        }
      },
      onTap: widget.onTap,
    );
  }
}

class _TopPainter extends CustomPainter {
  final TicketDecoration decoration;

  _TopPainter(this.decoration);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = decoration.topColor;

    var path = Path();
    path.moveTo(0.0, decoration.borderRadius);
    path.quadraticBezierTo(0, 0, decoration.borderRadius, 0);
    path.lineTo(size.width - decoration.borderRadius, 0.0);
    path.quadraticBezierTo(size.width, 0, size.width, decoration.borderRadius);
    path.lineTo(size.width, size.height - decoration.clipRadius);
    path.quadraticBezierTo(
        size.width - decoration.clipRadius,
        size.height - decoration.clipRadius,
        size.width - decoration.clipRadius,
        size.height);
    path.lineTo(decoration.clipRadius, size.height);
    path.quadraticBezierTo(
        decoration.clipRadius,
        size.height - decoration.clipRadius,
        0,
        size.height - decoration.clipRadius);
    path.close();

    canvas.drawShadow(path, decoration.shadowColor, decoration.elevation, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _BottomPainter extends CustomPainter {
  final TicketDecoration decoration;

  _BottomPainter(this.decoration);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = decoration.bottomColor;

    var path = Path();
    path.moveTo(0.0, decoration.clipRadius);
    path.quadraticBezierTo(
        decoration.clipRadius, decoration.clipRadius, decoration.clipRadius, 0);
    path.lineTo(size.width - decoration.clipRadius, 0.0);
    path.quadraticBezierTo(size.width - decoration.clipRadius,
        decoration.clipRadius, size.width, decoration.clipRadius);
    path.lineTo(size.width, size.height - decoration.borderRadius);
    path.quadraticBezierTo(size.width, size.height,
        size.width - decoration.borderRadius, size.height);
    path.lineTo(decoration.borderRadius, size.height);
    path.quadraticBezierTo(
        0, size.height, 0, size.height - decoration.borderRadius);
    path.close();

    canvas.drawShadow(path, decoration.shadowColor, decoration.elevation, true);
    canvas.drawPath(path, paint);

    // Inorder to hide the shadow on top of bottom view
    var hackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = decoration.bottomColor;
    canvas.drawLine(
      Offset(decoration.clipRadius, 0),
      Offset(size.width - decoration.clipRadius, 0),
      hackPaint,
    );
    // -----------------------
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _DividerPainter extends CustomPainter {
  final TicketDivider divider;

  _DividerPainter(this.divider);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = divider.dashHeight
      ..color = divider.color;

    // Chage to your preferred size
    double dashWidth = divider.dashWidth;
    double dashSpace = divider.dashSpace;

    // Start to draw from left size.
    // Of course, you can change it to match your requirement.
    double startX = 20;
    double y = 0;

    // Repeat drawing until we reach the right edge.
    while (startX < size.width - 20) {
      // Draw a small line.
      canvas.drawLine(Offset(startX, y), Offset(startX + dashWidth, y), paint);

      // Update the starting X
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class TicketDecoration {
  final Color topColor;
  final Color bottomColor;
  final double borderRadius;
  final double clipRadius;
  final Color shadowColor;
  final double elevation;

  TicketDecoration({
    this.topColor = Colors.white,
    this.bottomColor = Colors.white,
    this.borderRadius = 10.0,
    this.clipRadius = 10.0,
    this.shadowColor = Colors.black,
    this.elevation = 5.0,
  });
}

class TicketDivider {
  final double dashWidth;
  final double dashHeight;
  final double dashSpace;
  final Color color;

  TicketDivider({
    this.dashWidth = 10.0,
    this.dashSpace = 5.0,
    this.dashHeight = 1.0,
    this.color = Colors.grey,
  });
}
