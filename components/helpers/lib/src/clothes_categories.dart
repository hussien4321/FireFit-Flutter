import 'package:flutter/material.dart';

class ClothesCategories {
  
  static List<String> postCategories = [
    'General',
    'Fashion advice',
    'Outfit discussion',
    'Fashion news',
    'Random',
  ];

  static List<DropdownMenuItem> generatePostCategoriesWidget() {
    List<DropdownMenuItem> list = [];
    for(int i = 0; i< postCategories.length; i++){
      list.add(
        DropdownMenuItem(
          child: Text(postCategories[i]),
          value: postCategories[i],
        ),
      );
    }
    return list;
  }

  static List<CategoryData> clothesCategories = [
    CategoryData(false, "Dresses"),
    CategoryData(false, "Hoodies & Sweatshirts"),
    CategoryData(false, "Jackets & Coats"),
    CategoryData(false, "Jeans"),
    CategoryData(false, "Jumpsuits & Playsuits"),
    CategoryData(false, "Knitwear"),
    CategoryData(false, "Pyjamas"),
    CategoryData(false, "Skirts"),
    CategoryData(false, "Shirts"),
    CategoryData(false, "Blouses"),
    CategoryData(false, "T-shirts"),
    CategoryData(false, "Vests"),
    CategoryData(false, "Swimwear & Beachwear"),
    CategoryData(false, "Trousers"),
    CategoryData(false, "Shoes"),
    CategoryData(false, "Handbags"),
    CategoryData(false, "Hats, Scarves & Gloves"),
    CategoryData(false, "Purses"),
    CategoryData(false, "Sunglasses"),
    CategoryData(false, "Watches"),
    CategoryData(false, "Sportswear"),
    CategoryData(false, "Swimwear"),
    CategoryData(false, "Accessories"),
    CategoryData(false, "Other"),
    CategoryData(true, "Blazers & Waistcoats"),
    CategoryData(true, "Jumpers & Cardigans"),
    CategoryData(true, "Hoodies & Sweatshirts"),
    CategoryData(true, "Jackets & Coats"),
    CategoryData(true, "Jeans"),
    CategoryData(true, "Joggers"),
    CategoryData(true, "Pyjamas & Slippers"),
    CategoryData(true, "Shirts"),
    CategoryData(true, "Shorts"),
    CategoryData(true, "Suits"),
    CategoryData(true, "Swimwear"),
    CategoryData(true, "Trousers & Chinos"),
    CategoryData(true, "T-Shirts & Polo Shirts"),
    CategoryData(true, "Shoes"),
    CategoryData(true, "Bags"),
    CategoryData(true, "Hats, Gloves & Scarves"),
    CategoryData(true, "Sunglasses"),
    CategoryData(true, "Ties"),
    CategoryData(true, "Wallets"),
    CategoryData(true, "Watches"),
    CategoryData(true, "Sportswear"),
    CategoryData(true, "Swimwear"),
    CategoryData(true, "Accessories"),
    CategoryData(true, "Other")

  ];
  

  static List<String> sizes = [
    "One size", "XXXS", "XXS", "XS", "S", "M", "L", "XL", "XXL", "XXXL", "4XL", "5XL", "6XL", "7XL", "8XL"
  ];

  static List<ColorData> colors = [
    ColorData("Black", Colors.black, Colors.white),
    ColorData("White", Colors.white, Colors.black),
    ColorData("Brown", Colors.brown, Colors.black),
    ColorData("Grey", Colors.grey, Colors.black),
    ColorData("Blue", Colors.blue, Colors.black),
    ColorData("Green", Colors.green, Colors.black),
    ColorData("Yellow", Colors.yellow, Colors.black),
    ColorData("Orange", Colors.orange, Colors.black),
    ColorData("Red", Colors.red, Colors.black),
    ColorData("Pink", Colors.pink, Colors.black),
    ColorData("Denim", Color.fromRGBO(21, 96, 189, 1.0), Colors.black),
    ColorData("Cream", Color.fromRGBO(255, 253, 208, 1.0), Colors.black),
    ColorData("Gold", Color.fromRGBO(255,215,0, 1.0), Colors.black),
    ColorData("Silver", Color.fromRGBO(192,192,192, 1.0), Colors.black),
    ColorData("Multi", Colors.black, Colors.black),
  ];

  static List<ConditionData> conditions = [
    ConditionData("Perfect", "Brand new, never worn"),
    ConditionData("Very good", "Lightly used"),
    ConditionData("Good", "Small signs of usage are visible"),
    ConditionData("Acceptable", "Severable noticible flaws"),
  ];

  static Color getColorByName(String name){
    for(ColorData colorData in colors){
      if(colorData.name == name){
        return colorData.color;
      }
    }
    return null;
  }
}

class ColorData{
  String name;
  Color color;
  Color textColor;

  ColorData(this.name, this.color, this.textColor);
}
class ConditionData{
  String name;
  String desc;

  ConditionData(this.name, this.desc);
}
class CategoryData{
  bool isMale;
  String category;

  String toString() => 'isMale:$isMale category:$category';
  CategoryData(this.isMale, this.category);
}