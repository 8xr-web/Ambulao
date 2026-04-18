import 'package:flutter/material.dart';

class TripCompletedPatientScreen extends StatelessWidget {
  final String tripId;
  final String driverName;
  final String ambulanceType;
  final String pickupAddress;
  final String dropAddress;
  final double totalFare;
  final String paymentMethod;

  const TripCompletedPatientScreen({
    Key? key,
    required this.tripId,
    required this.driverName,
    required this.ambulanceType,
    required this.pickupAddress,
    required this.dropAddress,
    required this.totalFare,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success icon
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD1FFE0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF34C759),
                        size: 56,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Trip Completed',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          color: Color(0xFF0040A0),
                        )),
                    const SizedBox(height: 8),
                    const Text('You have safely arrived',
                        style: TextStyle(
                          color: Color(0xFF6E6E73),
                          fontSize: 15,
                        )),
                    const SizedBox(height: 32),

                    // Bill card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x150040A0),
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text('Trip Summary',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Color(0xFF0040A0),
                              )),
                          const SizedBox(height: 16),
                          _billRow('Ambulance Type',
                              ambulanceType),
                          _billRow('Driver', driverName),
                          _billRow('From', pickupAddress),
                          _billRow('To', dropAddress),
                          _billRow('Payment',
                              paymentMethod.toUpperCase()),
                          const Divider(
                            color: Color(0xFFE0E8FF),
                            height: 24,
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Amount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Color(0xFF0040A0),
                                  )),
                              Text(
                                  '₹${totalFare.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24,
                                    color: Color(0xFF007AFF),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text('Trip ID: $tripId',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFC7C7CC),
                        )),
                  ],
                ),
              ),

              // Bottom buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text('Back to Home',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          )),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Rate this trip',
                        style: TextStyle(
                          color: Color(0xFF007AFF),
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _billRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                color: Color(0xFF6E6E73),
                fontSize: 13,
              )),
          const SizedBox(width: 16),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                )),
          ),
        ],
      ),
    );
  }
}
