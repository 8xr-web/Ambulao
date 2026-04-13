import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../core/transitions.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/user_provider.dart';
import 'splash_screen.dart';
import 'settings_screen.dart';
import 'edit_profile_screen.dart';
import 'package:flutter_hello_world/localisation/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  final String heroTag;
  const ProfileScreen({super.key, this.heroTag = 'profile_photo_tab'});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _contactsExpanded = true;

  // Medical data (editable via bottom sheets)
  String _bloodType = 'O+';
  final Set<String> _selectedAllergies = {'None'};

  @override
  void initState() {
    super.initState();
    _loadAllergies();
  }

  Future<void> _loadAllergies() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('user_allergies') ?? ['None'];
    setState(() {
      _selectedAllergies.clear();
      _selectedAllergies.addAll(list);
    });
  }

  Future<void> _saveAllergies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_allergies', _selectedAllergies.toList());
  }
  String _conditions = 'Diabetes, High Blood Pressure';



  // Linked documents (local-only demo state)
  bool _aadhaarLinked = false;
  String _aadhaarLast4 = '3456';
  bool _insuranceLinked = false;
  String _insuranceProvider = 'Apollo';
  String _insurancePolicyLast4 = '7788';
  bool _cghsLinked = false;
  String _cghsLast4 = '1122';

  // --- Blood Type Picker ---
  void _showBloodTypePicker() {
    const types = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => StatefulBuilder(builder: (ctx, setInner) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _sheetHandle(),
          const SizedBox(height: 20),
          const Text('Select Blood Type', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0A0F1E))),
          const SizedBox(height: 20),
          Wrap(spacing: 10, runSpacing: 10, children: types.map((t) {
            final sel = _bloodType == t;
            return GestureDetector(
              onTap: () { setState(() => _bloodType = t); setInner(() {}); Navigator.pop(ctx); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: sel ? AppColors.primaryBlue : const Color(0xFFD6E4FF)),
                ),
                child: Text(t, style: TextStyle(color: sel ? Colors.white : AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            );
          }).toList()),
          const SizedBox(height: 8),
        ]),
      )),
    );
  }

  // --- Allergies Picker (multi-select) ---
  void _showAllergyPicker() {
    const opts = ['Penicillin', 'Sulfa', 'Aspirin', 'Latex', 'Other'];
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => StatefulBuilder(builder: (ctx, setInner) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _sheetHandle(),
          const SizedBox(height: 20),
          const Text('Allergies', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Select all that apply', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
          Wrap(spacing: 12, runSpacing: 12, children: _selectedAllergies.map((t) {
            if (t == 'None') return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFEEF4FF), borderRadius: BorderRadius.circular(100), border: Border.all(color: const Color(0xFFD6E4FF))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(t, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAllergies.remove(t);
                        if (_selectedAllergies.isEmpty) _selectedAllergies.add('None');
                        _saveAllergies();
                      });
                      setInner(() {});
                    },
                    child: const Icon(Icons.close, size: 14, color: AppColors.primaryBlue),
                  ),
                ],
              ),
            );
          }).toList()),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Common Allergies', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 10, children: opts.map((t) {
            final sel = _selectedAllergies.contains(t);
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAllergies.remove('None');
                  if (sel) { _selectedAllergies.remove(t); if (_selectedAllergies.isEmpty) _selectedAllergies.add('None'); }
                  else { _selectedAllergies.add(t); }
                  _saveAllergies();
                });
                setInner(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: sel ? AppColors.primaryBlue : const Color(0xFFD6E4FF)),
                ),
                child: Text(t, style: TextStyle(color: sel ? Colors.white : AppColors.primaryBlue, fontWeight: FontWeight.w600)),
              ),
            );
          }).toList()),
          const SizedBox(height: 16),
          TextField(controller: ctrl, decoration: _inputDecoration('Add custom allergy...')),
          const SizedBox(height: 16),
          _primaryButton('Save', () {
            if (ctrl.text.isNotEmpty) {
              setState(() {
                _selectedAllergies.remove('None');
                _selectedAllergies.add(ctrl.text.trim());
                _saveAllergies();
              });
            }
            Navigator.pop(ctx);
          }),
        ]),
      )),
    );
  }

  // --- Conditions Picker ---
  void _showConditionsPicker() {
    const opts = ['None', 'Diabetes', 'Hypertension', 'Asthma', 'Heart Disease', 'Other'];
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => StatefulBuilder(builder: (ctx, setInner) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _sheetHandle(),
          const SizedBox(height: 20),
          const Text('Existing Conditions', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(spacing: 10, runSpacing: 10, children: opts.map((t) {
            final sel = _conditions.contains(t) && t != 'None';
            return GestureDetector(
              onTap: () {
                setInner(() {});
                if (t == 'None') { setState(() => _conditions = 'None'); return; }
                setState(() {
                  final parts = _conditions.split(', ').where((s) => s.isNotEmpty && s != 'None').toList();
                  if (sel) { parts.remove(t); } else { parts.add(t); }
                  _conditions = parts.isEmpty ? 'None' : parts.join(', ');
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: sel ? AppColors.primaryBlue : const Color(0xFFD6E4FF)),
                ),
                child: Text(t, style: TextStyle(color: sel ? Colors.white : AppColors.primaryBlue, fontWeight: FontWeight.w600)),
              ),
            );
          }).toList()),
          const SizedBox(height: 16),
          TextField(controller: ctrl, decoration: _inputDecoration('Add custom condition...')),
          const SizedBox(height: 16),
          _primaryButton('Save', () { if (ctrl.text.isNotEmpty) { final parts = _conditions == 'None' ? [ctrl.text] : _conditions.split(', ')..add(ctrl.text); setState(() => _conditions = parts.join(', ')); } Navigator.pop(ctx); }),
        ]),
      )),
    );
  }

  // --- Add Contact Sheet ---
  void _showAddContactSheet({Map<String, String>? existing, int? editIndex}) {
    final isEdit = existing != null;
    final nameCtr = TextEditingController(text: existing?['name'] ?? '');
    final phoneCtr = TextEditingController(text: existing?['phone']?.replaceAll('+91 ', '') ?? '');
    String relation = existing?['relation'] ?? 'Wife';
    const relations = ['Wife', 'Husband', 'Mother', 'Father', 'Brother', 'Sister', 'Friend', 'Other'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => StatefulBuilder(builder: (ctx, setInner) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _sheetHandle(),
          const SizedBox(height: 20),
          Text(isEdit ? 'Edit Contact' : 'Add Emergency Contact', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(controller: nameCtr, decoration: _inputDecoration('Full name')),
          const SizedBox(height: 12),
          TextField(
            controller: phoneCtr, keyboardType: TextInputType.phone,
            decoration: _inputDecoration('Phone number').copyWith(prefixText: '+91  '),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: relation,
            decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF8FAFF),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD6E4FF))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1A6FE8), width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14)),
            items: relations.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setInner(() => relation = v!),
          ),
          const SizedBox(height: 20),
          _primaryButton(isEdit ? 'Save Changes' : 'Save Contact', () {
            if (nameCtr.text.isEmpty || phoneCtr.text.isEmpty) return;
            final currentContacts = List<Map<String, String>>.from(context.read<UserProvider>().emergencyContacts);
            final contact = {'name': nameCtr.text, 'relation': relation, 'phone': '+91 ${phoneCtr.text.replaceAll('+91 ', '')}'};
            
            if (isEdit && editIndex != null) {
              currentContacts[editIndex] = contact;
            } else {
              currentContacts.add(contact);
            }
            context.read<UserProvider>().updateEmergencyContacts(currentContacts);
            Navigator.pop(ctx);
          }),
          if (isEdit) ...[
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, height: 48,
              child: OutlinedButton(
                onPressed: () {
                  final currentContacts = List<Map<String, String>>.from(context.read<UserProvider>().emergencyContacts);
                  currentContacts.removeAt(editIndex!);
                  context.read<UserProvider>().updateEmergencyContacts(currentContacts);
                  Navigator.pop(ctx);
                },
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFEF4444)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
                child: const Text('Delete Contact', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ]),
      )),
    );
  }

  Widget _sheetHandle() => Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)));

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint, hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
    filled: true, fillColor: const Color(0xFFF8FAFF),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD6E4FF))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1A6FE8), width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );

  Widget _primaryButton(String label, VoidCallback onTap) => SizedBox(
    width: double.infinity, height: 52,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), elevation: 0),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
    ),
  );

  Future<void> _signOut() async {
    await context.read<AuthViewModel>().signOut();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true)
        .pushReplacement(SmoothPageRoute(page: const SplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final contacts = context.watch<UserProvider>().emergencyContacts;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.profile, style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context, rootNavigator: true).push(SmoothPageRoute(page: const SettingsScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blue Header
            GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                SmoothPageRoute(page: const EditProfileScreen()),
              ),
              child: Stack(children: [
                Consumer<UserProvider>(
                  builder: (context, user, _) => Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1A6FE8), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Row(children: [
                      Hero(
                        tag: widget.heroTag,
                        child: Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2)),
                          child: user.photoPath != null && user.photoPath!.isNotEmpty
                            ? ClipOval(child: kIsWeb
                                ? Image.network(user.photoPath!, width: 64, height: 64, fit: BoxFit.cover)
                                : Image.file(File(user.photoPath!), width: 64, height: 64, fit: BoxFit.cover))
                            : Center(child: Text(user.initials, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, color: Colors.white, size: 16),
                        ]),
                        const SizedBox(height: 4),
                        Text("+91 ${user.phone}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        const DecoratedBox(
                          decoration: BoxDecoration(color: Color(0xFF10B981), borderRadius: BorderRadius.all(Radius.circular(100))),
                          child: Padding(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Text("Verified User", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                        ),
                      ])),
                    ]),
                  ),
                ),
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // Medical Info
            Row(children: [
              Expanded(child: GestureDetector(onTap: _showBloodTypePicker, child: _buildMedicalCard(Icons.bloodtype, "Blood Type", _bloodType, const Color(0xFFFF3B30)))),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(onTap: _showAllergyPicker, child: _buildMedicalCard(Icons.eco, "Allergies", _selectedAllergies.where((s) => s != 'None').join(', ').isEmpty ? 'None' : _selectedAllergies.where((s) => s != 'None').join(', '), const Color(0xFF10B981)))),
            ]),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showConditionsPicker,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
                child: Row(children: [
                  const Icon(Icons.medical_information_outlined, color: AppColors.primaryBlue, size: 24),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Existing Conditions", style: TextStyle(color: Color(0xFF6E6E73), fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(_conditions, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                  ])),
                  const Icon(Icons.chevron_right, color: Color(0xFFD1D1D6), size: 18),
                ]),
              ),
            ),
            const SizedBox(height: 32),

            // Emergency Contacts
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Emergency Contacts", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () {
                  if (contacts.length >= 3) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You can add up to 3 emergency contacts'), behavior: SnackBarBehavior.floating));
                    return;
                  }
                  _showAddContactSheet();
                },
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text("Add"),
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
              ),
            ]),
            GestureDetector(
              onTap: () => setState(() => _contactsExpanded = !_contactsExpanded),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
                child: Column(children: [
                  for (int i = 0; i < contacts.length; i++) ...[
                    if (i > 0 && _contactsExpanded) const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0xFFF3F4F6))),
                    if (i == 0 || _contactsExpanded)
                      _buildContactRow(contacts[i]['name']!, contacts[i]['relation']!, contacts[i]['phone']!, () => _showAddContactSheet(existing: contacts[i], editIndex: i)),
                  ],
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.info_outline, color: Color(0xFF9CA3AF), size: 14),
                    const SizedBox(width: 6),
                    const Text("Auto-notified on every booking", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                    const Spacer(),
                    Icon(_contactsExpanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF9CA3AF)),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 32),

            // Linked Documents
            const Text("Linked Documents", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, clipBehavior: Clip.none,
              child: Row(children: [
                _buildDocumentTile("Aadhaar", Icons.badge_outlined, _aadhaarLinked, onTap: () => _openAadhaarSheet()),
                _buildDocumentTile("Insurance", Icons.shield_outlined, _insuranceLinked, onTap: () => _openInsuranceSheet()),
                _buildDocumentTile("CGHS", Icons.medical_services_outlined, _cghsLinked, onTap: () => _openCghsSheet()),
              ]),
            ),
            const SizedBox(height: 48),

            OutlinedButton(
              onPressed: _signOut,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Sign Out", style: TextStyle(color: Color(0xFFFF3B30), fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalCard(IconData icon, String label, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Color(0xFF6E6E73), fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        ])),
        const Icon(Icons.chevron_right, color: Color(0xFFD1D1D6), size: 16),
      ]),
    );
  }

  Widget _buildContactRow(String name, String relation, String phone, VoidCallback onEdit) {
    return Row(children: [
      Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
        child: const Center(child: Icon(Icons.person, color: Color(0xFF9CA3AF), size: 20))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4)),
            child: Text(relation, style: const TextStyle(color: Color(0xFF6E6E73), fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 2),
        Text(phone, style: const TextStyle(color: Color(0xFF6E6E73), fontSize: 12)),
      ])),
      GestureDetector(onTap: onEdit, child: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue, size: 20)),
    ]);
  }

  Widget _buildDocumentTile(String name, IconData icon, bool verified, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12), width: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
        child: Column(children: [
          Icon(icon, color: AppColors.primaryBlue, size: 28),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(verified ? Icons.check_circle : Icons.link_outlined, color: verified ? const Color(0xFF10B981) : const Color(0xFF9CA3AF), size: 12),
            const SizedBox(width: 4),
            Text(verified ? "Verified" : "Link",
                style: TextStyle(color: verified ? const Color(0xFF10B981) : const Color(0xFF9CA3AF), fontSize: 10, fontWeight: FontWeight.bold)),
          ]),
        ]),
      ),
    );
  }

  void _openAadhaarSheet() {
    final aadhaarCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => StatefulBuilder(builder: (ctx, setInner) {
        String? error;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(child: Text('Aadhaar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 18, color: Color(0xFF6B7A99)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!_aadhaarLinked) ...[
                const Text('Link Aadhaar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: aadhaarCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Aadhaar number (12 digits)'),
                  onChanged: (_) => setInner(() => error = null),
                ),
                if (error != null) ...[
                  const SizedBox(height: 6),
                  Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                _primaryButton('Verify with OTP', () {
                  final digits = aadhaarCtrl.text.replaceAll(RegExp(r'\D'), '');
                  if (digits.length != 12) {
                    setInner(() => error = 'Please enter a 12-digit Aadhaar number');
                    return;
                  }
                  setState(() {
                    _aadhaarLinked = true;
                    _aadhaarLast4 = digits.substring(8);
                  });
                  Navigator.pop(ctx);
                }),
                const SizedBox(height: 10),
              ] else ...[
                Row(
                  children: [
                    Text('XXXX XXXX $_aadhaarLast4', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(100)),
                      child: const Row(children: [
                        Icon(Icons.verified, color: Color(0xFF10B981), size: 14),
                        SizedBox(width: 6),
                        Text('Verified', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _aadhaarLinked = false);
                      Navigator.pop(ctx);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    child: const Text('Remove', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        );
      }),
    );
  }

  void _openInsuranceSheet() {
    final policyCtrl = TextEditingController();
    String provider = _insuranceProvider;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => StatefulBuilder(builder: (ctx, setInner) {
        String? error;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(child: Text('Insurance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 18, color: Color(0xFF6B7A99)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!_insuranceLinked) ...[
                const Text('Link Insurance', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: provider,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD6E4FF))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF1A6FE8), width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  items: const ['Apollo', 'HDFC ERGO', 'Star Health', 'ICICI Lombard']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setInner(() => provider = v ?? provider),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: policyCtrl,
                  decoration: _inputDecoration('Policy number'),
                  onChanged: (_) => setInner(() => error = null),
                ),
                if (error != null) ...[
                  const SizedBox(height: 6),
                  Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                _primaryButton('Link Insurance', () {
                  if (policyCtrl.text.trim().isEmpty) {
                    setInner(() => error = 'Please enter a policy number');
                    return;
                  }
                  final pol = policyCtrl.text.trim();
                  setState(() {
                    _insuranceLinked = true;
                    _insuranceProvider = provider;
                    _insurancePolicyLast4 = pol.length >= 4 ? pol.substring(pol.length - 4) : pol;
                  });
                  Navigator.pop(ctx);
                }),
                const SizedBox(height: 10),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text('$_insuranceProvider Â· XXXX$_insurancePolicyLast4',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(100)),
                      child: const Row(children: [
                        Icon(Icons.verified, color: Color(0xFF10B981), size: 14),
                        SizedBox(width: 6),
                        Text('Verified', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _insuranceLinked = false);
                      Navigator.pop(ctx);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    child: const Text('Remove', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        );
      }),
    );
  }

  void _openCghsSheet() {
    final cghsCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => StatefulBuilder(builder: (ctx, setInner) {
        String? error;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(child: Text('CGHS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 18, color: Color(0xFF6B7A99)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!_cghsLinked) ...[
                const Text('Link CGHS', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: cghsCtrl,
                  keyboardType: TextInputType.text,
                  decoration: _inputDecoration('CGHS beneficiary ID'),
                  onChanged: (_) => setInner(() => error = null),
                ),
                if (error != null) ...[
                  const SizedBox(height: 6),
                  Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                _primaryButton('Link CGHS', () {
                  final id = cghsCtrl.text.trim();
                  if (id.isEmpty) {
                    setInner(() => error = 'Please enter your CGHS ID');
                    return;
                  }
                  setState(() {
                    _cghsLinked = true;
                    _cghsLast4 = id.length >= 4 ? id.substring(id.length - 4) : id;
                  });
                  Navigator.pop(ctx);
                }),
                const SizedBox(height: 10),
              ] else ...[
                Row(
                  children: [
                    Text('XXXX$_cghsLast4', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(100)),
                      child: const Row(children: [
                        Icon(Icons.verified, color: Color(0xFF10B981), size: 14),
                        SizedBox(width: 6),
                        Text('Verified', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _cghsLinked = false);
                      Navigator.pop(ctx);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    ),
                    child: const Text('Remove', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        );
      }),
    );
  }
}
