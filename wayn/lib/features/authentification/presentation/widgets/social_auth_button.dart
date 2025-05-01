import 'package:flutter/material.dart';

class SocialAuthButton extends StatelessWidget {
  final String text;
  //final String? iconAsset;
  final VoidCallback onPressed;

  const SocialAuthButton({
    super.key,
    required this.text,
    //this.iconAsset,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[50],
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // if (iconAsset != null) ...[
            //   Image.asset(
            //     iconAsset!,
            //     width: 24,
            //     height: 24,
            //   ),
            //   const SizedBox(width: 8),
            // ],
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
