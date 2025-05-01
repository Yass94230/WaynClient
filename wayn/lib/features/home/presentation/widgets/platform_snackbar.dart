// platform_snackbar.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformSnackbar {
  static OverlayEntry? _currentSnackbar;

  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    EdgeInsets? margin,
  }) {
    if (Platform.isIOS) {
      _showIOSSnackbar(
        context: context,
        message: message,
        duration: duration,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize,
        margin: margin,
      );
    } else {
      _showAndroidSnackbar(
        context: context,
        message: message,
        duration: duration,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize,
      );
    }
  }

  static void _showAndroidSnackbar({
    required BuildContext context,
    required String message,
    required Duration duration,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
  }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: fontSize ?? 16,
        ),
      ),
      duration: duration,
      backgroundColor: backgroundColor ?? Colors.black87,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void _showIOSSnackbar({
    required BuildContext context,
    required String message,
    required Duration duration,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    EdgeInsets? margin,
  }) {
    // Hide current snackbar if exists
    _currentSnackbar?.remove();

    final overlay = Overlay.of(context);

    _currentSnackbar = OverlayEntry(
      builder: (context) => _IOSSnackbarOverlay(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize,
        margin: margin,
      ),
    );

    overlay.insert(_currentSnackbar!);

    Future.delayed(duration, () {
      _currentSnackbar?.remove();
      _currentSnackbar = null;
    });
  }
}

class _IOSSnackbarOverlay extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final EdgeInsets? margin;

  const _IOSSnackbarOverlay({
    required this.message,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: _IOSStyleSnackBar(
            message: message,
            backgroundColor: backgroundColor,
            textColor: textColor,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}

class _IOSStyleSnackBar extends StatelessWidget {
  final String message;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const _IOSStyleSnackBar({
    required this.message,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? CupertinoColors.systemGrey.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor ?? CupertinoColors.white,
                fontSize: fontSize ?? 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
