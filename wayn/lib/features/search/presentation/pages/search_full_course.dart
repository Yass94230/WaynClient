// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/authentification/presentation/cubits/user_cubit.dart';
import 'package:wayn/features/core/config/size_config.dart';
import 'package:wayn/features/home/presentation/widgets/platform_button.dart';
import 'package:wayn/features/home/presentation/widgets/platform_chechbox.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';
import 'package:wayn/features/home/presentation/widgets/platform_text_field.dart';
import 'package:wayn/features/map/presentation/bloc/map_bloc.dart';
import 'package:wayn/features/search/domain/entities/address.dart';
import 'package:wayn/features/search/presentation/blocs/search_bloc.dart';

import '../../../home/presentation/widgets/platform_icon.dart';

class SearchFullCourse extends StatefulWidget {
  final double userlat;
  final double userlng;
  const SearchFullCourse(
      {super.key, required this.userlat, required this.userlng});

  @override
  State<SearchFullCourse> createState() => _SearchFullCourseState();
}

class _SearchFullCourseState extends State<SearchFullCourse> {
  final departController = TextEditingController();
  final stopController = TextEditingController();
  final destinationController = TextEditingController();
  bool showStopField = false;
  String? userGender = '';
  String? userId = '';

  @override
  void dispose() {
    departController.dispose();
    stopController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  Widget _buildAddressField({
    required TextEditingController controller,
    required String placeholder,
    required Function(String) onChanged,
    required List<Address> suggestions,
    required Function(Address) onAddressSelected,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Champ de recherche amélioré
          Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 1.r,
                  blurRadius: 4.r,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 24.sp,
                  ),
                ),
                Expanded(
                  child: PlatformTextField(
                    read: false,
                    controller: controller,
                    placeholder: placeholder,
                    height: 50.h,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    onChanged: onChanged,
                    // style: TextStyle(
                    //   fontSize: 16.sp,
                    //   fontWeight: FontWeight.w400,
                    // ),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      controller.clear();
                      onChanged('');
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: 20.sp,
                      ),
                    ),
                  ),
                if (isLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Liste des suggestions avec animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: suggestions.isEmpty
                ? 0
                : (MobileAdaptive.isSmallPhone
                    ? min(suggestions.length * 60.h, 250.h)
                    : min(suggestions.length * 65.h, 220.h)),
            margin: EdgeInsets.only(top: suggestions.isEmpty ? 0 : 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: suggestions.isEmpty
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2.r,
                        blurRadius: 8.r,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: suggestions.map((address) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) => FocusScope.of(context).unfocus(),
                      onTap: () {
                        controller.text = address.secondaryText;
                        onAddressSelected(address);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 16.w,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.1),
                              width: 1.h,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.place,
                              color: Colors.grey[400],
                              size: 20.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    address.mainText,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: MobileAdaptive.isSmallPhone
                                          ? 14.sp
                                          : 16.sp,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (address.secondaryText.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.h),
                                      child: Text(
                                        address.secondaryText,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: MobileAdaptive.isSmallPhone
                                              ? 12.sp
                                              : 14.sp,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MobileAdaptive.init(context);

    return PlatformScaffold(
      showNavigationBar: true,
      title: 'Nouvelle course',
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is! AddressesLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Container(
              padding: MobileAdaptive.padding(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12.r),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: MobileAdaptive.isSmallPhone ? 15.h : 120.h),

                  // Stack des champs d'adresse
                  _buildAddressStack(state),

                  SizedBox(height: 12.h),

                  // Option Woman/Man
                  _buildGenderOption(context),

                  SizedBox(height: MobileAdaptive.isSmallPhone ? 20.h : 24.h),

                  // Bouton Continuer
                  _buildContinueButton(context, state),

                  SizedBox(height: MobileAdaptive.isSmallPhone ? 20.h : 24.h),

                  // Section Favoris
                  _buildFavoritesSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressStack(AddressesLoaded state) {
    return Stack(
      children: [
        Column(
          children: [
            _buildAddressField(
              controller: departController,
              placeholder: 'Adresse de départ',
              onChanged: (value) {
                context.read<SearchBloc>().add(
                    SearchStartAddress(value, widget.userlat, widget.userlng));
              },
              suggestions: state.startAddressSuggestions,
              onAddressSelected: (address) {
                state.startAddressSuggestions.clear();
                context
                    .read<SearchBloc>()
                    .add(SelectFavoriteAddress(address, true));
              },
            ),
            SizedBox(
                height: !showStopField
                    ? 20.h
                    : MobileAdaptive.isSmallPhone
                        ? 70.h
                        : 80.h),
            _buildAddressField(
              controller: destinationController,
              placeholder: 'Adresse de destination',
              onChanged: (value) {
                context.read<SearchBloc>().add(
                    SearchEndAddress(value, widget.userlat, widget.userlng));
              },
              suggestions: state.endAddressSuggestions,
              onAddressSelected: (address) {
                state.endAddressSuggestions.clear();
                context
                    .read<SearchBloc>()
                    .add(SelectFavoriteAddress(address, false));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        userGender = userState.user?.sexe;
        final bool isWoman = userState.user?.sexe == 'female';
        final String mainText = isWoman ? 'Option For Woman' : 'Option For Man';
        final String subText = isWoman
            ? '(seulement pour les femmes)'
            : '(seulement pour les hommes)';

        return Container(
          padding: MobileAdaptive.padding(
            horizontal: 12,
            vertical: MobileAdaptive.isSmallPhone ? 6 : 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              BlocBuilder<SearchBloc, SearchState>(
                buildWhen: (previous, current) =>
                    previous is AddressesLoaded &&
                    current is AddressesLoaded &&
                    previous.isWomanOptionEnabled !=
                        current.isWomanOptionEnabled,
                builder: (context, state) {
                  final isEnabled = state is AddressesLoaded
                      ? state.isWomanOptionEnabled
                      : false;
                  return Transform.scale(
                    scale: MobileAdaptive.isSmallPhone ? 0.9 : 1.0,
                    child: PlatformCheckbox(
                      value: isEnabled,
                      onChanged: (value) {
                        context
                            .read<SearchBloc>()
                            .add(ToggleWomanOption(value ?? false));
                      },
                    ),
                  );
                },
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainText,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: MobileAdaptive.isSmallPhone ? 14.sp : 16.sp,
                    ),
                  ),
                  Text(
                    subText,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: MobileAdaptive.isSmallPhone ? 10.sp : 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContinueButton(BuildContext context, AddressesLoaded state) {
    final buttonWidth = MobileAdaptive.isSmallPhone
        ? MediaQuery.of(context).size.width * 0.85
        : MediaQuery.of(context).size.width * 0.8;

    return Center(
      child: SizedBox(
        width: buttonWidth,
        height: MobileAdaptive.isSmallPhone ? 45.h : 50.h,
        child: PlatformButton(
          onPressed: state.selectedStartAddress != null &&
                  state.selectedEndAddress != null
              ? () {
                  Navigator.of(context).pop();
                  context.read<MapBloc>().add(
                        DrawRouteEvent(
                          Point(
                            coordinates: Position(
                              state.selectedStartAddress!.latitude,
                              state.selectedStartAddress!.longitude,
                            ),
                          ),
                          Point(
                            coordinates: Position(
                              state.selectedEndAddress!.latitude,
                              state.selectedEndAddress!.longitude,
                            ),
                          ),
                          '${state.selectedStartAddress?.secondaryText}',
                          '${state.selectedEndAddress?.secondaryText}',
                          state.isWomanOptionEnabled,
                          userGender,
                        ),
                      );
                }
              : null,
          text: 'Continuer',
        ),
      ),
    );
  }

  Widget _buildFavoritesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PlatformIcon(
              materialIcon: Icons.star,
              cupertinoIcon: CupertinoIcons.star,
              size: MobileAdaptive.isSmallPhone ? 18.sp : 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Adresses favoris',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: MobileAdaptive.isSmallPhone ? 14.sp : 16.sp,
              ),
            ),
          ],
        ),
        // Espace pour la liste des favoris
        SizedBox(height: MobileAdaptive.isSmallPhone ? 12.h : 16.h),
        Container(
          constraints: BoxConstraints(
            maxHeight: MobileAdaptive.isSmallPhone ? 120.h : 150.h,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 0, // À remplacer par state.favoriteAddresses.length
            itemBuilder: (context, index) {
              return Container(
                margin: MobileAdaptive.padding(
                    bottom: 8, vertical: 10, horizontal: 10),
                padding: MobileAdaptive.padding(
                  vertical: MobileAdaptive.isSmallPhone ? 8 : 10,
                  horizontal: MobileAdaptive.isSmallPhone ? 12 : 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                // Contenu de l'adresse favorite
                child: const SizedBox(), // À remplacer par le contenu réel
              );
            },
          ),
        ),
      ],
    );
  }
}
