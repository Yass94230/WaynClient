import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final bool disabled;

  const PlatformButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // Détection de la plateforme
    final platform = Theme.of(context).platform;

    // Style par défaut selon la plateforme
    if (platform == TargetPlatform.iOS) {
      return CupertinoButton(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: disabled
            ? CupertinoColors.systemGrey3
            : backgroundColor ?? CupertinoTheme.of(context).primaryColor,
        onPressed: disabled ? null : onPressed,
        child: _buildButtonContent(context),
      );
    } else {
      return MaterialButton(
        minWidth: width,
        height: height,
        color: disabled ? Colors.grey[300] : backgroundColor ?? Colors.blue,
        disabledColor: Colors.grey[300],
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onPressed: disabled ? null : onPressed,
        child: _buildButtonContent(context),
      );
    }
  }

  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return _buildLoadingIndicator(context);
    }
    return Text(
      text,
      style: TextStyle(
        color: disabled ? Colors.grey[600] : textColor ?? Colors.white,
        fontSize: 16,
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: Theme.of(context).platform == TargetPlatform.iOS
          ? const CupertinoActivityIndicator(color: Colors.white)
          : const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
    );
  }
}
