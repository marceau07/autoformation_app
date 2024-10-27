import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;

  Category({required this.name, required this.icon});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
      icon: _getIconFromName(json['icon']), // Convertit le nom de l'icône
    );
  }

  // Fonction pour convertir une chaîne en IconData
  static IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'computer':
        return Icons.computer;
      case 'construction':
        return Icons.construction;
      case 'code':
        return Icons.code;
      case 'electrical_services':
        return Icons.electrical_services;
      default:
        return Icons.help; // Icône par défaut si l'icône n'est pas reconnue
    }
  }
}
