import 'package:challengely/widgets/animated_components/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/onboarding_controller.dart';
import '../../utils/constants.dart';
import 'onboarding_wrapper.dart';

class GoalsScreen extends OnboardingScreen {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends OnboardingScreenState<GoalsScreen> {
  late TextEditingController _goalController;
  late FocusNode _focusNode;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final List<String> _suggestedGoals = [
    'Build positive daily habits',
    'Improve my physical health',
    'Develop mindfulness practice',
    'Learn new creative skills',
    'Connect more with others',
    'Boost personal productivity',
    'Enhance mental wellbeing',
    'Cultivate gratitude daily',
  ];

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _goalController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Consumer<OnboardingController>(
      builder: (context, controller, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // Header section
                _buildHeaderSection(context),
                
                const SizedBox(height: AppDimensions.paddingXL),
                
                // Goal input field
                _buildGoalInput(context, controller),
                
                const SizedBox(height: AppDimensions.paddingLarge),
                
                // Suggested goals
                Expanded(
                  child: _buildSuggestedGoals(context, controller),
                ),
                
                const SizedBox(height: AppDimensions.padding),
                
                // Continue button
                _buildContinueButton(controller),
                
                const SizedBox(height: AppDimensions.paddingLarge),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      children: [
        // Target icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.secondaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.flag_rounded,
            color: Colors.white,
            size: 40,
          ),
        )
        .animate()
        .scale(duration: 600.ms, curve: Curves.elasticOut)
        .then()
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5)),
        
        const SizedBox(height: AppDimensions.paddingLarge),
        
        Text(
          AppStrings.setGoals,
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
          AppStrings.setGoalsSubtitle,
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

  Widget _buildGoalInput(BuildContext context, OnboardingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: _goalController,
        focusNode: _focusNode,
        maxLines: 3,
        minLines: 1,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'What do you want to achieve?',
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textTertiary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
            borderSide: const BorderSide(
              color: AppColors.secondary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(AppDimensions.paddingLarge),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: controller.validateGoal,
        onChanged: (value) {
          controller.setGoal(value);
          _formKey.currentState?.validate();
        },
        textInputAction: TextInputAction.done,
      ),
    )
    .animate(delay: 600.ms)
    .fadeIn(duration: 600.ms)
    .slideY(begin: 0.5, end: 0);
  }

  Widget _buildSuggestedGoals(BuildContext context, OnboardingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Or choose from these suggestions:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        )
        .animate(delay: 800.ms)
        .fadeIn(duration: 600.ms),
        
        const SizedBox(height: AppDimensions.padding),
        
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _suggestedGoals.length,
            itemBuilder: (context, index) {
              final goal = _suggestedGoals[index];
              final isSelected = controller.selectedGoal == goal;
              
              return _buildSuggestionChip(
                context,
                goal,
                isSelected,
                () {
                  controller.setGoal(goal);
                  _goalController.text = goal;
                },
              )
              .animate(delay: (1000 + index * 100).ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.3, end: 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(
    BuildContext context,
    String goal,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return AnimatedButton(
      onPressed: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.padding,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.surfaceVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                goal,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(OnboardingController controller) {
    return AnimatedButton(
      onPressed: controller.canGoNext && _formKey.currentState?.validate() == true
          ? controller.nextPage
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          gradient: controller.canGoNext
              ? AppColors.secondaryGradient
              : const LinearGradient(
                  colors: [AppColors.textTertiary, AppColors.textTertiary],
                ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          boxShadow: controller.canGoNext
              ? [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
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
                controller.selectedGoal.isEmpty
                    ? 'Set your goal first'
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
    .animate(delay: 1400.ms)
    .fadeIn(duration: 600.ms)
    .slideY(begin: 0.5, end: 0);
  }
}