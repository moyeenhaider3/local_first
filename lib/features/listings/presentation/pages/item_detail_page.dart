import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local_first/core/di/service_locator.dart';
import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:local_first/features/listings/domain/entities/listing_entity.dart';
import 'package:local_first/features/listings/domain/repositories/discovery_repository.dart';

/// Screen displaying complete details for a rental item or service.
class ItemDetailPage extends StatefulWidget {
  final String listingId;

  const ItemDetailPage({
    super.key,
    required this.listingId,
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late Future<ListingEntity> _loadFuture;
  int _carouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFuture = _fetchListing();
  }

  Future<ListingEntity> _fetchListing() async {
    final result = await sl<DiscoveryRepository>().getListingById(widget.listingId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (listing) => listing,
    );
  }

  void _handleBookingRequest(BuildContext context, ListingEntity listing) {
    final authState = context.read<AuthCubit>().state;
    bool isKycVerified = false;

    if (authState is AuthSuccess) {
      isKycVerified = authState.hasKyc;
    }

    if (isKycVerified) {
      // Navigate to booking request setup page (BKG-01)
      context.pushNamed(
        RouteNames.bookingRequest,
        pathParameters: {'id': listing.id},
      );
    } else {
      // Warn and redirect to KYC upload page (AUTH-04)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('KYC verification required before booking.'),
          backgroundColor: Color(0xFFDC2626), // Danger color
        ),
      );
      context.pushNamed(RouteNames.kycUpload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return FutureBuilder<ListingEntity>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(spacing.edgeMargin),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Failed to load details.',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().replaceAll('Exception:', ''),
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _loadFuture = _fetchListing();
                        });
                      },
                      child: const Text('RETRY'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final listing = snapshot.data!;

        // Price display formatting
        String priceText = '';
        if (listing.listingType == ListingType.rental) {
          priceText = '₹${listing.pricePerDay?.toStringAsFixed(0) ?? '0'}/day';
        } else {
          priceText = 'From ₹${listing.startingRate?.toStringAsFixed(0) ?? '0'}/${listing.rateUnit ?? 'hr'}';
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.secondary),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share, color: theme.colorScheme.secondary),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(spacing.edgeMargin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Carousel
                      if (listing.images.isNotEmpty)
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Stack(
                            children: [
                              PageView.builder(
                                itemCount: listing.images.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _carouselIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: listing.images[index],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: const Color(0xFFF1F5F9),
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: const Color(0xFFF1F5F9),
                                        child: const Icon(Icons.broken_image, size: 40),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Dot Indicators
                              if (listing.images.length > 1)
                                Positioned(
                                  bottom: 12,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      listing.images.length,
                                      (idx) => Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _carouselIndex == idx
                                              ? theme.colorScheme.primary
                                              : Colors.white.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      SizedBox(height: spacing.space16),

                      // Title and Price Block
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  listing.title,
                                  style: theme.textTheme.displayLarge?.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: spacing.space4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    listing.categoryName.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            priceText,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.space16),

                      // Description
                      Text(
                        'Description',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: spacing.space4),
                      Text(
                        listing.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      SizedBox(height: spacing.space24),

                      // Owner Card
                      Text(
                        'Owner',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: spacing.space8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: listing.ownerPhotoUrl != null
                                  ? NetworkImage(listing.ownerPhotoUrl!)
                                  : null,
                              child: listing.ownerPhotoUrl == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        listing.ownerDisplayName,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.verified,
                                        color: theme.colorScheme.primary,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: Colors.amber, size: 14),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Trust Score: ${listing.ownerTrustScore.toStringAsFixed(1)}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing.space24),

                      // Pickup Estimate Map Zone
                      Text(
                        'Approximate Pickup Zone',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: spacing.space8),
                      Container(
                        height: 140,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(listing.location.latitude, listing.location.longitude),
                            zoom: 13.0,
                          ),
                          circles: {
                            Circle(
                              circleId: const CircleId('pickup_zone'),
                              center: LatLng(listing.location.latitude, listing.location.longitude),
                              radius: listing.pickupRadiusKm * 1000,
                              strokeWidth: 2,
                              strokeColor: theme.colorScheme.primary,
                              fillColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                            ),
                          },
                          liteModeEnabled: true,
                          scrollGesturesEnabled: false,
                          zoomGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                          rotateGesturesEnabled: false,
                        ),
                      ),
                      SizedBox(height: spacing.space24),
                    ],
                  ),
                ),
              ),

              // Sticky Initiate button at bottom
              Container(
                color: theme.colorScheme.surface,
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.edgeMargin,
                  vertical: spacing.space16,
                ),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed: () => _handleBookingRequest(context, listing),
                    child: const Text('INITIATE RENTAL REQUEST'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
