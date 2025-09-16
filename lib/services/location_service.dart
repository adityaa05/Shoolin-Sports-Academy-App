import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Default gym location (you can change this to your actual gym coordinates)
  static const double _gymLatitude = 19.222666; // Mumbai coordinates as example
  static const double _gymLongitude = 73.089570;
  static const double _allowedDistanceMeters = 500.0; // 500 meters radius

  // Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    final permission = await Permission.location.status;
    return permission.isGranted;
  }

  // Request location permission
  static Future<bool> requestLocationPermission() async {
    final permission = await Permission.location.request();
    return permission.isGranted;
  }

  // Simplified location verification - for now, we'll assume user is at gym
  // In a real implementation, you could use a QR code system or manual verification
  static Future<bool> isAtGym() async {
    try {
      // Check if location permission is granted
      if (!await hasLocationPermission()) {
        return false;
      }

      // For now, we'll return true if permission is granted
      // In a real app, you could implement:
      // 1. QR code scanning at gym entrance
      // 2. Manual instructor verification
      // 3. WiFi network detection
      // 4. Simple GPS check (if you want to add a lightweight GPS package later)
      
      return true;
    } catch (e) {
      print('Error checking gym location: $e');
      return false;
    }
  }

  // Get distance from gym (simplified)
  static Future<double?> getDistanceFromGym() async {
    try {
      // For now, return a default distance
      // In a real implementation, you'd calculate actual distance
      return 0.0; // Assume user is at gym
    } catch (e) {
      print('Error getting distance from gym: $e');
      return null;
    }
  }

  // Get gym address (simplified)
  static Future<String?> getGymAddress() async {
    // Return a default address
    return 'Your Gym Address, City, State';
  }

  // Update gym location (for admin to configure)
  static void updateGymLocation(double latitude, double longitude) {
    // In a real app, you'd save this to Firebase or local storage
    print('Gym location updated to: $latitude, $longitude');
  }

  // Get gym coordinates
  static Map<String, double> getGymCoordinates() {
    return {
      'latitude': _gymLatitude,
      'longitude': _gymLongitude,
    };
  }

  // Get allowed distance
  static double getAllowedDistance() {
    return _allowedDistanceMeters;
  }

  // Check if location services are enabled (simplified)
  static Future<bool> isLocationServiceEnabled() async {
    // For now, return true if permission is granted
    return await hasLocationPermission();
  }
} 