import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/screens/personal_info_screen.dart';
import 'package:ambulao_driver/screens/driving_preferences_screen.dart';
import 'package:ambulao_driver/screens/emergency_contacts_screen.dart';
import 'package:ambulao_driver/screens/security_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileUrl();
  }

  Future<void> _loadProfileUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _photoUrl = prefs.getString('profile_photo_url');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalInfoScreen())),
              icon: const Icon(Icons.edit, size: 18, color: AppTheme.primaryBlue),
              label: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryBlue)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            _ProfileHeader(
              photoUrl: _photoUrl, 
              onPhotoChanged: (url) => setState(() => _photoUrl = url),
            ),
            const SizedBox(height: 24),

            // Section 1: Personal Information
            _buildSection(
              title: 'PERSONAL INFORMATION',
              children: [
                _buildInfoRow(Icons.person_outline, 'Name', 'Syed Rayan Hussaini'),
                _buildInfoRow(Icons.phone_outlined, 'Phone', '+91 98765 43210'),
                _buildInfoRow(Icons.email_outlined, 'Email', 'rayan@ambulao.com'),
                _buildInfoRow(Icons.medical_services_outlined, 'Ambulance', 'TS-09-EA-1234 (ALS)'),
              ],
            ),
            const SizedBox(height: 20),

            // Section 2: Statistics
            _buildSection(
              title: 'STATISTICS',
              children: [
                _buildStatRow(Icons.currency_rupee, 'Total Earnings', '₹48,250'),
                _buildStatRow(Icons.route, 'Total Trips', '248'),
                _buildStatRow(Icons.star_outline, 'Rating', '4.92'),
              ],
            ),
            const SizedBox(height: 20),

            // Section 3: Settings
            _buildSection(
              title: 'SETTINGS',
              children: [
                _buildNavRow(Icons.health_and_safety_outlined, 'Emergency Contacts', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyContactsScreen()));
                }),
                _buildNavRow(Icons.drive_eta_outlined, 'Driving Preferences', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DrivingPreferencesScreen()));
                }),
                _buildNavRow(Icons.language_outlined, 'Language', () {
                  // Show language selection
                }, trailing: 'English'),
              ],
            ),
            const SizedBox(height: 20),

            // Section 4: Security
            _buildSection(
              title: 'SECURITY',
              children: [
                _buildNavRow(Icons.security, 'Security', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityScreen()));
                }),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textSecondary, letterSpacing: 1.0),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0A1F44))),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildNavRow(IconData icon, String label, VoidCallback onTap, {String? trailing, bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isDestructive ? AppTheme.criticalRed : AppTheme.primaryBlue),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDestructive ? AppTheme.criticalRed : const Color(0xFF0A1F44),
              ),
            ),
            const Spacer(),
            if (trailing != null)
              Text(trailing, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: isDestructive ? AppTheme.criticalRed.withValues(alpha: 0.5) : AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String? photoUrl;
  final Function(String?) onPhotoChanged;

  const _ProfileHeader({required this.photoUrl, required this.onPhotoChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfilePhotoWidget(photoUrl: photoUrl, onPhotoChanged: onPhotoChanged),
        const SizedBox(height: 16),
        const Text(
          'Syed Rayan Hussaini',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0A1F44)),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFE8F2FF), borderRadius: BorderRadius.circular(50)),
          child: const Text('Gold Partner • 4.92 ★', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue)),
        ),
      ],
    );
  }
}

class ProfilePhotoWidget extends StatefulWidget {
  final String? photoUrl;
  final Function(String?) onPhotoChanged;

  const ProfilePhotoWidget({super.key, required this.photoUrl, required this.onPhotoChanged});

  @override
  State<ProfilePhotoWidget> createState() => _ProfilePhotoWidgetState();
}

class _ProfilePhotoWidgetState extends State<ProfilePhotoWidget> {
  bool get _hasPhoto => widget.photoUrl != null && widget.photoUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _showPhotoOptions(context),
          child: Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2FF),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryBlue, width: 2),
              boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: 5)],
              image: _hasPhoto ? DecorationImage(image: NetworkImage(widget.photoUrl!), fit: BoxFit.cover) : null,
            ),
            child: !_hasPhoto ? const Icon(Icons.person, size: 44, color: AppTheme.primaryBlue) : null,
          ),
        ),

        Positioned(
          bottom: 0, right: 0,
          child: GestureDetector(
            onTap: () => _showPhotoOptions(context),
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE8F2FF), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.edit, size: 14, color: AppTheme.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2))),
            const Text('Profile Photo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0040A0))),
            const SizedBox(height: 16),
            _photoOption(icon: Icons.camera_alt, label: 'Take Photo', onTap: () async { Navigator.pop(ctx); await _pickAndUpload(ImageSource.camera); }),
            const SizedBox(height: 8),
            _photoOption(icon: Icons.photo_library, label: 'Choose from Gallery', onTap: () async { Navigator.pop(ctx); await _pickAndUpload(ImageSource.gallery); }),
            
            if (_hasPhoto) ...[
              const SizedBox(height: 8),
              _photoOption(icon: Icons.delete_outline, label: 'Remove Photo', color: const Color(0xFFFF3B30), onTap: () async { Navigator.pop(ctx); await _removePhoto(); }),
            ],
            
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF6E6E73))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoOption({required IconData icon, required String label, Color color = const Color(0xFF0A1F44), required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final permission = source == ImageSource.camera ? await Permission.camera.request() : await Permission.photos.request();
    if (!permission.isGranted) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 800, maxHeight: 800);
    if (image == null) return;

    _showUploadingDialog();

    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('driver_uid') ?? '';
      
      final refName = uid.isNotEmpty ? uid : DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref('profile_photos/$refName.jpg');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();

      if (uid.isNotEmpty) {
        await FirebaseFirestore.instance.collection('drivers').doc(uid).update({'photoUrl': url});
      }

      await prefs.setString('profile_photo_url', url);
      if (mounted) Navigator.pop(context); // dismiss loading
      widget.onPhotoChanged(url);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed. Try again.')));
      }
    }
  }

  Future<void> _removePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('driver_uid') ?? '';
    
    if (uid.isNotEmpty) {
      await FirebaseFirestore.instance.collection('drivers').doc(uid).update({'photoUrl': FieldValue.delete()});
    }
    await prefs.remove('profile_photo_url');
    widget.onPhotoChanged(null);
  }

  void _showUploadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryBlue),
              SizedBox(height: 12),
              Text('Uploading photo...', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0A1F44))),
            ],
          ),
        ),
      ),
    );
  }
}
