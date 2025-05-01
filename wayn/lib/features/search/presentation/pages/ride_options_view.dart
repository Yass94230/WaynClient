import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:wayn/features/core/config/size_config.dart';
import 'package:wayn/features/home/presentation/widgets/platform_bottom_sheet.dart';
import 'package:wayn/features/home/presentation/widgets/platform_icon.dart';
import 'package:wayn/features/map/directions/domain/entities/route_coordinate.dart';
import 'package:wayn/features/map/domain/entities/driver.dart';
import 'package:wayn/features/map/presentation/bloc/map_bloc.dart';
import 'package:wayn/features/payment/presentation/pages/payment_section_page.dart';

class RideOptionsView extends StatefulWidget {
  final Map<String, double> prices;
  final RouteCoordinates route;
  final List<Driver> nearbyDrivers;
  final String selectedVehicleType;
  final String originAddress;
  final String destinationAddress;
  final mapbox.Position origin;
  final mapbox.Position destination;
  final mapbox.MapboxMap mapController;

  const RideOptionsView({
    super.key,
    required this.prices,
    required this.route,
    required this.nearbyDrivers,
    required this.selectedVehicleType,
    required this.originAddress,
    required this.destinationAddress,
    required this.origin,
    required this.destination,
    required this.mapController,
  });

  @override
  State<RideOptionsView> createState() => _RideOptionsViewState();
}

class _RideOptionsViewState extends State<RideOptionsView> {
  late String _selectedVehicleType;

  @override
  void initState() {
    super.initState();
    _selectedVehicleType = widget.selectedVehicleType;
  }

  Widget _buildRideOption({
    required String vehicleType,
    required String title,
    required String imagePath,
    required double price,
    required int capacity,
  }) {
    final isSelected = _selectedVehicleType == vehicleType;

    final availableDrivers = widget.nearbyDrivers
        .where((driver) => driver.driverVehicle.vehicleType == vehicleType)
        .toList();

    final isAvailable = availableDrivers.isNotEmpty;

    final waitTime = isAvailable
        ? '${availableDrivers.first.estimatedTimeOfArrival} min d\'attente'
        : 'Aucun chauffeur disponible';

    return GestureDetector(
      onTap: isAvailable
          ? () {
              setState(() {
                _selectedVehicleType = vehicleType;
              });
            }
          : null,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0.w,
              vertical: 20.0.h,
            ),
            decoration: BoxDecoration(
              color: isSelected ? Colors.grey[300]! : Colors.white,
              borderRadius: BorderRadius.circular(2.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Opacity(
              opacity: isAvailable ? 1.0 : 0.5,
              child: Row(
                children: [
                  Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.person, size: 12.sp),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '$capacity',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14.sp,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                waitTime,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${price.toStringAsFixed(2)}€',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      if (isSelected && isAvailable) ...[
                        SizedBox(height: 4.h),
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                          size: 20.sp,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!isAvailable)
            Positioned.fill(
              child: CustomPaint(
                painter: StrikeThroughPainter(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MobileAdaptive.init(context);
    final hasAvailableVehicles = widget.nearbyDrivers.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: Platform.isIOS
                ? EdgeInsets.all(0.0.w)
                : EdgeInsets.only(top: 26.0.h),
            child: Row(
              // Wrapped in Row
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the row contents
              children: [
                IconButton(
                  icon: const PlatformIcon(
                      materialIcon: Icons.arrow_back,
                      cupertinoIcon: CupertinoIcons.back),
                  onPressed: () {
                    Navigator.of(context).pop(); // Ferme la bottom sheet
                    context.read<MapBloc>().add(BackToInitial());
                  },
                ),
                Text(
                  'Choisissez une course',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Ajout d'un widget vide pour équilibrer le layout
                SizedBox(width: 48.w), // Même largeur que IconButton
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0.w),
            child: Column(
              children: [
                _buildRideOption(
                  vehicleType: 'berline',
                  title: 'Berline',
                  imagePath: 'assets/berline.png',
                  price: widget.prices['berline'] ?? 0,
                  capacity: 3,
                ),
                SizedBox(height: 12.h),
                _buildRideOption(
                  vehicleType: 'van',
                  title: 'Van',
                  imagePath: 'assets/van.png',
                  price: widget.prices['van'] ?? 0,
                  capacity: 6,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0.w),
            child: ElevatedButton(
              onPressed: hasAvailableVehicles && _selectedVehicleType.isNotEmpty
                  ? () {
                      Navigator.of(context).pop();
                      final selectedPrice =
                          widget.prices[_selectedVehicleType] ?? 0.0;
                      PlatformBottomSheet.show(
                        context: context,
                        child: PaymentSectionPage(
                          price: selectedPrice,
                          vehicleType: _selectedVehicleType,
                          route: widget.route,
                          nearbyDrivers: widget.nearbyDrivers,
                          originAddress: widget.originAddress,
                          destinationAddress: widget.destinationAddress,
                          origin: widget.origin,
                          destination: widget.destination,
                        ),
                        isScrollControlled: true,
                        initialChildSize: 0.7,
                        minChildSize: 0.7,
                        maxChildSize: 0.9,
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Text(
                'Choisir $_selectedVehicleType',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StrikeThroughPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
