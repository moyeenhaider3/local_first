import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSelectorPage extends StatefulWidget {
  final GeoPoint initialLocation;

  const LocationSelectorPage({super.key, required this.initialLocation});

  @override
  State<LocationSelectorPage> createState() => _LocationSelectorPageState();
}

class _LocationSelectorPageState extends State<LocationSelectorPage> {
  static const String _googleApiKey = 'AIzaSyBHu2qkLnJViGI1WMfzikCIhoLxwAopPM0';

  late LatLng _selectedLatLng;
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  bool _useMockData = true;

  final List<Map<String, dynamic>> _mockLocations = const [
    {'address': 'Connaught Place, New Delhi', 'lat': 28.6304, 'lng': 77.2177},
    {
      'address': 'Sector 4, Noida, Uttar Pradesh',
      'lat': 28.5833,
      'lng': 77.3167,
    },
    {
      'address': 'DLF CyberCity, Gurugram, Haryana',
      'lat': 28.4963,
      'lng': 77.0818,
    },
    {'address': 'Saket, New Delhi', 'lat': 28.5244, 'lng': 77.2066},
    {'address': 'Dwarka, New Delhi', 'lat': 28.5823, 'lng': 77.0500},
    {'address': 'Rajouri Garden, New Delhi', 'lat': 28.6415, 'lng': 77.1248},
  ];

  List<Map<String, dynamic>> _suggestions = [];
  String _selectedAddress = 'Selected Map Location';

  @override
  void initState() {
    super.initState();
    _selectedLatLng = LatLng(
      widget.initialLocation.latitude,
      widget.initialLocation.longitude,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String text) async {
    if (text.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    final results = await _searchPlaces(text);
    setState(() {
      _suggestions = results;
    });
  }

  Future<List<Map<String, dynamic>>> _searchPlaces(String input) async {
    if (_useMockData) {
      final lowercase = input.toLowerCase();
      return _mockLocations
          .where(
            (loc) =>
                (loc['address'] as String).toLowerCase().contains(lowercase),
          )
          .toList();
    }

    try {
      final client = HttpClient();
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeQueryComponent(input)}'
        '&key=$_googleApiKey'
        '&components=country:in',
      );
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = json.decode(body);
        final predictions = data['predictions'] as List?;
        if (predictions != null && predictions.isNotEmpty) {
          return predictions.map((p) {
            return {
              'address': p['description'] as String,
              'place_id': p['place_id'] as String,
              'is_place_api': true,
            };
          }).toList();
        }
      }
    } catch (_) {
      // Fallback to mock data on error
    }

    // Fallback search in mock locations if API fails or returns empty
    final lowercase = input.toLowerCase();
    return _mockLocations
        .where(
          (loc) => (loc['address'] as String).toLowerCase().contains(lowercase),
        )
        .toList();
  }

  Future<void> _selectSuggestion(Map<String, dynamic> loc) async {
    final isPlaceApi = loc['is_place_api'] as bool? ?? false;

    if (!isPlaceApi) {
      final lat = loc['lat'] as double;
      final lng = loc['lng'] as double;
      final address = loc['address'] as String;

      setState(() {
        _selectedLatLng = LatLng(lat, lng);
        _selectedAddress = address;
        _searchController.text = address;
        _suggestions = [];
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15.0),
      );
      return;
    }

    final placeId = loc['place_id'] as String;
    final address = loc['address'] as String;

    try {
      final client = HttpClient();
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=geometry'
        '&key=$_googleApiKey',
      );
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = json.decode(body);
        final geometry = data['result']?['geometry'];
        final location = geometry?['location'];
        if (location != null) {
          final lat = location['lat'] as double;
          final lng = location['lng'] as double;

          setState(() {
            _selectedLatLng = LatLng(lat, lng);
            _selectedAddress = address;
            _searchController.text = address;
            _suggestions = [];
          });

          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15.0),
          );
          return;
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load place details.')),
        );
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          final pos = await Geolocator.getCurrentPosition();
          setState(() {
            _selectedLatLng = LatLng(pos.latitude, pos.longitude);
            _selectedAddress = 'Current Location';
            _searchController.text = 'Current Location';
          });
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(pos.latitude, pos.longitude),
              15.0,
            ),
          );
        }
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to detect current location.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _selectedLatLng,
              zoom: 14.0,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('selection_pin'),
                position: _selectedLatLng,
                draggable: true,
                onDragEnd: (LatLng latLng) {
                  setState(() {
                    _selectedLatLng = latLng;
                    _selectedAddress = 'Map Pin Location';
                  });
                },
              ),
            },
            onTap: (LatLng latLng) {
              setState(() {
                _selectedLatLng = latLng;
                _selectedAddress = 'Map Pin Location';
              });
            },
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),

          // Search bar floating at the top
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search address or location...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _useMockData
                                  ? Icons.cloud_off
                                  : Icons.cloud_queue,
                              color: _useMockData
                                  ? Colors.orange
                                  : theme.colorScheme.primary,
                            ),
                            tooltip: _useMockData
                                ? 'Using Mock Data'
                                : 'Using Google Places API',
                            onPressed: () {
                              setState(() {
                                _useMockData = !_useMockData;
                              });
                              _onSearchChanged(_searchController.text);
                            },
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            ),
                        ],
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(top: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        separatorBuilder: (context, _) =>
                            const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final loc = _suggestions[idx];
                          return ListTile(
                            leading: const Icon(
                              Icons.location_on,
                              color: Colors.grey,
                            ),
                            title: Text(loc['address'] as String),
                            onTap: () => _selectSuggestion(loc),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Use Current Location FAB
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _useCurrentLocation,
              label: const Text('Use Current Location'),
              icon: const Icon(Icons.my_location),
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
              elevation: 4,
            ),
          ),

          // Confirm Location sticky button at the bottom
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488), // Teal
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'location': GeoPoint(
                      _selectedLatLng.latitude,
                      _selectedLatLng.longitude,
                    ),
                    'address': _selectedAddress,
                  });
                },
                child: const Text(
                  'CONFIRM LOCATION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
