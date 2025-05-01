// lib/core/presentation/widgets/platform_dialogs.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformDialogs {
  static Future<String?> showEditDialog({
    required BuildContext context,
    required String title,
    required String initialValue,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) async {
    if (Platform.isIOS) {
      return _showIOSEditDialog(
        context: context,
        title: title,
        initialValue: initialValue,
        hintText: hintText,
        keyboardType: keyboardType,
        obscureText: obscureText,
      );
    } else {
      return _showAndroidEditDialog(
        context: context,
        title: title,
        initialValue: initialValue,
        hintText: hintText,
        keyboardType: keyboardType,
        obscureText: obscureText,
      );
    }
  }

  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDangerous = false,
  }) async {
    if (Platform.isIOS) {
      return _showIOSConfirmationDialog(
        context: context,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDangerous: isDangerous,
      );
    } else {
      return _showAndroidConfirmationDialog(
        context: context,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDangerous: isDangerous,
      );
    }
  }

  static Future<String?> _showAndroidEditDialog({
    required BuildContext context,
    required String title,
    required String initialValue,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    final controller = TextEditingController(text: initialValue);

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Enregistrer'),
              onPressed: () => Navigator.of(context).pop(controller.text),
            ),
          ],
        );
      },
    );
  }

  static Future<String?> _showIOSEditDialog({
    required BuildContext context,
    required String title,
    required String initialValue,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    final controller = TextEditingController(text: initialValue);

    return showCupertinoDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: CupertinoTextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              placeholder: hintText,
              autofocus: true,
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> _showAndroidConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(cancelText ?? 'Annuler'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                confirmText ?? 'Confirmer',
                style: TextStyle(
                  color: isDangerous ? Colors.red : null,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  static Future<bool> _showIOSConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDangerous = false,
  }) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText ?? 'Annuler'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: isDangerous,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText ?? 'Confirmer'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }
}
