import 'package:flutter/material.dart';
import 'package:montajat_customer_app/features/categories/data/models/category_model.dart';

abstract final class CategoriesRepository {
  static const items = [
    CategoryModel(labelKey: 'categories.food', icon: Icons.restaurant_outlined),
    CategoryModel(
      labelKey: 'categories.supplements',
      icon: Icons.shopping_bag_outlined,
    ),
    CategoryModel(labelKey: 'categories.furniture', icon: Icons.chair_outlined),
    CategoryModel(labelKey: 'categories.toys', icon: Icons.toys_outlined),
    CategoryModel(
      labelKey: 'categories.nutrition',
      icon: Icons.inventory_2_outlined,
    ),
    CategoryModel(
      labelKey: 'categories.medical',
      icon: Icons.medical_services_outlined,
    ),
    CategoryModel(
      labelKey: 'categories.health',
      icon: Icons.health_and_safety_outlined,
    ),
    CategoryModel(
      labelKey: 'categories.entertainment',
      icon: Icons.sports_tennis_outlined,
    ),
    CategoryModel(
      labelKey: 'categories.cages',
      icon: Icons.card_giftcard_outlined,
    ),
    CategoryModel(
      labelKey: 'categories.transport',
      icon: Icons.luggage_outlined,
    ),
    CategoryModel(
      labelKey: 'categories.grooming',
      icon: Icons.cleaning_services_outlined,
    ),
    CategoryModel(
      labelKey: 'categories.training',
      icon: Icons.content_cut_outlined,
    ),
    CategoryModel(
      labelKey: 'categories.clothes',
      icon: Icons.checkroom_outlined,
    ),
    CategoryModel(labelKey: 'categories.aquariums', icon: Icons.pets_outlined),
    CategoryModel(
      labelKey: 'categories.devices',
      icon: Icons.devices_other_outlined,
    ),
  ];

  static final homeItems = items.take(5).toList(growable: false);
}
