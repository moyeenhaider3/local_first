import 'package:equatable/equatable.dart';

enum CategoryListingType { rental, service, both }

/// Domain Layer: Category Entity.
/// Represents a listing category (e.g. Tools, Handyman, Electronics).
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final CategoryListingType listingType;
  final int sortOrder;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconName,
    required this.listingType,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        iconName,
        listingType,
        sortOrder,
      ];
}
