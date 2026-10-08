import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final bool success;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? errorMessage;

  LocationResult({
    required this.success,
    required this.address,
    this.latitude,
    this.longitude,
    this.errorMessage,
  });
}

class LocationService {
  /// Request location permissions and fetch the user's real GPS address
  Future<LocationResult> getCurrentDeviceAddress() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          success: false,
          address: 'Location services disabled',
          errorMessage: 'Location services are disabled on this device. Please turn on GPS.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            success: false,
            address: 'Permission Denied',
            errorMessage: 'Location permissions were denied by user.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          success: false,
          address: 'Permission Permanently Denied',
          errorMessage: 'Location permissions are permanently denied. Please enable them in app settings.',
        );
      }

      // Fetch Position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      // Reverse geocode to human-friendly street address
      try {
        final List<Placemark> placemarks =
            await Geocoding().placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final List<String> addressParts = [];

          if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
            addressParts.add(place.subThoroughfare!);
          }
          if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
            addressParts.add(place.thoroughfare!);
          } else if (place.name != null && place.name!.isNotEmpty) {
            addressParts.add(place.name!);
          }

          if (place.subLocality != null && place.subLocality!.isNotEmpty) {
            addressParts.add(place.subLocality!);
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            addressParts.add(place.locality!);
          }
          if (place.postalCode != null && place.postalCode!.isNotEmpty) {
            addressParts.add(place.postalCode!);
          }

          final formattedAddress = addressParts.isNotEmpty
              ? addressParts.join(', ')
              : 'GPS: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';

          return LocationResult(
            success: true,
            address: formattedAddress,
            latitude: position.latitude,
            longitude: position.longitude,
          );
        }
      } catch (geocodeError) {
        if (kDebugMode) {
          print('Reverse geocoding error: $geocodeError');
        }
      }

      // Fallback if reverse geocoding fails but coordinates are found
      return LocationResult(
        success: true,
        address: 'Current Location (${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)})',
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Location fetch error: $e');
      }
      return LocationResult(
        success: false,
        address: 'Unable to retrieve location',
        errorMessage: e.toString(),
      );
    }
  }
}
