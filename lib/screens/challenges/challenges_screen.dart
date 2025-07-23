import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/challenge_controller.dart';
import '../../models/challenges.dart';
import '../../utils/constants.dart';
import '../../widgets/animated_components/button.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilter = 0; // 0: All, 1: Easy, 2: Medium, 3: Hard
  String _searchQuery = '';
  bool _isSearching = false;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<ChallengeController>(
        builder: (context, challengeController, child) {
          return Column(
            children: [
              // Filter section
              _buildFilterSection(),
              
              // Tab bar
              _buildTabBar(),
              
              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUpcomingTab(challengeController),
                    _buildCompletedTab(challengeController),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: _isSearching ? _buildSearchField() : const Text(
        'Challenges',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      ),
      leading: _isSearching ? IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        color: AppColors.textPrimary,
        onPressed: _exitSearch,
      ) : null,
      actions: _isSearching ? [
        if (_searchQuery.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear_rounded),
            color: AppColors.textSecondary,
            onPressed: _clearSearch,
          ),
      ] : [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          color: AppColors.textPrimary,
          onPressed: _enterSearch,
          tooltip: 'Search challenges',
        ),
        IconButton(
          icon: const Icon(Icons.filter_list_rounded),
          color: AppColors.textPrimary,
          onPressed: _showFilterDialog,
          tooltip: 'Filter challenges',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search challenges...',
        hintStyle: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 18,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      onChanged: _onSearchChanged,
      textInputAction: TextInputAction.search,
    );
  }

  void _enterSearch() {
    setState(() {
      _isSearching = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _exitSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
    });
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
    });
    _searchController.clear();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  Widget _buildFilterSection() {
    final filters = ['All', 'Easy', 'Medium', 'Hard'];
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.padding,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(filters.length, (index) {
            final isSelected = _selectedFilter == index;
            return _buildFilterChip(
              filters[index],
              isSelected,
              () => setState(() => _selectedFilter = index),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return AnimatedButton(
      onPressed: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppDimensions.paddingSmall),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.padding,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.padding,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        splashFactory: NoSplash.splashFactory,
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        tabs: const [
          Tab(
            height: 44,
            child: Text('Upcoming'),
          ),
          Tab(
            height: 44,
            child: Text('Completed'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab(ChallengeController controller) {
    final upcomingChallenges = _getFilteredChallenges(
      controller.upcomingChallenges,
    );
    
    if (upcomingChallenges.isEmpty) {
      return _buildEmptyState(
        icon: _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.calendar_today_rounded,
        title: _searchQuery.isNotEmpty ? 'No results found' : 'No upcoming challenges',
        subtitle: _searchQuery.isNotEmpty 
            ? 'Try adjusting your search or filters'
            : 'New challenges will appear here soon!',
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshChallenge,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        itemCount: upcomingChallenges.length,
        itemBuilder: (context, index) {
          final challenge = upcomingChallenges[index];
          return _buildChallengeCard(challenge, index, false);
        },
      ),
    );
  }

  Widget _buildCompletedTab(ChallengeController controller) {
    final completedChallenges = _getFilteredChallenges(
      controller.completedChallenges,
    );
    
    if (completedChallenges.isEmpty) {
      return _buildEmptyState(
        icon: _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.emoji_events_rounded,
        title: _searchQuery.isNotEmpty ? 'No results found' : 'No completed challenges yet',
        subtitle: _searchQuery.isNotEmpty 
            ? 'Try adjusting your search or filters'
            : 'Start completing challenges to see them here!',
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      itemCount: completedChallenges.length,
      itemBuilder: (context, index) {
        final challenge = completedChallenges[index];
        return _buildChallengeCard(challenge, index, true);
      },
    );
  }

  Widget _buildChallengeCard(Challenge challenge, int index, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.padding),
      child: AnimatedButton(
        onPressed: () => _showChallengeDetails(challenge),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
            border: Border.all(
              color: challenge.categoryColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: challenge.categoryColor.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: challenge.categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      challenge.category.displayName,
                      style: TextStyle(
                        color: challenge.categoryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Emoji and completion status
                  Row(
                    children: [
                      Text(
                        challenge.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.padding),
              
              // Title
              Text(
                challenge.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: AppDimensions.paddingSmall),
              
              // Description with length handling
              _buildDescriptionText(challenge.description),
              
              const SizedBox(height: AppDimensions.paddingLarge),
              
              // Details row
              Row(
                children: [
                  _buildDetailItem(
                    Icons.access_time_rounded,
                    challenge.estimatedTimeText,
                    AppColors.primary,
                  ),
                  const SizedBox(width: AppDimensions.paddingLarge),
                  _buildDetailItem(
                    Icons.speed_rounded,
                    challenge.difficulty.displayName,
                    challenge.difficultyColor,
                  ),
                  const Spacer(),
                  if (isCompleted && challenge.timeSpent != null)
                    _buildDetailItem(
                      Icons.timer_rounded,
                      challenge.timeSpentText,
                      AppColors.success,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
    .animate(delay: (index * 100).ms)
    .fadeIn(duration: 500.ms)
    .slideY(begin: 0.3, end: 0);
  }

  Widget _buildDescriptionText(String description) {
    const int maxLength = 120; // Character limit for preview
    const int maxLines = 2;
    
    if (description.length <= maxLength) {
      return Text(
        description,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondary,
          height: 1.4,
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }
    
    final truncated = description.substring(0, maxLength);
    final lastSpaceIndex = truncated.lastIndexOf(' ');
    final preview = lastSpaceIndex > 0 ? truncated.substring(0, lastSpaceIndex) : truncated;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$preview...',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Tap to read more',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                icon,
                size: 60,
                color: AppColors.textTertiary,
              ),
            )
            .animate()
            .scale(duration: 800.ms, curve: Curves.elasticOut)
            .then()
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(duration: 2000.ms, begin: 1.0, end: 1.05),
            
            const SizedBox(height: AppDimensions.paddingLarge),
            
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppDimensions.paddingSmall),
            
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Challenge> _getFilteredChallenges(List<Challenge> challenges) {
    var filtered = challenges;
    
    // Apply difficulty filter
    if (_selectedFilter > 0) {
      final targetDifficulty = Difficulty.values[_selectedFilter - 1];
      filtered = filtered.where((c) => c.difficulty == targetDifficulty).toList();
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((challenge) {
        return challenge.title.toLowerCase().contains(_searchQuery) ||
               challenge.description.toLowerCase().contains(_searchQuery) ||
               challenge.category.displayName.toLowerCase().contains(_searchQuery) ||
               challenge.difficulty.displayName.toLowerCase().contains(_searchQuery);
      }).toList();
    }
    
    return filtered;
  }

  void _showChallengeDetails(Challenge challenge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChallengeDetailsModal(challenge: challenge),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          ),
          title: const Text('Filter Challenges'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filter by difficulty:'),
              const SizedBox(height: 16),
              ...Difficulty.values.map((difficulty) {
                return RadioListTile<Difficulty>(
                  title: Text(difficulty.displayName),
                  value: difficulty,
                  groupValue: _selectedFilter > 0 
                      ? Difficulty.values[_selectedFilter - 1] 
                      : null,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value != null 
                          ? Difficulty.values.indexOf(value) + 1 
                          : 0;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _selectedFilter = 0);
                Navigator.pop(context);
              },
              child: const Text('Clear Filter'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}


class _ChallengeDetailsModal extends StatelessWidget {
  final Challenge challenge;

  const _ChallengeDetailsModal({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.borderRadiusXL),
            ),
          ),
          child: Column(
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
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Text(
                            challenge.emoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: challenge.categoryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    challenge.category.displayName,
                                    style: TextStyle(
                                      color: challenge.categoryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  challenge.title,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingLarge),
                      
                      // Description
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        challenge.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.paddingLarge),
                      
                      // Instructions
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        challenge.detailedInstructions,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      
                      if (challenge.tips.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.paddingLarge),
                        
                        // Tips
                        Text(
                          'Tips',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...challenge.tips.map((tip) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '💡 ',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                      
                      const SizedBox(height: AppDimensions.paddingXL),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}