import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/booking_args.dart';
import 'home_screen.dart';
import 'location_selection_screen.dart';
import 'ambulance_selection_screen.dart';
import 'searching_screen.dart';
import 'ambulance_assigned_screen.dart';
import 'booking_history_screen.dart';
import 'profile_screen.dart';
import 'panic_mode_screen.dart';
import '../core/transitions.dart';

class MainLayout extends StatefulWidget {
  static final GlobalKey<NavigatorState> homeNavKey = GlobalKey<NavigatorState>();
  /// Bottom padding needed so screen content never hides under the nav pill.
  /// Per spec: 64px pill + 0px raised button + 16px clearance = 80px.
  static const double bodyBottomPad = 80.0;
  const MainLayout({super.key});

  static MainLayoutState? of(BuildContext context) => context.findAncestorStateOfType<MainLayoutState>();

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> with SingleTickerProviderStateMixin {
  void switchToHome() {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
    }
  }

  void switchToProfile() {
    if (_currentIndex != 2) {
      setState(() => _currentIndex = 2);
    }
  }
  int _currentIndex = 0;
  late AnimationController _pulseController;

  // Layout constants — single source of truth
  static const double _pillHeight = 64.0;
  static const double _emDiameter = 52.0;          // red circle
  static const double _emRaise = 0.0;              // px it rises above pill top edge
  static const double _pillBottomMargin = 20.0;     // gap from screen bottom
  // Total nav bar visual height = pill + how much button rises above pill
  static const double _navTotalHeight = _pillHeight + _emRaise;
  // Body bottom padding = nav height + extra clearance


  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1, milliseconds: 500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) {
      if (index == 0) MainLayout.homeNavKey.currentState?.popUntil((r) => r.isFirst);
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _openPanicMode() {
    Navigator.of(context, rootNavigator: true).push(
      SmoothPageRoute(page: const PanicModeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: Stack(
        children: [
          // ── Page content layer ──
          // Body gets bottom padding so pill never overlaps it
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: MainLayout.bodyBottomPad),
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  Navigator(
                    key: MainLayout.homeNavKey,
                    onGenerateRoute: (settings) {
                      Widget page;
                      switch (settings.name) {
                        case '/':
                          page = const HomeScreen();
                          break;
                        case '/search':
                          page = LocationSelectionScreen(ambulanceType: settings.arguments as String? ?? 'BLS');
                          break;
                        case '/book':
                          page = AmbulanceSelectionScreen(args: settings.arguments as BookingArgs? ?? const BookingArgs());
                          break;
                        case '/finding':
                          page = SearchingScreen(args: settings.arguments as BookingArgs? ?? const BookingArgs());
                          break;
                        case '/assigned':
                          page = AmbulanceAssignedScreen(args: settings.arguments as BookingArgs? ?? const BookingArgs());
                          break;
                        default:
                          page = const HomeScreen();
                      }
                      return PageRouteBuilder(
                        pageBuilder: (_, __, ___) => page,
                        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                      );
                    },
                  ),
                  const BookingHistoryScreen(),
                  const ProfileScreen(heroTag: 'profile_photo_tab'),
                ],
              ),
            ),
          ),

          // ── Floating Nav Pill ──
          // The pill sits at bottom with _pillBottomMargin clearance.
          // The emergency button rises _emRaise px above the pill — this space is
          // INSIDE the bodyBottomPad so page content is never obscured.
          Positioned(
            left: 24, right: 24,
            bottom: _pillBottomMargin,
            child: _buildNavPill(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavPill() {
    // The pill widget is a Stack:
    //   height = _pillHeight + _emRaise  (extra space at top for raised button)
    //   pill background fills bottom _pillHeight
    //   emergency button is centered horizontally in slot-1, aligned at top of pill (rises up)
    return SizedBox(
      height: _navTotalHeight,
      child: LayoutBuilder(builder: (context, constraints) {
        final double pillWidth = constraints.maxWidth;
        final double slotW = pillWidth / 4;

        // Animated indicator: maps logical tab index to physical slot
        // Tab 0=Home(slot0), Tab1=Activity(slot2), Tab2=Account(slot3)
        final int physSlot = _currentIndex == 0 ? 0 : _currentIndex + 1;
        final double indicatorLeft = physSlot * slotW + slotW / 2 - 24;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // ── White Pill (bottom _pillHeight of this SizedBox) ──
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: _pillHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(color: Color.fromRGBO(26, 111, 232, 0.15), blurRadius: 20, offset: Offset(0, 5)),
                  ],
                ),
              ),
            ),

            // ── Sliding Active Indicator ──
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              bottom: (_pillHeight - 48) / 2,
              left: indicatorLeft,
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.12), shape: BoxShape.circle),
              ),
            ),

            // ── Nav Icon Row (fills pill area only) ──
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: SizedBox(
                height: _pillHeight,
                child: Row(
                  children: [
                    Expanded(child: _buildNavItem(0, Icons.home_filled, 'Home')),
                    // Center slot: empty — emergency button drawn on top
                    const Expanded(child: SizedBox()),
                    Expanded(child: _buildNavItem(1, Icons.history, 'Activity')),
                    Expanded(child: _buildNavItem(2, Icons.person, 'Account')),
                  ],
                ),
              ),
            ),

            // ── Emergency Button ──
            // Horizontally centered in slot 1.
            // Vertically centered inside the 64px pill despite its 76px pulsing bounds.
            Positioned(
              top: (_pillHeight - (_emDiameter + 24)) / 2,
              left: slotW + slotW / 2 - _emDiameter / 2 - 4, // -4 to account for white ring
              child: GestureDetector(
                onTap: _openPanicMode,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final double p = _pulseController.value;
                    return SizedBox(
                      // include pulsing ring space
                      width: _emDiameter + 24,
                      height: _emDiameter + 24,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulsing halo ring
                          Container(
                            width: _emDiameter + 8 + 16 * p,
                            height: _emDiameter + 8 + 16 * p,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF04438).withValues(alpha: 0.10 * (1 - p)),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // White border ring (4px)
                          Container(
                            width: _emDiameter + 8,
                            height: _emDiameter + 8,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                          // Red circle with !
                          child!,
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: _emDiameter,
                    height: _emDiameter,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF04438),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color.fromRGBO(240, 68, 56, 0.30), blurRadius: 12, spreadRadius: 1, offset: Offset(0, 4))],
                    ),
                    child: const Center(child: Icon(Icons.priority_high, color: Colors.white, size: 30)),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool sel = _currentIndex == index;
    final Color color = sel ? AppColors.primaryBlue : const Color(0xFF6B7A99);
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}
