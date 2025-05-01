import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/home/presentation/widgets/platform_icon.dart';
import 'package:wayn/features/map/presentation/bloc/map_bloc.dart';

class ArrowBack extends StatelessWidget {
  const ArrowBack({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is! MapReady) {
          return Positioned(
            top: 40,
            left: 16,
            child: Builder(
              builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      log('Open drawer');
                      Scaffold.of(context).openDrawer();
                    },
                    child: const PlatformIcon(
                      materialIcon: Icons.arrow_back,
                      cupertinoIcon: CupertinoIcons.arrow_left,
                    ),
                  )),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
