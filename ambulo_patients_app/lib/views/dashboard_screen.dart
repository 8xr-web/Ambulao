import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/theme.dart';
import '../models/car_model.dart';
import '../viewmodels/car_view_model.dart';
import 'package:provider/provider.dart';
import 'car_detail_screen.dart';
import '../core/transitions.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CarViewModel>();
    final featuredCar = viewModel.cars[0]; // Fortuner

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTabItem(context, 'Information', true),
                  _buildTabItem(context, 'Notifications', false),
                ],
              ),
              const SizedBox(height: 32),

              const Text(
                'NEAREST CAR',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Featured Car
              GestureDetector(
                onTap: () {
                  viewModel.selectCar(featuredCar);
                  Navigator.push(
                    context,
                    SmoothPageRoute(
                        page: const CarDetailScreen()),
                  );
                },
                child: Image.network(
                  'https://freepngimg.com/thumb/toyota/15-2-toyota-fortuner-png-picture.png',
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                featuredCar.name,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  _buildInfoChip(
                      FontAwesomeIcons.locationArrow, featuredCar.distance),
                  const SizedBox(width: 16),
                  _buildInfoChip(FontAwesomeIcons.gasPump, featuredCar.fuel),
                  const Spacer(),
                  Text(
                    '${featuredCar.price}/h',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Profile & Map Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10),
                          ]),
                      child: const Column(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/150?img=11'),
                          ),
                          SizedBox(height: 12),
                          Text('Jane Cooper',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('\$ 4,253',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: 140, // Match height roughly
                        color: Colors.grey[200],
                        child: Stack(
                          children: [
                            // Placeholder map
                            const Center(
                                child: Opacity(
                                    opacity: 0.2,
                                    child: Icon(Icons.map, size: 64))),
                            Positioned(
                              right: 16,
                              top: 16,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.near_me,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // More Cars List
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue, // Changed to red for new theme
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('More Cars',
                              style: TextStyle(color: Colors.white54)),
                          Icon(Icons.more_horiz, color: Colors.white54),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // List Items
                      _buildDarkListItem(viewModel.cars[1]),
                      const SizedBox(height: 16),
                      _buildDarkListItem(viewModel.cars[2]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, String text, bool isActive) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isActive ? Colors.black : Colors.grey,
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        )
      ],
    );
  }

  Widget _buildDarkListItem(Car car) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(car.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildInfoChip(FontAwesomeIcons.locationArrow, car.distance),
                const SizedBox(width: 12),
                _buildInfoChip(
                    car.isElectric
                        ? FontAwesomeIcons.bolt
                        : FontAwesomeIcons.gasPump,
                    car.fuel),
              ],
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_forward, size: 16),
        ),
      ],
    );
  }
}
