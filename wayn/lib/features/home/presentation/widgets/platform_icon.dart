import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformIcon extends StatelessWidget {
  final IconData materialIcon;
  final IconData cupertinoIcon;
  final double? size;
  final Color? color;
  final VoidCallback? onPressed;

  const PlatformIcon({
    super.key,
    required this.materialIcon,
    required this.cupertinoIcon,
    this.size,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final icon = Icon(
      isIOS ? cupertinoIcon : materialIcon,
      size: size,
      color: color,
    );

    if (onPressed != null) {
      return isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onPressed,
              child: icon,
            )
          : IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: icon,
              onPressed: onPressed,
            );
    }

    return icon;
  }
}
