import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? email;

  @HiveField(2)
  final String phoneNumber;

  @HiveField(3)
  final String firstName;

  @HiveField(4)
  final String lastName;

  @HiveField(5)
  final String sexe;

  @HiveField(6)
  final List<String> choices;

  @HiveField(7)
  final String? createdAt;

  @HiveField(8)
  final String? preferedDepart;

  @HiveField(9)
  final String? preferedArrival;

  @HiveField(10)
  final String firebaseToken;

  @HiveField(11)
  final String stripeId;

  @HiveField(12)
  final List<String> roles;

  @HiveField(13)
  final List<String>? carPreferences;

  @HiveField(15)
  User({
    required this.id,
    this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.sexe,
    required this.choices,
    required this.firebaseToken,
    required this.stripeId,
    this.carPreferences = const [],
    this.createdAt,
    this.preferedDepart,
    this.preferedArrival,
    this.roles = const [],
  });
}
