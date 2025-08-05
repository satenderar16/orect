import 'package:amtnew/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



TextTheme createTextTheme(String bodyFontString, String displayFontString) {
  TextTheme bodyTextTheme = GoogleFonts.getTextTheme(bodyFontString);
  TextTheme displayTextTheme = GoogleFonts.getTextTheme(displayFontString);

  TextTheme textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );

  return textTheme;
}


class ColorFamily {
  const ColorFamily({
    required this.seed,
    required this.value,
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });
  final Color seed;
  final Color value;
  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}


class ExtendedColor {

  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({

    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class CustomColor{
  final Color seed, value;
  final List<ColorFamily> light;
  final List<ColorFamily> lightMediumContrast;
  final List<ColorFamily> lightHighContrast;

  final List<ColorFamily> dark;
  final List<ColorFamily> darkMediumContrast;
  final List<ColorFamily> darkHighContrast;

  CustomColor({
    required this.seed, required this.value,
    required this.light,
    required this.lightMediumContrast,
    required this.lightHighContrast,
    required this.dark,
    required this.darkMediumContrast,
    required this.darkHighContrast,



  });

}

