import 'package:flutter/material.dart';
import 'package:local_first/core/theme/app_theme.dart';

/// Interactive chip for selecting/filtering by category.
class CategoryChip extends StatelessWidget {
  final String categoryId;
  final String name;
  final String iconName;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.categoryId,
    required this.name,
    required this.iconName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    final IconData icon = _getCategoryIcon(iconName);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? theme.colorScheme.onPrimary : theme.textTheme.bodySmall?.color,
            ),
            SizedBox(width: spacing.space4),
            Text(
              name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? theme.colorScheme.onPrimary : theme.textTheme.bodyLarge?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    switch (name) {
      case 'construction':
        return Icons.construction;
      case 'devices':
        return Icons.devices;
      case 'directions_car':
        return Icons.directions_car;
      case 'terrain':
        return Icons.terrain;
      case 'plumbing':
        return Icons.plumbing;
      case 'bolt':
        return Icons.bolt;
      case 'cleaning_services':
        return Icons.cleaning_services;
      default:
        return Icons.category;
    }
  }
}
