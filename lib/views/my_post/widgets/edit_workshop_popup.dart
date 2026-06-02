import 'package:autofinder/config/app_colors.dart';
import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:autofinder/views/my_post/provider/edit_workshop_provider.dart';
import 'package:autofinder/views/my_post/provider/my_post_provider.dart';
import 'package:autofinder/views/my_post/controller/my_post_controller.dart';
import 'package:autofinder/views/my_post/utils/workshop_step_helper.dart';
import 'package:autofinder/views/add_workshop/widgets/build_step_item.dart';
import 'package:autofinder/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:autofinder/widgets/header.dart';

void showEditWorkshopPopup(
  BuildContext context,
  WorkshopModel workshop,
  MyPostProvider postProvider,
  String userId,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      return ChangeNotifierProvider(
        create: (_) => EditWorkshopProvider()..initData(workshop),
        child: _EditWorkshopBottomSheet(
          postProvider: postProvider,
          userId: userId,
        ),
      );
    },
  );
}

class _EditWorkshopBottomSheet extends StatelessWidget {
  final MyPostProvider postProvider;
  final String userId;

  const _EditWorkshopBottomSheet({
    required this.postProvider,
    required this.userId,
  });

  Future<void> _handleNextOrSubmit(
    BuildContext context,
    EditWorkshopProvider provider,
  ) async {
    final isLastStep = provider.currentStep == 4;
    final myPostController = MyPostController();

    final errorMessage = await provider.processNextOrSubmit(userId, (updatedWorkshop) async {
      await myPostController.updatePost(
        workshopId: updatedWorkshop.uid ?? '',
        updatedWorkshop: updatedWorkshop,
        provider: postProvider,
        userId: userId,
      );
    });

    if (!context.mounted) return;

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
      return;
    }

    if (isLastStep && errorMessage == null) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close the popup
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EditWorkshopProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Header(
                      fontSizeTitle: 24,
                      fontSizeSubtitle: 14,
                      title: 'Edit Workshop',
                      subtitle: 'Update your workshop details and information',
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardBgDark : AppColors.cardBgLight,
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
                            onTap: () => provider.setStep(index),
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
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(
                                    color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
                                  ),
                                  backgroundColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E7EB),
                                ),
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
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
                              backgroundColor: (provider.currentStep == 3 &&
                                      provider.getInvalidUptimeDays().isNotEmpty)
                                  ? (isDark ? const Color(0xFF3A4B5C) : const Color(0xFFB0C4DE))
                                  : theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              provider.currentStep == 4 ? 'Save Changes' : 'Next',
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
              if (provider.isLoading) const Loading(asOverlay: true),
            ],
          ),
        );
      },
    );
  }
}
