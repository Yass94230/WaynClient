import 'package:flutter/material.dart';

class MobileAdaptive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static bool _initialized = false;

  // Device baselines (iPhone 12/13 comme référence)
  static const double baselineWidth = 390;
  static const double baselineHeight = 844;

  static void init(BuildContext context) {
    if (!_initialized) {
      _mediaQueryData = MediaQuery.of(context);
      screenWidth = _mediaQueryData.size.width;
      screenHeight = _mediaQueryData.size.height;
      _initialized = true;
    }
  }

  // Vérifier l'initialisation
  static void checkInit() {
    if (!_initialized) {
      throw Exception('MobileAdaptive not initialized. Call init() first');
    }
  }

  // Obtenir la largeur adaptative avec gestion des petits écrans
  static double width(double width) {
    checkInit();
    if (isSmallPhone) {
      return (width / baselineWidth) * screenWidth * 0.9;
    }
    return (width / baselineWidth) * screenWidth;
  }

  // Obtenir la hauteur adaptative avec limitation pour grands écrans
  static double height(double height) {
    checkInit();
    double ratio = screenHeight / baselineHeight;
    if (ratio > 1.2) ratio = 1.2;
    return height * ratio;
  }

  // Obtenir un padding ou margin adaptatif
  static EdgeInsets padding({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
    required int vertical,
    required int horizontal,
  }) {
    checkInit();
    return EdgeInsets.only(
      left: width(left),
      top: height(top),
      right: width(right),
      bottom: height(bottom),
    );
  }

  // Obtenir une taille de police adaptative avec limites min/max
  static double fontSize(double size) {
    checkInit();
    if (isSmallPhone && size < 14) {
      return width(14);
    }
    if (isLargePhone && size > 24) {
      return width(24);
    }
    return width(size);
  }

  // Obtenir une taille d'icône adaptative basée sur la taille d'écran
  static double iconSize(double size) {
    checkInit();
    return getAdaptiveSize(size);
  }

  // Obtenir un radius adaptatif
  static double radius(double radius) {
    checkInit();
    return width(radius);
  }

  // Calcul adaptatif basé sur la taille d'écran
  static double getAdaptiveSize(double size) {
    checkInit();
    if (screenWidth < 320) return size * 0.8; // iPhone SE 1ère gen
    if (screenWidth < 375) return size * 0.9; // iPhone SE 2/3
    if (screenWidth > 428) return size * 1.1; // iPhone Pro Max
    return size;
  }

  // Vérifications de taille d'écran
  static bool get isSmallPhone => screenHeight < 700;
  static bool get isLargePhone => screenHeight > 850;
  static double get screenRatio => screenHeight / screenWidth;
  static bool get isWideScreen => screenRatio < 2;

  // Safe Area
  static double get topPadding => _mediaQueryData.padding.top;
  static double get bottomPadding => _mediaQueryData.padding.bottom;
}

// Extension pour rendre le code plus lisible
extension AdaptiveNum on num {
  double get w => MobileAdaptive.width(toDouble());
  double get h => MobileAdaptive.height(toDouble());
  double get sp => MobileAdaptive.fontSize(toDouble());
  double get r => MobileAdaptive.radius(toDouble());

  // Nouvelle extension pour les icônes
  double get i => MobileAdaptive.iconSize(toDouble());
}
