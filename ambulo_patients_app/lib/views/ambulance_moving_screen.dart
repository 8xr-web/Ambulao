import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'trip_completed_patient_screen.dart';

class AmbulanceMovingScreen extends StatefulWidget {
  final String tripId;
  final String driverName;
  final String dropAddress;
  final double estimatedFare;

  const AmbulanceMovingScreen({
    Key? key,
    required this.tripId,
    required this.driverName,
    required this.dropAddress,
    required this.estimatedFare,
  }) : super(key: key);

  @override
  State<AmbulanceMovingScreen> createState() =>
      _AmbulanceMovingScreenState();
}

class _AmbulanceMovingScreenState
    extends State<AmbulanceMovingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripId)
            .snapshots(),
        builder: (context, snapshot) {
          // Check if trip completed
          if (snapshot.hasData && snapshot.data!.exists) {
            final data =
                snapshot.data!.data() as Map<String, dynamic>;
            if (data['status'] == 'completed') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripCompletedPatientScreen(
                      tripId: widget.tripId,
                      driverName: widget.driverName,
                      ambulanceType:
                          data['ambulance_type'] as String? ?? 'BLS',
                      pickupAddress:
                          (data['pickup'] as Map<String, dynamic>?)?['address'] as String? ?? '',
                      dropAddress:
                          (data['destination'] as Map<String, dynamic>?)?['address'] as String? ?? '',
                      totalFare: ((data['final_fare'] ??
                              data['estimated_fare'] ?? 350.0) as num)
                          .toDouble(),
                      paymentMethod:
                          data['payment_method'] as String? ?? 'cash',
                    ),
                  ),
                );
              });
            }
          }

          return SafeArea(
            child: Column(
              children: [
                // Map placeholder — replace with Google Maps
                Expanded(
                  flex: 3,
                  child: Container(
                    color: const Color(0xFFDCE8F8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🚑',
                              style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          const Text('Ambulance is on the way',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Color(0xFF0040A0),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom card
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(
                            top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFF34C759),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Ambulance Moving',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: Color(0xFF0040A0),
                              )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Driver: ${widget.driverName}',
                          style: const TextStyle(
                            color: Color(0xFF6E6E73),
                            fontSize: 14,
                          )),
                      const SizedBox(height: 4),
                      Text(
                          'Heading to: ${widget.dropAddress}',
                          style: const TextStyle(
                            color: Color(0xFF6E6E73),
                            fontSize: 14,
                          )),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F2FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Estimated Fare',
                                style: TextStyle(
                                  color: Color(0xFF6E6E73),
                                  fontWeight: FontWeight.w600,
                                )),
                            Text(
                                '₹${widget.estimatedFare.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Color(0xFF0040A0),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
