import 'package:flutter/services.dart';

// class ExpiryDateFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     if (newValue.text.isEmpty) {
//       return newValue;
//     }

//     String numbers = newValue.text.replaceAll('/', '');
//     String formatted = '';

//     for (int i = 0; i < numbers.length; i++) {
//       if (i == 2) {
//         formatted += '/';
//       }
//       formatted += numbers[i];
//     }

//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//   }
// }
