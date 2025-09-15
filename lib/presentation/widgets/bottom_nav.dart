import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../navigation/route_names.dart';

class HomeBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int>? onChanged;

  const HomeBottomNav({
    super.key,
    this.index = 0,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.85),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.transparent,
              indicatorColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              iconTheme: WidgetStateProperty.all(
                const IconThemeData(size: 26),
              ),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: index,
              height: 64,
              onDestinationSelected: (i) {

                onChanged?.call(i);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.home, color: AppColors.primary),
                  label: 'Главная',
                ),
                NavigationDestination(
                  icon: Icon(Icons.show_chart_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.show_chart, color: AppColors.primary),
                  label: 'Статистика',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline, color: Colors.grey),
                  selectedIcon: Icon(Icons.add_circle, color: AppColors.primary),
                  label: 'Добавить матч',
                ),
                NavigationDestination(
                  icon: Icon(Icons.local_fire_department_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.local_fire_department, color: AppColors.primary),
                  label: 'Состояние',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline, color: Colors.grey),
                  selectedIcon: Icon(Icons.person, color: AppColors.primary),
                  label: 'Профиль',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
