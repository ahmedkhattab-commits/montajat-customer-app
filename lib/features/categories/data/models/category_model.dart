import 'package:flutter/material.dart';

class CategoryModel {
  const CategoryModel({
    required this.value,
    required this.icon,
    this.productCount = 0,
    this.labelKey,
  });

  final String value;
  final String? labelKey;
  final IconData icon;
  final int productCount;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final value = json['value'];
    final productCount = json['product_count'];
    if (value is! String || value.isEmpty || productCount is! int) {
      throw const FormatException('Invalid category item');
    }

    return CategoryModel(
      value: value,
      productCount: productCount,
      labelKey: _labelKeys[value.toLowerCase()],
      icon: _icons[value.toLowerCase()] ?? Icons.category_outlined,
    );
  }

  static const _labelKeys = <String, String>{
    'food': 'categories.food',
    'supplements & treats': 'categories.supplements',
    'fruniture': 'categories.furniture',
    'furniture': 'categories.furniture',
    'toys': 'categories.toys',
    'litter & accessories': 'categories.nutrition',
    'litters & accessories': 'categories.nutrition',
    'medical': 'categories.medical',
    'wellness': 'categories.health',
    'entertainment': 'categories.entertainment',
    'collars & harnesses': 'categories.cages',
    'carriers & cages': 'categories.transport',
    'grooming': 'categories.grooming',
    'training & cleaning': 'categories.training',
    'appearals': 'categories.clothes',
    'aquariums': 'categories.aquariums',
    'device': 'categories.devices',
  };

  static const _icons = <String, IconData>{
    'food': Icons.restaurant_outlined,
    'supplements & treats': Icons.shopping_bag_outlined,
    'fruniture': Icons.chair_outlined,
    'furniture': Icons.chair_outlined,
    'toys': Icons.toys_outlined,
    'litter & accessories': Icons.inventory_2_outlined,
    'litters & accessories': Icons.inventory_2_outlined,
    'medical': Icons.medical_services_outlined,
    'wellness': Icons.health_and_safety_outlined,
    'entertainment': Icons.sports_tennis_outlined,
    'collars & harnesses': Icons.card_giftcard_outlined,
    'carriers & cages': Icons.luggage_outlined,
    'grooming': Icons.cleaning_services_outlined,
    'training & cleaning': Icons.content_cut_outlined,
    'appearals': Icons.checkroom_outlined,
    'aquariums': Icons.pets_outlined,
    'device': Icons.devices_other_outlined,
  };
}
