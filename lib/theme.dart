import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const bgDark = Color(0xFF0D0F1A);
const bgCard = Color(0xFF151828);
const bgCard2 = Color(0xFF1A1D2E);
const accentPurple = Color(0xFF7B6EF6);
const accentPink = Color(0xFFFF6B8A);
const accentBlue = Color(0xFF4FC3F7);
const textPrimary = Color(0xFFFFFFFF);
const textSecondary = Color(0xFF8A8FA8);
const gradientStart = Color(0xFF7B6EF6);
const gradientEnd = Color(0xFFFF6B8A);

final appTheme = ThemeData(
  scaffoldBackgroundColor: bgDark,
  colorScheme: const ColorScheme.dark(
    primary: accentPurple,
    secondary: accentPink,
    surface: bgCard,
  ),
  fontFamily: 'sans-serif',
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: textPrimary),
    bodySmall: TextStyle(color: textSecondary),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: bgDark,
    elevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  ),
  bottomAppBarTheme: const BottomAppBarThemeData(
    color: bgCard,
    elevation: 0,
  ),
  useMaterial3: true,
);

const btnGradient = LinearGradient(
  colors: [gradientStart, gradientEnd],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
