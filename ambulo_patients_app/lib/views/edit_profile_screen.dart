import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/user_provider.dart';
import 'change_phone_screen.dart';
import '../core/transitions.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  // Pre-fill with current user data from Provider
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>();
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _dobController = TextEditingController(text: user.dob);
    _addressController = TextEditingController(text: user.address);
    _selectedGender = user.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: Column(children: [

        // BLUE HEADER — same style as profile screen
        Container(
          color: const Color(0xFF1A6FE8),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(children: [

                // Back + title + Save button row
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text('Edit Profile',
                    style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.w700, color: Colors.white)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _saveProfile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text('Save',
                        style: TextStyle(color: Color(0xFF1A6FE8),
                          fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),

                // Avatar with camera icon
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4), width: 2),
                      ),
                      child: Consumer<UserProvider>(
                        builder: (_, user, __) => user.photoPath != null && user.photoPath!.isNotEmpty
                          ? ClipOval(child: kIsWeb
                              ? Image.network(user.photoPath!, width: 80, height: 80, fit: BoxFit.cover)
                              : Image.file(File(user.photoPath!), width: 80, height: 80, fit: BoxFit.cover))
                          : Center(child: Text(
                              context.read<UserProvider>().initials,
                              style: const TextStyle(color: Colors.white,
                                fontSize: 26, fontWeight: FontWeight.w700))),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1A6FE8), width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                          color: Color(0xFF1A6FE8), size: 14),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 6),
                Text('Tap to change photo',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12)),

              ]),
            ),
          ),
        ),

        // FORM
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [

              // Full Name
              _inputField('Full Name', _nameController,
                Icons.person_outline_rounded, TextInputType.name),

              // Phone — read only, tap Change to go to ChangePhoneScreen
              Consumer<UserProvider>(
                builder: (context, user, child) {
                  return _inputField('Mobile Number',
                    TextEditingController(text: '+91 ${user.phone}'),
                    Icons.phone_outlined, TextInputType.phone,
                    readOnly: true,
                    suffix: GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                          SmoothPageRoute(
                            page: const ChangePhoneScreen()));
                      },
                      child: const Text('Change',
                        style: TextStyle(color: Color(0xFF1A6FE8),
                          fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  );
                }
              ),

              // Email
              _inputField('Email Address', _emailController,
                Icons.email_outlined, TextInputType.emailAddress,
                hint: 'Enter email (optional)'),

              // Date of Birth — opens date picker
              _inputField('Date of Birth', _dobController,
                Icons.cake_outlined, TextInputType.none,
                hint: 'DD / MM / YYYY',
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(1990),
                    firstDate: DateTime(1920),
                    lastDate: DateTime.now(),
                    builder: (ctx, child) => Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF1A6FE8))),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    setState(() {
                      _dobController.text =
                        '${picked.day.toString().padLeft(2,'0')} / '
                        '${picked.month.toString().padLeft(2,'0')} / '
                        '${picked.year}';
                    });
                  }
                },
              ),

              // Gender toggle
              const SizedBox(height: 4),
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE8EFF8), width: 1.5),
                ),
                child: Row(
                  children: ['Male','Female','Other'].map((g) =>
                    Expanded(child: GestureDetector(
                      onTap: () => setState(() => _selectedGender = g),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedGender == g
                            ? const Color(0xFF1A6FE8)
                            : Colors.transparent,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(g,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedGender == g
                              ? Colors.white
                              : const Color(0xFF6B7A99),
                          )),
                      ),
                    ))
                  ).toList(),
                ),
              ),

              // Address
              _inputField('Home Address', _addressController,
                Icons.location_on_outlined, TextInputType.streetAddress,
                maxLines: 2),

              const SizedBox(height: 8),

              // Save button
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A6FE8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const Text('Save Changes',
                    style: TextStyle(color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 20),

            ]),
          ),
        ),
      ]),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller,
    IconData icon,
    TextInputType keyboardType, {
    String? hint,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffix,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EFF8), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
            style: const TextStyle(fontSize: 11,
              fontWeight: FontWeight.w600, color: Color(0xFF9AA5BE))),
          const SizedBox(height: 6),
          Row(children: [
            Icon(icon, color: const Color(0xFF1A6FE8), size: 18),
            const SizedBox(width: 10),
            Expanded(child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: readOnly,
              onTap: onTap,
              maxLines: maxLines,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: readOnly
                  ? const Color(0xFF9AA5BE)
                  : const Color(0xFF0A0F1E),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFFB0B8CC)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            )),
            if (suffix != null) suffix,
          ]),
        ],
      ),
    );
  }

  void _saveProfile() {
    context.read<UserProvider>().updateProfile(
      name: _nameController.text,
      email: _emailController.text,
      dob: _dobController.text,
      gender: _selectedGender,
      address: _addressController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        SizedBox(width: 8),
        Text('Profile updated successfully'),
      ]),
      backgroundColor: const Color(0xFF12B76A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));

    Navigator.pop(context);
  }

  Future<void> _pickPhoto() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E5F0),
                borderRadius: BorderRadius.circular(100),
              ),
            )),
            const SizedBox(height: 20),
            const Text('Change Profile Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: Color(0xFF0A0F1E))),
            const SizedBox(height: 20),

            _photoOption(
              icon: Icons.camera_alt_rounded,
              label: 'Take a photo',
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (image != null) {
                  if (!mounted) return;
                  context.read<UserProvider>().updatePhoto(image.path);
                }
              },
            ),
            const SizedBox(height: 10),

            _photoOption(
              icon: Icons.photo_library_rounded,
              label: 'Choose from gallery',
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (image != null) {
                  if (!mounted) return;
                  context.read<UserProvider>().updatePhoto(image.path);
                }
              },
            ),
            const SizedBox(height: 10),

            Consumer<UserProvider>(
              builder: (_, user, __) => user.photoPath != null
                ? Column(children: [
                    _photoOption(
                      icon: Icons.delete_outline_rounded,
                      label: 'Remove photo',
                      isDestructive: true,
                      onTap: () {
                        Navigator.pop(context);
                        context.read<UserProvider>().updatePhoto(null);
                      },
                    ),
                    const SizedBox(height: 10),
                  ])
                : const SizedBox.shrink(),
            ),

            SizedBox(
              width: double.infinity, height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE8EFF8), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF6B7A99),
                    fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFFFFF0F0) : const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive
              ? const Color(0xFFFFCDD2)
              : const Color(0xFFE8EFF8),
            width: 1.5,
          ),
        ),
        child: Row(children: [
          Icon(icon,
            color: isDestructive
              ? const Color(0xFFF04438)
              : const Color(0xFF1A6FE8),
            size: 22),
          const SizedBox(width: 14),
          Text(label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDestructive
                ? const Color(0xFFF04438)
                : const Color(0xFF0A0F1E),
            )),
        ]),
      ),
    );
  }
}
