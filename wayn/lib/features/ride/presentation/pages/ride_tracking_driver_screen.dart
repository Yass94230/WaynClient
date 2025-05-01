import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/agora/domain/utils/call_util.dart';
import 'package:wayn/features/agora/presentation/blocs/call_bloc.dart';
import 'package:wayn/features/agora/presentation/blocs/call_event.dart';
import 'package:wayn/features/agora/presentation/blocs/call_state.dart';
import 'package:wayn/features/authentification/presentation/widgets/auth_button.dart';
import 'package:wayn/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:wayn/features/chat/presentation/blocs/chat_event.dart';
import 'package:wayn/features/chat/presentation/blocs/chat_state.dart';
import 'package:wayn/features/chat/presentation/pages/chat_screen.dart';
import 'package:wayn/features/home/presentation/widgets/platform_bottom_sheet.dart';
import 'package:wayn/features/map/domain/entities/driver.dart';
import 'package:wayn/features/map/presentation/bloc/map_bloc.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';
import 'package:wayn/features/ride/presentation/blocs/ride_confirmation_bloc.dart';
import 'package:wayn/features/ride/presentation/blocs/ride_confirmation_event.dart';
import 'package:wayn/features/ride/presentation/blocs/ride_confirmation_state.dart';
import 'package:wayn/features/ride/presentation/pages/cancel_ride_screen.dart';
import '../../../agora/presentation/pages/call_page.dart';

class RideTrackingDriverScreen extends StatelessWidget {
  final Driver driver;
  final RideRequest rideRequest;

  const RideTrackingDriverScreen({
    required this.driver,
    required this.rideRequest,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RideConfirmationBloc, RideConfirmationState>(
        listener: (context, state) {
      log('RideConfirmationBloc state: $state');
      if (state is DriverPositionUpdated) {
        context.read<MapBloc>().add(DriverFoundComing(
              position: state.position,
              driver: state.driver,
              rideRequest: state.rideRequest,
            ));
      } else if (state is DriverArrived) {
        context
            .read<RideConfirmationBloc>()
            .add(ArrivedDriver(state.rideRequest, state.driver));
        log('Driver arrived');
      } else if (state is FullRideStarted) {
        context.read<MapBloc>().add(
              FullRideStartedInMap(
                driver: state.driver,
                rideRequest: state.rideRequest,
              ),
            );
      } else if (state is RideConfirmationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
    }, builder: (context, rideState) {
      final isDriverArrived = rideState is DriverArrived;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ArrivalTime(
              isDriverArrived: isDriverArrived,
            ),
            _DriverInfoCard(driver: driver),
            _RideDetailsRow(rideRequest: rideRequest),
            _ActionButtons(driver: driver),
            _CancelButton(
              driverId: driver.driverId,
              rideRequest: rideRequest,
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

class _DriverInfoCard extends StatelessWidget {
  final Driver driver;

  const _DriverInfoCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // CircleAvatar(
          //   radius: 24,
          //   backgroundColor: Colors.grey[200],
          //   backgroundImage: driver.driverPhotoUrl != null
          //       ? NetworkImage(driver.driverPhotoUrl)
          //       : const AssetImage('assets/berline.png') as ImageProvider,
          // ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.driverName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${driver.driverVehicle.vehicleModel} • ${driver.driverVehicle.plateNumber}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
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

class _ArrivalTime extends StatefulWidget {
  final bool isDriverArrived;
  const _ArrivalTime({required this.isDriverArrived});

  @override
  State<_ArrivalTime> createState() => _ArrivalTimeState();
}

class _ArrivalTimeState extends State<_ArrivalTime> {
  Timer? _timer;
  int _remainingSeconds = 300; // 5 minutes in seconds

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (widget.isDriverArrived) {
      _timer?.cancel(); // Annule le timer existant s'il y en a un
      _remainingSeconds = 300; // Réinitialise le compteur
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            // Implémenter ce qui se passe quand le timer atteint 0
            // Par exemple, afficher une dialog ou déclencher l'annulation
          }
        });
      });
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String formatTimeFromDouble(double timeInMinutes) {
    int totalMinutes = timeInMinutes.round();
    if (totalMinutes < 60) {
      return '$totalMinutes min';
    } else {
      int hours = totalMinutes ~/ 60;
      int remainingMinutes = totalMinutes % 60;
      String minutesStr = remainingMinutes.toString().padLeft(2, '0');
      return '$hours:$minutesStr min';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RideConfirmationBloc, RideConfirmationState>(
      builder: (context, rideState) {
        return BlocBuilder<MapBloc, MapState>(
          builder: (context, mapState) {
            if (rideState is DriverArrived) {
              _startTimer();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    const Text(
                      'Votre chauffeur vous attend',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Temps restant: ${_formatTime(_remainingSeconds)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _remainingSeconds < 60
                            ? Colors.red
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            } else if (mapState is MapDriverLocationUpdated &&
                widget.isDriverArrived) {
              log('${widget.isDriverArrived}');
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      'Arrive dans environ ${formatTimeFromDouble(mapState.duration)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Veuillez vous présenter pour éviter l'annulation",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey[600],
                      ),
                    )
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

class _RideDetailsRow extends StatelessWidget {
  final RideRequest rideRequest;

  const _RideDetailsRow({required this.rideRequest});

  String formatDuration(Duration duration) {
    int totalMinutes = duration.inMinutes;
    if (totalMinutes < 60) {
      return '$totalMinutes min';
    } else {
      int hours = totalMinutes ~/ 60;
      int remainingMinutes = totalMinutes % 60;
      String minutesStr = remainingMinutes.toString().padLeft(2, '0');
      return '$hours:$minutesStr min';
    }
  }

  @override
  Widget build(BuildContext context) {
    log('${rideRequest.totalRideTime} min');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(
            icon: Icons.route,
            value: '${(rideRequest.distance / 1000).toStringAsFixed(1)} km',
          ),
          _buildDetailItem(
            icon: Icons.timer,
            value: formatDuration(rideRequest.totalRideTime),
          ),
          _buildDetailItem(
            icon: Icons.euro,
            value: '${rideRequest.grossPrice.toStringAsFixed(2)} €',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Driver driver;

  const _ActionButtons({required this.driver});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ChatBloc, ChatState>(
          listener: (context, chatState) {
            if (chatState is ChatCreating) {
              PlatformBottomSheet.show(
                initialChildSize: 1.0,
                minChildSize: 0.7,
                maxChildSize: 1.0,
                context: context,
                child: ChatScreen(chatId: chatState.chatId),
              );
            }
          },
        ),
        BlocListener<CallBloc, CallState>(
          listener: (context, callState) {
            if (callState is CallInitial) {
              final channelName = CallUtils.generateChannelName(
                FirebaseAuth.instance.currentUser!.uid,
                driver.driverId,
              );
              context.read<CallBloc>().add(JoinCallEvent(channelName));
            }
            if (callState is CallConnected) {
              // Vous pouvez personnaliser l'UI pour l'appel ici
              PlatformBottomSheet.show(
                initialChildSize: 1.0,
                minChildSize: 0.7,
                maxChildSize: 1.0,
                context: context,
                child: CallScreen(session: callState.session),
              );
            } else if (callState is CallError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(callState.message)),
              );
            }
          },
        ),
      ],
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<CallBloc, CallState>(
              builder: (context, callState) {
                log('Call state: $callState');
                return ElevatedButton(
                  onPressed: callState is CallLoading
                      ? null
                      : () {
                          context.read<CallBloc>().add(InitializeAgoraEvent());
                          // Après l'initialisation, rejoindre le canal
                          // Utiliser un identifiant unique pour le canal, par exemple une combinaison des IDs
                          //            final channelName = CallUtils.generateChannelName(
                          //   FirebaseAuth.instance.currentUser!.uid,
                          //   driver.driverId,
                          // );
                          //           context
                          //               .read<CallBloc>()
                          //               .add(JoinCallEvent(channelName));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: callState is CallLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Appel',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, chatState) {
                return ElevatedButton(
                  onPressed: chatState is ChatCreating
                      ? null
                      : () {
                          context.read<ChatBloc>().add(
                                CreatePrivateChat(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  driver.driverId,
                                ),
                              );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: chatState is ChatCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Message',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final String driverId;
  final RideRequest rideRequest;

  const _CancelButton({
    required this.driverId,
    required this.rideRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: AuthButton(
          text: 'Annuler la course',
          textColor: Colors.white,
          color: Colors.grey[200]!,
          onPressed: () {
            // Show confirmation dialog
            PlatformBottomSheet.show(
              initialChildSize: 1.0,
              minChildSize: 0.7,
              maxChildSize: 1.0,
              context: context,
              child: CancelRideScreen(rideRequest: rideRequest),
            );
          },
        ),
      ),
    );
  }
}
