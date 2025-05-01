import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/presentation/cubits/user_cubit.dart';
import 'package:wayn/features/home/bloc/navigation_bloc.dart';
import 'package:wayn/features/home/presentation/pages/activity_page.dart';
import 'package:wayn/features/home/presentation/pages/preference_pages.dart';
import 'package:wayn/features/home/presentation/pages/profil_page.dart';
import 'package:wayn/features/home/presentation/widgets/platform_bottom_nav_bar.dart';
import 'package:wayn/features/home/presentation/widgets/platform_bottom_sheet.dart';
import 'package:wayn/features/home/presentation/widgets/platform_icon.dart';
import 'package:wayn/features/home/presentation/widgets/platform_text_field.dart';
import 'package:wayn/features/map/presentation/bloc/map_bloc.dart';
import 'package:wayn/features/search/presentation/pages/search_full_course.dart';

class SearchDestination extends StatelessWidget {
  const SearchDestination({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is MapReady) {
          return BlocConsumer<NavigationBloc, NavigationState>(
            listener: (context, navState) {
              if (navState.currentIndex != 0) {
                PlatformBottomSheet.show(
                  context: context,
                  enableDrag: true,
                  isDismissible: true,
                  initialChildSize: 0.9,
                  minChildSize: 0.9,
                  maxChildSize: 0.9,
                  child: _buildBottomSheetContent(navState.currentIndex),
                );
              }
            },
            builder: (context, navState) {
              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Section principale blanche avec le champ de recherche
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        left: true,
                        right: true,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildSearchBar(context, state),
                            PlatformBottomNavBar(
                              items: [
                                BottomNavBarItem(
                                    icon: const PlatformIcon(
                                        materialIcon: Icons.home,
                                        cupertinoIcon: CupertinoIcons.home),
                                    label: 'Accueil',
                                    activeIcon: const PlatformIcon(
                                      materialIcon: Icons.home,
                                      color: Colors.blue,
                                      cupertinoIcon: CupertinoIcons.home,
                                    )),
                                BottomNavBarItem(
                                  icon: const PlatformIcon(
                                      materialIcon: Icons.settings,
                                      cupertinoIcon: CupertinoIcons.settings),
                                  activeIcon: const PlatformIcon(
                                      materialIcon: Icons.settings,
                                      color: Colors.blue,
                                      cupertinoIcon: CupertinoIcons.settings),
                                  label: 'Préférences',
                                ),
                                BottomNavBarItem(
                                  icon: const PlatformIcon(
                                      materialIcon: Icons.transform,
                                      cupertinoIcon:
                                          CupertinoIcons.ticket_fill),
                                  activeIcon: const PlatformIcon(
                                      materialIcon: Icons.transform,
                                      color: Colors.blue,
                                      cupertinoIcon:
                                          CupertinoIcons.ticket_fill),
                                  label: 'Activités',
                                ),
                                BottomNavBarItem(
                                  icon: const PlatformIcon(
                                      materialIcon: Icons.person,
                                      cupertinoIcon: CupertinoIcons.person),
                                  activeIcon: const PlatformIcon(
                                      materialIcon: Icons.person,
                                      color: Colors.blue,
                                      cupertinoIcon: CupertinoIcons.person),
                                  label: 'Compte',
                                ),
                              ],
                              currentIndex: navState.currentIndex,
                              onTap: (index) {
                                context
                                    .read<NavigationBloc>()
                                    .add(NavigateToTab(index));
                              },
                              activeColor: Theme.of(context).primaryColor,
                              inactiveColor: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildBottomSheetContent(int index) {
    switch (index) {
      case 1:
        return const PreferencesScreen();
      case 2:
        return const ActivityScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox();
    }
  }

  Widget _buildSearchBar(BuildContext context, MapReady mapState) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        final bool hasPreferredLocations =
            userState.status == UserStatus.loaded &&
                (userState.user!.preferedDepart != null ||
                    userState.user!.preferedArrival != null);

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Titre centré
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Où allez-vous ?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Champ de recherche
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PlatformTextField(
                  read: true,
                  placeholder: 'Entrez votre destination...',
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Icon(
                      CupertinoIcons.search,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ),
                  keyboardType: TextInputType.none,
                  onTap: () {
                    PlatformBottomSheet.show(
                      enableDrag: true,
                      isDismissible: true,
                      context: context,
                      child: SearchFullCourse(
                        userlat: mapState.userLocation!.latitude,
                        userlng: mapState.userLocation!.longitude,
                      ),
                      initialChildSize: 1.0,
                      minChildSize: 1.0,
                      maxChildSize: 1.0,
                      isScrollControlled: true,
                    );
                  },
                ),
              ),

              // Destinations récentes
              if (hasPreferredLocations)
                Column(
                  children: [
                    if (userState.user!.preferedDepart != null)
                      _buildRecentDestinationItem(
                        userState.user!.preferedDepart.toString(),
                        context,
                      ),
                    if (userState.user!.preferedArrival != null)
                      _buildRecentDestinationItem(
                        userState.user!.preferedArrival.toString(),
                        context,
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentDestinationItem(String title, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              CupertinoIcons.clock,
              size: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
