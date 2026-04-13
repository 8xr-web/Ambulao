import 'package:flutter/material.dart';
import '../core/app_strings.dart';
import '../core/theme.dart';
import 'main_layout.dart';
import 'nurse_searching_screen.dart';
import '../core/transitions.dart';

enum NurseServiceType { general, postSurgery, elderly, icu }

class NurseBookingScreen extends StatefulWidget {
  const NurseBookingScreen({super.key});

  @override
  State<NurseBookingScreen> createState() => _NurseBookingScreenState();
}

class _NurseBookingScreenState extends State<NurseBookingScreen> {
  NurseServiceType _serviceType = NurseServiceType.general;
  int _durationHours = 4;
  int _selectedNurseIndex = 0;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isNow = true;

  final List<int> _durations = const [2, 4, 8, 12, 24];

  final Map<NurseServiceType, int> _hourlyRate = const {
    NurseServiceType.general: 299,
    NurseServiceType.postSurgery: 499,
    NurseServiceType.elderly: 399,
    NurseServiceType.icu: 799,
  };

  final List<_NurseCardModel> _nurses = const [
    _NurseCardModel(
      initials: 'SP',
      name: 'Sunita Priya',
      availabilityText: 'Available now',
      availabilityColor: Color(0xFF22C55E),
      experienceText: '5 yrs exp',
      rating: 4.9,
      sessions: 312,
      tags: ['ICU', 'Post-Surgery', 'Diabetic'],
      avatarBg: AppColors.primaryBlue,
    ),
    _NurseCardModel(
      initials: 'MR',
      name: 'Meena Rao',
      availabilityText: 'Available now',
      availabilityColor: Color(0xFF22C55E),
      experienceText: '8 yrs exp',
      rating: 4.8,
      sessions: 489,
      tags: ['Elderly', 'Palliative', 'Neuro'],
      avatarBg: Color(0xFF065F46),
    ),
    _NurseCardModel(
      initials: 'DK',
      name: 'Divya Kumari',
      availabilityText: 'In 30 min',
      availabilityColor: Color(0xFFEF4444),
      experienceText: '3 yrs exp',
      rating: 4.7,
      sessions: 198,
      tags: ['General', 'Pediatric'],
      avatarBg: Color(0xFF8B5A00),
    ),
  ];

  int get _totalPrice => _hourlyRate[_serviceType]! * _durationHours;

  String get _serviceLabel {
    switch (_serviceType) {
      case NurseServiceType.general:
        return AppStrings.generalCare;
      case NurseServiceType.postSurgery:
        return AppStrings.postSurgery;
      case NurseServiceType.elderly:
        return AppStrings.elderlyCare;
      case NurseServiceType.icu:
        return AppStrings.icuCare;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nurse = _nurses[_selectedNurseIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: Padding(
                padding: const EdgeInsets.only(bottom: MainLayout.bodyBottomPad + 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topBar(),
                    const SizedBox(height: 10),
                    _heroCard(),
                    const SizedBox(height: 12),
                    const Text(
                      AppStrings.chooseServiceType,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _serviceGrid(),
                    const SizedBox(height: 12),
                    const Text(
                      AppStrings.duration,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _durations.map((h) => _durationPill(h)).toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      AppStrings.availableNurses,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: List.generate(
                        _nurses.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _nurseCard(
                            _nurses[i],
                            selected: i == _selectedNurseIndex,
                            onTap: () => setState(() => _selectedNurseIndex = i),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppStrings.schedule,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildScheduleCard('date')),
                        const SizedBox(width: 10),
                        Expanded(child: _buildScheduleCard('time')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _verifiedBanner(),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _stickyBottomBar(
                summary: '$_serviceLabel · $_durationHours hrs · ${nurse.name.split(' ').first}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => MainLayout.homeNavKey.currentState?.pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          AppStrings.bookANurseTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A6FE8),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A6FE8).withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.professionalNurses,
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  AppStrings.professionalNursesSubtitle,
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                ),
                SizedBox(height: 8),
                _HeroPill(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _serviceCard(
                type: NurseServiceType.general,
                icon: Icons.monitor_heart_outlined,
                title: AppStrings.generalCare,
                subtitle: AppStrings.generalCareSubtitle,
                rate: _hourlyRate[NurseServiceType.general]!,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _serviceCard(
                type: NurseServiceType.postSurgery,
                icon: Icons.favorite_border,
                title: AppStrings.postSurgery,
                subtitle: AppStrings.postSurgerySubtitle,
                rate: _hourlyRate[NurseServiceType.postSurgery]!,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _serviceCard(
                type: NurseServiceType.elderly,
                icon: Icons.access_time,
                title: AppStrings.elderlyCare,
                subtitle: AppStrings.elderlyCareSubtitle,
                rate: _hourlyRate[NurseServiceType.elderly]!,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _serviceCard(
                type: NurseServiceType.icu,
                icon: Icons.verified_user_outlined,
                title: AppStrings.icuCare,
                subtitle: AppStrings.icuCareSubtitle,
                rate: _hourlyRate[NurseServiceType.icu]!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _serviceCard({
    required NurseServiceType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required int rate,
  }) {
    final bool selected = _serviceType == type;
    return GestureDetector(
      onTap: () => setState(() => _serviceType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7A99), height: 1.2),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            Text(
              '₹$rate / hr',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _durationPill(int hours) {
    final bool selected = _durationHours == hours;
    return GestureDetector(
      onTap: () => setState(() => _durationHours = hours),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? AppColors.primaryBlue : const Color(0xFFBFD3FF)),
        ),
        child: Text(
          '$hours hrs',
          style: TextStyle(
            color: selected ? Colors.white : AppColors.primaryBlue,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _nurseCard(_NurseCardModel model, {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : const Color(0xFFE5E7EB),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: model.avatarBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  model.initials,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          model.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.star, color: Color(0xFFFBBF24), size: 14),
                      const SizedBox(width: 2),
                      Text(
                        model.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: model.availabilityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '${model.availabilityText} · ${model.experienceText} · ${model.sessions} sessions',
                          style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: model.tags.map((t) => _tagChip(t)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4FF),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildScheduleCard(String type) {
    final isDate = type == 'date';
    String label, value;
    if (isDate) {
      label = AppStrings.dateLabel;
      if (_selectedDate == null) {
        value = 'Today, Mar 19';
      } else {
        final d = _selectedDate!;
        const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        value = '${d.day} ${months[d.month - 1]} ${d.year}';
      }
    } else {
      label = AppStrings.startTimeLabel;
      if (_isNow) {
        value = 'Now · ASAP';
      } else if (_selectedTime != null) {
        final h = _selectedTime!.hour.toString().padLeft(2, '0');
        final m = _selectedTime!.minute.toString().padLeft(2, '0');
        value = '$h:$m';
      } else {
        value = 'Tap to select';
      }
    }
    return GestureDetector(
      onTap: () async {
        if (isDate) {
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: const ColorScheme.light(primary: Color(0xFF1A6FE8)),
              ),
              child: child!,
            ),
          );
          if (picked != null) setState(() => _selectedDate = picked);
        } else {
          final picked = await showTimePicker(
            context: context,
            initialTime: _selectedTime ?? TimeOfDay.now(),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: const ColorScheme.light(primary: Color(0xFF1A6FE8)),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            setState(() {
              _selectedTime = picked;
              _isNow = false;
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBFD3FF)),
        ),
        child: Row(
          children: [
            Icon(
              isDate ? Icons.calendar_today : Icons.access_time,
              color: const Color(0xFF1A6FE8),
              size: 14,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verifiedBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE68A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline, color: Color(0xFF8A6A00), size: 18),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.verifiedBannerTitle,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF8A6A00)),
                ),
                SizedBox(height: 3),
                Text(
                  AppStrings.verifiedBannerBody,
                  style: TextStyle(fontSize: 11, color: Color(0xFF8A6A00), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stickyBottomBar({required String summary}) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -6),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    summary,
                    style: const TextStyle(color: Color(0xFF6B7A99), fontSize: 12, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '₹${_totalPrice.toString()}',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  MainLayout.homeNavKey.currentState?.push(
                    SmoothPageRoute(
                      page: NurseSearchingScreen(
                        serviceLabel: _serviceLabel,
                        durationHours: _durationHours,
                        nurseName: _nurses[_selectedNurseIndex].name,
                        totalPrice: _totalPrice,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                ),
                child: const Text(
                  AppStrings.confirmBookNurse,
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Text(
          AppStrings.available247,
          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _NurseCardModel {
  final String initials;
  final String name;
  final String availabilityText;
  final Color availabilityColor;
  final String experienceText;
  final double rating;
  final int sessions;
  final List<String> tags;
  final Color avatarBg;

  const _NurseCardModel({
    required this.initials,
    required this.name,
    required this.availabilityText,
    required this.availabilityColor,
    required this.experienceText,
    required this.rating,
    required this.sessions,
    required this.tags,
    required this.avatarBg,
  });
}
