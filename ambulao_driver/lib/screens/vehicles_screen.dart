import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  int _activeIndex = 0;

  final List<Map<String, String>> _vehicles = [
    {'title': 'Force Traveller Ambulance', 'plate': 'DL 3C AB 1234', 'type': 'Ambulance'},
    {'title': 'Maruti Suzuki Eeco', 'plate': 'TS 09 XY 9876', 'type': 'Van'},
  ];

  OverlayEntry? _toastOverlay;

  void _switchVehicle(int index) {
    if (index == _activeIndex) return;
    setState(() => _activeIndex = index);
    _showSwitchToast(_vehicles[index]['plate']!);
  }

  void _showSwitchToast(String plate) {
    _toastOverlay?.remove();
    final overlay = Overlay.of(context);
    _toastOverlay = OverlayEntry(
      builder: (_) => _VehicleToast(message: 'Vehicle switched to $plate'),
    );
    overlay.insert(_toastOverlay!);
    Future.delayed(const Duration(seconds: 2), () {
      _toastOverlay?.remove();
      _toastOverlay = null;
    });
  }

  void _showAddVehicleSheet() {
    final formKey = GlobalKey<FormState>();
    String? selectedType = 'Ambulance';
    final regController = TextEditingController();
    final modelController = TextEditingController();
    final yearController = TextEditingController();
    String? insuranceDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 48, height: 4,
                            decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Add New Vehicle',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44)),
                        ),
                        const SizedBox(height: 24),

                        // Vehicle Type dropdown
                        const Text('Vehicle Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FBFF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFDDE3EE)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedType,
                              isExpanded: true,
                              items: ['Bike', 'Auto', 'Ambulance', 'Van'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (v) => setLocal(() => selectedType = v),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0A1F44)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildInput('Registration Number', regController, 'e.g. TS 09 AB 1234'),
                        _buildInput('Vehicle Model', modelController, 'e.g. Force Traveller'),
                        _buildInput('Year of Manufacture', yearController, 'e.g. 2021', isNumber: true),

                        // Insurance Validity picker
                        const Text('Insurance Validity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: DateTime.now().add(const Duration(days: 365)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                              builder: (ctx, child) => Theme(
                                data: Theme.of(ctx).copyWith(
                                  colorScheme: const ColorScheme.light(primary: AppTheme.primaryBlue),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setLocal(() => insuranceDate = '${picked.day} ${_monthName(picked.month)} ${picked.year}');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FBFF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFDDE3EE)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    insuranceDate ?? 'Select date',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: insuranceDate != null ? const Color(0xFF0A1F44) : Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.calendar_today_outlined, color: AppTheme.primaryBlue, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              if (regController.text.isNotEmpty && modelController.text.isNotEmpty) {
                                Navigator.pop(ctx);
                                setState(() {
                                  _vehicles.add({
                                    'title': '${modelController.text} (${selectedType ?? 'Vehicle'})',
                                    'plate': regController.text.toUpperCase(),
                                    'type': selectedType ?? 'Vehicle',
                                  });
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              elevation: 0,
                            ),
                            child: const Text('Save Vehicle', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFDDE3EE), width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              foregroundColor: AppTheme.textSecondary,
                            ),
                            child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInput(String label, TextEditingController controller, String hint, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0A1F44)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w400),
            filled: true,
            fillColor: const Color(0xFFF9FBFF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFDDE3EE)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFDDE3EE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A1F44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Vehicles',
          style: TextStyle(color: Color(0xFF0A1F44), fontSize: 18, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            itemCount: _vehicles.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (_, i) {
              final v = _vehicles[i];
              final isActive = i == _activeIndex;
              return GestureDetector(
                onTap: () => _switchVehicle(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? AppTheme.primaryBlue : const Color(0xFFEBEFF8),
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Radio indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? AppTheme.primaryBlue : Colors.transparent,
                          border: Border.all(
                            color: isActive ? AppTheme.primaryBlue : const Color(0xFFDDE3EE),
                            width: 2,
                          ),
                        ),
                        child: isActive
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.directions_car, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v['title']!,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              v['plate']!,
                              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                            ),
                            if (isActive) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Active',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.successGreen),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Floating + Add Vehicle button
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _showAddVehicleSheet,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  '+ Add Vehicle',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  elevation: 8,
                  shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleToast extends StatefulWidget {
  final String message;
  const _VehicleToast({required this.message});
  @override
  State<_VehicleToast> createState() => _VehicleToastState();
}

class _VehicleToastState extends State<_VehicleToast> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) _ctrl.reverse();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 32, right: 32,
      child: SlideTransition(
        position: _slide,
        child: Material(
          borderRadius: BorderRadius.circular(50),
          elevation: 6,
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
