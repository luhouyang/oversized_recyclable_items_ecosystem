import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UIColor {
  final Color primaryColorDark = const Color.fromARGB(255, 178, 255, 255);
  final Color primaryColorLight = const Color.fromARGB(255, 15, 165, 165);

  final Color celeste = const Color.fromARGB(255, 178, 255, 255);
  final Color scarlet = const Color.fromARGB(255, 255, 36, 00);
  final Color springGreen = const Color.fromARGB(255, 00, 255, 127);
  final Color lightCanary = const Color.fromARGB(255, 255, 225, 159);

  final Color white = const Color.fromARGB(255, 255, 255, 255);
  final Color whiteSmoke = const Color.fromARGB(255, 245, 245, 245);
  final Color gray = const Color.fromARGB(255, 180, 180, 180);
  final Color mediumGray = const Color.fromARGB(255, 56, 56, 56);
  final Color darkGray = const Color.fromARGB(255, 32, 32, 32);

  // transparent colors
  final Color transparentCeleste = const Color.fromARGB(255, 224, 242, 242);
  final Color transparentScarlet = const Color.fromARGB(255, 255, 111, 88);
  final Color transparentSpringGreen = const Color.fromARGB(255, 136, 254, 195);
  final Color transparentLightCanary = const Color.fromARGB(255, 255, 237, 199);
}

final ThemeData lightTheme = ThemeData(
  primaryColor: UIColor().primaryColorLight,
  scaffoldBackgroundColor: UIColor().whiteSmoke,
  appBarTheme: AppBarTheme(color: UIColor().primaryColorLight, foregroundColor: UIColor().darkGray),
  iconTheme: IconThemeData(color: UIColor().primaryColorLight),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.inter(
      textStyle: TextStyle(
        color: UIColor().primaryColorLight,
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
    ),
    displayMedium: GoogleFonts.inter(
      textStyle: TextStyle(
        color: UIColor().primaryColorLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    headlineMedium: GoogleFonts.inter(
      textStyle: TextStyle(color: UIColor().white, fontSize: 20, fontWeight: FontWeight.w500),
    ),
    headlineSmall: GoogleFonts.inter(
      textStyle: TextStyle(color: UIColor().white, fontSize: 16, fontWeight: FontWeight.w500),
    ),
    bodyMedium: GoogleFonts.inter(textStyle: TextStyle(color: UIColor().primaryColorLight)),
    labelLarge: GoogleFonts.inter(textStyle: TextStyle(color: UIColor().springGreen)),
    labelSmall: GoogleFonts.inter(textStyle: TextStyle(color: UIColor().gray)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: UIColor().whiteSmoke,
      backgroundColor: UIColor().primaryColorLight,
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(8)),
      shadowColor: UIColor().gray,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(UIColor().whiteSmoke),
      backgroundColor: WidgetStatePropertyAll(UIColor().primaryColorLight),
      shape: WidgetStatePropertyAll(
        ContinuousRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      shadowColor: WidgetStatePropertyAll(UIColor().gray),
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(cursorColor: UIColor().darkGray),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: UIColor().transparentCeleste,
    hintStyle: TextStyle(fontSize: 16, color: UIColor().primaryColorLight),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: UIColor().primaryColorLight)),
    border: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: UIColor().springGreen),
    ),
    hoverColor: UIColor().transparentSpringGreen,
    errorStyle: TextStyle(color: UIColor().scarlet),
    floatingLabelStyle: TextStyle(color: UIColor().primaryColorLight),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: UIColor().transparentCeleste,
    contentTextStyle: GoogleFonts.inter(textStyle: TextStyle(color: UIColor().primaryColorLight)),
  ),
  scrollbarTheme: ScrollbarThemeData(thumbColor: WidgetStatePropertyAll(UIColor().springGreen)),
  cardTheme: CardTheme(color: UIColor().whiteSmoke, elevation: 3),
  highlightColor: UIColor().springGreen,
  dividerTheme: DividerThemeData(color: UIColor().primaryColorLight, thickness: 1.5),
  useMaterial3: true,
);

final ThemeData darkTheme = ThemeData(
  primaryColor: UIColor().primaryColorDark,
  scaffoldBackgroundColor: UIColor().darkGray,
  appBarTheme: AppBarTheme(color: UIColor().primaryColorDark, foregroundColor: UIColor().darkGray),
  iconTheme: IconThemeData(color: UIColor().primaryColorDark),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.inter(
      textStyle: TextStyle(
        color: UIColor().primaryColorDark,
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
    ),
    displayMedium: GoogleFonts.inter(
      textStyle: TextStyle(
        color: UIColor().primaryColorDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    headlineMedium: GoogleFonts.inter(
      textStyle: TextStyle(
        color: UIColor().primaryColorDark,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    bodyMedium: GoogleFonts.inter(textStyle: TextStyle(color: UIColor().primaryColorDark)),
    labelLarge: GoogleFonts.inter(textStyle: TextStyle(color: UIColor().springGreen)),
    labelSmall: GoogleFonts.inter(textStyle: TextStyle(color: UIColor().gray)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: UIColor().darkGray,
      backgroundColor: UIColor().springGreen,
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(UIColor().darkGray),
      backgroundColor: WidgetStatePropertyAll(UIColor().springGreen),
      shape: WidgetStatePropertyAll(
        ContinuousRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  ),
  textSelectionTheme: TextSelectionThemeData(cursorColor: UIColor().darkGray),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: UIColor().transparentCeleste,
    hintStyle: TextStyle(fontSize: 16, color: UIColor().darkGray),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: UIColor().primaryColorDark)),
    border: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: UIColor().springGreen),
    ),
    hoverColor: UIColor().transparentSpringGreen,
    errorStyle: TextStyle(color: UIColor().scarlet),
    floatingLabelStyle: TextStyle(color: UIColor().gray),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: UIColor().transparentCeleste,
    contentTextStyle: GoogleFonts.inter(textStyle: TextStyle(color: UIColor().darkGray)),
  ),
  scrollbarTheme: ScrollbarThemeData(thumbColor: WidgetStatePropertyAll(UIColor().springGreen)),
  cardTheme: CardTheme(color: UIColor().mediumGray),
  highlightColor: UIColor().springGreen,
  dividerTheme: DividerThemeData(color: UIColor().primaryColorDark, thickness: 1.5),
  dialogTheme: DialogTheme(
    backgroundColor: UIColor().mediumGray,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  useMaterial3: true,
);
