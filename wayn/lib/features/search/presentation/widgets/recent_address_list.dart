// platform_recent_addresses_list.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformRecentAddressesList extends StatelessWidget {
  final List<AddressItem> recentAddresses;
  final List<AddressItem> favoriteAddresses;
  final Function(AddressItem) onAddressSelected;

  const PlatformRecentAddressesList({
    super.key,
    required this.recentAddresses,
    required this.favoriteAddresses,
    required this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Adresses favorites
        ...favoriteAddresses.map((address) => _buildAddressItem(
              context: context,
              address: address,
              icon: Icon(
                Theme.of(context).platform == TargetPlatform.iOS
                    ? CupertinoIcons.house_fill
                    : Icons.home,
                color: Colors.black54,
                size: 22,
              ),
            )),

        // Adresses récentes
        ...recentAddresses.map((address) => _buildAddressItem(
              context: context,
              address: address,
              icon: Icon(
                Theme.of(context).platform == TargetPlatform.iOS
                    ? CupertinoIcons.clock
                    : Icons.history,
                color: Colors.black54,
                size: 22,
              ),
            )),
      ],
    );
  }

  Widget _buildAddressItem({
    required BuildContext context,
    required AddressItem address,
    required Icon icon,
  }) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    Widget content = Row(
      children: [
        icon,
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                address.name,
                style: TextStyle(
                  fontSize: isIOS ? 17 : 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              if (address.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  address.description!,
                  style: TextStyle(
                    fontSize: isIOS ? 15 : 14,
                    color:
                        isIOS ? CupertinoColors.secondaryLabel : Colors.black54,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    if (isIOS) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        onPressed: () => onAddressSelected(address),
        child: content,
      );
    }

    return InkWell(
      onTap: () => onAddressSelected(address),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: content,
      ),
    );
  }
}

class AddressItem {
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final bool isFavorite;

  const AddressItem({
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
  });
}

// Exemple d'utilisation:
/*
final recentAddresses = [
  AddressItem(
    name: 'Aéroport de Montpellier',
    description: 'Mauguio, Hérault',
    latitude: 43.5796,
    longitude: 3.9633,
  ),
  AddressItem(
    name: 'Hôtel de Ville Montpellier',
    description: 'Place Georges Frêche, Montpellier',
    latitude: 43.5992,
    longitude: 3.8968,
  ),
];

PlatformRecentAddressesList(
  recentAddresses: recentAddresses,
  favoriteAddresses: const [],
  onAddressSelected: (address) {
    // Gérer la sélection de l'adresse
    print('Adresse sélectionnée: ${address.name}');
  },
),
*/
