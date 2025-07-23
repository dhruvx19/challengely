import 'package:challengely/screens/onboarding/interest_screen.dart';
import 'package:challengely/screens/onboarding/name_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/onboarding_controller.dart';
import '../../utils/constants.dart';
import '../../utils/animations.dart';
import 'welcome_screen.dart';
import 'difficulty_screen.dart';
import 'goals_screen.dart';
import 'summary_screen.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper>
    with TickerProviderStateMixin {
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Reset page controller when onboarding starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<OnboardingController>();
      controller.resetPageController();
    });
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingController>(
      builder: (context, controller, child) {
        // Update progress animation when page changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _progressAnimationController.animateTo(controller.progress);
        });

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: controller.currentPage > 0 ? _buildAppBar(controller) : null,
          body: Column(
            children: [
              if (controller.currentPage > 0) _buildProgressIndicator(controller),
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    WelcomeScreen(),
                    NameInputScreen(),
                    InterestsScreen(),
                    DifficultyScreen(),
                    GoalsScreen(),
                    SummaryScreen(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(OnboardingController controller) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: controller.currentPage > 0
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: controller.previousPage,
              color: AppColors.textPrimary,
            )
          : null,
      actions: [
        TextButton(
          onPressed: controller.skipOnboarding,
          child: const Text(
            AppStrings.skip,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProgressIndicator(OnboardingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.padding,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${controller.currentPage} of ${controller.totalPages}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(controller.progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: AppColors.surfaceVariant,
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Custom page transition for onboarding
class OnboardingPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  OnboardingPageRoute({required this.child})
      : super(
          transitionDuration: AnimationConstants.pageTransition,
          reverseTransitionDuration: AnimationConstants.pageTransition,
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AppAnimations.slideTransition(
              animation,
              secondaryAnimation,
              child,
            );
          },
        );
}

// Base onboarding screen widget
abstract class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
}

abstract class OnboardingScreenState<T extends OnboardingScreen>
    extends State<T> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    // Start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      animationController.forward();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget buildAnimatedContent(Widget child) {
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }

  // Abstract method to be implemented by each screen
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return buildAnimatedContent(buildContent(context));
  }
}