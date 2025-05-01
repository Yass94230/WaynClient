// platform_checkbox_list_tile.dart
// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformCheckboxListTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String title;
  final String? subtitle;
  final Color? activeColor;
  final Color? checkColor;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? secondary;
  final bool selected;
  final bool autofocus;
  final bool? tristate;
  final ListTileControlAffinity controlAffinity;

  const PlatformCheckboxListTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.activeColor,
    this.checkColor,
    this.contentPadding,
    this.secondary,
    this.selected = false,
    this.autofocus = false,
    this.tristate = false,
    this.controlAffinity = ListTileControlAffinity.platform,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return _IOSStyleCheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: title,
        subtitle: subtitle,
        activeColor: activeColor ?? CupertinoColors.activeBlue,
        checkColor: checkColor ?? CupertinoColors.white,
        contentPadding: contentPadding,
        secondary: secondary,
        selected: selected,
        controlAffinity: controlAffinity,
      );
    }

    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      activeColor: activeColor,
      checkColor: checkColor,
      contentPadding: contentPadding,
      secondary: secondary,
      selected: selected,
      autofocus: autofocus,
      tristate: tristate ?? false,
      controlAffinity: controlAffinity,
    );
  }
}

class _IOSStyleCheckboxListTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String title;
  final String? subtitle;
  final Color activeColor;
  final Color checkColor;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? secondary;
  final bool selected;
  final ListTileControlAffinity controlAffinity;

  const _IOSStyleCheckboxListTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    required this.activeColor,
    required this.checkColor,
    this.subtitle,
    this.contentPadding,
    this.secondary,
    this.selected = false,
    this.controlAffinity = ListTileControlAffinity.platform,
  });

  Widget _buildCheckbox() {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: value
            ? null
            : Border.all(
                color: CupertinoColors.systemGrey3,
                width: 2.0,
              ),
        color: value ? activeColor : CupertinoColors.systemBackground,
      ),
      child: value
          ? Icon(
              CupertinoIcons.check_mark,
              size: 20,
              color: checkColor,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLeading = controlAffinity == ListTileControlAffinity.leading;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Container(
        color: selected
            ? CupertinoColors.systemGrey6
            : CupertinoColors.systemBackground,
        child: Padding(
          padding: contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              if (isLeading) ...[
                _buildCheckbox(),
                const SizedBox(width: 16),
              ],
              if (secondary != null && !isLeading) ...[
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
                        color: value || selected
                            ? activeColor
                            : CupertinoColors.label,
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
              if (!isLeading && secondary == null) ...[
                const SizedBox(width: 16),
                _buildCheckbox(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
