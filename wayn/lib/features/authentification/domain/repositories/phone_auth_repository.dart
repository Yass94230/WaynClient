abstract class PhoneAuthRepository {
  Future<void> sendVerificationCode(String phoneNumber);
  Future<bool> verifyCode(String code, String phoneNumber);
  Future<void> signInWithApple();
  Future<void> completeUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required List<String> choices,
  });
}
