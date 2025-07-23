import 'package:challengely/screens/challenges/challenge_home_screen.dart';
import 'package:challengely/screens/challenges/challenges_screen.dart';
import 'package:challengely/screens/challenges/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/challenge_controller.dart';
import '../controllers/chat_controller.dart';
import '../utils/constants.dart';
import 'chat/chat_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<Widget> _screens = [
    const ChallengeHomeScreen(),
    const ChallengesScreen(),
    const ProgressScreen(),
    const ChatScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.home_rounded,
      label: 'Home',
      activeIcon: Icons.home_rounded,
    ),
    NavItem(
      icon: Icons.explore_outlined,
      label: 'Challenges',
      activeIcon: Icons.explore_rounded,
    ),
    NavItem(
      icon: Icons.trending_up_outlined,
      label: 'Progress',
      activeIcon: Icons.trending_up_rounded,
    ),
    NavItem(
      icon: Icons.chat_bubble_outline_rounded,
      label: 'Chat',
      activeIcon: Icons.chat_bubble_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      
      // Animate FAB
      _fabAnimationController.reset();
      _fabAnimationController.forward();
      
      // Update chat controller if going to chat
      if (index == 3) {
        final challengeController = context.read<ChallengeController>();
        context.read<ChatController>().setCurrentChallenge(
          challengeController.currentChallenge,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          items: _navItems.map((item) {
            final index = _navItems.indexOf(item);
            final isSelected = _currentIndex == index;
            
            return BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 24,
                ),
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<ChallengeController>(
      builder: (context, challengeController, child) {
        // Show FAB only on home screen and when challenge is available
        if (_currentIndex != 0 || 
            challengeController.currentChallenge == null ||
            !challengeController.canStartChallenge) {
          return const SizedBox.shrink();
        }

        return ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton.extended(
            onPressed: () => challengeController.startChallenge(),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 8,
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: const Text(
              'Start Challenge',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
      },
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}