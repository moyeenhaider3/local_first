import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/listings/domain/entities/category_entity.dart';
import 'package:local_first/features/listings/domain/entities/listing_entity.dart';
import 'package:local_first/features/listings/presentation/cubits/discovery_cubit.dart';
import 'package:local_first/features/listings/presentation/widgets/category_chip.dart';
import 'package:local_first/features/listings/presentation/widgets/filter_bottom_sheet.dart';
import 'package:local_first/features/listings/presentation/widgets/listing_card.dart';

/// Unified marketplace main hub for browsing nearby items and services.
class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({super.key});

  @override
  State<MarketplaceHomePage> createState() => _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  ListingType _selectedType = ListingType.rental;

  @override
  void initState() {
    super.initState();
    // Dispatch initial load of discovery listings and categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<DiscoveryCubit>();
      _selectedType = cubit.filters.listingType ?? ListingType.rental;
      cubit.loadDiscovery();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final cubit = context.read<DiscoveryCubit>();
      cubit.updateFilters(cubit.filters.copyWith(
        searchQuery: () => query,
      ));
    });
  }

  void _onCategoryTapped(String categoryId, String? activeCategoryId) {
    final cubit = context.read<DiscoveryCubit>();
    final isAlreadySelected = activeCategoryId == categoryId;
    cubit.updateFilters(cubit.filters.copyWith(
      categoryId: () => isAlreadySelected ? null : categoryId,
    ));
  }

  void _openFiltersBottomSheet(
    BuildContext context,
    DiscoveryFilters activeFilters,
    List<CategoryEntity> categories,
  ) async {
    final cubit = context.read<DiscoveryCubit>();
    final newFilters = await showModalBottomSheet<DiscoveryFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialFilters: activeFilters,
        categories: categories,
      ),
    );

    if (newFilters != null) {
      cubit.updateFilters(newFilters);
      // Sync local segment tab selection if updated in filter sheet
      if (newFilters.listingType != null) {
        setState(() {
          _selectedType = newFilters.listingType!;
        });
      }
    }
  }

  double? _calculateDistance(GeoPoint? center, GeoPoint target) {
    if (center == null) return null;
    final double distanceInMeters = Geolocator.distanceBetween(
      center.latitude,
      center.longitude,
      target.latitude,
      target.longitude,
    );
    return distanceInMeters / 1000.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Local First',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.map_outlined,
              color: theme.textTheme.bodySmall?.color,
            ),
            onPressed: () => context.pushNamed(RouteNames.mapPreview),
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: theme.textTheme.bodySmall?.color,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<DiscoveryCubit, DiscoveryState>(
        listener: (context, state) {
          // Sync text field with cubit filter state when cleared/altered externally
          String? currentQuery;
          if (state is DiscoveryLoaded) {
            currentQuery = state.activeFilters.searchQuery;
          } else if (state is DiscoveryEmpty) {
            currentQuery = state.activeFilters.searchQuery;
          }
          if (currentQuery != _searchController.text) {
            _searchController.text = currentQuery ?? '';
          }
        },
        builder: (context, state) {
          final cubit = context.read<DiscoveryCubit>();
          final center = cubit.lastCenter;

          // Determine center locality name
          String locality = 'New Delhi';
          if (center != null) {
            if (center.latitude.toStringAsFixed(2) != '28.61' ||
                center.longitude.toStringAsFixed(2) != '77.21') {
              locality = 'Sector 4';
            }
          }

          // Shared Header layouts (Location, Toggles, Search bar, Category lists)
          List<CategoryEntity> categories = [];
          DiscoveryFilters activeFilters = const DiscoveryFilters();

          if (state is DiscoveryLoaded) {
            categories = state.categories;
            activeFilters = state.activeFilters;
          } else if (state is DiscoveryEmpty) {
            categories = state.categories;
            activeFilters = state.activeFilters;
          }

          return Column(
            children: [
              // Location header bar
              Container(
                color: theme.colorScheme.surface,
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.edgeMargin,
                  vertical: spacing.space8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: spacing.space8),
                    Text(
                      locality,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Dynamic scroll/body wrapper
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<DiscoveryCubit>().loadDiscovery(forceRefresh: true),
                  child: ListView(
                    padding: EdgeInsets.all(spacing.edgeMargin),
                    children: [
                      // Directory Switcher
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9), // surface-container-low (light slate)
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedType = ListingType.rental;
                                  });
                                  cubit.updateFilters(cubit.filters.copyWith(
                                    listingType: () => ListingType.rental,
                                  ));
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedType == ListingType.rental
                                        ? theme.colorScheme.surface
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: _selectedType == ListingType.rental
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    'RENT ITEMS',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: _selectedType == ListingType.rental
                                          ? theme.colorScheme.primary
                                          : theme.textTheme.bodySmall?.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedType = ListingType.service;
                                  });
                                  cubit.updateFilters(cubit.filters.copyWith(
                                    listingType: () => ListingType.service,
                                  ));
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedType == ListingType.service
                                        ? theme.colorScheme.surface
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: _selectedType == ListingType.service
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    'HIRE SERVICES',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: _selectedType == ListingType.service
                                          ? theme.colorScheme.primary
                                          : theme.textTheme.bodySmall?.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing.space16),

                      // Search and filters row
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: _selectedType == ListingType.rental
                                      ? 'Search items, tools, and gears...'
                                      : 'Search local services and workers...',
                                  prefixIcon: const Icon(Icons.search),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: spacing.space8),
                          InkWell(
                            onTap: () => _openFiltersBottomSheet(context, activeFilters, categories),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                                borderRadius: BorderRadius.circular(8),
                                color: theme.colorScheme.surface,
                              ),
                              child: Icon(
                                Icons.tune,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.space16),

                      // Horizontal Categories List
                      if (categories.isNotEmpty) ...[
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            separatorBuilder: (context, _) => SizedBox(width: spacing.space8),
                            itemBuilder: (context, idx) {
                              final cat = categories[idx];
                              return CategoryChip(
                                categoryId: cat.id,
                                name: cat.name,
                                iconName: cat.iconName,
                                isSelected: activeFilters.categoryId == cat.id,
                                onTap: () => _onCategoryTapped(cat.id, activeFilters.categoryId),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: spacing.space16),
                      ],

                      // Grid Body or Alternate states
                      _buildStateBody(context, state, center),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: const CircleBorder(),
        onPressed: () {
          context.pushNamed(RouteNames.createListing);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStateBody(BuildContext context, DiscoveryState state, GeoPoint? center) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    if (state is DiscoveryLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is DiscoveryError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.message,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<DiscoveryCubit>().loadDiscovery(),
                child: const Text('RETRY'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is DiscoveryEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: theme.colorScheme.secondary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'No items found nearby.',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try clearing some filters or expanding your search distance.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state is DiscoveryLoaded) {
      final listings = state.listings;
      if (listings.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64, color: theme.colorScheme.secondary.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                'No items found nearby.',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: spacing.space16,
          mainAxisSpacing: spacing.space16,
          childAspectRatio: 0.72,
        ),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final item = listings[index];
          final distance = _calculateDistance(center, item.location);
          return ListingCard(
            listing: item,
            distanceKm: distance,
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
