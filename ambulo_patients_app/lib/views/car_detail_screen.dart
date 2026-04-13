import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/theme.dart';
import '../viewmodels/car_view_model.dart';
import '../widgets/primary_button.dart';
import 'package:provider/provider.dart';

class CarDetailScreen extends StatelessWidget {
  const CarDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final car = context.watch<CarViewModel>().selectedCar!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Map Background (Top half)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Container(
              color: Colors.grey[200],
              child: Stack(
                children: [
                  // Placeholder map visuals
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.3,
                      child: Image.network(
                        'https://img.freepik.com/free-vector/grey-world-map_1053-431.jpg', // Better map placeholder
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Route line (simulated)
                  Center(
                    child: Icon(Icons.show_chart,
                        size: 200, color: Colors.black.withValues(alpha: 0.5)),
                  ),
                  // Car Location Marker
                  const Positioned(
                    top: 150,
                    left: 150,
                    child:
                        Icon(Icons.location_on, size: 40, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, size: 28),
            ),
          ),

          // Top Right Filter Icon
          const Positioned(
            top: 50,
            right: 24,
            child: Icon(Icons.tune, size: 28),
          ),

          // Search overlay
          Positioned(
            top: 100,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(car.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('< 3km',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Colors.black, shape: BoxShape.circle),
                    child: const Icon(Icons.circle,
                        color: Colors.white, size: 12), // Placeholder for logo
                  )
                ],
              ),
            ),
          ),

          // Bottom Sheet (Draggable-like container)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue, // Changed to red for new theme
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ),

                  // Car Image (Overlapping logic would be complex, putting inside for simplicity)
                  Center(
                    child: Transform.translate(
                      offset: const Offset(0, -60),
                      child: Image.network(
                        car.imagePath.startsWith('http')
                            ? car.imagePath
                            : 'https://freepngimg.com/thumb/toyota/15-2-toyota-fortuner-png-picture.png',
                        height: 160,
                      ),
                    ),
                  ),

                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(car.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildInfoChip(
                                FontAwesomeIcons.locationArrow, car.distance),
                            const SizedBox(width: 16),
                            _buildInfoChip(Icons.local_gas_station, car.fuel),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text("Features",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFeatureBox(Icons.local_gas_station, 'Diesel',
                                'Common Rail Fuel Injection'),
                            _buildFeatureBox(
                                Icons.speed, 'Acceleration', car.acceleration),
                            _buildFeatureBox(
                                Icons.ac_unit, 'Cool', 'Temp Control'),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  car.price,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                  '/day',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                            const Spacer(),
                            PrimaryButton(
                              text: 'Book Now',
                              onTap: () {},
                              width: 160,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        )
      ],
    );
  }

  Widget _buildFeatureBox(IconData icon, String title, String subtitle) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 8),
              overflow: TextOverflow.ellipsis,
              maxLines: 2),
        ],
      ),
    );
  }
}
