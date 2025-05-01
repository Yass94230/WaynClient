import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/core/config/size_config.dart';
import 'package:wayn/features/home/presentation/widgets/platform_button.dart';
import 'package:wayn/features/map/directions/domain/entities/route_coordinate.dart';
import 'package:wayn/features/map/presentation/bloc/map_bloc.dart';
import 'package:wayn/features/search/presentation/widgets/animation_no_driver.dart';

class NoDriversAvailableScreen extends StatelessWidget {
  final RouteCoordinates route;
  final Point origin;
  final Point destination;
  final String originAddress;
  final String destinationAddress;

  const NoDriversAvailableScreen({
    super.key,
    required this.route,
    required this.origin,
    required this.destination,
    required this.originAddress,
    required this.destinationAddress,
  });

  @override
  Widget build(BuildContext context) {
    MobileAdaptive.init(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.r,
            spreadRadius: 1.r,
          ),
        ],
      ),
      child: Padding(
        padding: MobileAdaptive.padding(
          horizontal: 24,
          vertical: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar (optional)
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Animation
            const NoDriverAnimation(),
            SizedBox(height: 16.h),

            // Title
            Text(
              'Aucun chauffeur disponible',
              style: TextStyle(
                fontSize: MobileAdaptive.isSmallPhone ? 20.sp : 24.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Description
            Text(
              'Nous n\'avons pas trouvé de chauffeur disponible pour votre trajet. Veuillez réessayer plus tard ou modifier votre itinéraire.',
              style: TextStyle(
                fontSize: MobileAdaptive.isSmallPhone ? 14.sp : 16.sp,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),

            // Route details
            Container(
              padding: MobileAdaptive.padding(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  _buildAddressRow(
                    'Départ',
                    originAddress,
                    Colors.green,
                    Icons.location_on_outlined,
                  ),
                  SizedBox(height: 8.h),
                  _buildAddressRow(
                    'Destination',
                    destinationAddress,
                    Colors.red,
                    Icons.location_on,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Button
            SizedBox(
              width: double.infinity,
              height: MobileAdaptive.isSmallPhone ? 45.h : 50.h,
              child: PlatformButton(
                onPressed: () {
                  // Retour à l'écran précédent
                  context.read<MapBloc>().add(BackToInitial());
                  Navigator.of(context).pop();
                },
                text: 'Retour',
              ),
            ),
            SizedBox(height: MobileAdaptive.isSmallPhone ? 16.h : 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(
    String label,
    String address,
    Color iconColor,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: iconColor,
          size: MobileAdaptive.isSmallPhone ? 18.sp : 20.sp,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: MobileAdaptive.isSmallPhone ? 12.sp : 14.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                address,
                style: TextStyle(
                  fontSize: MobileAdaptive.isSmallPhone ? 14.sp : 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
