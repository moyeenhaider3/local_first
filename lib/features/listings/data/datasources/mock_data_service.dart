import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

/// Service to populate Firebase Firestore with mock categories and listings.
/// Runs on startup in debug mode to ensure data matches the expected schema.
class MockDataService {
  final FirebaseFirestore firestore;

  MockDataService({required this.firestore});

  /// Populates categories and listings if they do not exist.
  Future<void> populateIfEmpty() async {
    try {
      final categoriesSnap = await firestore.collection('categories').limit(1).get();
      if (categoriesSnap.docs.isEmpty) {
        await _populateCategories();
      }

      final listingsSnap = await firestore.collection('listings').limit(1).get();
      if (listingsSnap.docs.isEmpty) {
        await _populateListings();
      }
    } catch (e) {
      // Silently log or handle initialization errors
      debugPrint('MockDataService error during populating: $e');
    }
  }

  Future<void> _populateCategories() async {
    final categories = [
      {
        'id': 'tools',
        'name': 'Tools',
        'iconName': 'construction',
        'listingType': 'rental',
        'sortOrder': 1,
      },
      {
        'id': 'electronics',
        'name': 'Electronics',
        'iconName': 'devices',
        'listingType': 'rental',
        'sortOrder': 2,
      },
      {
        'id': 'vehicles',
        'name': 'Vehicles',
        'iconName': 'directions_car',
        'listingType': 'rental',
        'sortOrder': 3,
      },
      {
        'id': 'camping',
        'name': 'Camping',
        'iconName': 'terrain',
        'listingType': 'rental',
        'sortOrder': 4,
      },
      {
        'id': 'plumbing',
        'name': 'Plumbing',
        'iconName': 'plumbing',
        'listingType': 'service',
        'sortOrder': 5,
      },
      {
        'id': 'electrician',
        'name': 'Electrician',
        'iconName': 'bolt',
        'listingType': 'service',
        'sortOrder': 6,
      },
      {
        'id': 'cleaning',
        'name': 'Cleaning',
        'iconName': 'cleaning_services',
        'listingType': 'service',
        'sortOrder': 7,
      },
    ];

    for (final cat in categories) {
      final docId = cat['id'] as String;
      final data = Map<String, dynamic>.from(cat)..remove('id');
      await firestore.collection('categories').doc(docId).set(data);
    }
  }

  Future<void> _populateListings() async {
    final mockListings = [
      {
        'ownerId': 'owner_rohan',
        'ownerDisplayName': 'Rohan Sharma',
        'ownerPhotoUrl': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        'ownerTrustScore': 4.8,
        'listingType': 'rental',
        'categoryId': 'tools',
        'categoryName': 'Tools',
        'title': 'Premium Hammer Drill',
        'description': 'Heavy duty drill machine perfect for drilling concrete, stone, and brickwork. Comes with multiple speed settings and auxiliary handle.',
        'status': 'available',
        'images': [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBXI1Dl4m3SRX3mTtEhp_QXRi8tlda7QwogVrenC8cwnULjvBE5BQec5IDIapEhT6RVTl8cDBVD-GH76l0sCD5G2Ku0YJOySwBuG-ineO30DrGoWNhHYASdk-04JhCRWE-dU3TbT0IQoBlA7lYkCGhDqfnlcI0-K1jJjriMOGIXn1l6VdAyJbIpuCdK1EdqXJ7tWa6xzhIebPqkOVYaegOGSOTEbW6avNOJfWqU7zDKdM6ro4O2BI5oXrT9ZtFPNi16Nfz7MFtcdXB7',
          'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=500',
        ],
        'thumbnailUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBXI1Dl4m3SRX3mTtEhp_QXRi8tlda7QwogVrenC8cwnULjvBE5BQec5IDIapEhT6RVTl8cDBVD-GH76l0sCD5G2Ku0YJOySwBuG-ineO30DrGoWNhHYASdk-04JhCRWE-dU3TbT0IQoBlA7lYkCGhDqfnlcI0-K1jJjriMOGIXn1l6VdAyJbIpuCdK1EdqXJ7tWa6xzhIebPqkOVYaegOGSOTEbW6avNOJfWqU7zDKdM6ro4O2BI5oXrT9ZtFPNi16Nfz7MFtcdXB7',
        'pricePerDay': 300.0,
        'securityDeposit': 1500.0,
        'pickupRadiusKm': 2.0,
        'lat': 28.6150,
        'lng': 77.2095,
        'tags': ['drill', 'hammer', 'tools', 'diy'],
      },
      {
        'ownerId': 'owner_sneha',
        'ownerDisplayName': 'Sneha Patel',
        'ownerPhotoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        'ownerTrustScore': 4.9,
        'listingType': 'rental',
        'categoryId': 'camping',
        'categoryName': 'Camping',
        'title': '4-Person Camping Tent',
        'description': 'Waterproof and wind-resistant 4-person tent, easy setup. Ideal for hiking, family camping, and backyard get-togethers.',
        'status': 'available',
        'images': [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDld4blIuzFnohv1nPIAM8CaDqEnbb3eXXpCiEeL8UsgDA5z-iTg1ddZsfHpzX38E20Y254Lq-ArhTbdDJFJON10mplv0KICUwROTbku8hX7GafDxI9hoD8u4PpGIHv4lzhiaj01nWQ_CYws3A2ph59UDRVTDuAMRXgiTk5SOAHvD-M67kZYj4jFzP3ZH9FW-d5RDa05rAgRnKaC-GZz42CLJxjHbX3XepMpiGjDnYK3QzXyI93nufTZy8Ntey4FN92_198VVBxCygF',
          'https://images.unsplash.com/photo-1510312305653-8ed496efae75?w=500',
        ],
        'thumbnailUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDld4blIuzFnohv1nPIAM8CaDqEnbb3eXXpCiEeL8UsgDA5z-iTg1ddZsfHpzX38E20Y254Lq-ArhTbdDJFJON10mplv0KICUwROTbku8hX7GafDxI9hoD8u4PpGIHv4lzhiaj01nWQ_CYws3A2ph59UDRVTDuAMRXgiTk5SOAHvD-M67kZYj4jFzP3ZH9FW-d5RDa05rAgRnKaC-GZz42CLJxjHbX3XepMpiGjDnYK3QzXyI93nufTZy8Ntey4FN92_198VVBxCygF',
        'pricePerDay': 150.0,
        'securityDeposit': 1000.0,
        'pickupRadiusKm': 3.0,
        'lat': 28.6210,
        'lng': 77.2150,
        'tags': ['tent', 'camping', 'outdoor', 'adventure'],
      },
      {
        'ownerId': 'owner_rahul',
        'ownerDisplayName': 'Rahul Verma',
        'ownerPhotoUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        'ownerTrustScore': 4.5,
        'listingType': 'rental',
        'categoryId': 'tools',
        'categoryName': 'Tools',
        'title': '12 ft Aluminum Folding Ladder',
        'description': 'Sturdy multi-purpose folding ladder, 12 feet long. Very compact to store, perfect for painting, cleaning roofs, and high maintenance work.',
        'status': 'available',
        'images': [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCfm2q2wdHVTmq4Gt3w0GERSocpZ6w5K4mrkFk4qr5ZikMc8oYQb9-Toj8kqdXUdi_yv93kUG_74kRweXpAbKQ00VBk3rvDdCEf9waQrTh2cWyBxCewnEj2feE2k83RX60LAyJDHxloVqn4sMXFnAuvX-vHT-XxO5tnNsZxwUU8PUUBEjpnZg2KP0X8Nohonsr0daLJveFCAfQaklvnh6GvRAQB0pNobPn_qWx8fmA6WDnv74YsZhONa8uiyYYX-umWoGuEUyPt9rzk',
        ],
        'thumbnailUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCfm2q2wdHVTmq4Gt3w0GERSocpZ6w5K4mrkFk4qr5ZikMc8oYQb9-Toj8kqdXUdi_yv93kUG_74kRweXpAbKQ00VBk3rvDdCEf9waQrTh2cWyBxCewnEj2feE2k83RX60LAyJDHxloVqn4sMXFnAuvX-vHT-XxO5tnNsZxwUU8PUUBEjpnZg2KP0X8Nohonsr0daLJveFCAfQaklvnh6GvRAQB0pNobPn_qWx8fmA6WDnv74YsZhONa8uiyYYX-umWoGuEUyPt9rzk',
        'pricePerDay': 100.0,
        'securityDeposit': 500.0,
        'pickupRadiusKm': 1.5,
        'lat': 28.6090,
        'lng': 77.1980,
        'tags': ['ladder', 'aluminum', 'tools', 'repair'],
      },
      {
        'ownerId': 'owner_aman',
        'ownerDisplayName': 'Aman Gupta',
        'ownerPhotoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        'ownerTrustScore': 5.0,
        'listingType': 'rental',
        'categoryId': 'electronics',
        'categoryName': 'Electronics',
        'title': '500W Portable Power Station',
        'description': 'High capacity portable battery generator with AC outlets, USB ports, and DC outputs. Great for camping, emergency backup, and outdoor shoots.',
        'status': 'available',
        'images': [
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBr-P9uToSzvESHTNRfrWHZt8M2mitO6rruh0cg7LTJLAo4JD3ZVtYY415RJTB-Zd4cvjvhU_B_NhyQAYabZEZSkzzDVUR2HI4va8pd4viaByVYkFvX_AzCBhLZ9pZ6qDOusA7R-e4IDEI8nAjrX1YbakwBMe9nDQp4xAIPhqFaIsN41E8dHCGJ3TL6oCmFnahwBqSnT3hXHl4kKiCVT-QhKsD4qlM3OqRl9zZrWMdkN_dC-ZEhng_nq5c6UHAH5syu_z6CZWgyTkgB',
        ],
        'thumbnailUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBr-P9uToSzvESHTNRfrWHZt8M2mitO6rruh0cg7LTJLAo4JD3ZVtYY415RJTB-Zd4cvjvhU_B_NhyQAYabZEZSkzzDVUR2HI4va8pd4viaByVYkFvX_AzCBhLZ9pZ6qDOusA7R-e4IDEI8nAjrX1YbakwBMe9nDQp4xAIPhqFaIsN41E8dHCGJ3TL6oCmFnahwBqSnT3hXHl4kKiCVT-QhKsD4qlM3OqRl9zZrWMdkN_dC-ZEhng_nq5c6UHAH5syu_z6CZWgyTkgB',
        'pricePerDay': 500.0,
        'securityDeposit': 3000.0,
        'pickupRadiusKm': 2.5,
        'lat': 28.6120,
        'lng': 77.2050,
        'tags': ['power', 'generator', 'battery', 'electronics'],
      },
      {
        'ownerId': 'worker_ramesh',
        'ownerDisplayName': 'Ramesh Singh',
        'ownerPhotoUrl': 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=150',
        'ownerTrustScore': 4.9,
        'listingType': 'service',
        'categoryId': 'electrician',
        'categoryName': 'Electrician',
        'title': 'Certified Electrician Services',
        'description': 'Over 10 years of experience in house wiring, appliance repairs, short circuit fixes, and power supply diagnostics. Quick and clean service.',
        'status': 'available',
        'images': [
          'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=500',
        ],
        'thumbnailUrl': 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=150',
        'startingRate': 400.0,
        'rateUnit': 'hr',
        'pickupRadiusKm': 5.0,
        'lat': 28.6160,
        'lng': 77.2080,
        'tags': ['electrician', 'wiring', 'repair', 'service'],
      },
      {
        'ownerId': 'worker_amit',
        'ownerDisplayName': 'Amit Kumar',
        'ownerPhotoUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        'ownerTrustScore': 4.7,
        'listingType': 'service',
        'categoryId': 'plumbing',
        'categoryName': 'Plumbing',
        'title': 'Plumbing Specialist',
        'description': 'Professional plumber offering leak repairs, drain cleanings, pipe installation, water heater services, and bathroom fittings setup.',
        'status': 'available',
        'images': [
          'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=500',
        ],
        'thumbnailUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        'startingRate': 350.0,
        'rateUnit': 'hr',
        'pickupRadiusKm': 4.0,
        'lat': 28.6250,
        'lng': 77.2200,
        'tags': ['plumbing', 'leak', 'drain', 'service'],
      },
      {
        'ownerId': 'worker_sunita',
        'ownerDisplayName': 'Sunita Sen',
        'ownerPhotoUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        'ownerTrustScore': 5.0,
        'listingType': 'service',
        'categoryId': 'cleaning',
        'categoryName': 'Cleaning',
        'title': 'Professional Housekeeping & Cleaning',
        'description': 'Deep cleaning services for apartments and commercial spaces. Expert in carpet wash, sofa cleaning, window dusting, and kitchen sanitization.',
        'status': 'available',
        'images': [
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500',
        ],
        'thumbnailUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        'startingRate': 250.0,
        'rateUnit': 'hr',
        'pickupRadiusKm': 3.0,
        'lat': 28.6110,
        'lng': 77.2070,
        'tags': ['cleaning', 'housekeeping', 'maid', 'service'],
      },
    ];

    for (final item in mockListings) {
      final lat = item['lat'] as double;
      final lng = item['lng'] as double;
      final gp = GeoPoint(lat, lng);
      final gfp = GeoFirePoint(gp);

      final data = Map<String, dynamic>.from(item)
        ..remove('lat')
        ..remove('lng')
        ..addAll({
          'location': {
            'geopoint': gp,
            'geohash': gfp.geohash,
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

      await firestore.collection('listings').add(data);
    }
  }
}
