library;

import 'package:flutter/material.dart';

class TicketCard extends StatefulWidget {
  final EdgeInsets margin;
  final TicketDecoration _decoration;
  final TicketDivider? _divider;
  final int topFlex, bottomFlex;
  final Widget topChild, bottomChild;
  final GestureTapCallback? onTap;

  TicketCard({
    super.key,
    this.margin = const EdgeInsets.all(5),
    TicketDecoration? decoration,
    TicketDivider? divider,
    this.topFlex = 1,
    this.bottomFlex = 1,
    required this.topChild,
    required this.bottomChild,
    this.onTap,
  })  : _decoration = decoration ?? TicketDecoration(),
        _divider = divider;

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
      duration: const Duration(milliseconds: 200),
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
    final clipRatio = widget.topFlex / (widget.topFlex + widget.bottomFlex);

    return GestureDetector(
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
      onTapCancel: () {
        _controller.forward();
      },
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _animation,
        child: Padding(
          padding: widget.margin,
          child: CustomPaint(
            painter: _CustomPainter(widget._decoration, clipRatio),
            child: ClipPath(
              clipper: _CustomClipper(widget._decoration, clipRatio),
              child: CustomPaint(
                foregroundPainter: widget._divider == null
                    ? null
                    : _DividerPainter(
                        widget._divider!,
                        clipRatio,
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      flex: widget.topFlex,
                      child: widget.topChild,
                    ),
                    Flexible(
                      flex: widget.bottomFlex,
                      child: widget.bottomChild,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomClipper extends CustomClipper<Path> {
  final TicketDecoration decoration;
  final double clipRatio;

  _CustomClipper(this.decoration, this.clipRatio);

  @override
  getClip(Size size) {
    final clipHeight = size.height * clipRatio;

    final path = Path()
      ..moveTo(0.0, decoration.borderRadius)
      ..quadraticBezierTo(0, 0, decoration.borderRadius, 0)
      ..lineTo(size.width - decoration.borderRadius, 0.0)
      ..quadraticBezierTo(size.width, 0, size.width, decoration.borderRadius)
      ..lineTo(size.width, clipHeight - decoration.clipRadius)
      ..arcToPoint(
        Offset(size.width, clipHeight + decoration.clipRadius),
        radius: Radius.circular(decoration.clipRadius),
        clockwise: false,
      )
      ..lineTo(size.width, size.height - decoration.borderRadius)
      ..quadraticBezierTo(size.width, size.height,
          size.width - decoration.borderRadius, size.height)
      ..lineTo(decoration.borderRadius, size.height)
      ..quadraticBezierTo(
          0, size.height, 0, size.height - decoration.borderRadius)
      ..lineTo(0, clipHeight + decoration.clipRadius)
      ..arcToPoint(
        Offset(0, clipHeight - decoration.clipRadius),
        radius: Radius.circular(decoration.clipRadius),
        clockwise: false,
      )
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return false;
  }
}

class _CustomPainter extends CustomPainter {
  final TicketDecoration decoration;
  final double clipRatio;

  _CustomPainter(this.decoration, this.clipRatio);

  @override
  void paint(Canvas canvas, Size size) {
    final clipHeight = size.height * clipRatio;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    final path = Path()
      ..moveTo(0.0, decoration.borderRadius)
      ..quadraticBezierTo(0, 0, decoration.borderRadius, 0)
      ..lineTo(size.width - decoration.borderRadius, 0.0)
      ..quadraticBezierTo(size.width, 0, size.width, decoration.borderRadius)
      ..lineTo(size.width, clipHeight - decoration.clipRadius)
      ..arcToPoint(
        Offset(size.width, clipHeight + decoration.clipRadius),
        radius: Radius.circular(decoration.clipRadius),
        clockwise: false,
      )
      ..lineTo(size.width, size.height - decoration.borderRadius)
      ..quadraticBezierTo(size.width, size.height,
          size.width - decoration.borderRadius, size.height)
      ..lineTo(decoration.borderRadius, size.height)
      ..quadraticBezierTo(
          0, size.height, 0, size.height - decoration.borderRadius)
      ..lineTo(0, clipHeight + decoration.clipRadius)
      ..arcToPoint(
        Offset(0, clipHeight - decoration.clipRadius),
        radius: Radius.circular(decoration.clipRadius),
        clockwise: false,
      )
      ..close();

    canvas.drawShadow(path, decoration.shadowColor, decoration.elevation, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _DividerPainter extends CustomPainter {
  final TicketDivider divider;
  final double clipRatio;

  _DividerPainter(this.divider, this.clipRatio);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = divider.dashHeight
      ..color = divider.color;

    // Chage to your preferred size
    final double dashWidth = divider.dashWidth;
    final double dashSpace = divider.dashSpace;

    // Start to draw from left size.
    // Of course, you can change it to match your requirement.
    double startX = 0;
    final double y = size.height * clipRatio;

    // Repeat drawing until we reach the right edge.
    while (startX < size.width) {
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
  final double borderRadius;
  final double clipRadius;
  final Color shadowColor;
  final double elevation;

  TicketDecoration({
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
    this.color = Colors.black,
  });
}
