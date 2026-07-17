import 'package:flutter/material.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/listings/domain/entities/category_entity.dart';
import 'package:local_first/features/listings/presentation/cubits/discovery_cubit.dart';
import 'package:local_first/features/listings/presentation/widgets/category_chip.dart';

/// Bottom sheet for editing search filters (radius, category, trust score).
class FilterBottomSheet extends StatefulWidget {
  final DiscoveryFilters initialFilters;
  final List<CategoryEntity> categories;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.categories,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _radiusKm;
  late String? _categoryId;
  late double? _minTrustScore;

  @override
  void initState() {
    super.initState();
    _radiusKm = widget.initialFilters.radiusKm;
    _categoryId = widget.initialFilters.categoryId;
    _minTrustScore = widget.initialFilters.minTrustScore;
  }

  bool get _hasChanges {
    return _radiusKm != widget.initialFilters.radiusKm ||
        _categoryId != widget.initialFilters.categoryId ||
        _minTrustScore != widget.initialFilters.minTrustScore;
  }

  void _resetAll() {
    setState(() {
      _radiusKm = 5.0; // Default
      _categoryId = null;
      _minTrustScore = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        left: spacing.edgeMargin,
        right: spacing.edgeMargin,
        top: spacing.space8,
        bottom: spacing.space24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: spacing.space16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters & Preferences',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _resetAll,
                child: Text(
                  'Reset All',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFFE2E8F0)),
          SizedBox(height: spacing.space16),

          // Distance Range Slider / Slider
          Text(
            'Distance Radius: ${_radiusKm.toStringAsFixed(1)} km',
            style: theme.textTheme.labelLarge,
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.colorScheme.primary,
              thumbColor: theme.colorScheme.primary,
            ),
            child: Slider(
              value: _radiusKm,
              min: 0.5,
              max: 15.0,
              divisions: 29, // 0.5 increments
              label: '${_radiusKm.toStringAsFixed(1)} km',
              onChanged: (val) {
                setState(() {
                  _radiusKm = val;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('500m', style: theme.textTheme.labelSmall),
                Text('1km', style: theme.textTheme.labelSmall),
                Text('5km', style: theme.textTheme.labelSmall),
                Text('10km', style: theme.textTheme.labelSmall),
                Text('15km', style: theme.textTheme.labelSmall),
              ],
            ),
          ),
          SizedBox(height: spacing.space24),

          // Category section
          Text(
            'Category',
            style: theme.textTheme.labelLarge,
          ),
          SizedBox(height: spacing.space8),
          Wrap(
            spacing: spacing.space8,
            runSpacing: spacing.space8,
            children: widget.categories.map((category) {
              final isSelected = _categoryId == category.id;
              return CategoryChip(
                categoryId: category.id,
                name: category.name,
                iconName: category.iconName,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _categoryId = null;
                    } else {
                      _categoryId = category.id;
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: spacing.space24),

          // Trust score section
          Text(
            'Minimum Owner Trust Score',
            style: theme.textTheme.labelLarge,
          ),
          SizedBox(height: spacing.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTrustButton(context, 'Any', null),
              _buildTrustButton(context, '★ 3.0+', 3.0),
              _buildTrustButton(context, '★ 4.0+', 4.0),
              _buildTrustButton(context, '★ 4.5+', 4.5),
            ],
          ),
          SizedBox(height: spacing.space32),

          // Sticky Button
          ElevatedButton(
            onPressed: _hasChanges
                ? () {
                    final newFilters = widget.initialFilters.copyWith(
                      radiusKm: _radiusKm,
                      categoryId: () => _categoryId,
                      minTrustScore: () => _minTrustScore,
                    );
                    Navigator.of(context).pop(newFilters);
                  }
                : null,
            child: const Text('APPLY FILTERS'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustButton(BuildContext context, String label, double? value) {
    final theme = Theme.of(context);
    final isSelected = _minTrustScore == value;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: () {
            setState(() {
              _minTrustScore = value;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : const Color(0xFFCBD5E1),
              ),
            ),
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? theme.colorScheme.onPrimary : theme.textTheme.bodyLarge?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
