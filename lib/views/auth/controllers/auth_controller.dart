import 'package:autofinder/models/service_callback.dart';
import 'package:autofinder/services/users/models/user_model.dart';
import 'package:autofinder/services/users/users_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends ChangeNotifier {
  final UsersService _usersService = UsersService();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

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
            );

            _usersService.createUser(
              newUser,
              password,
              ServiceCallback(
                onSuccessData: (createdMap) {
                  // 2. Simpan ke State Management Lokal
                  _currentUser = UserModel.fromMap(
                    createdMap as Map<String, dynamic>,
                  );
                  notifyListeners();

                  // 3. Langsung pindah halaman dari sini karena data sudah aman di state
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                onErrorData: (error) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error)));
                },
                onFullFailed: () {
                  _setLoading(false); // Matikan loading proses create
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
      ServiceCallback(
        onSuccessData: (UserModel? user) {
          if (user == null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Email not found")));
          } else {
            if (user.email.isNotEmpty) {
              // 2. Simpan ke State Management Lokal
              _currentUser = user;
              notifyListeners();

              // 3. Langsung pindah halaman
              Navigator.pushReplacementNamed(context, '/dashboard');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Incorrect password")),
              );
            }
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
            notifyListeners();
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            _usersService.createUser(
              googleData,
              'google_mock_password',
              ServiceCallback(
                onSuccessData: (createdMap) {
                  _currentUser = UserModel.fromMap(
                    createdMap as Map<String, dynamic>,
                  );
                  notifyListeners();
                  Navigator.pushReplacementNamed(context, '/dashboard');
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
      await GoogleSignIn.instance.signOut();

      _currentUser = null;
      _setLoading(false);

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
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
}
