// lib/features/authentification/domain/entities/subscription_options.dart

class UserChoiceOption {
  final String id;
  final String title;
  final List<String> incompatibleWith; // IDs des options incompatibles
  bool isSelected;

  UserChoiceOption({
    required this.id,
    required this.title,
    required this.incompatibleWith,
    this.isSelected = false,
  });
}

class SubscriptionOptionsManager {
  static List<UserChoiceOption> getFemaleOptions() {
    return [
      UserChoiceOption(
        id: 'wayn_femme',
        title: 'Wayn femme',
        incompatibleWith: ['wayn_femme_homme'],
      ),
      UserChoiceOption(
        id: 'wayn_femme_homme',
        title: 'Wayn femme et Homme',
        incompatibleWith: ['wayn_femme'],
      ),
      UserChoiceOption(
        id: 'wayn_pet',
        title: 'Wayn pet',
        incompatibleWith: [],
      ),
    ];
  }

  static List<UserChoiceOption> getMaleOptions() {
    return [
      UserChoiceOption(
        id: 'wayn_homme',
        title: 'Wayn homme',
        incompatibleWith: ['wayn_homme_femme'],
      ),
      UserChoiceOption(
        id: 'wayn_homme_femme',
        title: 'Wayn homme et Femme',
        incompatibleWith: ['wayn_homme'],
      ),
      UserChoiceOption(
        id: 'wayn_pet',
        title: 'Wayn pet',
        incompatibleWith: [],
      ),
    ];
  }

  static bool canSelect(
    UserChoiceOption option,
    List<UserChoiceOption> allOptions,
  ) {
    // Vérifie si une option incompatible est déjà sélectionnée
    return !allOptions.any((other) =>
        other.isSelected &&
        (option.incompatibleWith.contains(other.id) ||
            other.incompatibleWith.contains(option.id)));
  }
}
