import 'package:challengely/widgets/animated_components/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/onboarding_controller.dart';
import '../../utils/constants.dart';
import 'onboarding_wrapper.dart';

class WelcomeScreen extends OnboardingScreen {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends OnboardingScreenState<WelcomeScreen> {
  @override
  Widget buildContent(BuildContext context) {
    return Consumer<OnboardingController>(
      builder: (context, controller, child) {
        return SafeArea(
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLarge,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                           MediaQuery.of(context).padding.top - 
                           MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                
                      // Logo and title section
                      _buildHeaderSection(context),
                
                      const SizedBox(height: AppDimensions.paddingXL),
                
                      // Features section
                      _buildFeaturesSection(context),
                
                      const Spacer(flex: 2),
                
                      // CTA Button
                      _buildActionButton(controller),
                
                      const SizedBox(height: AppDimensions.paddingLarge),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      children: [
        // Logo/Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_fire_department_rounded,
            size: 60,
            color: Colors.white,
          ),
        )
            .animate()
            .scale(
              duration: 600.ms,
              curve: Curves.elasticOut,
            )
            .then()
            .shake(duration: 300.ms, hz: 2),

        const SizedBox(height: AppDimensions.paddingLarge),

        // Title
        Text(
          AppStrings.welcomeTitle,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
          textAlign: TextAlign.center,
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.3, end: 0),

        const SizedBox(height: AppDimensions.padding),

        // Subtitle
        Text(
          AppStrings.welcomeSubtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        )
            .animate(delay: 400.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      const _FeatureItem(
        icon: Icons.track_changes_rounded,
        title: 'Daily Challenges',
        description: 'Personalized tasks that grow with you',
        color: AppColors.primary,
      ),
      const _FeatureItem(
        icon: Icons.psychology_rounded,
        title: 'AI Assistant',
        description: 'Get support and motivation when you need it',
        color: AppColors.secondary,
      ),
      const _FeatureItem(
        icon: Icons.trending_up_rounded,
        title: 'Track Progress',
        description: 'Build streaks and celebrate your growth',
        color: AppColors.success,
      ),
    ];

    return Column(
      children: features.map((feature) {
        final index = features.indexOf(feature);
        return _buildFeatureItem(context, feature)
            .animate(delay: (600 + index * 150).ms)
            .fadeIn(duration: 500.ms)
            .slideX(begin: 0.3, end: 0);
      }).toList(),
    );
  }

  Widget _buildFeatureItem(BuildContext context, _FeatureItem feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.padding),
      padding: const EdgeInsets.all(AppDimensions.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: [
          const BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: feature.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature.icon,
              color: feature.color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(OnboardingController controller) {
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
                AppStrings.getStarted,
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
        .animate(delay: 1000.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.5, end: 0)
        .then()
        // ignore: deprecated_member_use
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3));
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}