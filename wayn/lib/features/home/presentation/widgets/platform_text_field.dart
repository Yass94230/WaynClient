import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformTextField extends StatelessWidget {
  final double? width;
  final double? height;
  final String? placeholder;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final int? maxLines;
  final int? minLines;
  final bool? enabled;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final String? errorText;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final bool read;

  const PlatformTextField({
    super.key,
    this.width,
    this.height,
    this.placeholder,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.keyboardType,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.textInputAction,
    this.focusNode,
    this.padding,
    this.decoration,
    this.errorText,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    required this.read,
  });

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? _buildCupertinoTextField(context)
        : _buildMaterialTextField(context);
  }

  Widget _buildMaterialTextField(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      dragStartBehavior: DragStartBehavior.start,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      textInputAction: textInputAction,
      focusNode: focusNode,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        hintText: placeholder,
        errorText: errorText,
        prefixIcon: prefix,
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[900]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[300],
        contentPadding: padding ?? const EdgeInsets.all(6),
      ),
    );
  }

  Widget _buildCupertinoTextField(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: decoration ??
          BoxDecoration(
            color: CupertinoColors.systemBackground,
            border: Border.all(
              color: errorText != null
                  ? CupertinoColors.systemRed
                  : CupertinoColors.systemGrey4,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoTextField(
            controller: controller,
            onChanged: onChanged,
            onTap: onTap,
            onSubmitted: onSubmitted,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: maxLines,
            minLines: minLines,
            enabled: enabled!,
            textInputAction: textInputAction,
            focusNode: focusNode,
            autofocus: autofocus,
            textCapitalization: textCapitalization,
            placeholder: placeholder,
            prefix: prefix != null
                ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: prefix,
                  )
                : null,
            suffix: suffix != null
                ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: suffix,
                  )
                : null,
            decoration: null, // CupertinoTextField gère sa propre décoration
            style: const TextStyle(
              color: CupertinoColors.black,
            ),
            placeholderStyle: const TextStyle(
              color: CupertinoColors.systemGrey,
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 6.0, left: 12.0),
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: CupertinoColors.systemRed,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
