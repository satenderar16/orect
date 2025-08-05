


import 'package:amtnew/core/theme/theme.dart';
import 'package:amtnew/core/theme/util.dart';
import 'package:flutter/material.dart';

extension ThemeExtras on BuildContext {
  CustomColorPalette get colorPalette =>
      Theme.of(this).extension<CustomColorPalette>()!;
}


class CustomColorPalette extends ThemeExtension<CustomColorPalette> {
  final List<ColorFamily> colorFamilies;

  const CustomColorPalette({required this.colorFamilies});

  @override
  CustomColorPalette copyWith({List<ColorFamily>? colorFamilies}) {
    return CustomColorPalette(
      colorFamilies: colorFamilies ?? this.colorFamilies,
    );
  }

  @override
  CustomColorPalette lerp(ThemeExtension<CustomColorPalette>? other, double t) {
    return this; // No interpolation needed for static list
  }
}
