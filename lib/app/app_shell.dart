import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../screens/ai_plans_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/home_screen.dart';
import '../screens/plan_detail_screen.dart';
import '../screens/stats_screen.dart';
import '../state/school_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_background.dart';
import '../widgets/focus_plan_picker_sheet.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: school,
      builder: (context, _) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: context.sc.bg,
            body: Stack(
              children: [
                const Positioned.fill(
                  child: AppBackground(pattern: 'dots'),
                ),
                Positioned.fill(
                  child: _animatedScreen(),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18 + MediaQuery.paddingOf(context).bottom,
                  child: _NavBar(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _animatedScreen() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: const Interval(0.35, 1, curve: Curves.easeOutCubic),
      switchOutCurve: const Interval(0.6, 1, curve: Curves.easeOut),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(school.route),
        child: _screen(),
      ),
    );
  }

  Widget _screen() {
    switch (school.route) {
      case 'ai-plans':
        return const AiPlansScreen();
      case 'plan-detail':
        return const PlanDetailScreen();
      case 'stats':
        return const StatsScreen();
      case 'calendar':
        return const CalendarScreen();
      case 'home':
      default:
        return const HomeScreen();
    }
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar();

  static const _iw = 58.0;

  int get _selectedIndex {
    switch (school.route) {
      case 'home':
        return 0;
      case 'ai-plans':
      case 'plan-detail':
        return 1;
      case 'stats':
        return 2;
      case 'calendar':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sc = context.sc;

    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: sc.bgRaised,
        border: Border.all(color: sc.border),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Color(0x59000000), blurRadius: 32, offset: Offset(0, 12)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _item(context, 0, PhosphorIconsRegular.house, PhosphorIconsFill.house, 'Home', school.goHome),
            _item(context, 1, PhosphorIconsRegular.sparkle, PhosphorIconsFill.sparkle, 'Piano AI', school.goPlans),
            _fab(context),
            _item(context, 2, PhosphorIconsRegular.chartLineUp, PhosphorIconsFill.chartLineUp, 'Stats', school.goStats),
            _item(context, 3, PhosphorIconsRegular.calendarBlank, PhosphorIconsFill.calendarBlank, 'Calendario', school.goCalendar),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    int index,
    IconData icon,
    IconData iconFill,
    String label,
    VoidCallback onTap,
  ) {
    final sc = context.sc;
    final selected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: _iw,
        height: 54,
        decoration: BoxDecoration(
          color: selected ? sc.bgRaised2 : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: selected
              ? Border.all(color: sc.border.withValues(alpha: 0.6), width: 1)
              : Border.all(color: Colors.transparent, width: 1),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: sc.accent.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                selected ? iconFill : icon,
                key: ValueKey('${label}_$selected'),
                size: 22,
                color: selected ? sc.text : sc.textTertiary,
              ),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: AppTheme.s(
                    9.5,
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? sc.text : sc.textTertiary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fab(BuildContext context) {
    final sc = context.sc;
    return GestureDetector(
      onTap: () => showFocusPlanPickerSheet(context),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [sc.accent, sc.brass],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: sc.accent.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(PhosphorIconsFill.play, size: 24, color: sc.bg),
      ),
    );
  }
}

