import 'package:challengely/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/challenge_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/onboarding_controller.dart';
import '../../models/challenges.dart';
import '../../utils/constants.dart';
import '../../services/navigation_service.dart';
import '../../widgets/animated_components/button.dart';

class ChallengeHomeScreen extends StatefulWidget {
  const ChallengeHomeScreen({super.key});

  @override
  State<ChallengeHomeScreen> createState() => _ChallengeHomeScreenState();
}

class _ChallengeHomeScreenState extends State<ChallengeHomeScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _revealController;
  late AnimationController _progressController;
  
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Start reveal animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _revealController.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _revealController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ChallengeController>(
        builder: (context, challengeController, child) {
          return Stack(
            children: [
              // Background gradient
              _buildBackground(),
              
              // Main content
              RefreshIndicator(
                onRefresh: challengeController.refreshChallenge,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // App bar
                    _buildSliverAppBar(challengeController),
                    
                    // Content
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingLarge,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: AppDimensions.padding),
                          
                          // Stats cards
                          _buildStatsSection(challengeController),
                          
                          const SizedBox(height: AppDimensions.paddingLarge),
                          
                          // Main challenge card
                          _buildChallengeCard(challengeController),
                          
                          const SizedBox(height: AppDimensions.paddingLarge),
                          
                          // Upcoming challenges
                          _buildUpcomingSection(challengeController),
                          
                          const SizedBox(height: 140), // Extra padding for floating button
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Confetti overlay
              _buildConfettiOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            Colors.white,
          ],
          stops: [0.0, 0.3],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ChallengeController controller) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background,
                Colors.transparent,
              ],
            ),
          ),
        ),
        title: Consumer<ChallengeController>(
          builder: (context, challengeController, child) {
            final profile = challengeController.userProfile;
            final greeting = _getGreeting();
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // User avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        profile?.name.isNotEmpty == true 
                            ? profile!.name[0].toUpperCase() 
                            : 'C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Greeting text
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          profile?.name ?? 'Challenger',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_outlined, size: 20),
            ),
            color: AppColors.textPrimary,
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_outline_rounded, size: 20),
            ),
            color: AppColors.textPrimary,
            onPressed: () {
              _showProfileMenu(context);
            },
            tooltip: 'Profile',
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(ChallengeController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Current Streak',
            '${controller.currentStreak}',
            '🔥',
            AppColors.primary,
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3, end: 0),
        ),
        const SizedBox(width: AppDimensions.padding),
        Expanded(
          child: _buildStatCard(
            'Completed',
            '${controller.totalCompleted}',
            '✅',
            AppColors.success,
          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3, end: 0),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const Spacer(),
              Icon(
                Icons.trending_up_rounded,
                color: color,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(ChallengeController controller) {
    final challenge = controller.currentChallenge;
    
    if (challenge == null) {
      return _buildNoChallengeCard();
    }

    return AnimatedBuilder(
      animation: _revealController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _revealController.value),
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - _revealController.value)),
            child: Opacity(
              opacity: _revealController.value,
              child: _buildMainChallengeCard(challenge, controller),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainChallengeCard(Challenge challenge, ChallengeController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        gradient: _getChallengeGradient(challenge.state),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXL),
        boxShadow: [
          BoxShadow(
            color: challenge.categoryColor.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  challenge.category.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                challenge.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Challenge title
          Text(
            challenge.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingSmall),
          
          // Description
          Text(
            challenge.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Challenge details
          _buildChallengeDetails(challenge),
          
          const SizedBox(height: AppDimensions.paddingLarge),
          
          // Action based on state
          _buildChallengeAction(challenge, controller),
        ],
      ),
    );
  }

  Widget _buildChallengeDetails(Challenge challenge) {
    return Row(
      children: [
        _buildDetailChip(
          Icons.access_time_rounded,
          challenge.estimatedTimeText,
        ),
        const SizedBox(width: AppDimensions.padding),
        _buildDetailChip(
          Icons.speed_rounded,
          challenge.difficulty.displayName,
        ),
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeAction(Challenge challenge, ChallengeController controller) {
    switch (challenge.state) {
      case ChallengeState.available:
        return _buildStartButton(controller);
      
      case ChallengeState.inProgress:
        return _buildInProgressSection(controller);
      
      case ChallengeState.completed:
        return _buildCompletedSection(challenge, controller);
      
      case ChallengeState.locked:
        return _buildLockedSection(controller);
    }
  }

  Widget _buildStartButton(ChallengeController controller) {
    return AnimatedButton(
      onPressed: () async {
        await controller.startChallenge();
        // Notify chat controller
        final challenge = controller.currentChallenge;
        if (challenge != null) {
          context.read<ChatController>().onChallengeStarted(challenge);
        }
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow_rounded,
                color: controller.currentChallenge?.categoryColor ?? AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Accept Challenge',
                style: TextStyle(
                  color: controller.currentChallenge?.categoryColor ?? AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInProgressSection(ChallengeController controller) {
    return Column(
      children: [
        // Timer
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  final elapsed = controller.elapsedTime;
                  final minutes = elapsed.inMinutes;
                  final seconds = elapsed.inSeconds % 60;
                  return Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppDimensions.padding),
        
        // Complete button
        AnimatedButton(
          onPressed: () async {
            await controller.completeChallenge();
            _showCompletionCelebration();
            
            // Notify chat controller
            final challenge = controller.currentChallenge;
            if (challenge != null) {
              context.read<ChatController>().onChallengeCompleted(
                challenge,
                controller.elapsedTime,
              );
            }
          },
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Center(
              child: Text(
                'Mark as Complete',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedSection(Challenge challenge, ChallengeController controller) {
    return Column(
      children: [
        // Completion time
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Completed in ${challenge.timeSpentText}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppDimensions.padding),
        
        // Share button
        AnimatedButton(
          onPressed: controller.shareChallenge,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.share_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Share Achievement',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLockedSection(ChallengeController controller) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: AppDimensions.padding),
          Text(
            'Next challenge available in',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          Text(
            controller.getTimeUntilNextChallenge(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoChallengeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.psychology_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            'No challenge available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'Check back soon for your next personalized challenge',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSection(ChallengeController controller) {
    final upcomingChallenges = controller.upcomingChallenges;
    
    if (upcomingChallenges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coming Up',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.padding),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: upcomingChallenges.length,
            itemBuilder: (context, index) {
              final challenge = upcomingChallenges[index];
              return _buildUpcomingChallengeCard(challenge, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingChallengeCard(Challenge challenge, int index) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(
        right: AppDimensions.padding,
        left: index == 0 ? 0 : 0,
      ),
      padding: const EdgeInsets.all(AppDimensions.padding),
      decoration: BoxDecoration(
        color: challenge.categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(
          color: challenge.categoryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                challenge.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: challenge.categoryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  challenge.difficulty.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            challenge.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            challenge.estimatedTimeText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    )
    .animate(delay: (200 + index * 100).ms)
    .fadeIn(duration: 500.ms)
    .slideX(begin: 0.3, end: 0);
  }

  Widget _buildConfettiOverlay() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: 1.5708, // radians for downward
        maxBlastForce: 5,
        minBlastForce: 1,
        emissionFrequency: 0.05,
        numberOfParticles: 50,
        gravity: 0.3,
        shouldLoop: false,
        colors: const [
          AppColors.primary,
          AppColors.secondary,
          AppColors.success,
          AppColors.warning,
        ],
      ),
    );
  }

  LinearGradient _getChallengeGradient(ChallengeState state) {
    switch (state) {
      case ChallengeState.available:
        return AppColors.primaryGradient;
      case ChallengeState.inProgress:
        return const LinearGradient(
          colors: [AppColors.warning, Color(0xFFFF8A00)],
        );
      case ChallengeState.completed:
        return AppColors.successGradient;
      case ChallengeState.locked:
        return const LinearGradient(
          colors: [AppColors.textTertiary, AppColors.textSecondary],
        );
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _showCompletionCelebration() {
    _confettiController.play();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '🎉 Challenge completed! Great job!',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProfileMenuModal(),
    );
  }
}

class _ProfileMenuModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ChallengeController, OnboardingController>(
      builder: (context, challengeController, onboardingController, child) {
        final profile = challengeController.userProfile;
        
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.borderRadiusXL),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Profile header
                if (profile != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'C',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: AppDimensions.padding),
                        
                        // Profile info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                profile.achievementLevel,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  profile.streakText,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(height: 1),
                ],
                
                // Menu items
                _buildMenuItem(
                  context,
                  Icons.person_rounded,
                  'Edit Profile',
                  'Update your information',
                  () {
                    Navigator.pop(context);
                    _showEditProfileDialog(context, profile);
                  },
                ),
                
                _buildMenuItem(
                  context,
                  Icons.notifications_rounded,
                  'Notifications',
                  'Manage your reminders',
                  () {
                    Navigator.pop(context);
                    _showNotificationSettings(context);
                  },
                ),
                
                _buildMenuItem(
                  context,
                  Icons.share_rounded,
                  'Share App',
                  'Tell friends about Challengely',
                  () {
                    Navigator.pop(context);
                    _shareApp();
                  },
                ),
                
                _buildMenuItem(
                  context,
                  Icons.help_outline_rounded,
                  'Help & Support',
                  'Get help or send feedback',
                  () {
                    Navigator.pop(context);
                    _showHelpDialog(context);
                  },
                ),
                
                const Divider(height: 1),
                
                // Logout button
                _buildMenuItem(
                  context,
                  Icons.logout_rounded,
                  'Start Over',
                  'Reset app and go through onboarding again',
                  () {
                    Navigator.pop(context);
                    _showLogoutConfirmation(context, onboardingController, challengeController);
                  },
                  isDestructive: true,
                ),
                
                const SizedBox(height: AppDimensions.paddingLarge),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive 
              ? AppColors.error.withOpacity(0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: 4,
      ),
    );
  }

  void _showLogoutConfirmation(
    BuildContext context,
    OnboardingController onboardingController,
    ChallengeController challengeController,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          ),
          title: const Text('Start Over?'),
          content: const Text(
            'This will reset all your progress and take you back to the beginning. Your streak, completed challenges, and chat history will be lost.\n\nAre you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Close the confirmation dialog first
                Navigator.pop(dialogContext);
                
                // Perform reset operation
                await _performReset(context, onboardingController, challengeController);
              },
              child: const Text(
                'Start Over',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performReset(
    BuildContext context,
    OnboardingController onboardingController,
    ChallengeController challengeController,
  ) async {
    // Show loading dialog using safe navigation
    NavigationService.showDialog(
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Logging out...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    
    try {
      // Reset all data with proper order
      await challengeController.clearAllData();
      
      // Add a small delay to ensure cleanup
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Reset onboarding (this triggers UI rebuild)
      await onboardingController.resetOnboarding();
      
      // The widget tree will rebuild completely, so dialogs are automatically dismissed
      
      // Show success message after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        NavigationService.showSnackBar(
          const SnackBar(
            content: Text('Welcome back! Let\'s set up your challenges again.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
      });
      
    } catch (e) {
      print('Reset error: $e');
      
      // Try to close any open dialogs
      if (NavigationService.canPop()) {
        NavigationService.pop();
      }
      
      // Show error message
      NavigationService.showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showEditProfileDialog(BuildContext context, UserProfile? profile) {
    if (profile == null) return;
    
    final nameController = TextEditingController(text: profile.name);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          ),
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'To change interests, difficulty, or goals, use "Start Over"',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update profile name logic would go here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated!')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          ),
          title: const Text('Notification Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Daily Reminders'),
                subtitle: const Text('Get reminded about your daily challenge'),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: const Text('Streak Warnings'),
                subtitle: const Text('Get notified when your streak is at risk'),
                value: true,
                onChanged: (value) {},
              ),
              SwitchListTile(
                title: const Text('Achievement Notifications'),
                subtitle: const Text('Celebrate when you unlock achievements'),
                value: true,
                onChanged: (value) {},
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _shareApp() {
    // Share app logic would go here
    // Using share_plus package that's already included
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          ),
          title: const Text('Help & Support'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Need help? Here are some options:'),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.email_rounded),
                title: const Text('Contact Support'),
                subtitle: const Text('support@challengely.app'),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  // Open email
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report_rounded),
                title: const Text('Report a Bug'),
                subtitle: const Text('Help us improve the app'),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  // Open bug report
                },
              ),
              ListTile(
                leading: const Icon(Icons.star_rounded),
                title: const Text('Rate the App'),
                subtitle: const Text('Leave a review'),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  // Open app store
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}