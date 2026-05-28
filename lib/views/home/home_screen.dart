import 'package:autofinder/widgets/buttom_nav_bar.dart';
import 'package:autofinder/widgets/header.dart';
import 'package:autofinder/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/controllers/location_controller.dart';
import 'package:autofinder/config/app_locale.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String contohTeks = "-";

  @override
  void initState() {
    super.initState();
    ambilTerjemahan();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationController>().fetchUserLocation();
    });
  }

  void ambilTerjemahan() async {
    String hasil = await AppLocale.translateLive("test");

    if (!mounted) return;

    setState(() {
      contohTeks = hasil;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: const Navbar(),
      bottomNavigationBar: const ButtonNavBar(currentIndex: 0),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF0F172A),
                        const Color(0xFF1E293B),
                        theme.scaffoldBackgroundColor,
                      ]
                    : [
                        const Color(0xFFEFF3F9),
                        const Color(0xFFF6F8FC),
                        Colors.white,
                      ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(contohTeks),

                      Consumer<LocationController>(
                        builder: (context, locationController, child) {
                          return Header(
                            fontSizeTitle: 32,
                            fontSizeSubtitle: 16,
                            title: "Find the Workshop",
                            subtitle: locationController.isLoading
                                ? "Mendeteksi lokasi..."
                                : "Lokasi: ${locationController.currentCity}",
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
