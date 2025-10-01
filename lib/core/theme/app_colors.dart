import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surface,
    required this.scaffold,
    required this.border,
    required this.primaryGradient,
    required this.cardGradient,
    required this.shadow,
    required this.glass,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color surface;
  final Color scaffold;
  final Color border;
  final Gradient primaryGradient;
  final Gradient cardGradient;
  final Color shadow;
  final Color glass;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color textPrimary;
  final Color textSecondary;

  @override
  AppColors copyWith({
    Color? surface,
    Color? scaffold,
    Color? border,
    Gradient? primaryGradient,
    Gradient? cardGradient,
    Color? shadow,
    Color? glass,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return AppColors(
      surface: surface ?? this.surface,
      scaffold: scaffold ?? this.scaffold,
      border: border ?? this.border,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      cardGradient: cardGradient ?? this.cardGradient,
      shadow: shadow ?? this.shadow,
      glass: glass ?? this.glass,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      surface: Color.lerp(surface, other.surface, t)!,
      scaffold: Color.lerp(scaffold, other.scaffold, t)!,
      border: Color.lerp(border, other.border, t)!,
      primaryGradient:
      Gradient.lerp(primaryGradient, other.primaryGradient, t)!,
      cardGradient: Gradient.lerp(cardGradient, other.cardGradient, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight:
      Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}