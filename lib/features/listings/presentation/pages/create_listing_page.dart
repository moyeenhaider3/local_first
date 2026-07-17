import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:local_first/core/router/route_names.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:local_first/features/listings/domain/entities/category_entity.dart';
import 'package:local_first/features/listings/domain/entities/listing_entity.dart';
import 'package:local_first/features/listings/presentation/cubits/discovery_cubit.dart';
import 'package:local_first/features/listings/presentation/cubits/listing_form_cubit.dart';
import 'package:local_first/features/listings/presentation/cubits/listing_form_state.dart';
import 'package:local_first/features/listings/presentation/pages/location_selector_page.dart';

class CreateListingPage extends StatefulWidget {
  const CreateListingPage({super.key});

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoadingKycStatus = true;
  bool _isVerified = false;

  ListingType _selectedType = ListingType.rental;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _depositController;
  late TextEditingController _rateController;
  late TextEditingController _tagsController;

  String? _selectedCategoryId;
  String? _selectedRateUnit = 'hr';

  final List<XFile> _images = [];
  final List<String> _tags = [];

  GeoPoint _currentLocation = const GeoPoint(28.6139, 77.2090); // Default New Delhi
  String _locationAddress = 'Connaught Place, New Delhi';
  bool _isLoadingLocation = true;
  GoogleMapController? _mapController;

  double _pickupRadiusKm = 5.0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController()..addListener(_updateFormState);
    _descriptionController = TextEditingController()..addListener(_updateFormState);
    _priceController = TextEditingController()..addListener(_updateFormState);
    _depositController = TextEditingController()..addListener(_updateFormState);
    _rateController = TextEditingController()..addListener(_updateFormState);
    _tagsController = TextEditingController()..addListener(_updateFormState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkKycStatus();
    });
    _detectLocation();

    // Load categories if not already loaded
    final discoveryCubit = context.read<DiscoveryCubit>();
    if (discoveryCubit.state is! DiscoveryLoaded && discoveryCubit.state is! DiscoveryEmpty) {
      discoveryCubit.loadDiscovery();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _rateController.dispose();
    _tagsController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _updateFormState() {
    setState(() {});
  }

  Future<void> _checkKycStatus() async {
    final authCubit = context.read<AuthCubit>();
    final state = authCubit.state;
    if (state is AuthSuccess) {
      if (state.userEntity != null) {
        if (state.userEntity!.verificationStatus == 'verified') {
          if (!mounted) return;
          setState(() {
            _isVerified = true;
            _isLoadingKycStatus = false;
          });
          return;
        }
      }

      // Fetch user profile from database to get the absolute latest status
      final result = await authCubit.repository.getUser(state.uid);
      if (!mounted) return;
      result.fold(
        (failure) {
          _redirectUnverified();
        },
        (user) {
          if (!mounted) return;
          if (user != null && user.verificationStatus == 'verified') {
            setState(() {
              _isVerified = true;
              _isLoadingKycStatus = false;
            });
          } else {
            _redirectUnverified();
          }
        },
      );
    } else {
      _redirectUnverified();
    }
  }

  void _redirectUnverified() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Only verified users can create listings. Redirecting to KYC Verification...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (GoRouter.of(context).canPop()) {
      context.pop();
    }
    context.pushNamed(RouteNames.kycUpload);
  }

  Future<void> _detectLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
          final pos = await Geolocator.getCurrentPosition();
          final point = GeoPoint(pos.latitude, pos.longitude);
          if (!mounted) return;
          setState(() {
            _currentLocation = point;
            _isLoadingLocation = false;
            _locationAddress = 'Auto-detected Location';
          });
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
          );
        }
      }
    } catch (_) {
      // Keep default
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _openLocationSelector() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSelectorPage(initialLocation: _currentLocation),
      ),
    );
    if (result != null) {
      final point = result['location'] as GeoPoint;
      final address = result['address'] as String;
      setState(() {
        _currentLocation = point;
        _locationAddress = address;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(point.latitude, point.longitude)),
      );
    }
  }

  Future<void> _pickImage(int index) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          if (index < _images.length) {
            _images[index] = picked;
          } else {
            _images.add(picked);
          }
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _onTagsChanged(String text) {
    if (text.endsWith(',')) {
      final parts = text.split(',');
      for (var part in parts) {
        final trimmed = part.trim();
        if (trimmed.isNotEmpty && !_tags.contains(trimmed) && _tags.length < 5) {
          setState(() {
            _tags.add(trimmed);
          });
        }
      }
      _tagsController.clear();
    }
  }

  void _onTabChanged(ListingType newType) async {
    if (_selectedType == newType) return;

    final hasData = _titleController.text.trim().isNotEmpty ||
        _descriptionController.text.trim().isNotEmpty ||
        _priceController.text.trim().isNotEmpty ||
        _depositController.text.trim().isNotEmpty ||
        _rateController.text.trim().isNotEmpty ||
        _images.isNotEmpty ||
        _tags.isNotEmpty;

    if (hasData) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('Switching directory will clear your current form progress. Do you want to proceed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('PROCEED'),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    setState(() {
      _selectedType = newType;
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _depositController.clear();
      _rateController.clear();
      _tagsController.clear();
      _selectedCategoryId = null;
      _images.clear();
      _tags.clear();
    });
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

  void _showCategorySelector(List<CategoryEntity> categories) async {
    final spacing = context.spacing;
    final theme = Theme.of(context);

    final selected = await showModalBottomSheet<CategoryEntity>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(spacing.edgeMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Select Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  separatorBuilder: (context, _) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final cat = categories[idx];
                    final isSelected = cat.id == _selectedCategoryId;
                    return ListTile(
                      leading: Icon(
                        _getCategoryIcon(cat.iconName),
                        color: isSelected ? theme.colorScheme.primary : Colors.grey,
                      ),
                      title: Text(
                        cat.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                          : null,
                      onTap: () => Navigator.pop(context, cat),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedCategoryId = selected.id;
      });
    }
  }

  bool _isFormValid() {
    if (_titleController.text.trim().length < 3) return false;
    if (_descriptionController.text.trim().length < 15) return false;
    if (_selectedCategoryId == null) return false;
    if (_images.isEmpty) return false;
    if (_selectedType == ListingType.rental) {
      final price = double.tryParse(_priceController.text);
      if (price == null || price <= 0) return false;
    } else {
      final rate = double.tryParse(_rateController.text);
      if (rate == null || rate <= 0) return false;
      if (_selectedRateUnit == null) return false;
    }
    return true;
  }

  void _onSubmit() {
    if (!_isFormValid()) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess || authState.userEntity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to create a listing.')),
      );
      return;
    }

    final user = authState.userEntity!;

    final finalTags = List<String>.from(_tags);
    if (_tagsController.text.trim().isNotEmpty) {
      final parts = _tagsController.text.split(',');
      for (var part in parts) {
        final trimmed = part.trim();
        if (trimmed.isNotEmpty && !finalTags.contains(trimmed) && finalTags.length < 5) {
          finalTags.add(trimmed);
        }
      }
    }

    final centerPoint = GeoFirePoint(_currentLocation);

    final discoveryCubit = context.read<DiscoveryCubit>();
    String categoryName = 'General';
    if (discoveryCubit.state is DiscoveryLoaded) {
      final cats = (discoveryCubit.state as DiscoveryLoaded).categories;
      final match = cats.firstWhere((c) => c.id == _selectedCategoryId, orElse: () => cats.first);
      categoryName = match.name;
    } else if (discoveryCubit.state is DiscoveryEmpty) {
      final cats = (discoveryCubit.state as DiscoveryEmpty).categories;
      final match = cats.firstWhere((c) => c.id == _selectedCategoryId, orElse: () => cats.first);
      categoryName = match.name;
    }

    context.read<ListingFormCubit>().submitListing(
          ownerId: user.userId,
          ownerDisplayName: user.displayName ?? 'Anonymous',
          ownerPhotoUrl: user.photoUrl,
          listingType: _selectedType,
          categoryId: _selectedCategoryId!,
          categoryName: categoryName,
          title: _titleController.text,
          description: _descriptionController.text,
          imageFiles: _images,
          pricePerDay: _selectedType == ListingType.rental ? double.tryParse(_priceController.text) : null,
          securityDeposit: _selectedType == ListingType.rental ? double.tryParse(_depositController.text) : null,
          startingRate: _selectedType == ListingType.service ? double.tryParse(_rateController.text) : null,
          rateUnit: _selectedType == ListingType.service ? _selectedRateUnit : null,
          pickupRadiusKm: _pickupRadiusKm,
          location: _currentLocation,
          geohash: centerPoint.geohash,
          tags: finalTags,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    if (_isLoadingKycStatus) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isVerified) {
      return const Scaffold(
        body: Center(child: Text('Redirecting to KYC...')),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Create Local First Listing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<DiscoveryCubit, DiscoveryState>(
        listener: (context, state) {},
        builder: (context, discState) {
          List<CategoryEntity> categories = [];
          if (discState is DiscoveryLoaded) {
            categories = discState.categories;
          } else if (discState is DiscoveryEmpty) {
            categories = discState.categories;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(spacing.edgeMargin),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tab switcher matching Marketplace slate design
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onTabChanged(ListingType.rental),
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
                            onTap: () => _onTabChanged(ListingType.service),
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

                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g., Mountain Bike / Wedding Photographer',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  SizedBox(height: spacing.space16),

                  // Description Field
                  SizedBox(
                    height: 120,
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Provide detailed item specs, conditions or service scope...',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  SizedBox(height: spacing.space16),

                  // Custom Dropdown / Bottom Sheet Category Selector
                  GestureDetector(
                    onTap: () => _showCategorySelector(categories),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        suffixIcon: Icon(Icons.keyboard_arrow_down),
                      ),
                      child: Text(
                        _selectedCategoryId == null
                            ? 'Select Category'
                            : (categories.firstWhere((c) => c.id == _selectedCategoryId, orElse: () => const CategoryEntity(id: '', name: '', iconName: '', listingType: CategoryListingType.both, sortOrder: 0)).name),
                        style: TextStyle(
                          color: _selectedCategoryId == null ? Colors.grey.shade600 : theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.space16),

                  // Dynamic Price/Rate fields
                  if (_selectedType == ListingType.rental) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Price per day (₹)',
                            ),
                          ),
                        ),
                        SizedBox(width: spacing.space16),
                        Expanded(
                          child: TextFormField(
                            controller: _depositController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Security deposit (₹)',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _rateController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Starting rate (₹)',
                            ),
                          ),
                        ),
                        SizedBox(width: spacing.space16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedRateUnit,
                            decoration: const InputDecoration(
                              labelText: 'Rate unit',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'hr', child: Text('per hour')),
                              DropdownMenuItem(value: 'day', child: Text('per day')),
                              DropdownMenuItem(value: 'job', child: Text('per job')),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedRateUnit = val;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: spacing.space16),

                  // Slider for radius
                  Text(
                    'Pickup / Service Radius: ${_pickupRadiusKm.toStringAsFixed(0)} km',
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _pickupRadiusKm,
                    min: 1.0,
                    max: 15.0,
                    divisions: 14,
                    label: '${_pickupRadiusKm.toStringAsFixed(0)} km',
                    onChanged: (val) {
                      setState(() {
                        _pickupRadiusKm = val;
                      });
                    },
                  ),
                  SizedBox(height: spacing.space16),

                  // Google Map location selector (Tapping map launches LocationSelectorPage)
                  Text(
                    'Item / Service Location (Tap map to select address)',
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _openLocationSelector,
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _isLoadingLocation
                            ? const Center(child: CircularProgressIndicator())
                            : Stack(
                                children: [
                                  GoogleMap(
                                    onMapCreated: (controller) => _mapController = controller,
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(_currentLocation.latitude, _currentLocation.longitude),
                                      zoom: 14.0,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId: const MarkerId('selected_pin'),
                                        position: LatLng(_currentLocation.latitude, _currentLocation.longitude),
                                        draggable: false,
                                      ),
                                    },
                                    zoomControlsEnabled: false,
                                    myLocationEnabled: false,
                                    myLocationButtonEnabled: false,
                                    scrollGesturesEnabled: false,
                                    zoomGesturesEnabled: false,
                                    tiltGesturesEnabled: false,
                                    rotateGesturesEnabled: false,
                                    onTap: (_) => _openLocationSelector(),
                                  ),
                                  // Intercept all map events
                                  Positioned.fill(
                                    child: Container(color: Colors.transparent),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Selected Address: $_locationAddress',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: spacing.space16),

                  // Tags chip field
                  TextFormField(
                    controller: _tagsController,
                    onChanged: _onTagsChanged,
                    decoration: const InputDecoration(
                      labelText: 'Tags',
                      hintText: 'Enter tag and add comma (e.g. tools, cycle, camera)',
                    ),
                  ),
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _tags.map((tag) {
                        return InputChip(
                          label: Text(tag),
                          onDeleted: () {
                            setState(() {
                              _tags.remove(tag);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  SizedBox(height: spacing.space24),

                  // Images section
                  _buildImagesSection(),
                  SizedBox(height: spacing.space32),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.edgeMargin, vertical: spacing.space8),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: BlocConsumer<ListingFormCubit, ListingFormState>(
              listener: (context, state) {
                if (state is ListingFormSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Listing published successfully!')),
                  );
                  context.read<DiscoveryCubit>().loadDiscovery(forceRefresh: true);
                  context.goNamed(RouteNames.home);
                } else if (state is ListingFormError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is ListingFormUploading || state is ListingFormSubmitting;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    disabledBackgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: (_isFormValid() && !isLoading) ? _onSubmit : null,
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'PUBLISH LISTING',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    final spacing = context.spacing;
    final theme = Theme.of(context);
    final showAddSlot = _images.length < 5;
    final totalCount = _images.length + (showAddSlot ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images (Max 5, at least 1 required)',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: totalCount,
            separatorBuilder: (context, _) => SizedBox(width: spacing.space8),
            itemBuilder: (context, index) {
              if (showAddSlot && index == 0) {
                return GestureDetector(
                  onTap: () => _pickImage(_images.length),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, color: theme.colorScheme.primary),
                        const SizedBox(height: 4),
                        Text(
                          'Add Image',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final imageIdx = showAddSlot ? index - 1 : index;
              final file = _images[imageIdx];

              return Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(file.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(imageIdx),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
