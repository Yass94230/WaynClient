import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool useSwitch;
  final Color? activeColor;
  final String? label;

  const PlatformCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.useSwitch = true, // Par défaut, utilise CupertinoSwitch sur iOS
    this.activeColor,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (!isIOS) {
      // Version Android (Material)
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
          ),
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(label!),
            ),
        ],
      );
    }

    // Version iOS (Cupertino)
    if (useSwitch) {
      // Utilise CupertinoSwitch
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoSwitch(
            value: value,
            onChanged: (bool newValue) => onChanged(newValue),
            activeTrackColor: activeColor,
          ),
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(label!),
            ),
        ],
      );
    } else {
      // Alternative avec style Checkbox pour iOS
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(
                color: value
                    ? (activeColor ?? CupertinoColors.activeBlue)
                    : CupertinoColors.systemGrey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
              color: value
                  ? (activeColor ?? CupertinoColors.activeBlue)
                  : CupertinoColors.systemBackground,
            ),
            child: value
                ? const Icon(
                    CupertinoIcons.checkmark,
                    size: 16,
                    color: CupertinoColors.white,
                  )
                : null,
          ),
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(label!),
            ),
        ],
      );
    }
  }
}
