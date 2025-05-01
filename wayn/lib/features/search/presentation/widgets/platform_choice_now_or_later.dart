import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformChoiceNowOrLater extends StatefulWidget {
  final bool isNow;
  final Function(bool) onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final double width;
  final double height;

  const PlatformChoiceNowOrLater({
    super.key,
    required this.isNow,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.width = 120, // Largeur par défaut
    this.height = 40, // Hauteur par défaut
  });

  @override
  State<PlatformChoiceNowOrLater> createState() =>
      _ExpandableTimingSelectorState();
}

class _ExpandableTimingSelectorState extends State<PlatformChoiceNowOrLater> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? _buildCupertinoSelector()
        : _buildMaterialSelector();
  }

  Widget _buildMaterialSelector() {
    return SizedBox(
      width: 160,
      child: Container(
        margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.black87),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMaterialOption(
              text: widget.isNow ? 'Maintenant' : 'Plus tard',
              isSelected: true,
              onTap: _toggleExpansion,
              showArrow: true,
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(height: 0),
              secondChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1),
                  _buildMaterialOption(
                    text: widget.isNow ? 'Plus tard' : 'Maintenant',
                    isSelected: false,
                    onTap: () {
                      widget.onChanged(!widget.isNow);
                      setState(() {
                        _isExpanded = false;
                      });
                    },
                  ),
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupertinoSelector() {
    return SizedBox(
      width: widget.width,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          border: Border.all(color: CupertinoColors.systemGrey4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCupertinoOption(
              text: widget.isNow ? 'Maintenant' : 'Plus tard',
              isSelected: true,
              onTap: _toggleExpansion,
              showArrow: true,
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(height: 0),
              secondChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(height: 1),
                  _buildCupertinoOption(
                    text: widget.isNow ? 'Plus tard' : 'Maintenant',
                    isSelected: false,
                    onTap: () {
                      widget.onChanged(!widget.isNow);
                      setState(() {
                        _isExpanded = false;
                      });
                    },
                  ),
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialOption({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    bool showArrow = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? (Colors.white) : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (showArrow)
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoOption({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    bool showArrow = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isSelected
                    ? (widget.activeColor ??
                        CupertinoTheme.of(context).primaryColor)
                    : CupertinoColors.systemGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (showArrow)
              Icon(
                _isExpanded
                    ? CupertinoIcons.chevron_up
                    : CupertinoIcons.chevron_down,
                color: CupertinoColors.systemGrey,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
}
