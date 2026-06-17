import 'package:flutter/material.dart';
import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:autofinder/services/workshop/operation_time_model.dart';

class EditWorkshopProvider extends ChangeNotifier {
  bool _disposed = false;

  String _workshopId = '';

  EditWorkshopProvider();

  void initData(WorkshopModel workshop) {
    _workshopId = workshop.uid ?? '';

    // Initialize Identity
    nameController.text = workshop.title;
    missionController.text = workshop.description;
    
    if (workshop.priceEstimate != null && workshop.priceEstimate!.isNotEmpty) {
      final parts = workshop.priceEstimate!.replaceAll('Rp', '').split('-');
      if (parts.length == 2) {
        priceStartController.text = parts[0].trim();
        priceEndController.text = parts[1].trim();
      }
    }
    
    // Parse Phone Number
    String fullPhone = workshop.phoneNumber;
    if (fullPhone.startsWith('+62')) {
      _selectedCountryCode = '+62';
      phoneController.text = fullPhone.replaceFirst('+62', '').trim();
    } else {
      _selectedCountryCode = '+62';
      phoneController.text = fullPhone;
    }

    _selectedSpecialization = workshop.specialization.isNotEmpty ? workshop.specialization : 'car';

    // Initialize Services
    _selectedServices.clear();
    _selectedServices.addAll(workshop.services);

    // Initialize Location
    _address = workshop.address;
    _latitude = workshop.latitude;
    _longitude = workshop.longitude;

    // Initialize Images
    _images.clear();
    _images.addAll(workshop.image);

    // Initialize Operation Times
    for (var day in _isOpen.keys) {
      _isOpen[day] = false;
    }
    if (workshop.operationTimes != null) {
      for (var opTime in workshop.operationTimes!) {
        _isOpen[opTime.day] = true;
        int index = _operationTimes.indexWhere((e) => e.day == opTime.day);
        if (index != -1) {
          _operationTimes[index] = OperationTimeModel(
            day: opTime.day,
            openTime: opTime.openTime,
            closeTime: opTime.closeTime,
          );
        }
      }
    }
    
    notifyListeners();
  }

  int _currentStep = 0;
  int get currentStep => _currentStep;

  final GlobalKey<FormState> identityFormKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController missionController = TextEditingController();
  final TextEditingController priceStartController = TextEditingController();
  final TextEditingController priceEndController = TextEditingController();
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
    OperationTimeModel(day: 'Monday', openTime: '08:00 AM', closeTime: '05:00 PM'),
    OperationTimeModel(day: 'Tuesday', openTime: '08:00 AM', closeTime: '05:00 PM'),
    OperationTimeModel(day: 'Wednesday', openTime: '08:00 AM', closeTime: '05:00 PM'),
    OperationTimeModel(day: 'Thursday', openTime: '08:00 AM', closeTime: '05:00 PM'),
    OperationTimeModel(day: 'Friday', openTime: '08:00 AM', closeTime: '05:00 PM'),
    OperationTimeModel(day: 'Saturday', openTime: '08:00 AM', closeTime: '05:00 PM'),
    OperationTimeModel(day: 'Sunday', openTime: '08:00 AM', closeTime: '05:00 PM'),
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
    return _operationTimes.where((element) => _isOpen[element.day] == true).toList();
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

      final startText = priceStartController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final endText = priceEndController.text.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (startText.isNotEmpty && endText.isNotEmpty) {
        final start = int.tryParse(startText) ?? 0;
        final end = int.tryParse(endText) ?? 0;
        if (start >= end) {
          return 'Harga awal harus lebih kecil dari harga akhir';
        }
      } else if (startText.isNotEmpty || endText.isNotEmpty) {
        return 'Harap isi kedua estimasi harga atau kosongkan keduanya';
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

  Future<void> submitEditWorkshop(String? idUser, Function(WorkshopModel) onUpdateCallback) async {
    try {
      final updatedWorkshop = WorkshopModel(
        uid: _workshopId.isNotEmpty ? _workshopId : null,
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
        priceEstimate: (priceStartController.text.isNotEmpty && priceEndController.text.isNotEmpty)
            ? 'Rp ${priceStartController.text} - Rp ${priceEndController.text}'
            : null,
      );

      // Kita bisa langsung memanggil callback yang akan menggunakan MyPostController
      // Atau memanggil WorkshopService di sini. Kita pakai callback.
      await onUpdateCallback(updatedWorkshop);
    } catch (e) {
      throw e;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    phoneController.dispose();
    nameController.dispose();
    missionController.dispose();
    priceStartController.dispose();
    priceEndController.dispose();
    super.dispose();
  }

  Future<String?> processNextOrSubmit(String? idUser, Function(WorkshopModel) onUpdateCallback) async {
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
      await submitEditWorkshop(idUser, onUpdateCallback);
      _isLoading = false;
      if (!_disposed) notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      if (!_disposed) notifyListeners();
      return 'Gagal mengubah data: $e';
    }
  }
}
