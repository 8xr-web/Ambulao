import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';

class SlideToAcceptButton extends StatefulWidget {
  final Future<void> Function() onAccept;
  final String text;

  const SlideToAcceptButton({
    super.key,
    required this.onAccept,
    this.text = 'SLIDE TO ACCEPT',
  });

  @override
  State<SlideToAcceptButton> createState() => _SlideToAcceptButtonState();
}

class _SlideToAcceptButtonState extends State<SlideToAcceptButton> {
  double _dragPosition = 0.0;
  bool _isAccepted = false;
  final GlobalKey _containerKey = GlobalKey();

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isAccepted) return;
    setState(() {
      _dragPosition += details.delta.dx;
      if (_dragPosition < 0) _dragPosition = 0;

      final containerWidth = _containerKey.currentContext?.size?.width ?? 300;
      final maxDrag = containerWidth - 60; // 60 is button width + padding

      if (_dragPosition > maxDrag) {
        _dragPosition = maxDrag;
      }
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isAccepted) return;

    final containerWidth = _containerKey.currentContext?.size?.width ?? 300;
    final maxDrag = containerWidth - 60;

    if (_dragPosition > maxDrag * 0.8) {
      // Trigger accept
      setState(() {
        _isAccepted = true;
        _dragPosition = maxDrag;
      });
      widget.onAccept();
    } else {
      // Snap back
      setState(() {
        _dragPosition = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _containerKey,
      height: 64, // iOS 26 sleek height
      decoration: BoxDecoration(
        color: _isAccepted ? AppTheme.successGreen : AppTheme.primaryBlue,
        borderRadius: BorderRadius.circular(32), // Completely rounded
        boxShadow: [
          BoxShadow(
            color: (_isAccepted ? AppTheme.successGreen : AppTheme.primaryBlue)
                .withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              _isAccepted ? 'ACCEPTED' : widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700, // Thicker font
                fontSize: 17, // Classic iOS size
                letterSpacing: 0.5,
              ),
            ),
          ),
          Positioned(
            left: _dragPosition + 4,
            top: 4,
            bottom: 4,
            child: GestureDetector(
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: Container(
                width: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _isAccepted
                      ? AppTheme.successGreen
                      : AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
