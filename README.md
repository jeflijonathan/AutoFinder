# sha1

```bash
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android
```

# struktur folder lib

```text
lib/
├── config/              # Konfigurasi aplikasi (Tema, rute/routing, warna)
│   ├── app_colors.dart
│   └── app_routes.dart
│
├── models/              # Model data untuk konversi JSON (jika ada API)
│   └── api_response.dart
│   └── service_callback.dart
│
├── services/            # Fungsi untuk API, database, atau share preferences
│   |── users/
|   |    |── models/
|   |    |   └── login_model.dart
|   |    |   └── user_model.dart
|   |    └── user_service.dart
│   └── api_service.dart
│
├── views/               # Semua tampilan UI (Halaman & Widget)
│   ├── auth/            # Khusus halaman terkait login/daftar
|   |   ├── controllers
|   |   |   └── auth_controller.dart
|   |   ├── utils
|   |   |   └── login_form.dart
|   |   |   └── register_form.dart
│   │   ├── welcome_screen.dart
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   │
│   ├── home/            # Halaman utama setelah masuk
│   │   └── home_screen.dart
│   │
│   └── widgets/         # Komponen UI yang dipakai berulang-ulang (Global)
│       ├── custom_button.dart
│       └── custom_textfield.dart
│
└── main.dart            # Titik awal aplikasi
```

## depedency

1. cloud_firestore: ^6.4.1
2. firebase_core: ^4.9.0
3. form_validator: ^2.1.1
4. google_sign_in: ^7.2.0
5. http: ^1.6.0
6. provider: ^6.1.5+1

## Links

1. [Login Screen](docs/markdown/login_screen.md)
2. [Register Screen](docs/markdown/register_screen.md)
3. [Welcome Screen](docs/markdown/welcome_screen.md)
