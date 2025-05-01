// platform_radio_list_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformRadioListTile<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final String title;
  final String? subtitle;
  final Color? activeColor;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? secondary;
  final bool selected;
  final bool toggleable;

  const PlatformRadioListTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.activeColor,
    this.contentPadding,
    this.secondary,
    this.selected = false,
    this.toggleable = false,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return _IOSStyleRadioListTile<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        title: title,
        subtitle: subtitle,
        activeColor: activeColor ?? CupertinoColors.activeBlue,
        contentPadding: contentPadding,
        secondary: secondary,
        selected: selected,
      );
    }

    return RadioListTile<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      activeColor: activeColor,
      contentPadding: contentPadding,
      secondary: secondary,
      selected: selected,
      toggleable: toggleable,
    );
  }
}

class _IOSStyleRadioListTile<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final String title;
  final String? subtitle;
  final Color activeColor;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? secondary;
  final bool selected;

  const _IOSStyleRadioListTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.title,
    required this.activeColor,
    this.subtitle,
    this.contentPadding,
    this.secondary,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;
    final effectiveSelected = selected || isSelected;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(value),
      child: Container(
        color: effectiveSelected
            ? CupertinoColors.systemGrey6
            : CupertinoColors.systemBackground,
        child: Padding(
          padding: contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              if (secondary != null) ...[
                secondary!,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        color: isSelected ? activeColor : CupertinoColors.label,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  CupertinoIcons.check_mark,
                  color: activeColor,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
