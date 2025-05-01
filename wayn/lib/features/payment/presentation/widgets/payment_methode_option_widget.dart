import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:wayn/features/core/config/size_config.dart';
import 'package:wayn/features/home/presentation/widgets/platform_icon.dart';

class PaymentMethodOptionWidget extends StatelessWidget {
  final Widget leading;
  final String title;
  final VoidCallback onTap;

  const PaymentMethodOptionWidget({
    super.key,
    required this.leading,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? _buildCupertinoOption()
        : _buildMaterialOption(context);
  }

  Widget _buildMaterialOption(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40.w,
                child: leading,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black,
                  ),
                ),
              ),
              const PlatformIcon(
                materialIcon: Icons.chevron_right,
                cupertinoIcon: CupertinoIcons.chevron_right,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoOption() {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40.w,
              child: leading,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: CupertinoColors.black,
                ),
              ),
            ),
            const PlatformIcon(
              materialIcon: Icons.chevron_right,
              cupertinoIcon: CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }
}
