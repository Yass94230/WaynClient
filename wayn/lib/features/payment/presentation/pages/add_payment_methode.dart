import 'package:flutter/material.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';
import 'package:wayn/features/payment/presentation/widgets/card_form_widget.dart';
import 'package:wayn/features/payment/presentation/widgets/payment_methode_option_widget.dart';

class AddPaymentMethodContent extends StatelessWidget {
  final double price;
  const AddPaymentMethodContent({required this.price, super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      showNavigationBar: true,
      body: Container(
        color: Colors.white,
        child: ListView(
          children: [
            PaymentMethodOptionWidget(
                leading: const Icon(
                  Icons.credit_card,
                  color: Colors.black,
                  size: 24,
                ),
                title: 'Carte bancaire',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardForm(
                        amount: price,
                      ),
                    ),
                  );
                }),
            const Divider(height: 1),
            PaymentMethodOptionWidget(
                leading: Image.asset(
                  'assets/paypalLogo.png',
                  width: 24,
                  height: 24,
                ),
                title: 'Paypal',
                onTap: () {}),
          ],
        ),
      ),
    );
  }
}
