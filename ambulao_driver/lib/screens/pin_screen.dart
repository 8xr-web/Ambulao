import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/screens/navigate_to_hospital_screen.dart';

class PinScreen extends StatefulWidget {
  final String tripId;
  final String patientName;
  final String dropAddress;
  final double dropLat;
  final double dropLng;
  final double estimatedFare;

  const PinScreen({
    super.key,
    this.tripId = '',
    this.patientName = 'Patient',
    this.dropAddress = '',
    this.dropLat = 0,
    this.dropLng = 0,
    this.estimatedFare = 350.0,
  });

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final List<String> _digits = [];

  void _onKey(String val) {
    if (_digits.length < 4) {
      setState(() => _digits.add(val));
      if (_digits.length == 4) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => NavigateToHospitalScreen(
                tripId: widget.tripId,
                dropAddress: widget.dropAddress,
                dropLat: widget.dropLat,
                dropLng: widget.dropLng,
                patientName: widget.patientName,
                estimatedFare: widget.estimatedFare,
              ),
            ),
          );
        });
      }
    }
  }

  void _onDelete() {
    if (_digits.isNotEmpty) {
      setState(() => _digits.removeLast());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF0A1F44),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Enter Patient's PIN",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A1F44),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ask the patient for the 4-digit PIN',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < _digits.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: filled
                            ? AppTheme.primaryBlue
                            : const Color(0xFFDDE3EE),
                        width: filled ? 2 : 1.5,
                      ),
                      boxShadow: filled
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryBlue
                                    .withValues(alpha: 0.12),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: filled
                          ? Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              // Numpad
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...['1', '2', '3', '4', '5', '6', '7', '8', '9']
                        .map((n) => _buildKey(n)),
                    const SizedBox(),
                    _buildKey('0'),
                    _buildDeleteKey(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String val) {
    return GestureDetector(
      onTap: () => _onKey(val),
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            val,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A1F44),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return GestureDetector(
      onTap: _onDelete,
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            color: AppTheme.textSecondary,
            size: 22,
          ),
        ),
      ),
    );
  }
}
