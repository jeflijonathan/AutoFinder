import 'dart:io';
import 'dart:convert';
import 'package:autofinder/config/app_routes.dart';
import 'package:autofinder/models/service_callback.dart';
import 'package:autofinder/services/users/models/user_model.dart';
import 'package:autofinder/services/users/users_service.dart';
import 'package:autofinder/views/profile/widgets/image_source_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  final UsersService _usersService = UsersService();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isGoogleLogin = false;

  AuthController({UserModel? initialUser, bool isGoogleLogin = false}) {
    _currentUser = initialUser;
    _isGoogleLogin = isGoogleLogin;
  }

  Future<void> _saveUserToPrefs(UserModel user, bool isGoogle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(user.toMap()));
    await prefs.setBool('is_google_login', isGoogle);
  }

  Future<void> _clearUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    await prefs.remove('is_google_login');
  }


  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isGoogleLogin => _isGoogleLogin;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void handleRegisterRequest({
    required BuildContext context,
    required String email,
    required String username,
    required String phoneNumber,
    required String password,
  }) {
    _setLoading(true);

    _usersService.getUserByEmail(
      email,
      ServiceCallback(
        onSuccessData: (UserModel? user) {
          if (user != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Email already exists")),
            );
          } else {
            final newUser = UserModel(
              uid: "",
              email: email.trim(),
              username: username.trim(),
              phoneNumber: phoneNumber.trim(),
              password: password,
            );

            _usersService.createUser(
              newUser,
              password,
              ServiceCallback(
                onSuccessData: (createdMap) {
                  _currentUser = UserModel.fromMap(
                    createdMap as Map<String, dynamic>,
                  );
                  _saveUserToPrefs(_currentUser!, false);
                  notifyListeners();

                  Navigator.pushReplacementNamed(context, '/home');
                },
                onErrorData: (error) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error)));
                },
                onFullFailed: () {
                  _setLoading(false);
                },
              ),
            );
          }
        },
        onErrorData: (error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        },
        onFullFailed: () {
          _setLoading(false);
        },
      ),
    );
  }

  void handleLoginRequest({
    required BuildContext context,
    required String email,
    required String password,
  }) {
    _setLoading(true);

    _usersService.getUserByEmail(
      email,
      ServiceCallback<UserModel?>(
        onSuccessData: (UserModel? user) {
          if (user == null ||
              user.password != null && user.password != password) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Incorrect password or email")),
            );
            _setLoading(false);
            return;
          }

          _currentUser = user;
          _isGoogleLogin = false;
          _saveUserToPrefs(user, false);
          notifyListeners();
          Navigator.pushReplacementNamed(context, '/home');
        },
        onErrorData: (error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        },
        onFullFailed: () {
          _setLoading(false);
        },
      ),
    );
  }

  void handleLoginWithGoogleRequest({
    required BuildContext context,
    required UserModel googleData,
  }) {
    _setLoading(true);

    _usersService.getUserByEmail(
      googleData.email,
      ServiceCallback(
        onSuccessData: (UserModel? user) {
          if (user != null) {
            _currentUser = user;
            _isGoogleLogin = true;
            _saveUserToPrefs(user, true);
            notifyListeners();
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            _usersService.createUser(
              googleData,
              'google_mock_password',
              ServiceCallback(
                onSuccessData: (createdMap) {
                  _currentUser = UserModel.fromMap(
                    createdMap as Map<String, dynamic>,
                  );
                  _isGoogleLogin = true;
                  _saveUserToPrefs(_currentUser!, true);
                  notifyListeners();
                  Navigator.pushReplacementNamed(context, '/home');
                },
                onErrorData: (error) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error)));
                },
                onFullFailed: () {
                  _setLoading(false);
                },
              ),
            );
          }
        },
        onErrorData: (error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        },
        onFullFailed: () {
          _setLoading(false);
        },
      ),
    );
  }

  void handleLogoutRequest({required BuildContext context}) async {
    _setLoading(true);

    try {
      await _clearUserFromPrefs();
      await GoogleSignIn.instance.signOut();

      _currentUser = null;
      _isGoogleLogin = false;
      _setLoading(false);

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      _setLoading(false);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal Logout: $e")));
      }
    }
  }

  Future<void> handleUpdateProfilePicture(
    BuildContext context,
    ImageSourceType source,
  ) async {
    if (_currentUser == null || _currentUser!.uid == null) return;

    _setLoading(true);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source == ImageSourceType.camera
            ? ImageSource.camera
            : ImageSource.gallery,
      );

      if (image == null) {
        _setLoading(false);
        return;
      }

      File file = File(image.path);

      // Convert to Base64
      final bytes = await file.readAsBytes();
      final String base64Image = base64Encode(bytes);

      final Map<String, dynamic> updateData = {
        'profilePictureUrl': base64Image,
      };

      _usersService.updateUser(
        _currentUser!.uid!,
        updateData,
        ServiceCallback(
          onSuccessData: (bool success) {
            if (success) {
              _currentUser = UserModel(
                uid: _currentUser!.uid,
                email: _currentUser!.email,
                username: _currentUser!.username,
                phoneNumber: _currentUser!.phoneNumber,
                password: _currentUser!.password,
                profilePictureUrl: base64Image,
              );
              _saveUserToPrefs(_currentUser!, _isGoogleLogin);
              notifyListeners();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Successfully profile picture updated"),
                  ),
                );
              }
            }
          },
          onErrorData: (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to update profile: $error")),
              );
            }
          },
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      _setLoading(false);
    }
  }

  void handleUpdateProfile({
    required BuildContext context,
    required String username,
    required String phoneNumber,
  }) {
    if (_currentUser == null || _currentUser!.uid == null) return;

    _setLoading(true);

    final Map<String, dynamic> updateData = {
      'username': username,
      'phoneNumber': phoneNumber,
    };

    _usersService.updateUser(
      _currentUser!.uid!,
      updateData,
      ServiceCallback(
        onSuccessData: (bool success) {
          if (success) {
            _currentUser = UserModel(
              uid: _currentUser!.uid,
              email: _currentUser!.email,
              username: username,
              phoneNumber: phoneNumber,
              password: _currentUser!.password,
              profilePictureUrl: _currentUser!.profilePictureUrl,
            );
            _saveUserToPrefs(_currentUser!, _isGoogleLogin);
            notifyListeners();
            _setLoading(false);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Profile updated successfully"),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacementNamed(context, AppRoutes.profile);
            }
          }
        },
        onErrorData: (error) {
          _setLoading(false);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to update profile: $error")),
            );
          }
        },
        onFullFailed: () {
          _setLoading(false);
        },
      ),
    );
  }

  void handleUpdatePassword({
    required BuildContext context,
    required String currentPassword,
    required String newPassword,
  }) {
    if (_currentUser == null || _currentUser!.uid == null) return;

    if (_currentUser!.password != null &&
        _currentUser!.password != currentPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Current password is incorrect"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _setLoading(true);

    final Map<String, dynamic> updateData = {'password': newPassword};

    _usersService.updateUser(
      _currentUser!.uid!,
      updateData,
      ServiceCallback(
        onSuccessData: (bool success) {
          if (success) {
            _currentUser = UserModel(
              uid: _currentUser!.uid,
              email: _currentUser!.email,
              username: _currentUser!.username,
              phoneNumber: _currentUser!.phoneNumber,
              password: newPassword,
              profilePictureUrl: _currentUser!.profilePictureUrl,
            );
            _saveUserToPrefs(_currentUser!, _isGoogleLogin);
            notifyListeners();
            _setLoading(false);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Password updated successfully"),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushReplacementNamed(context, AppRoutes.profile);
            }
          }
        },
        onErrorData: (error) {
          _setLoading(false);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to update password: $error")),
            );
          }
        },
        onFullFailed: () {
          _setLoading(false);
        },
      ),
    );
  }
}
