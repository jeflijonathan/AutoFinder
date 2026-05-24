import 'package:flutter/material.dart';

class ServiceCategoryProvider extends ChangeNotifier {
  static const List<Map<String, dynamic>> _allServices = [
    {'name': 'Lube & Oil', 'icon': Icons.oil_barrel_outlined},
    {'name': 'Suspension', 'icon': Icons.car_repair_outlined},
    {'name': 'Electrical', 'icon': Icons.electric_bolt_outlined},
    {'name': 'Brake Service', 'icon': Icons.album_outlined},
    {'name': 'Tire Service', 'icon': Icons.tire_repair_outlined},
    {'name': 'AC & Cooling', 'icon': Icons.ac_unit_outlined},
    {'name': 'Engine Repair', 'icon': Icons.settings_outlined},
    {'name': 'Transmission', 'icon': Icons.swap_horiz_outlined},
    {'name': 'Body Repair', 'icon': Icons.car_crash_outlined},
    {'name': 'Paint & Polish', 'icon': Icons.format_paint_outlined},
    {'name': 'Wheel Alignment', 'icon': Icons.rotate_right_outlined},
    {'name': 'Exhaust System', 'icon': Icons.air_outlined},
    {'name': 'Battery', 'icon': Icons.battery_charging_full_outlined},
    {'name': 'Detailing', 'icon': Icons.cleaning_services_outlined},
    {'name': 'Inspection', 'icon': Icons.search_outlined},
    {'name': 'Radiator', 'icon': Icons.thermostat_outlined},
    {'name': 'Steering', 'icon': Icons.radio_button_checked_outlined},
    {'name': 'Clutch', 'icon': Icons.circle_outlined},
  ];

  List<Map<String, dynamic>> get allServices => _allServices;
}
