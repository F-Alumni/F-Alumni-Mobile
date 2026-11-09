import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:alumni_connect/core/theme/app_colors.dart';

class MainScaffoldWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffoldWrapper({
    super.key,
    required this.navigationShell,
  });

  static const double _tabletBreakpoint = 600.0;
  static const double _maxContentWidth = 720.0;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= _tabletBreakpoint;

        if (isWideScreen) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Row(
                children: [
                  NavigationRail(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: _onDestinationSelected,
                    backgroundColor: Colors.white,
                    indicatorColor: AppColors.fptOrange.withValues(alpha: 0.15),
                    labelType: NavigationRailLabelType.all,
                    selectedLabelTextStyle: const TextStyle(
                      color: AppColors.fptOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    unselectedLabelTextStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.feed_outlined),
                        selectedIcon: Icon(
                          Icons.feed,
                          color: AppColors.fptOrange,
                        ),
                        label: Text('Bảng tin'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.people_outline),
                        selectedIcon: Icon(
                          Icons.people,
                          color: AppColors.fptOrange,
                        ),
                        label: Text('Danh bạ'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.work_outline),
                        selectedIcon: Icon(
                          Icons.work,
                          color: AppColors.fptOrange,
                        ),
                        label: Text('Việc làm'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.auto_awesome_outlined),
                        selectedIcon: Icon(
                          Icons.auto_awesome,
                          color: AppColors.fptOrange,
                        ),
                        label: Text('AI Mentor'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(
                          Icons.person,
                          color: AppColors.fptOrange,
                        ),
                        label: Text('Cá nhân'),
                      ),
                    ],
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _maxContentWidth,
                        ),
                        child: navigationShell,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              backgroundColor: Colors.white,
              indicatorColor: AppColors.fptOrange.withValues(alpha: 0.15),
              elevation: 0,
              onDestinationSelected: _onDestinationSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.feed_outlined),
                  selectedIcon: Icon(Icons.feed, color: AppColors.fptOrange),
                  label: 'Bảng tin',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people, color: AppColors.fptOrange),
                  label: 'Danh bạ',
                ),
                NavigationDestination(
                  icon: Icon(Icons.work_outline),
                  selectedIcon: Icon(Icons.work, color: AppColors.fptOrange),
                  label: 'Việc làm',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_outlined),
                  selectedIcon: Icon(
                    Icons.auto_awesome,
                    color: AppColors.fptOrange,
                  ),
                  label: 'AI Mentor',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: AppColors.fptOrange),
                  label: 'Cá nhân',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
