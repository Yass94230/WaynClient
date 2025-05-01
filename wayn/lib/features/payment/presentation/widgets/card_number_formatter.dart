import 'package:flutter/services.dart';

// class CardNumberFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     if (newValue.text.isEmpty) {
//       return newValue;
//     }

//     String numbers = newValue.text.replaceAll(' ', '');
//     String formatted = '';

//     for (int i = 0; i < numbers.length; i++) {
//       if (i > 0 && i % 4 == 0) {
//         formatted += ' ';
//       }
//       formatted += numbers[i];
//     }

//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//   }
// }
