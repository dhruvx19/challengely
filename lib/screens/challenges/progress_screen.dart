import 'package:challengely/models/challenges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/challenge_controller.dart';
import '../../models/user_profile.dart';
import '../../utils/constants.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<ChallengeController>(
        builder: (context, challengeController, child) {
          final profile = challengeController.userProfile;

          if (profile == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await challengeController.refreshChallenge();
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header
                  _buildProfileHeader(profile),

                  const SizedBox(height: AppDimensions.paddingXL),

                  // Stats overview
                  _buildStatsOverview(challengeController),

                  const SizedBox(height: AppDimensions.paddingXL),

                  // Streak section
                  _buildStreakSection(profile),

                  const SizedBox(height: AppDimensions.paddingXL),

                  // Categories breakdown
                  _buildCategoriesBreakdown(challengeController),

                  const SizedBox(height: AppDimensions.paddingXL),

                  // Achievement badges
                  _buildAchievements(profile),

                  const SizedBox(height: AppDimensions.paddingXL),

                  // Recent activity
                  _buildRecentActivity(challengeController),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Your Progress',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded),
          color: AppColors.textPrimary,
          onPressed: _shareProgress,
          tooltip: 'Share progress',
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          color: AppColors.textPrimary,
          onPressed: _showSettings,
          tooltip: 'Settings',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),

          const SizedBox(width: AppDimensions.paddingLarge),

          // Profile info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.3, end: 0),
                const SizedBox(height: 4),
                Text(
                  profile.achievementLevel,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.3, end: 0),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    profile.streakText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate(delay: 600.ms).fadeIn().slideX(begin: 0.3, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(ChallengeController controller) {
    final stats = [
      _StatItem(
        title: 'Current Streak',
        value: '${controller.currentStreak}',
        unit: 'days',
        icon: Icons.local_fire_department_rounded,
        color: AppColors.primary,
      ),
      _StatItem(
        title: 'Total Completed',
        value: '${controller.totalCompleted}',
        unit: 'challenges',
        icon: Icons.emoji_events_rounded,
        color: AppColors.success,
      ),
      _StatItem(
        title: 'This Week',
        value: '${_getWeeklyCount(controller)}',
        unit: 'completed',
        icon: Icons.calendar_today_rounded,
        color: AppColors.secondary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),

        // Vertical layout - three rows
        Column(
          children: stats.asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            return Container(
              width: double.infinity, // Full width
              margin: EdgeInsets.only(
                bottom: index < stats.length - 1 ? AppDimensions.padding : 0,
              ),
              child: _buildStatCard(stat)
                  .animate(delay: (200 + index * 150).ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatCard(_StatItem stat) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: stat.color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              stat.icon,
              color: stat.color,
              size: 28,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingLarge),

          // Content section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Value with animation
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    final animatedValue = (int.tryParse(stat.value) ?? 0) *
                        _progressAnimation.value;
                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: animatedValue.toInt().toString(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: stat.color,
                                  height: 1.1,
                                ),
                          ),
                        TextSpan(
                            text: ' ',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  
                                  color: stat.color,
                                  height: 1.1,
                                ),
                          ),
                          TextSpan(
                            text: stat.unit,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                const SizedBox(height: 4),

                // Unit and title in one line for compact look
                RichText(
                  text: TextSpan(
                    children: [
                      
                      TextSpan(
                        text: stat.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Right side indicator/arrow
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.trending_up_rounded,
              color: stat.color,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Streak Calendar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const Spacer(),
              Text(
                '🔥 ${profile.currentStreak} days',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          _buildStreakCalendar(profile),
        ],
      ),
    )
        .animate(delay: 600.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildStreakCalendar(UserProfile profile) {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 14, // Last 14 days
        itemBuilder: (context, index) {
          final date = DateTime.now().subtract(Duration(days: 13 - index));
          final hasCompleted = _hasCompletedOnDate(date, profile);
          final isToday = _isToday(date);

          return Container(
            width: 48,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: hasCompleted
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: isToday
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getDayName(date.weekday),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: hasCompleted
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                if (hasCompleted)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 12,
                    color: AppColors.success,
                  )
                else
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesBreakdown(ChallengeController controller) {
    final completedChallenges = controller.completedChallenges;
    final categoryStats = _getCategoryStats(completedChallenges);

    if (categoryStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        ...categoryStats.entries.map((entry) {
          final category = entry.key;
          final count = entry.value;
          final total = completedChallenges.length;
          final percentage = total > 0 ? (count / total) : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: AppDimensions.padding),
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusLarge),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: AppDimensions.padding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.displayName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count challenge${count == 1 ? '' : 's'} completed',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: category.color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(category.color),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.padding),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: category.color,
                      ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    )
        .animate(delay: 800.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildAchievements(UserProfile profile) {
    final achievements = _getAchievements(profile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _buildAchievementBadge(achievement, index);
            },
          ),
        ),
      ],
    )
        .animate(delay: 1000.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildAchievementBadge(_Achievement achievement, int index) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(
        right: AppDimensions.padding,
        left: index == 0 ? 0 : 0,
      ),
      padding: const EdgeInsets.all(AppDimensions.padding),
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? Colors.white : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: achievement.isUnlocked
            ? Border.all(color: achievement.color, width: 2)
            : null,
        boxShadow: achievement.isUnlocked
            ? [
                BoxShadow(
                  color: achievement.color.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            achievement.emoji,
            style: TextStyle(
              fontSize: 32,
              color: achievement.isUnlocked ? null : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: achievement.isUnlocked
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    )
        .animate(delay: (200 + index * 100).ms)
        .fadeIn(duration: 500.ms)
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildRecentActivity(ChallengeController controller) {
    final recentChallenges = controller.completedChallenges.take(5).toList();

    if (recentChallenges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        ...recentChallenges.map((challenge) {
          final index = recentChallenges.indexOf(challenge);
          return _buildActivityItem(challenge)
              .animate(delay: (1200 + index * 100).ms)
              .fadeIn(duration: 500.ms)
              .slideX(begin: 0.3, end: 0);
        }).toList(),
      ],
    );
  }

  Widget _buildActivityItem(Challenge challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      padding: const EdgeInsets.all(AppDimensions.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            challenge.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: AppDimensions.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                Text(
                  'Completed in ${challenge.timeSpentText}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 20,
          ),
        ],
      ),
    );
  }

  // Helper methods
  int _getWeeklyCount(ChallengeController controller) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    return controller.completedChallenges
        .where((c) =>
            c.completionTime != null && c.completionTime!.isAfter(weekStart))
        .length;
  }

  Map<ChallengeCategory, int> _getCategoryStats(List<Challenge> challenges) {
    final stats = <ChallengeCategory, int>{};

    for (final challenge in challenges) {
      stats[challenge.category] = (stats[challenge.category] ?? 0) + 1;
    }

    return stats;
  }

  bool _hasCompletedOnDate(DateTime date, UserProfile profile) {
    final lastCompleted = profile.lastChallengeDate;
    if (lastCompleted == null) return false;

    return lastCompleted.year == date.year &&
        lastCompleted.month == date.month &&
        lastCompleted.day == date.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _getDayName(int weekday) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[weekday - 1];
  }

  List<_Achievement> _getAchievements(UserProfile profile) {
    return [
      _Achievement(
        title: 'First Step',
        emoji: '👟',
        color: AppColors.success,
        isUnlocked: profile.totalChallengesCompleted >= 1,
      ),
      _Achievement(
        title: 'Week Warrior',
        emoji: '⚔️',
        color: AppColors.primary,
        isUnlocked: profile.currentStreak >= 7,
      ),
      _Achievement(
        title: 'Month Master',
        emoji: '👑',
        color: AppColors.warning,
        isUnlocked: profile.currentStreak >= 30,
      ),
      _Achievement(
        title: 'Century Club',
        emoji: '💯',
        color: AppColors.secondary,
        isUnlocked: profile.totalChallengesCompleted >= 100,
      ),
    ];
  }

  void _shareProgress() {
    final message = 'Check out my progress on Challengely! 🚀\n'
        'Current streak: ${context.read<ChallengeController>().currentStreak} days 🔥\n'
        'Challenges completed: ${context.read<ChallengeController>().totalCompleted} 💪';

    // Share logic would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progress shared!')),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.borderRadiusXL),
            ),
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              ListTile(
                leading: const Icon(Icons.notifications_rounded),
                title: const Text('Notifications'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded),
                title: const Text('Export Data'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_rounded),
                title: const Text('About'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });
}

class _Achievement {
  final String title;
  final String emoji;
  final Color color;
  final bool isUnlocked;

  const _Achievement({
    required this.title,
    required this.emoji,
    required this.color,
    required this.isUnlocked,
  });
}
