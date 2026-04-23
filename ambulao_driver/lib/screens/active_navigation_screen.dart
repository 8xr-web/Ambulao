import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/screens/pin_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ActiveNavigationScreen extends StatefulWidget {
  final String tripId;
  final String patientName;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropAddress;
  final double dropLat;
  final double dropLng;
  final double estimatedFare;
  final String patientPhone;

  const ActiveNavigationScreen({
    super.key,
    required this.tripId,
    required this.patientName,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropAddress,
    required this.dropLat,
    required this.dropLng,
    required this.estimatedFare,
    required this.patientPhone,
  });

  @override
  State<ActiveNavigationScreen> createState() =>
      _ActiveNavigationScreenState();
}

class _ActiveNavigationScreenState extends State<ActiveNavigationScreen> {
  GoogleMapController? _mapController;

  Set<Marker> get _markers => {
    Marker(
      markerId: const MarkerId('pickup'),
      position: LatLng(widget.pickupLat, widget.pickupLng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: 'Pickup — ${widget.patientName}',
        snippet: widget.pickupAddress,
      ),
    ),
  };

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Full-screen GoogleMap ─────────────────────────────────────────
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.pickupLat, widget.pickupLng),
                zoom: 15,
              ),
              onMapCreated: (c) => _mapController = c,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              // All gesture defaults are true — do not disable
            ),
          ),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
              // Top pickup address card
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
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.location_pin,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.pickupAddress.isEmpty
                                  ? 'Pickup Location'
                                  : widget.pickupAddress,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0A1F44)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Picking up ${widget.patientName}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary),
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
                  // Navigate to Patient pill
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 20),
                      child: GestureDetector(
                        onTap: () => _showMapsActionSheet(
                            context, widget.pickupLat, widget.pickupLng),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      AppTheme.primaryBlue.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.navigation,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('Navigate to Patient',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom info card
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 24,
                            spreadRadius: 2)
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(
                        24, 20, 24, MediaQuery.of(context).padding.bottom + 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                                color: const Color(0xFFDDE3EE),
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Picking up ${widget.patientName}',
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0A1F44)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.pickupAddress,
                          style: const TextStyle(
                              fontSize: 14, color: AppTheme.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 20),

                        // Patient info row
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  shape: BoxShape.circle),
                              child: Center(
                                child: Text(
                                  widget.patientName.isNotEmpty
                                      ? widget.patientName[0].toUpperCase()
                                      : 'P',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.patientName,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0A1F44))),
                                  const Text('Patient',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            // Call button
                            GestureDetector(
                              onTap: () => _showCallSheet(
                                  context,
                                  widget.patientName,
                                  widget.patientPhone),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                    color: AppTheme.primaryBlue,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.phone,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Chat button
                            GestureDetector(
                              onTap: () => _showChatSheet(
                                  context, widget.patientName),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppTheme.primaryBlue, width: 1.5),
                                ),
                                child: const Icon(Icons.chat_bubble,
                                    color: AppTheme.primaryBlue, size: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // I've Arrived button → PIN verification before starting trip
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PinScreen(
                                    tripId: widget.tripId,
                                    patientName: widget.patientName,
                                    dropAddress: widget.dropAddress,
                                    dropLat: widget.dropLat,
                                    dropLng: widget.dropLng,
                                    estimatedFare: widget.estimatedFare,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28)),
                              elevation: 0,
                            ),
                            child: const Text("I've Arrived",
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],           // inner Column.children
                    ),             // inner Column
                  ),               // Container (bottom card)
                ],                 // outer Column.children
              ),                   // outer Column
            ],                     // inner Stack.children
          ),                       // inner Stack
        ),                         // SafeArea
      ],                           // outer Stack.children
    ),                             // outer Stack (Scaffold body)
  );
  }

  void _showCallSheet(BuildContext context, String name, String phone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFDDE3EE),
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue,
                border: Border.all(color: const Color(0xFF34C759), width: 3),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'P',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(name,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A1F44))),
            const Text('Patient',
                style:
                    TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  if (phone.isNotEmpty) _launchUrl('tel:$phone');
                },
                icon: const Icon(Icons.phone, color: Colors.white),
                label: Text('Call $name',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34C759),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatSheet(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChatSheet(patientName: name),
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
            const Text('Navigate with',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A1F44))),
            const SizedBox(height: 24),
            _buildMapOption(context, 'Open in Google Maps', Icons.map_outlined,
                () {
              Navigator.pop(context);
              _launchUrl(
                  'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
            }),
            const SizedBox(height: 12),
            _buildMapOption(
                context, 'Open in Apple Maps', Icons.explore_outlined, () {
              Navigator.pop(context);
              _launchUrl('maps://?q=$lat,$lng');
            }),
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
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMapOption(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF0F4FF),
          foregroundColor: AppTheme.primaryBlue,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _ChatSheet extends StatefulWidget {
  final String patientName;
  const _ChatSheet({required this.patientName});

  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  final List<String> _messages = [];
  final TextEditingController _textCtrl = TextEditingController();

  final List<String> _quickReplies = [
    "I've Arrived 🚑",
    "On My Way ⏱",
    "Please Come Outside 🚪",
    "5 Minutes Away ⏳",
    "Call Me 📞",
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() => _messages.add(text.trim()));
    _textCtrl.clear();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                    color: const Color(0xFFDDE3EE),
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Color(0xFFF0F4FF), width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                      color: AppTheme.primaryBlue, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      widget.patientName.isNotEmpty
                          ? widget.patientName[0].toUpperCase()
                          : 'P',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.patientName,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0A1F44))),
                    const Text('Patient',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child:
                      const Icon(Icons.close, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Start the conversation 💬',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                        child: Text(_messages[i],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14)),
                      ),
                    ),
                  ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _sendMessage(_quickReplies[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: const Color(0xFFDDE3EE)),
                  ),
                  child: Text(_quickReplies[i],
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0A1F44))),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    style: const TextStyle(
                        fontSize: 15, color: Color(0xFF0A1F44)),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: const Color(0xFFF5F8FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _sendMessage(_textCtrl.text),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                        color: AppTheme.primaryBlue, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_upward,
                        color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
