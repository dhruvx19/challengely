import 'package:challengely/widgets/animated_components/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/onboarding_controller.dart';
import '../../utils/constants.dart';
import 'onboarding_wrapper.dart';

class DifficultyScreen extends OnboardingScreen {
  const DifficultyScreen({super.key});

  @override
  State<DifficultyScreen> createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends OnboardingScreenState<DifficultyScreen> {
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
              _buildHeaderSection(context),
              
              const SizedBox(height: AppDimensions.paddingXL),
              
              // Difficulty cards
              Expanded(
                child: _buildDifficultyCards(context, controller),
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

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.tune_rounded,
            color: Colors.white,
            size: 40,
          ),
        )
        .animate()
        .scale(duration: 600.ms, curve: Curves.elasticOut)
        .then()
        .rotate(duration: 1000.ms, begin: 0, end: 0.1)
        .then()
        .rotate(duration: 1000.ms, begin: 0.1, end: 0),
        
        const SizedBox(height: AppDimensions.paddingLarge),
        
        Text(
          AppStrings.selectDifficulty,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        )
        .animate(delay: 200.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.3, end: 0),
        
        const SizedBox(height: AppDimensions.padding),
        
        Text(
          AppStrings.selectDifficultySubtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        )
        .animate(delay: 400.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.3, end: 0),
      ],
    );
  }

  Widget _buildDifficultyCards(BuildContext context, OnboardingController controller) {
    final difficulties = Difficulty.values;
    
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: difficulties.length,
      itemBuilder: (context, index) {
        final difficulty = difficulties[index];
        final isSelected = controller.selectedDifficulty == difficulty;
        
        return _buildDifficultyCard(
          context,
          difficulty,
          isSelected,
          () => controller.setDifficulty(difficulty),
        )
        .animate(delay: (600 + index * 200).ms)
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3, end: 0);
      },
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context,
    Difficulty difficulty,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return AnimatedButton(
      onPressed: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.padding),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          decoration: BoxDecoration(
            color: isSelected ? difficulty.color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
            border: Border.all(
              color: isSelected ? difficulty.color : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                    ? difficulty.color.withOpacity(0.2)
                    : AppColors.cardShadow,
                blurRadius: isSelected ? 20 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Level indicator
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: difficulty.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      return Container(
                        width: 6,
                        height: index < difficulty.level ? 20 : 8,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: index < difficulty.level 
                              ? difficulty.color
                              : difficulty.color.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              
              const SizedBox(width: AppDimensions.paddingLarge),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficulty.displayName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? difficulty.color : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      difficulty.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? difficulty.color : Colors.transparent,
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
    );
  }

  Widget _buildContinueButton(OnboardingController controller) {
    return AnimatedButton(
      onPressed: controller.nextPage,
      child: Container(
        width: double.infinity,
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.next,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    )
    .animate(delay: 1200.ms)
    .fadeIn(duration: 600.ms)
    .slideY(begin: 0.5, end: 0);
  }
}