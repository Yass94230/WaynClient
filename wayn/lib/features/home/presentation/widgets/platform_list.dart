import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color? backgroundColor;

  const PlatformListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return CupertinoListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        leading: leading,
        trailing: trailing ??
            (showChevron && onTap != null
                ? const CupertinoListTileChevron()
                : null),
        onTap: onTap,
        backgroundColor: backgroundColor,
      );
    }

    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      leading: leading,
      trailing: trailing ??
          (showChevron && onTap != null
              ? const Icon(Icons.chevron_right)
              : null),
      onTap: onTap,
      tileColor: backgroundColor,
    );
  }
}

// Widget utilitaire pour les séparateurs
class PlatformListDivider extends StatelessWidget {
  final Color? color;
  final double? height;
  final EdgeInsets? margin;

  const PlatformListDivider({
    super.key,
    this.color,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return Container(
        margin: margin,
        height: height ?? 0.5,
        color: color ?? CupertinoColors.separator,
      );
    }

    return Divider(
      height: height,
      color: color,
      indent: margin?.left ?? 0,
      endIndent: margin?.right ?? 0,
    );
  }
}
