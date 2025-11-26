import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  Future<void> openNearbyGroceryStores(BuildContext context) async {
    try {
      // 1. Включены ли сервисы геолокации
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack(context, 'Location services are disabled.');
        return;
      }

      // 2. Проверяем и запрашиваем разрешения
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack(context, 'Location permission denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnack(
          context,
          'Location permission permanently denied. Enable it in system settings.',
        );
        return;
      }

      // 3. Получаем текущую позицию
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final lat = position.latitude;
      final lng = position.longitude;

      // 4. Формируем ссылку на Google Maps
      final uri = Uri.parse(
        'https://www.google.com/maps/search/grocery+store/@$lat,$lng,15z',
      );

      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!ok) {
        _showSnack(context, 'Could not open Maps.');
      }
    } catch (e) {
      _showSnack(context, 'Error getting location: $e');
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
