import 'package:challengely/widgets/animated_components/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/onboarding_controller.dart';
import '../../utils/constants.dart';

import 'onboarding_wrapper.dart';

class SummaryScreen extends OnboardingScreen {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends OnboardingScreenState<SummaryScreen> {
  @override
  Widget buildContent(BuildContext context) {
    return Consumer<OnboardingController>(
      builder: (context, controller, child) {
        final summary = controller.getSummary();
        
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
              
              // Summary cards
              Expanded(
                child: _buildSummaryCards(context, summary),
              ),
              
              const SizedBox(height: AppDimensions.padding),
              
              // Action buttons
              _buildActionButtons(controller),
              
              const SizedBox(height: AppDimensions.paddingLarge),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(BuildContext context, OnboardingController controller) {
    return Column(
      children: [
        // Success icon with celebration
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.successGradient,
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.celebration_rounded,
            color: Colors.white,
            size: 50,
          ),
        )
        .animate()
        .scale(duration: 800.ms, curve: Curves.elasticOut)
        .then()
        .animate(onPlay: (animationController) => animationController.repeat())
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
        
        const SizedBox(height: AppDimensions.paddingLarge),
        
        Text(
          controller.getWelcomeMessage(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        )
        .animate(delay: 300.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.3, end: 0),
        
        const SizedBox(height: AppDimensions.padding),
        
        Text(
          'Here\'s your personalized challenge profile',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        )
        .animate(delay: 500.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: -0.3, end: 0),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context, Map<String, String> summary) {
    final cards = [
      _SummaryItem(
        icon: Icons.person_rounded,
        title: 'Name',
        value: summary['name']!,
        color: AppColors.primary,
      ),
      _SummaryItem(
        icon: Icons.favorite_rounded,
        title: 'Interests',
        value: summary['interests']!,
        color: AppColors.secondary,
      ),
      _SummaryItem(
        icon: Icons.trending_up_rounded,
        title: 'Difficulty',
        value: summary['difficulty']!,
        color: AppColors.warning,
      ),
      _SummaryItem(
        icon: Icons.flag_rounded,
        title: 'Goal',
        value: summary['goal']!,
        color: AppColors.success,
      ),
      _SummaryItem(
        icon: Icons.schedule_rounded,
        title: 'Daily Time',
        value: summary['estimatedTime']!,
        color: AppColors.accent,
      ),
    ];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final item = cards[index];
        return _buildSummaryCard(context, item)
            .animate(delay: (700 + index * 150).ms)
            .fadeIn(duration: 500.ms)
            .slideX(begin: 0.3, end: 0);
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, _SummaryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.padding),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: item.color,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OnboardingController controller) {
    return Column(
      children: [
        // Main CTA button
        AnimatedButton(
          onPressed: controller.completeOnboarding,
          child: Container(
            width: double.infinity,
            height: AppDimensions.buttonHeight,
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.rocket_launch_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.finish,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: 1500.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.5, end: 0)
        .then()
        .animate(onPlay: (animationController) => animationController.repeat(reverse: true))
        .scaleXY(duration: 2000.ms, begin: 1.0, end: 1.05),
        
        const SizedBox(height: AppDimensions.padding),
        
        // Edit button
        TextButton.icon(
          onPressed: () => controller.goToPage(1), // Go back to name input
          icon: const Icon(
            Icons.edit_rounded,
            size: 16,
          ),
          label: const Text('Edit details'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
          ),
        )
        .animate(delay: 1700.ms)
        .fadeIn(duration: 600.ms),
      ],
    );
  }
}

class _SummaryItem {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });
}