import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:local_first/core/theme/app_theme.dart';

class MarketplaceHomePage extends StatefulWidget {
  const MarketplaceHomePage({super.key});

  @override
  State<MarketplaceHomePage> createState() => _MarketplaceHomePageState();
}

class _MarketplaceHomePageState extends State<MarketplaceHomePage> {
  bool _isRentSelected = true;

  // Mock data for Rent Items (directly from Stitch spec)
  final List<Map<String, dynamic>> _rentItems = [
    {
      'title': 'Hammer Drill',
      'desc': 'Heavy duty',
      'price': '₹300',
      'unit': '/day',
      'rating': '4.8',
      'distance': '0.8km',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBXI1Dl4m3SRX3mTtEhp_QXRi8tlda7QwogVrenC8cwnULjvBE5BQec5IDIapEhT6RVTl8cDBVD-GH76l0sCD5G2Ku0YJOySwBuG-ineO30DrGoWNhHYASdk-04JhCRWE-dU3TbT0IQoBlA7lYkCGhDqfnlcI0-K1jJjriMOGIXn1l6VdAyJbIpuCdK1EdqXJ7tWa6xzhIebPqkOVYaegOGSOTEbW6avNOJfWqU7zDKdM6ro4O2BI5oXrT9ZtFPNi16Nfz7MFtcdXB7',
    },
    {
      'title': 'Camping Tent',
      'desc': '4 Person',
      'price': '₹150',
      'unit': '/day',
      'rating': '4.9',
      'distance': '1.2km',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDld4blIuzFnohv1nPIAM8CaDqEnbb3eXXpCiEeL8UsgDA5z-iTg1ddZsfHpzX38E20Y254Lq-ArhTbdDJFJON10mplv0KICUwROTbku8hX7GafDxI9hoD8u4PpGIHv4lzhiaj01nWQ_CYws3A2ph59UDRVTDuAMRXgiTk5SOAHvD-M67kZYj4jFzP3ZH9FW-d5RDa05rAgRnKaC-GZz42CLJxjHbX3XepMpiGjDnYK3QzXyI93nufTZy8Ntey4FN92_198VVBxCygF',
    },
    {
      'title': 'Folding Ladder',
      'desc': '12 ft Aluminum',
      'price': '₹100',
      'unit': '/day',
      'rating': '4.5',
      'distance': '2.1km',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCfm2q2wdHVTmq4Gt3w0GERSocpZ6w5K4mrkFk4qr5ZikMc8oYQb9-Toj8kqdXUdi_yv93kUG_74kRweXpAbKQ00VBk3rvDdCEf9waQrTh2cWyBxCewnEj2feE2k83RX60LAyJDHxloVqn4sMXFnAuvX-vHT-XxO5tnNsZxwUU8PUUBEjpnZg2KP0X8Nohonsr0daLJveFCAfQaklvnh6GvRAQB0pNobPn_qWx8fmA6WDnv74YsZhONa8uiyYYX-umWoGuEUyPt9rzk',
    },
    {
      'title': 'Power Station',
      'desc': '500W Portable',
      'price': '₹500',
      'unit': '/day',
      'rating': '5.0',
      'distance': '0.5km',
      'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBr-P9uToSzvESHTNRfrWHZt8M2mitO6rruh0cg7LTJLAo4JD3ZVtYY415RJTB-Zd4cvjvhU_B_NhyQAYabZEZSkzzDVUR2HI4va8pd4viaByVYkFvX_AzCBhLZ9pZ6qDOusA7R-e4IDEI8nAjrX1YbakwBMe9nDQp4xAIPhqFaIsN41E8dHCGJ3TL6oCmFnahwBqSnT3hXHl4kKiCVT-QhKsD4qlM3OqRl9zZrWMdkN_dC-ZEhng_nq5c6UHAH5syu_z6CZWgyTkgB',
    },
  ];

  // Mock data for Hire Services (Workers)
  final List<Map<String, dynamic>> _hireWorkers = [
    {
      'title': 'Ramesh Singh',
      'desc': 'Certified Electrician',
      'price': '₹400',
      'unit': '/hr',
      'rating': '4.9',
      'distance': '0.6km',
      'image': 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=150',
    },
    {
      'title': 'Amit Kumar',
      'desc': 'Plumbing Specialist',
      'price': '₹350',
      'unit': '/hr',
      'rating': '4.7',
      'distance': '1.1km',
      'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    },
    {
      'title': 'Vikram Dev',
      'desc': 'Master Carpenter',
      'price': '₹500',
      'unit': '/hr',
      'rating': '4.8',
      'distance': '1.8km',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    },
    {
      'title': 'Sunita Sen',
      'desc': 'Professional Housekeeping',
      'price': '₹250',
      'unit': '/hr',
      'rating': '5.0',
      'distance': '0.4km',
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final listings = _isRentSelected ? _rentItems : _hireWorkers;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: Icon(
          Icons.verified_user,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          'ShieldShare',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: theme.textTheme.bodySmall?.color,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Location Header
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
                  'Sector 4',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(width: spacing.space4),
                Text(
                  '(1.5km)',
                  style: theme.textTheme.labelSmall,
                ),
                const Spacer(),
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        'Change',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Icon(
                        Icons.expand_more,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Scrollable listings content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(spacing.edgeMargin),
              child: Column(
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
                                _isRentSelected = true;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isRentSelected
                                    ? theme.colorScheme.surface
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: _isRentSelected
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
                                  color: _isRentSelected
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
                                _isRentSelected = false;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isRentSelected
                                    ? theme.colorScheme.surface
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: !_isRentSelected
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
                                  color: !_isRentSelected
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

                  // Search & Filter Row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: _isRentSelected
                                  ? 'Search items...'
                                  : 'Search services...',
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
                        onTap: () {},
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

                  // Grid listings
                  GridView.builder(
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
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Image + Star Rating Overlay
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CachedNetworkImage(
                                      imageUrl: item['image'],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: const Color(0xFFF1F5F9),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: const Color(0xFFF1F5F9),
                                        child: Icon(
                                          _isRentSelected
                                              ? Icons.inventory_2
                                              : Icons.person,
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            item['rating'],
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                              color: const Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Details
                            Padding(
                              padding: EdgeInsets.all(spacing.space8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['desc'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: spacing.space8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: item['price'],
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: item['unit'],
                                              style: theme.textTheme.labelSmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.near_me,
                                            size: 10,
                                            color: theme
                                                .textTheme.bodySmall?.color,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            item['distance'],
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              fontSize: 10,
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
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
