// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/home/presentation/widgets/platform_bottom_sheet.dart';
import 'package:wayn/features/home/presentation/widgets/platform_icon.dart';
import 'package:wayn/features/home/presentation/widgets/platform_list.dart';
import 'package:wayn/features/home/presentation/widgets/platform_snackbar.dart';
import 'package:wayn/features/map/directions/domain/entities/route_coordinate.dart';
import 'package:wayn/features/map/domain/entities/driver.dart';
import 'package:wayn/features/map/presentation/bloc/map_bloc.dart';
import 'package:wayn/features/payment/presentation/blocs/payment_bloc.dart';
import 'package:wayn/features/payment/presentation/pages/add_payment_methode.dart';
import 'package:wayn/features/ride/presentation/pages/confimation_screen.dart';
import 'package:wayn/features/authentification/domain/entities/user.dart';
import 'package:wayn/features/authentification/presentation/cubits/user_cubit.dart';

class PaymentSectionPage extends StatefulWidget {
  final double price;
  final String vehicleType;
  final RouteCoordinates route;
  final List<Driver> nearbyDrivers;
  final String originAddress;
  final String destinationAddress;
  final Position origin;
  final Position destination;

  const PaymentSectionPage({
    required this.price,
    required this.vehicleType,
    required this.route,
    required this.nearbyDrivers,
    required this.originAddress,
    required this.destinationAddress,
    required this.origin,
    required this.destination,
    super.key,
  });

  @override
  State<PaymentSectionPage> createState() => _PaymentSectionPageState();
}

class _PaymentSectionPageState extends State<PaymentSectionPage> {
  String _selectedPaymentMethod = 'card';
  PaymentMethod? _selectedCard;

  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(LoadSavedCardsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        log('UserState dans PaymentSectionPage: ${userState.status}');

        if (userState.user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return _PaymentContent(
          user: userState.user!,
          price: widget.price,
          vehicleType: widget.vehicleType,
          route: widget.route,
          nearbyDrivers: widget.nearbyDrivers,
          originAddress: widget.originAddress,
          destinationAddress: widget.destinationAddress,
          origin: widget.origin,
          destination: widget.destination,
          selectedPaymentMethod: _selectedPaymentMethod,
          selectedCard: _selectedCard,
          onPaymentMethodChanged: (method, card) {
            setState(() {
              _selectedPaymentMethod = method;
              _selectedCard = card;
            });
          },
        );
      },
    );
  }
}

class _PaymentContent extends StatelessWidget {
  final User user;
  final double price;
  final String vehicleType;
  final RouteCoordinates route;
  final List<Driver> nearbyDrivers;
  final String originAddress;
  final String destinationAddress;
  final Position origin;
  final Position destination;
  final String selectedPaymentMethod;
  final PaymentMethod? selectedCard;
  final Function(String, PaymentMethod?) onPaymentMethodChanged;

  const _PaymentContent({
    required this.user,
    required this.price,
    required this.vehicleType,
    required this.route,
    required this.nearbyDrivers,
    required this.originAddress,
    required this.destinationAddress,
    required this.origin,
    required this.destination,
    required this.selectedPaymentMethod,
    required this.selectedCard,
    required this.onPaymentMethodChanged,
  });

  void _handlePayment(BuildContext context) {
    log('🚀 _handlePayment démarré');
    if (selectedPaymentMethod == 'card' && selectedCard != null) {
      log('💳 Carte sélectionnée - ID: ${selectedCard!.id}');
      context.read<PaymentBloc>().add(
            CreatePaymentIntentEvent(
              amount: price,
              currency: 'eur',
              paymentMethodId: selectedCard!.id,
            ),
          );
    } else if (selectedPaymentMethod == 'card') {
      _showNoCardSelectedError(context);
    }
  }

  void _showNoCardSelectedError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veuillez sélectionner ou ajouter une carte'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentBloc, PaymentState>(
      listener: _handlePaymentState,
      builder: (context, state) {
        return _PaymentLayout(
          price: price,
          vehicleType: vehicleType,
          selectedPaymentMethod: selectedPaymentMethod,
          selectedCard: selectedCard,
          state: state,
          onPaymentMethodChanged: onPaymentMethodChanged,
          onPaymentSubmit: () => _handlePayment(context),
        );
      },
    );
  }

  void _handlePaymentState(BuildContext context, PaymentState state) {
    if (state is PaymentInitialized) {
      _handlePaymentInitialized(context, state);
    } else if (state is PaymentSuccess) {
      _handlePaymentSuccess(context, state);
    } else if (state is PaymentError) {
      _handlePaymentError(context, state);
    }
  }

  void _handlePaymentInitialized(
      BuildContext context, PaymentInitialized state) {
    context.read<PaymentBloc>().add(
          ConfirmPaymentEvent(
            user: user,
            clientSecret: state.clientSecret,
            status: state.status,
            originAddress: originAddress,
            destinationAddress: destinationAddress,
            vehicleType: vehicleType,
            nearbyDrivers: nearbyDrivers,
            price: price,
            route: route,
            origin: origin,
            destination: destination,
          ),
        );
  }

  void _handlePaymentSuccess(BuildContext context, PaymentSuccess state) {
    Navigator.of(context).pop();
    PlatformBottomSheet.show(
      context: context,
      child: ConfirmationScreen(
        vehicleType: vehicleType,
        rideRequest: state.rideRequest,
        nearbyDrivers: nearbyDrivers,
      ),
      initialChildSize: 1.0,
      minChildSize: 1.0,
      maxChildSize: 1.0,
      isDismissible: false,
      isScrollControlled: true,
    );
  }

  void _handlePaymentError(BuildContext context, PaymentError state) {
    PlatformSnackbar.show(
      context: context,
      message: state.message,
      backgroundColor: Colors.red,
    );
  }
}

class _PaymentLayout extends StatelessWidget {
  final double price;
  final String vehicleType;
  final String selectedPaymentMethod;
  final PaymentMethod? selectedCard;
  final PaymentState state;
  final Function(String, PaymentMethod?) onPaymentMethodChanged;
  final VoidCallback onPaymentSubmit;

  const _PaymentLayout({
    required this.price,
    required this.vehicleType,
    required this.selectedPaymentMethod,
    required this.selectedCard,
    required this.state,
    required this.onPaymentMethodChanged,
    required this.onPaymentSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Container(
              color: Colors.red.withOpacity(0.2), // Pour voir la zone du bouton
              child: IconButton(
                padding: const EdgeInsets.all(12),
                constraints:
                    const BoxConstraints(), // Enlever les contraintes par défaut
                icon: const PlatformIcon(
                    materialIcon: Icons.arrow_back,
                    cupertinoIcon: CupertinoIcons.back),
                onPressed: () {
                  debugPrint('TEST BUTTON CLICK'); // Un autre type de log
                  log('🚀 Tentative de retour');
                  context.read<MapBloc>().add(ReturnToPreviousScreen(context));
                },
              ),
            ),
          ),
          _VehicleSection(
            vehicleType: vehicleType,
            price: price,
          ),
          const SizedBox(height: 24),
          _PaymentMethodSection(
            state: state,
            selectedPaymentMethod: selectedPaymentMethod,
            selectedCard: selectedCard,
            onPaymentMethodChanged: onPaymentMethodChanged,
          ),
          const SizedBox(height: 16),
          const _PromoCodeSection(),
          const SizedBox(height: 24),
          _ConfirmButton(
            selectedPaymentMethod: selectedPaymentMethod,
            onPressed: onPaymentSubmit,
          ),
        ],
      ),
    );
  }
}

class _VehicleSection extends StatelessWidget {
  final String vehicleType;
  final double price;

  const _VehicleSection({
    required this.vehicleType,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _VehicleImage(vehicleType: vehicleType),
        const SizedBox(width: 12),
        Expanded(
          child: _VehicleInfo(vehicleType: vehicleType),
        ),
        _PriceDisplay(price: price),
      ],
    );
  }
}

class _VehicleImage extends StatelessWidget {
  final String vehicleType;

  const _VehicleImage({required this.vehicleType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        'assets/$vehicleType.png',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _VehicleInfo extends StatelessWidget {
  final String vehicleType;

  const _VehicleInfo({required this.vehicleType});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          vehicleType.capitalize(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        _PassengerCount(vehicleType: vehicleType),
      ],
    );
  }
}

class _PassengerCount extends StatelessWidget {
  final String vehicleType;

  const _PassengerCount({required this.vehicleType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.person,
            size: 16,
            color: Colors.black54,
          ),
          Text(
            vehicleType == 'berline' ? '3' : '6',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _PriceDisplay extends StatelessWidget {
  final double price;

  const _PriceDisplay({required this.price});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${price.toStringAsFixed(2)}€',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  final PaymentState state;
  final String selectedPaymentMethod;
  final PaymentMethod? selectedCard;
  final Function(String, PaymentMethod?) onPaymentMethodChanged;

  const _PaymentMethodSection({
    required this.state,
    required this.selectedPaymentMethod,
    required this.selectedCard,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Vérifier le type spécifique de l'état
    final hasCards = state is SavedCardsLoaded &&
        (state as SavedCardsLoaded).cards.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PaymentMethodHeader(hasCards: hasCards),
        const SizedBox(height: 16),
        _PaymentMethodList(
          state: state,
          selectedPaymentMethod: selectedPaymentMethod,
          selectedCard: selectedCard,
          onPaymentMethodChanged: onPaymentMethodChanged,
        ),
      ],
    );
  }
}

class _PaymentMethodHeader extends StatelessWidget {
  final bool hasCards;

  const _PaymentMethodHeader({required this.hasCards});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Paiement',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (!hasCards) _AddNewCardButton(),
      ],
    );
  }
}

class _AddNewCardButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _navigateToAddPaymentMethod(context),
      icon: const Icon(Icons.add, color: Colors.blue),
      label: const Text(
        'Nouveau',
        style: TextStyle(color: Colors.blue),
      ),
    );
  }

  void _navigateToAddPaymentMethod(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPaymentMethodContent(
          price:
              context.findAncestorWidgetOfExactType<_PaymentContent>()?.price ??
                  0.0,
        ),
      ),
    ).then((_) {
      context.read<PaymentBloc>().add(LoadSavedCardsEvent());
    });
  }
}

class _PaymentMethodList extends StatelessWidget {
  final PaymentState state;
  final String selectedPaymentMethod;
  final PaymentMethod? selectedCard;
  final Function(String, PaymentMethod?) onPaymentMethodChanged;

  const _PaymentMethodList({
    required this.state,
    required this.selectedPaymentMethod,
    required this.selectedCard,
    required this.onPaymentMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Vérifier et cast de l'état
    if (state is SavedCardsLoaded) {
      final savedCardsState = state as SavedCardsLoaded;
      if (savedCardsState.cards.isNotEmpty) {
        return Column(
          children: [
            ...savedCardsState.cards.map((card) => _SavedCardItem(
                  card: card,
                  isSelected: selectedCard?.id == card.id,
                  onSelected: () => onPaymentMethodChanged('card', card),
                )),
            const SizedBox(height: 8),
            _CashPaymentOption(
              isSelected: selectedPaymentMethod == 'cash',
              onSelected: () => onPaymentMethodChanged('cash', null),
            ),
          ],
        );
      }
    }

    return _AddFirstCardPrompt(
        onTap: () => _navigateToAddPaymentMethod(context));
  }

  void _navigateToAddPaymentMethod(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPaymentMethodContent(
          price:
              context.findAncestorWidgetOfExactType<_PaymentContent>()?.price ??
                  0.0,
        ),
      ),
    ).then((_) {
      context.read<PaymentBloc>().add(LoadSavedCardsEvent());
    });
  }
}

class _SavedCardItem extends StatelessWidget {
  final PaymentMethod card;
  final bool isSelected;
  final VoidCallback onSelected;

  const _SavedCardItem({
    required this.card,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onSelected,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border:
                isSelected ? Border.all(color: Colors.blue, width: 2) : null,
          ),
          child: PlatformListTile(
            leading: _buildLeading(),
            title: '****${card.card.last4 ?? ""}',
            subtitle: 'Expire ${card.card.expMonth}/${card.card.expYear}',

            // title: Text(
            //   '****${card.card.last4 ?? ""}',
            //   style: TextStyle(
            //     color: Colors.grey[800],
            //     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            //   ),
            // ),
            // subtitle: Text(
            //   'Expire ${card.card.expMonth}/${card.card.expYear}',
            //   style: TextStyle(
            //     color: Colors.grey[600],
            //     fontSize: 12,
            //   ),
            // ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSelected)
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: const Icon(Icons.check, size: 16, color: Colors.blue),
          ),
        const SizedBox(width: 8),
        Image.asset(
          'assets/${card.card.brand?.toLowerCase() ?? "visa"}.png',
          width: 40,
          height: 25,
        ),
      ],
    );
  }
}

class _CashPaymentOption extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onSelected;

  const _CashPaymentOption({
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: PlatformListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.blue),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.payments_outlined, size: 30, color: Colors.grey),
            ],
          ),
          title: 'Espèces',
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class _AddFirstCardPrompt extends StatelessWidget {
  final VoidCallback onTap;

  const _AddFirstCardPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: PlatformListTile(
        leading: const Icon(Icons.credit_card, color: Colors.blue),
        title: 'Ajouter une carte pour payer',
        onTap: onTap,
        trailing: const Icon(Icons.add, color: Colors.blue),
      ),
    );
  }
}

class _PromoCodeSection extends StatelessWidget {
  const _PromoCodeSection();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Vous avez un code promo ?',
      style: TextStyle(color: Colors.grey),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final String selectedPaymentMethod;
  final VoidCallback onPressed;

  const _ConfirmButton({
    required this.selectedPaymentMethod,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        selectedPaymentMethod == 'card'
            ? 'Confirmer et payer'
            : 'Confirmer - Paiement en espèces',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Extension utilitaire pour capitaliser la première lettre
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
