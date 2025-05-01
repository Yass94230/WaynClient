import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformScaffold extends StatelessWidget {
  final Widget body;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool automaticallyImplyLeading;
  final bool resizeToAvoidBottomInset;
  final bool
      showNavigationBar; // Paramètre renommé pour être plateforme-agnostique
  final String? title; // Ajout d'un titre optionnel pour la barre de navigation

  const PlatformScaffold({
    super.key,
    required this.body,
    this.leading,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
    this.resizeToAvoidBottomInset = false,
    this.showNavigationBar = false,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return CupertinoPageScaffold(
        navigationBar: showNavigationBar
            ? CupertinoNavigationBar(
                leading: leading,
                middle: title != null ? Text(title!) : null,
                trailing: actions != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!,
                      )
                    : null,
                backgroundColor: backgroundColor,
                automaticallyImplyLeading: automaticallyImplyLeading,
              )
            : null,
        backgroundColor: backgroundColor,
        child: body,
      );
    }

    return Scaffold(
      appBar: showNavigationBar
          ? AppBar(
              elevation: 0,
              leading: leading,
              title: title != null ? Text(title!) : null,
              centerTitle: true,
              actions: actions,
              backgroundColor: backgroundColor,
              automaticallyImplyLeading: automaticallyImplyLeading,
            )
          : null,
      body: SafeArea(
        top: !showNavigationBar,
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

// Le reste des classes reste inchangé
class PlatformNavigationBarButton extends StatelessWidget {
  final IconData materialIcon;
  final IconData cupertinoIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const PlatformNavigationBarButton({
    super.key,
    required this.materialIcon,
    required this.cupertinoIcon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              cupertinoIcon,
              color: isSelected ? CupertinoColors.activeBlue : null,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? CupertinoColors.activeBlue : null,
              ),
            ),
          ],
        ),
      );
    }

    return NavigationDestination(
      icon: Icon(materialIcon),
      label: label,
    );
  }
}

class PlatformNavigationBar extends StatelessWidget {
  final List<NavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;

  const PlatformNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return CupertinoTabBar(
        items: items
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.cupertinoIcon),
                  label: item.label,
                ))
            .toList(),
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: backgroundColor,
      );
    }

    return NavigationBar(
      destinations: items
          .map((item) => NavigationDestination(
                icon: Icon(item.materialIcon),
                label: item.label,
              ))
          .toList(),
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: backgroundColor,
    );
  }
}

class NavigationItem {
  final IconData materialIcon;
  final IconData cupertinoIcon;
  final String label;

  const NavigationItem({
    required this.materialIcon,
    required this.cupertinoIcon,
    required this.label,
  });
}
