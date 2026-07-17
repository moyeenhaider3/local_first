import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/features/listings/domain/entities/listing_entity.dart';
import 'package:local_first/features/listings/presentation/cubits/discovery_cubit.dart';

/// Screen displaying nearby listings on an interactive map.
/// Connects with DiscoveryCubit to show filtered markers and preview cards.
class MapPreviewOverlay extends StatefulWidget {
  const MapPreviewOverlay({super.key});

  @override
  State<MapPreviewOverlay> createState() => _MapPreviewOverlayState();
}

class _MapPreviewOverlayState extends State<MapPreviewOverlay> {
  GoogleMapController? _mapController;
  late PageController _pageController;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });
  }

  void _onPageChanged(int index, List<ListingEntity> listings) {
    if (_isMapReady && index < listings.length) {
      final listing = listings[index];
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(listing.location.latitude, listing.location.longitude),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<DiscoveryCubit, DiscoveryState>(
        builder: (context, state) {
          if (state is DiscoveryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DiscoveryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DiscoveryCubit>().loadDiscovery(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          List<ListingEntity> listings = [];
          if (state is DiscoveryLoaded) {
            listings = state.listings;
          }

          if (listings.isEmpty) {
            return Center(
              child: Text(
                'No listings found nearby.',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          // Initial position at first listing, or fallback
          final initialLatLng = LatLng(
            listings.first.location.latitude,
            listings.first.location.longitude,
          );

          // Create Map markers
          final Set<Marker> markers = listings.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Marker(
              markerId: MarkerId(item.id),
              position: LatLng(item.location.latitude, item.location.longitude),
              infoWindow: InfoWindow(title: item.title),
              onTap: () {
                _pageController.animateToPage(
                  idx,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            );
          }).toSet();

          return Stack(
            children: [
              // Google Map
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: initialLatLng,
                  zoom: 14.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: markers,
                zoomControlsEnabled: false,
              ),

              // Bottom Overlay Quick Preview PageView
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: listings.length,
                  onPageChanged: (idx) => _onPageChanged(idx, listings),
                  itemBuilder: (context, idx) {
                    final item = listings[idx];
                    return _buildPreviewCard(context, item);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context, ListingEntity item) {
    final theme = Theme.of(context);

    // Price display logic
    String priceText = '';
    if (item.listingType == ListingType.rental) {
      priceText = '₹${item.pricePerDay?.toStringAsFixed(0) ?? '0'}/day';
    } else {
      priceText = 'From ₹${item.startingRate?.toStringAsFixed(0) ?? '0'}/${item.rateUnit ?? 'hr'}';
    }

    final isHighTrust = item.ownerTrustScore >= 4.0;
    final badgeColor = isHighTrust ? const Color(0xFF16A34A) : theme.colorScheme.secondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Aspect 1:1 image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: item.thumbnailUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 80,
                      height: 80,
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: const Color(0xFFF1F5F9),
                      child: Icon(
                        item.listingType == ListingType.rental ? Icons.inventory_2 : Icons.person,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'By ${item.ownerDisplayName}',
                        maxLines: 1,
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            priceText,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: badgeColor, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                item.ownerTrustScore.toStringAsFixed(1),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: badgeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // View full details button
          SizedBox(
            height: 40,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () {
                context.pushNamed(
                  RouteNames.itemDetail,
                  pathParameters: {'id': item.id},
                );
              },
              child: const Text('VIEW DETAILS'),
            ),
          ),
        ],
      ),
    );
  }
}
