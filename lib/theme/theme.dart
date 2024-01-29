

import 'package:flutter/material.dart';

import 'package:delivery_flutter/theme/colors.dart';

final appTheme = ThemeData(
  fontFamily: 'NimbusSans',
  primaryColor: MyColors.primaryColor,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: MyColors.primaryColor
  ),
  canvasColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    elevation: 0,
    iconTheme: const IconThemeData(
      color: Colors.white
    ),
    backgroundColor: MyColors.primaryColor,
    titleTextStyle: const TextStyle().copyWith(
      color: Colors.white,
      fontSize: 18
    )
  ),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: const EdgeInsets.all(15),
    hintStyle: TextStyle(
      color: MyColors.primaryColorDark
    ),
    focusedBorder: const UnderlineInputBorder( 
      borderSide: BorderSide(
        style: BorderStyle.none,
      )
    ),
    enabledBorder: const UnderlineInputBorder( 
      borderSide: BorderSide(
        style: BorderStyle.none,
      )
    ),
    border: const UnderlineInputBorder( 
      borderSide: BorderSide(
        style: BorderStyle.none,
      )
    )
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: MyColors.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30)
      ),
      textStyle: const TextStyle().copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold
      ),
    )
  )
);