import 'package:flutter/material.dart';
import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:autofinder/services/workshop/operation_time_model.dart';
import 'package:autofinder/services/workshop/workshop_service.dart';
import 'package:autofinder/services/location/location_service.dart';
import 'package:geolocator/geolocator.dart';

import 'package:geocoding/geocoding.dart';

class AddWorkshopProvider extends ChangeNotifier {
  final WorkshopService _workshopService = WorkshopService();
  bool _disposed = false;

  AddWorkshopProvider() {
    _initLocation();
  }

  Future<void> _initLocation() async {
    Position? position = await LocationService.getCurrentPosition();
    if (_disposed) return;
    if (position != null) {
      _latitude = position.latitude;
      _longitude = position.longitude;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (_disposed) return;
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          List<String> parts = [];
          if (place.street != null && place.street!.isNotEmpty)
            parts.add(place.street!);
          if (place.subLocality != null && place.subLocality!.isNotEmpty)
            parts.add(place.subLocality!);
          if (place.locality != null && place.locality!.isNotEmpty)
            parts.add(place.locality!);
          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty)
            parts.add(place.administrativeArea!);

          _address = parts.join(', ');
        }
      } catch (e) {
        print("Error getting address: $e");
      }

      if (!_disposed) notifyListeners();
    }
  }

  int _currentStep = 0;
  int get currentStep => _currentStep;

  final GlobalKey<FormState> identityFormKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController missionController = TextEditingController();
  String _selectedSpecialization = 'car';
  String get selectedSpecialization => _selectedSpecialization;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String _selectedCountryCode = '+62';
  String get selectedCountryCode => _selectedCountryCode;

  void setCountryCode(String code) {
    _selectedCountryCode = code;
    notifyListeners();
  }

  void setSpecialization(String val) {
    _selectedSpecialization = val;
    notifyListeners();
  }

  final List<String> _selectedServices = [];
  List<String> get selectedServices => _selectedServices;

  void toggleService(String service) {
    if (_selectedServices.contains(service)) {
      _selectedServices.remove(service);
    } else {
      _selectedServices.add(service);
    }
    notifyListeners();
  }

  String _address = '';
  String get address => _address;
  double _latitude = -6.200000;
  double _longitude = 106.816666;
  double get latitude => _latitude;
  double get longitude => _longitude;

  void setAddress(String val) {
    _address = val;
    notifyListeners();
  }

  void setLocation(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  final List<OperationTimeModel> _operationTimes = [
    OperationTimeModel(
      day: 'Monday',
      openTime: '08:00 AM',
      closeTime: '05:00 PM',
    ),
    OperationTimeModel(
      day: 'Tuesday',
      openTime: '08:00 AM',
      closeTime: '05:00 PM',
    ),
    OperationTimeModel(
      day: 'Wednesday',
      openTime: '08:00 AM',
      closeTime: '05:00 PM',
    ),
    OperationTimeModel(
      day: 'Thursday',
      openTime: '08:00 AM',
      closeTime: '05:00 PM',
    ),
    OperationTimeModel(
      day: 'Friday',
      openTime: '08:00 AM',
      closeTime: '05:00 PM',
    ),
  ];

  final Map<String, bool> _isOpen = {
    'Monday': true,
    'Tuesday': true,
    'Wednesday': true,
    'Thursday': true,
    'Friday': true,
    'Saturday': false,
    'Sunday': false,
  };
  Map<String, bool> get isOpen => _isOpen;

  void toggleDayOpen(String day, bool value) {
    _isOpen[day] = value;
    notifyListeners();
  }

  List<String> getInvalidUptimeDays() {
    final invalid = <String>[];
    for (final model in _operationTimes) {
      if (_isOpen[model.day] != true) continue;
      final open = _parseTime(model.openTime);
      final close = _parseTime(model.closeTime);
      if (open != null && close != null && open >= close) {
        invalid.add(model.day);
      }
    }
    return invalid;
  }

  double? _parseTime(String time) {
    try {
      final parts = time.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);
      if (parts[1].toUpperCase() == 'PM' && hour != 12) hour += 12;
      if (parts[1].toUpperCase() == 'AM' && hour == 12) hour = 0;
      return hour + minute / 60.0;
    } catch (_) {
      return null;
    }
  }

  void updateOperationTime(String day, bool isOpening, String time) {
    int index = _operationTimes.indexWhere((e) => e.day == day);
    if (index != -1) {
      final oldModel = _operationTimes[index];
      _operationTimes[index] = OperationTimeModel(
        day: oldModel.day,
        openTime: isOpening ? time : oldModel.openTime,
        closeTime: isOpening ? oldModel.closeTime : time,
      );
      notifyListeners();
    }
  }

  List<OperationTimeModel> get activeOperationTimes {
    return _operationTimes
        .where((element) => _isOpen[element.day] == true)
        .toList();
  }

  final List<String> _images = [];
  List<String> get images => _images;

  void addImage(String path) {
    if (_images.length < 4) {
      _images.add(path);
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _images.length) {
      _images.removeAt(index);
      notifyListeners();
    }
  }

  String? validateCurrentStep() {
    if (_currentStep == 0) {
      final isValid = identityFormKey.currentState?.validate() ?? false;
      if (!isValid) {
        return 'Please complete all required fields correctly';
      }
    }
    if (_currentStep == 1) {
      if (_selectedServices.isEmpty) {
        return 'Pilih minimal 1 layanan service';
      }
    }
    if (_currentStep == 3) {
      final invalidDays = getInvalidUptimeDays();
      if (invalidDays.isNotEmpty) {
        return 'Perbaiki jam operasional: ${invalidDays.join(', ')}';
      }
    }
    if (_currentStep == 4) {
      if (_images.isEmpty) {
        return 'Unggah minimal 1 gambar workshop';
      }
    }
    return null;
  }

  // Navigation
  void nextStep() {
    if (_currentStep < 4) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  String getCompletePhoneNumber() {
    String rawPhone = phoneController.text.trim();

    if (rawPhone.startsWith('0')) {
      rawPhone = rawPhone.substring(1);
    }

    return '$_selectedCountryCode $rawPhone';
  }

  Future<void> submitWorkshop(String? idUser) async {
    try {
      final workshop = WorkshopModel(
        uid: null,
        idUser: idUser,
        title: nameController.text,
        phoneNumber: getCompletePhoneNumber(),
        description: missionController.text,
        specialization: _selectedSpecialization,
        services: _selectedServices,
        address: _address,
        latitude: _latitude,
        longitude: _longitude,
        operationTimes: activeOperationTimes,
        image: _images,
      );

      await _workshopService.addWorkshop(workshop);
      // Handle success
      print('Workshop submitted successfully');
    } catch (e) {
      print('Error submitting workshop: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    phoneController.dispose();
    nameController.dispose();
    missionController.dispose();
    super.dispose();
  }

  Future<String?> processNextOrSubmit(String? idUser) async {
    if (_currentStep == 3 && getInvalidUptimeDays().isNotEmpty) {
      return 'Harap perbaiki data uptime yang tidak valid';
    }

    final errorMsg = validateCurrentStep();
    if (errorMsg != null) {
      return errorMsg;
    }

    if (_currentStep < 4) {
      nextStep();
      return null;
    }

    _isLoading = true;
    if (!_disposed) notifyListeners();

    try {
      await submitWorkshop(idUser);
      _isLoading = false;
      if (!_disposed) notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      if (!_disposed) notifyListeners();
      return 'Gagal mengirim data: $e';
    }
  }
}
