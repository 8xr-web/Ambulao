import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/services/trip_service.dart';
import 'package:ambulao_driver/widgets/map_background_mock.dart';
import 'package:ambulao_driver/screens/trip_screen.dart';

class NavigateToHospitalScreen extends StatefulWidget {
  final String tripId;
  final String dropAddress;
  final double dropLat;
  final double dropLng;
  final String patientName;
  final double estimatedFare;

  const NavigateToHospitalScreen({
    super.key,
    required this.tripId,
    required this.dropAddress,
    required this.dropLat,
    required this.dropLng,
    required this.patientName,
    required this.estimatedFare,
  });

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  State<NavigateToHospitalScreen> createState() =>
      _NavigateToHospitalScreenState();
}

class _NavigateToHospitalScreenState extends State<NavigateToHospitalScreen> {
  bool _isLoading = false;

  Future<void> _startTrip() async {
    setState(() => _isLoading = true);
    try {
      await TripService.startTrip(widget.tripId);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TripScreen(
            tripId: widget.tripId,
            dropAddress: widget.dropAddress,
            patientName: widget.patientName,
            estimatedFare: widget.estimatedFare,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting trip: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: MapBackgroundMock(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Top destination card
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_hospital,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.dropAddress.isEmpty
                                  ? 'Hospital'
                                  : widget.dropAddress,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0A1F44),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Patient: ${widget.patientName}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Bottom card
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(
                      24,
                      24,
                      24,
                      MediaQuery.of(context).padding.bottom + 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fare + Patient row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Patient: ${widget.patientName}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0A1F44),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F2FF),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                '₹${widget.estimatedFare.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Navigate to Hospital button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => _showMapsActionSheet(
                                context, widget.dropLat, widget.dropLng),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.navigation, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Navigate to Hospital',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Start Trip button — calls TripService.startTrip
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: AppTheme.primaryBlue))
                              : TextButton(
                                  onPressed: _startTrip,
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.primaryBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(28),
                                    ),
                                  ),
                                  child: const Text(
                                    'Start Trip',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMapsActionSheet(BuildContext context, double lat, double lng) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFDDE3EE),
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Navigate with',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A1F44)),
            ),
            const SizedBox(height: 24),
            _buildMapOption(
              context,
              'Open in Google Maps',
              Icons.map_outlined,
              () {
                Navigator.pop(context);
                widget._launchUrl(
                    'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
              },
            ),
            const SizedBox(height: 12),
            _buildMapOption(
              context,
              'Open in Apple Maps',
              Icons.explore_outlined,
              () {
                Navigator.pop(context);
                widget._launchUrl('maps://?q=$lat,$lng');
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMapOption(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FBFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDDE3EE)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 28),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A1F44)),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
