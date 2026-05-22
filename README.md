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
├── controllers/         # Logika bisnis / State Management (Bloc, Provider, GetX, dll)
│   └── auth_controller.dart
│
├── models/              # Model data untuk konversi JSON (jika ada API)
│   └── user_model.dart
│
├── services/            # Fungsi untuk API, database, atau share preferences
│   └── api_service.dart
│
├── views/               # Semua tampilan UI (Halaman & Widget)
│   ├── auth/            # Khusus halaman terkait login/daftar
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

# assets fitur

## Gateway Screen

1. background: images/background-1.png
2. icon google : images/google-icon.png
3. content : images/automotif-images.png

## Login screen

1. background: images/background-1.png

## Register Screen

1. background: images/background-1.png
