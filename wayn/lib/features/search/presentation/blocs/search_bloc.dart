import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/search/domain/entities/address.dart';
import 'package:wayn/features/search/domain/usecases/favorite_addresses_usecase.dart';
import 'package:wayn/features/search/domain/usecases/get_coordinates_usescase.dart';
import 'package:wayn/features/search/domain/usecases/search_addresses_usecase.dart';

// Events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchStartAddress extends SearchEvent {
  final String query;
  final double userlat;
  final double userlng;
  const SearchStartAddress(this.query, this.userlat, this.userlng);

  @override
  List<Object?> get props => [query];
}

class SearchEndAddress extends SearchEvent {
  final String query;
  final double userlat;
  final double userlng;
  const SearchEndAddress(this.query, this.userlat, this.userlng);

  @override
  List<Object?> get props => [query];
}

class ToggleWomanOption extends SearchEvent {
  final bool value;
  const ToggleWomanOption(this.value);

  @override
  List<Object?> get props => [value];
}

class LoadFavoriteAddresses extends SearchEvent {
  const LoadFavoriteAddresses();
}

class SelectFavoriteAddress extends SearchEvent {
  final Address address;
  final bool isStartAddress;
  const SelectFavoriteAddress(this.address, this.isStartAddress);

  @override
  List<Object?> get props => [address, isStartAddress];
}

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddressesLoaded extends SearchState {
  final List<Address> startAddressSuggestions;
  final List<Address> endAddressSuggestions;
  final List<Address> favoriteAddresses;
  final bool isWomanOptionEnabled;
  final Address? selectedStartAddress;
  final Address? selectedEndAddress;

  const AddressesLoaded({
    this.startAddressSuggestions = const [],
    this.endAddressSuggestions = const [],
    this.favoriteAddresses = const [],
    this.isWomanOptionEnabled = false,
    this.selectedStartAddress,
    this.selectedEndAddress,
  });

  AddressesLoaded copyWith({
    List<Address>? startAddressSuggestions,
    List<Address>? endAddressSuggestions,
    List<Address>? favoriteAddresses,
    bool? isWomanOptionEnabled,
    Address? selectedStartAddress,
    Address? selectedEndAddress,
  }) {
    return AddressesLoaded(
      startAddressSuggestions:
          startAddressSuggestions ?? this.startAddressSuggestions,
      endAddressSuggestions:
          endAddressSuggestions ?? this.endAddressSuggestions,
      favoriteAddresses: favoriteAddresses ?? this.favoriteAddresses,
      isWomanOptionEnabled: isWomanOptionEnabled ?? this.isWomanOptionEnabled,
      selectedStartAddress: selectedStartAddress ?? this.selectedStartAddress,
      selectedEndAddress: selectedEndAddress ?? this.selectedEndAddress,
    );
  }

  @override
  List<Object?> get props => [
        startAddressSuggestions,
        endAddressSuggestions,
        favoriteAddresses,
        isWomanOptionEnabled,
        selectedStartAddress,
        selectedEndAddress,
      ];
}

// Bloc
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final FavoriteAddressesUsecase _getFavoriteAddressesUseCase;
  final SearchAddressesUsecase _searchAddressesUseCase;
  final GetCoordinatesUseCase _getCoordinatesUseCase;

  SearchBloc({
    required GetCoordinatesUseCase getCoordinatesUseCase,
    required FavoriteAddressesUsecase getFavoriteAddressesUseCase,
    required SearchAddressesUsecase searchAddressesUseCase,
  })  : _getFavoriteAddressesUseCase = getFavoriteAddressesUseCase,
        _searchAddressesUseCase = searchAddressesUseCase,
        _getCoordinatesUseCase = getCoordinatesUseCase,
        super(const AddressesLoaded()) {
    on<LoadFavoriteAddresses>(_onLoadFavoriteAddresses);
    on<SearchStartAddress>(_onSearchStartAddress);
    on<SearchEndAddress>(_onSearchEndAddress);
    on<ToggleWomanOption>(_onToggleWomanOption);
    on<SelectFavoriteAddress>(_onSelectFavoriteAddress);
  }

  Future<void> _onLoadFavoriteAddresses(
    LoadFavoriteAddresses event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());
    try {
      final favorites = await _getFavoriteAddressesUseCase();
      emit(AddressesLoaded(favoriteAddresses: favorites));
    } catch (e) {
      emit(const SearchError('Erreur lors du chargement des favoris'));
    }
  }

  Future<void> _onSearchStartAddress(
    SearchStartAddress event,
    Emitter<SearchState> emit,
  ) async {
    log('SearchStartAddress: ${event.query}'); // Ajout du log
    if (event.query.length < 3) return;

    try {
      if (state is AddressesLoaded) {
        final currentState = state as AddressesLoaded;

        log('Searching addresses...'); // Ajout du log
        final suggestions = await _searchAddressesUseCase(
            event.query, event.userlat, event.userlng);
        log('Found ${suggestions.length} suggestions'); // Ajout du log
        emit(currentState.copyWith(startAddressSuggestions: suggestions));
      } else {
        log('State is not AddressesLoaded: $state'); // Ajout du log
      }
    } catch (e) {
      log('Error searching addresses: $e'); // Ajout du log
      emit(const SearchError('Erreur lors de la recherche'));
    }
  }

  Future<void> _onSearchEndAddress(
    SearchEndAddress event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.length < 3) return;
    try {
      if (state is AddressesLoaded) {
        final currentState = state as AddressesLoaded;
        final suggestions = await _searchAddressesUseCase(
            event.query, event.userlat, event.userlng);
        emit(currentState.copyWith(endAddressSuggestions: suggestions));
      }
    } catch (e) {
      emit(const SearchError('Erreur lors de la recherche'));
    }
  }

  void _onToggleWomanOption(
    ToggleWomanOption event,
    Emitter<SearchState> emit,
  ) {
    if (state is AddressesLoaded) {
      final currentState = state as AddressesLoaded;
      emit(currentState.copyWith(isWomanOptionEnabled: event.value));
    }
  }

  Future<void> _onSelectFavoriteAddress(
    SelectFavoriteAddress event,
    Emitter<SearchState> emit,
  ) async {
    if (state is AddressesLoaded) {
      final currentState = state as AddressesLoaded;

      try {
        // Récupérer les coordonnées de l'adresse sélectionnée
        final coordinates =
            await _getCoordinatesUseCase(event.address.mainText);

        // Mettre à jour l'adresse avec les coordonnées
        final addressWithCoordinates = event.address.copyWith(
          coordinates: Point(
            coordinates: Position(
              coordinates.latitude,
              coordinates.longitude,
            ),
          ),
        );

        // Mettre à jour le state
        emit(currentState.copyWith(
          selectedStartAddress: event.isStartAddress
              ? addressWithCoordinates
              : currentState.selectedStartAddress,
          selectedEndAddress: !event.isStartAddress
              ? addressWithCoordinates
              : currentState.selectedEndAddress,
          // Vider les suggestions après sélection
          startAddressSuggestions:
              event.isStartAddress ? [] : currentState.startAddressSuggestions,
          endAddressSuggestions:
              !event.isStartAddress ? [] : currentState.endAddressSuggestions,
        ));

        log('Coordonnées récupérées: ${coordinates.latitude}, ${coordinates.longitude}');
      } catch (e) {
        log('Erreur lors de la récupération des coordonnées: $e');
        emit(const SearchError(
            'Erreur lors de la récupération des coordonnées'));
      }
    }
  }
}
