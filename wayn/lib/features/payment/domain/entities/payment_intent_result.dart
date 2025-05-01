class PaymentIntentResult {
  final String clientSecret;
  final String status;

  PaymentIntentResult({
    required this.clientSecret,
    required this.status,
  });
}
