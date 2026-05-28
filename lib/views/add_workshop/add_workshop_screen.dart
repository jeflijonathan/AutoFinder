import 'package:autofinder/config/app_routes.dart';
import 'package:autofinder/provider/add_workshop_provider.dart';
import 'package:autofinder/views/auth/controllers/auth_controller.dart';
import 'package:autofinder/views/add_workshop/utils/workshop_step_helper.dart';
import 'package:autofinder/views/add_workshop/widgets/build_step_item.dart';
import 'package:autofinder/widgets/buttom_nav_bar.dart';
import 'package:autofinder/widgets/loading.dart';
import 'package:autofinder/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/widgets/header.dart';

class AddWorkshopScreen extends StatelessWidget {
  const AddWorkshopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddWorkshopProvider(),
      child: const AddWorkshopView(),
    );
  }
}

class AddWorkshopView extends StatelessWidget {
  const AddWorkshopView({super.key});

  Future<void> _handleNextOrSubmit(
    BuildContext context,
    AddWorkshopProvider provider,
  ) async {
    final authController = context.read<AuthController>();
    final isLastStep = provider.currentStep == 4;
    final errorMessage = await provider.processNextOrSubmit(
      authController.currentUser?.uid,
    );

    if (!context.mounted) return;

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
      return;
    }

    if (isLastStep && errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workshop berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddWorkshopProvider>(context);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const Navbar(),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Header(
                    fontSizeTitle: 32,
                    fontSizeSubtitle: 16,
                    title: 'Create a new Post',
                    subtitle:
                        'Share your service experience or workshop recommendations through new posts.',
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) {
                        final isActive = provider.currentStep == index;
                        final isCompleted = provider.currentStep > index;
                        return BuildStepItem(
                          stepNumber: index + 1,
                          title: WorkshopStepHelper.getStepName(index),
                          isCompleted: isActive || isCompleted,
                          isActive: isActive,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 32),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: WorkshopStepHelper.getStepWidget(
                      provider.currentStep,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (provider.currentStep > 0)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: OutlinedButton(
                              onPressed: () => provider.previousStep(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF333333)
                                      : const Color(0xFFE5E7EB),
                                ),
                                backgroundColor: isDark
                                    ? const Color(0xFF2C2C2C)
                                    : const Color(0xFFE5E7EB),
                              ),
                              child: Text(
                                'Back',
                                style: TextStyle(
                                  color: theme
                                      .colorScheme
                                      .onSurface, // Warna teks mengikuti tema aktif
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _handleNextOrSubmit(context, provider);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                (provider.currentStep == 3 &&
                                    provider.getInvalidUptimeDays().isNotEmpty)
                                ? (isDark
                                      ? const Color(0xFF3A4B5C)
                                      : const Color(
                                          0xFFB0C4DE,
                                        )) // Warna disable/invalid adaptif
                                : theme
                                      .colorScheme
                                      .primary, // Warna biru utama aplikasi yang dinamis
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            provider.currentStep == 4
                                ? 'Post Workshop'
                                : 'Next',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (provider.isLoading) const Loading(asOverlay: true),
        ],
      ),
      bottomNavigationBar: const ButtonNavBar(currentIndex: 2),
    );
  }
}
