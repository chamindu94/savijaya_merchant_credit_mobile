import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

final _location = Location();
final _firestore = FirebaseFirestore.instance;

void startTrackingLocation(String employeeId) async {
  // Ask for permissions
  bool serviceEnabled = await _location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await _location.requestService();
  }

  PermissionStatus permissionGranted = await _location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await _location.requestPermission();
  }

  // Listen to location updates
  _location.onLocationChanged.listen((locationData) {
    _firestore.collection('employees_locations').doc(employeeId).set({
      'lat': locationData.latitude,
      'lng': locationData.longitude,
      'updated_at': FieldValue.serverTimestamp(),
    });
  });
}
