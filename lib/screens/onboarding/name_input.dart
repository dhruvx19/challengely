import 'package:challengely/widgets/animated_components/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/onboarding_controller.dart';
import '../../utils/constants.dart';
import 'onboarding_wrapper.dart';

class NameInputScreen extends OnboardingScreen {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends OnboardingScreenState<NameInputScreen> {
  late TextEditingController _nameController;
  late FocusNode _focusNode;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _focusNode = FocusNode();
    
    // Auto-focus after animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });

    // Listen to focus changes
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _hasInteracted) {
        _validateName(_nameController.text);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validateName(String value) {
    setState(() {
      _errorMessage = _getValidationError(value);
    });
  }

  String? _getValidationError(String value) {
    if (value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 30) {
      return 'Name must be less than 30 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  bool get _isValid => _errorMessage == null && _nameController.text.trim().isNotEmpty;

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
                const Spacer(flex: 1),
                
                // Header section
                _buildHeaderSection(context),
                
                const SizedBox(height: AppDimensions.paddingXL),
                
                // Name input field
                _buildNameInput(context, controller),
                
                // Error message
                if (_errorMessage != null && _hasInteracted)
                  _buildErrorMessage(),
                
                const Spacer(flex: 2),
                
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
        // Greeting emoji
        const Text(
          '👋',
          style: TextStyle(fontSize: 80),
        )
        .animate()
        .scale(duration: 600.ms, curve: Curves.elasticOut)
        .then()
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .rotate(duration: 2000.ms, begin: -0.1, end: 0.1),
        
        const SizedBox(height: AppDimensions.paddingLarge),
        
        // Title
        Text(
          'What should we call you?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
          'We\'ll use this to personalize your experience',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        )
        .animate(delay: 400.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildNameInput(BuildContext context, OnboardingController controller) {
    final hasError = _errorMessage != null && _hasInteracted;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(
          color: hasError 
              ? AppColors.error
              : _focusNode.hasFocus 
                  ? AppColors.primary
                  : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: hasError 
                ? AppColors.error.withOpacity(0.1)
                : AppColors.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _nameController,
        focusNode: _focusNode,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.words,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: hasError ? AppColors.error : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Enter your name',
          hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingLarge,
          ),
          filled: true,
          fillColor: Colors.white,
          // Add character counter
          suffixIcon: _nameController.text.isNotEmpty
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  child: Icon(
                    _isValid ? Icons.check_circle : Icons.error,
                    color: _isValid ? AppColors.success : AppColors.error,
                    size: 20,
                  ),
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _hasInteracted = true;
          });
          controller.setUserName(value);
          _validateName(value);
        },
        textInputAction: TextInputAction.next,
        onSubmitted: (value) {
          if (_isValid) {
            controller.nextPage();
          }
        },
      ),
    )
    .animate(delay: 600.ms)
    .fadeIn(duration: 600.ms)
    .slideY(begin: 0.5, end: 0)
    .then()
    .shimmer(duration: 1500.ms, color: AppColors.primary.withOpacity(0.1));
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.paddingSmall),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 300.ms)
    .slideY(begin: -0.5, end: 0)
    .shake(duration: 500.ms);
  }

  Widget _buildContinueButton(OnboardingController controller) {
    final canProceed = _isValid && controller.userName.trim().isNotEmpty;
    
    return AnimatedButton(
      onPressed: canProceed ? controller.nextPage : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: AppDimensions.buttonHeight,
        decoration: BoxDecoration(
          gradient: canProceed
              ? AppColors.primaryGradient
              : const LinearGradient(
                  colors: [AppColors.textTertiary, AppColors.textTertiary],
                ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          boxShadow: canProceed
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
                canProceed ? AppStrings.next : 'Enter your name first',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (canProceed) ...[
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
    .animate(delay: 800.ms)
    .fadeIn(duration: 600.ms)
    .slideY(begin: 0.5, end: 0);
  }
}
