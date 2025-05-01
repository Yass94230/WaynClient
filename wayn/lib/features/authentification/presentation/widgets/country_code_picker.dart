import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CountryCode extends StatelessWidget {
  final Function(String) onCountryChanged;

  const CountryCode({super.key, required this.onCountryChanged});

  @override
  Widget build(BuildContext context) {
    return CountryCodePicker(
      padding: const EdgeInsets.only(left: 0),
      hideMainText: false,
      onChanged: (code) {
        // Utilisation de code.dialCode pour obtenir le code numérique
        onCountryChanged(code.dialCode ?? '+33');

        // Émission de l'événement pour changer la locale
        // context.read<LocaleBloc>().add(
        //     ChangeLocale(Locale(code.code?.toLowerCase() ?? 'fr', code.code)));
      },
      flagWidth: 25,
      initialSelection: 'FR',
      showCountryOnly: false,
      backgroundColor: Colors.grey[800],
      countryFilter: const [
        '+33',
      ],
      showFlagDialog: true,
      searchStyle: GoogleFonts.mPlus1(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      dialogTextStyle: GoogleFonts.mPlus1(
        color: Colors.black87,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      enabled: true,
      textStyle: GoogleFonts.mPlus1(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      showOnlyCountryWhenClosed: false,
      comparator: (a, b) => b.name!.compareTo(a.name!),
      onInit: (code) =>
          debugPrint("on init ${code!.name} ${code.dialCode} ${code.name}"),
    );
  }
}
