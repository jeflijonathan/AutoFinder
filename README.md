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
│   │   ├── welcome_screen.dart   <-- Halaman di gambar Anda
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

## Login screen

1. background: images/background-1.png

## Register Screen

1. background: images/background-1.png
