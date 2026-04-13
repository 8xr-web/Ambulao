import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../core/transitions.dart';
import '../models/booking_args.dart';
import 'main_layout.dart';
import 'searching_screen.dart';

class AmbulanceSelectionScreen extends StatefulWidget {
  final BookingArgs args;
  const AmbulanceSelectionScreen({super.key, required this.args});

  @override
  State<AmbulanceSelectionScreen> createState() => _AmbulanceSelectionScreenState();
}

class _AmbulanceSelectionScreenState extends State<AmbulanceSelectionScreen>
    with TickerProviderStateMixin {
  late String _selectedAmbulance;
  String _whoNeedsHelp = 'Self';
  final Set<String> _selectedConditions = {};
  final TextEditingController _someoneElseController = TextEditingController();
  bool _showSomeoneElseField = false;
  String? _someoneElseError;

  final List<String> conditions = [
    'Accident',
    'Cardiac',
    'Breathing',
    'Maternity',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _selectedAmbulance = widget.args.ambulanceType; // Pre-select from args
    if (_selectedAmbulance == 'LastRide') {
      _whoNeedsHelp = 'Self';
    }
  }

  @override
  void dispose() {
    _someoneElseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
            onPressed: () => MainLayout.homeNavKey.currentState?.pop(),
          ),
        ),
        title: Text(
          _selectedAmbulance == 'LastRide' ? 'Book LastRide' : 'Book Ambulance',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primaryBlue, size: 20),
                          const SizedBox(width: 8),
                          Text(widget.args.pickup, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.arrow_forward, color: Color(0xFF9CA3AF), size: 16),
                          ),
                          const Icon(Icons.business_outlined, color: AppColors.primaryBlue, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(widget.args.destination, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text("3.2 km • ~8 min", style: TextStyle(color: Color(0xFF6E6E73), fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text("Choose Ambulance Type", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildAmbulanceCard(
                  'BLS',
                  'BLS – Basic Life Support',
                  'Oxygen • Stretcher • First Aid',
                  '₹499',
                  '4 min',
                  icon: Icons.medical_services_outlined,
                ),
                const SizedBox(height: 12),
                _buildAmbulanceCard(
                  'ALS',
                  'ALS – Advanced Life Support',
                  'ICU-equipped • Paramedic • Defib',
                  '₹999',
                  '6 min',
                  icon: Icons.favorite_border,
                ),
                const SizedBox(height: 12),
                _buildAmbulanceCard(
                  'Bike',
                  'Ambu Bike',
                  'Fastest • Traffic-beating • 1st responder',
                  '₹199',
                  '2 min',
                  icon: Icons.pedal_bike,
                ),
                const SizedBox(height: 12),
                _buildAmbulanceCard(
                  'LastRide',
                  'LastRide — Mortuary Service',
                  'Dignified transport · Handled with care',
                  '₹799 base',
                  '',
                  icon: Icons.airport_shuttle_outlined,
                  mutedStyle: true,
                  showEta: false,
                ),
                const SizedBox(height: 8),
                if (_selectedAmbulance == 'LastRide')
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Need to find a crematorium or burial ground?',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7A99),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final uri = Uri.parse(
                                'https://maps.google.com/?q=crematorium+near+me');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          child: const Text(
                            'Open in Maps',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                const Text("Who needs help?",
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildHelpToggle('Self')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildHelpToggle('Someone Else')),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: _showSomeoneElseField
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            const Text(
                              "Their mobile number",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildSomeoneElseField(),
                            if (_someoneElseError != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                _someoneElseError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                if (_selectedAmbulance != 'LastRide') ...[
                  const Text("Patient Condition", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12, runSpacing: 12,
                    children: conditions.map((c) => _buildConditionChip(c)).toList(),
                  ),
                ],
              ],
            ),
          ),

          // ── Pinned Confirm Button (Fix 8) ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: ElevatedButton(
                    onPressed: () {
                      final trimmedPhone = _whoNeedsHelp == 'Someone Else'
                          ? _someoneElseController.text.replaceAll(RegExp(r'\D'), '')
                          : null;

                      if (_whoNeedsHelp == 'Someone Else') {
                        if (trimmedPhone == null || trimmedPhone.length < 10) {
                          setState(() {
                            _someoneElseError = 'Please enter a 10-digit mobile number';
                          });
                          return;
                        }
                      }

                      final updatedArgs = BookingArgs(
                        ambulanceType: _selectedAmbulance,
                        pickup: widget.args.pickup,
                        destination: widget.args.destination,
                        forPhone: trimmedPhone,
                      );
                      MainLayout.homeNavKey.currentState?.push(
                        SmoothPageRoute(page: SearchingScreen(args: updatedArgs)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Confirm & Find Ambulance",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbulanceCard(
    String id,
    String title,
    String subtitle,
    String price,
    String eta, {
    required IconData icon,
    bool mutedStyle = false,
    bool showEta = true,
  }) {
    final isSelected = _selectedAmbulance == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedAmbulance = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEEF4FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? (mutedStyle
                    ? const Color(0xFF8A9AB5)
                    : AppColors.primaryBlue)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: (mutedStyle
                        ? const Color(0xFF8A9AB5)
                        : AppColors.primaryBlue)
                    .withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: mutedStyle
                    ? const Color(0xFFF3F4F6)
                    : (isSelected
                        ? AppColors.primaryBlue
                        : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: mutedStyle
                    ? const Color(0xFF9CA3AF)
                    : (isSelected ? Colors.white : AppColors.primaryBlue),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: mutedStyle
                          ? const Color(0xFF8A9AB5)
                          : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF6E6E73), fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (showEta)
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        color: Color(0xFF6E6E73),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        eta,
                        style: const TextStyle(
                          color: Color(0xFF6E6E73),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else
                  const Text(
                    'Scheduled service',
                    style: TextStyle(
                      color: Color(0xFF6E6E73),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpToggle(String label) {
    final isSelected = _whoNeedsHelp == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _whoNeedsHelp = label;
          if (label == 'Self') {
            _showSomeoneElseField = false;
            _someoneElseController.clear();
            _someoneElseError = null;
          } else {
            _showSomeoneElseField = true;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : const Color(0xFFE5E7EB),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSomeoneElseField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _someoneElseError == null
              ? const Color(0xFFD6E4FF)
              : Colors.redAccent,
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              '+91',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _someoneElseController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter mobile number',
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),
              onChanged: (_) {
                if (_someoneElseError != null) {
                  setState(() {
                    _someoneElseError = null;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionChip(String label) {
    final isSelected = _selectedConditions.contains(label);
    return GestureDetector(
      onTap: () => setState(() {
        if (isSelected) { _selectedConditions.remove(label); }
        else { _selectedConditions.add(label); }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: isSelected ? AppColors.primaryBlue : const Color(0xFFE5E7EB)),
          boxShadow: [if (isSelected) BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
      ),
    );
  }
}
