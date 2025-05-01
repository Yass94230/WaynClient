import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/map/presentation/bloc/map_bloc.dart';

class PromotionBanner extends StatelessWidget {
  final VoidCallback onTap;

  const PromotionBanner({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is MapReady) {
          return GestureDetector(
            onTap: onTap,
            child: Container(
              height: 65,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.tag_fill,
                    color: Colors.white,
                    size: 25,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '-10% sur votre prochain trajet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(width: 3),
                  Icon(
                    CupertinoIcons.chevron_up,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
