import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';

class BottomSheetCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const BottomSheetCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
  });

  @override
  Widget build(BuildContext context) {
    // Ensures padding at bottom for iPhone 16 home indicator if it extends to the very bottom
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.surfaceSolid.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.8),
                width: 0.5,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            top: padding.resolve(Directionality.of(context)).top,
            left: padding.resolve(Directionality.of(context)).left,
            right: padding.resolve(Directionality.of(context)).right,
            bottom:
                padding.resolve(Directionality.of(context)).bottom +
                (bottomPadding > 0 ? bottomPadding / 2 : 0),
          ),
          child: child,
        ),
      ),
    );
  }
}
