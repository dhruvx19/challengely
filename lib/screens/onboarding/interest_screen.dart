import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../controllers/onboarding_controller.dart';
import '../../utils/constants.dart';
import 'onboarding_wrapper.dart';
import 'package:challengely/widgets/animated_components/button.dart';

class InterestsScreen extends OnboardingScreen {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends OnboardingScreenState<InterestsScreen> {
  @override
  Widget buildContent(BuildContext context) {
    return Consumer<OnboardingController>(
      builder: (context, controller, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
          ),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.paddingLarge),

              // Header section
              _buildHeaderSection(context, controller),

              const SizedBox(height: AppDimensions.paddingXL),

              // Interests grid
              Expanded(
                child: _buildInterestsGrid(context, controller),
              ),

              const SizedBox(height: AppDimensions.padding),

              // Continue button
              _buildContinueButton(controller),

              const SizedBox(height: AppDimensions.paddingLarge),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(
      BuildContext context, OnboardingController controller) {
    return Column(
      children: [
        Text(
          AppStrings.selectInterests,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
        const SizedBox(height: AppDimensions.padding),
        Text(
          AppStrings.selectInterestsSubtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.3, end: 0),
        if (controller.selectedInterests.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.padding),
          Text(
            '${controller.selectedInterests.length} selected',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .scaleXY(begin: 0.8, end: 1.0, curve: Curves.elasticOut),
        ],
      ],
    );
  }

  Widget _buildInterestsGrid(
      BuildContext context, OnboardingController controller) {
    final interests = ChallengeCategory.values;

    return AnimationLimiter(
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.padding,
          mainAxisSpacing: AppDimensions.padding,
          childAspectRatio: 1.1,
        ),
        itemCount: interests.length,
        itemBuilder: (context, index) {
          final category = interests[index];
          final isSelected = controller.selectedInterests.contains(category);

          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 600),
            columnCount: 2,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildInterestCard(
                  context,
                  category,
                  isSelected,
                  () => controller.toggleInterest(category),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInterestCard(
    BuildContext context,
    ChallengeCategory category,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return AnimatedButton(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? category.color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          border: Border.all(
            color: isSelected ? category.color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? category.color.withOpacity(0.2)
                  : AppColors.cardShadow,
              blurRadius: isSelected ? 15 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.padding),
          child: FittedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji
                AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  child: Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingSmall),

                // Title
                Text(
                  category.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? category.color : AppColors.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin:
                      const EdgeInsets.only(top: AppDimensions.paddingSmall),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? category.color : Colors.transparent,
                    border: isSelected
                        ? null
                        : Border.all(color: AppColors.textTertiary, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(OnboardingController controller) {
    return AnimatedButton(
      onPressed: controller.canGoNext ? controller.nextPage : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          gradient: controller.canGoNext
              ? AppColors.primaryGradient
              : const LinearGradient(
                  colors: [AppColors.textTertiary, AppColors.textTertiary],
                ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          boxShadow: controller.canGoNext
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.selectedInterests.isEmpty
                    ? 'Select at least one interest'
                    : AppStrings.next,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (controller.canGoNext) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate(delay: 1000.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.5, end: 0);
  }
}
