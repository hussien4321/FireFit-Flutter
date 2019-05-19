import 'package:flutter/material.dart';

enum ClothesStyles {
  CASUAL,
  SPORTS,
  STREET,
  OFFICE,
  FORMAL,
  HOME,
}

class Style {


  static List<ClothesStyles> allStyles = [
    ClothesStyles.CASUAL,
    ClothesStyles.SPORTS,
    ClothesStyles.STREET,
    ClothesStyles.OFFICE,
    ClothesStyles.FORMAL,
    ClothesStyles.HOME,
  ];
  
  String name;
  String asset;
  Color backgroundColor;
  Color textColor;

  Style(ClothesStyles selectedStyle) {

    textColor = Colors.black;

    switch (selectedStyle) {
      case ClothesStyles.CASUAL:
        name = "Casualwear";
        asset = "assets/style/casualwear.png";
        textColor = Colors.white;
        backgroundColor = Color.fromRGBO(234, 57, 78, 1.0);
        break;
      case ClothesStyles.HOME:
        name = "Homewear";
        asset = "assets/style/homewear.png";
        backgroundColor = Color.fromRGBO(234, 190, 50, 1.0);
        break;
      case ClothesStyles.FORMAL:
        name = "Formalwear";
        asset = "assets/style/formalwear.png";
        textColor = Colors.white;
        backgroundColor = Color.fromRGBO(81, 90, 94, 1.0);
        break;
      case ClothesStyles.OFFICE:
        name = "Officewear";
        asset = "assets/style/officewear.png";
        backgroundColor = Color.fromRGBO(157, 202, 224, 1.0);
        break;
      case ClothesStyles.STREET:
        name = "Streetwear";
        asset = "assets/style/streetwear.png";
        textColor = Colors.white;
        backgroundColor = Color.fromRGBO(14, 112, 142, 1.0);
        break;
      case ClothesStyles.SPORTS:
        name = "Sportswear";
        asset = "assets/style/sportswear.png";
        backgroundColor = Color.fromRGBO(106, 169, 124, 1.0);
        break;
      default:
        return;
    }
  }

  
  static Style    fromStyleString(String style) {
    switch (style.toLowerCase()) {
      case 'casualwear':
        return Style(ClothesStyles.CASUAL);
      case 'homewear':
        return Style(ClothesStyles.HOME);
      case 'formalwear':
        return Style(ClothesStyles.FORMAL);
      case 'officewear':
        return Style(ClothesStyles.OFFICE);
      case 'streetwear':
        return Style(ClothesStyles.STREET);
      case 'sportswear':
        return Style(ClothesStyles.SPORTS);
      default:
        return null;
    }
  }
}