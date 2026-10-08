import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final String iconUrl;
  final IconData iconData;
  final Color backgroundColor;

  CategoryItem({
    required this.id,
    required this.name,
    this.iconUrl = '',
    required this.iconData,
    this.backgroundColor = const Color(0xFFE8F5E9),
  });
}
