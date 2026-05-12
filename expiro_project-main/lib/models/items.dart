import 'package:flutter/material.dart';

enum ItemStatus { expired, soon, fresh }

enum ProductType {
  food,
  dairy,
  meat,
  vegetables,
  medicine,
  cosmetics,
  household,
  other
}

extension ProductTypeExt on ProductType {
  String get label {
    switch (this) {
      case ProductType.food:
        return 'Food';
      case ProductType.dairy:
        return 'Dairy';
      case ProductType.meat:
        return 'Meat';
      case ProductType.vegetables:
        return 'Vegetables';
      case ProductType.medicine:
        return 'Medicine';
      case ProductType.cosmetics:
        return 'Cosmetics';
      case ProductType.household:
        return 'Household';
      case ProductType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ProductType.food:
        return Icons.apple_outlined;
      case ProductType.dairy:
        return Icons.water_drop_outlined;
      case ProductType.meat:
        return Icons.set_meal_outlined;
      case ProductType.vegetables:
        return Icons.eco_outlined;
      case ProductType.medicine:
        return Icons.medication_outlined;
      case ProductType.cosmetics:
        return Icons.auto_awesome_outlined;
      case ProductType.household:
        return Icons.home_outlined;
      case ProductType.other:
        return Icons.inventory_2_outlined;
    }
  }
}

class Item {
  final int id;
  final String name;
  final ProductType type;
  final DateTime expiryDate;
  final int quantity;
  final bool isFavorite;

  Item({
    required this.id,
    required this.name,
    required this.type,
    required this.expiryDate,
    this.quantity = 1,
    this.isFavorite = false,
  });

  int get daysLeft {
    final now = DateTime.now();
    return expiryDate.difference(
      DateTime(now.year, now.month, now.day),
    ).inDays;
  }

  ItemStatus get status {
    if (daysLeft < 0) return ItemStatus.expired;
    if (daysLeft <= 3) return ItemStatus.soon;
    return ItemStatus.fresh;
  }

  Color get statusColor {
    switch (status) {
      case ItemStatus.expired:
        return const Color(0xFFE53935);
      case ItemStatus.soon:
        return const Color(0xFFFF7043);
      case ItemStatus.fresh:
        return const Color(0xFF43A047);
    }
  }

  String get statusLabel {
    switch (status) {
      case ItemStatus.expired:
        return 'Expired';
      case ItemStatus.soon:
        return 'Soon';
      case ItemStatus.fresh:
        return 'Fresh';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.index,
    'expiryDate': expiryDate.toIso8601String(),
    'quantity': quantity,
    'isFavorite': isFavorite,
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'] as int,
    name: json['name'] as String,
    type: ProductType.values[json['type'] as int],
    expiryDate: DateTime.parse(json['expiryDate'] as String),
    quantity: json['quantity'] as int? ?? 1,
    isFavorite: json['isFavorite'] as bool? ?? false,
  );

  Item copyWith({
    int? id,
    String? name,
    ProductType? type,
    DateTime? expiryDate,
    int? quantity,
    bool? isFavorite,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}