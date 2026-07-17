import 'package:equatable/equatable.dart';
import 'package:local_first/features/listings/domain/entities/category_entity.dart';

/// Data Model representing a category document in Firestore.
class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final CategoryListingType listingType;
  final int sortOrder;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.listingType,
    required this.sortOrder,
  });

  /// Factory to convert a domain entity to a data model.
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      iconName: entity.iconName,
      listingType: entity.listingType,
      sortOrder: entity.sortOrder,
    );
  }

  /// Factory to convert JSON from Firestore to a data model.
  factory CategoryModel.fromJson(Map<String, dynamic> json, {required String id}) {
    return CategoryModel(
      id: id,
      name: json['name'] as String? ?? '',
      iconName: json['iconName'] as String? ?? '',
      listingType: _parseListingType(json['listingType'] as String?),
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  static CategoryListingType _parseListingType(String? typeStr) {
    switch (typeStr) {
      case 'rental':
        return CategoryListingType.rental;
      case 'service':
        return CategoryListingType.service;
      case 'both':
      default:
        return CategoryListingType.both;
    }
  }

  /// Converts this model instance into a domain category entity.
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      iconName: iconName,
      listingType: listingType,
      sortOrder: sortOrder,
    );
  }

  /// Converts this model instance to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconName': iconName,
      'listingType': listingType.name,
      'sortOrder': sortOrder,
    };
  }

  @override
  List<Object?> get props => [id, name, iconName, listingType, sortOrder];
}
