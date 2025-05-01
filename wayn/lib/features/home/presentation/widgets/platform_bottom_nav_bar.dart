import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformBottomNavBar extends StatelessWidget {
  final List<BottomNavBarItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final Color? activeColor;
  final Color? inactiveColor;

  const PlatformBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? _buildCupertinoTabBar()
        : _buildMaterialBottomNavBar();
  }

  Widget _buildMaterialBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      items: items
          .map(
            (item) => BottomNavigationBarItem(
              icon: item.icon,
              activeIcon: item.activeIcon ?? item.icon,
              label: item.label,
            ),
          )
          .toList(),
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: activeColor ?? Colors.blue,
      unselectedItemColor: inactiveColor ?? Colors.grey,
    );
  }

  Widget _buildCupertinoTabBar() {
    return CupertinoTabBar(
      backgroundColor: Colors.white,
      items: items
          .map(
            (item) => BottomNavigationBarItem(
              icon: item.icon,
              activeIcon: item.activeIcon ?? item.icon,
              label: item.label,
            ),
          )
          .toList(),
      currentIndex: currentIndex,
      onTap: onTap,
      activeColor: activeColor ?? CupertinoColors.activeBlue,
      inactiveColor: inactiveColor ?? CupertinoColors.inactiveGray,
    );
  }
}

class BottomNavBarItem {
  final Widget icon;
  final Widget? activeIcon;
  final String label;

  BottomNavBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}
