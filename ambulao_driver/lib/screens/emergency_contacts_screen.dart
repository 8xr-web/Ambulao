import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyContact {
  String id;
  String name;
  String phone;
  String relation;

  EmergencyContact({required this.id, required this.name, required this.phone, required this.relation});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'phone': phone, 'relation': relation};

  factory EmergencyContact.fromJson(Map<dynamic, dynamic> json) {
    return EmergencyContact(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      relation: json['relation'] ?? '',
    );
  }
}

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? existingJson = prefs.getString('emergency_contacts');
    if (existingJson != null) {
      final List decoded = jsonDecode(existingJson);
      _contacts = decoded.map((e) => EmergencyContact.fromJson(e)).toList();
    }
    setState(() => _isLoading = false);
  }

  void _addContact() {
    if (_contacts.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 contacts allowed')),
      );
      return;
    }
    _showContactScreen();
  }

  void _showContactScreen({EmergencyContact? existingContact}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _EditContactScreen(
          contact: existingContact,
          onSave: (c) async {
            await _saveContact(c);
          },
        ),
      ),
    );
  }

  Future<void> _saveContact(EmergencyContact contact) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('driver_uid') ?? '';

    if (contact.id.isEmpty) {
      contact.id = DateTime.now().millisecondsSinceEpoch.toString();
    }

    final String? existingJson = prefs.getString('emergency_contacts');
    List<EmergencyContact> contacts = [];
    if (existingJson != null) {
      final List decoded = jsonDecode(existingJson);
      contacts = decoded.map((e) => EmergencyContact.fromJson(e)).toList();
    }

    final int index = contacts.indexWhere((c) => c.id == contact.id);
    if (index >= 0) {
      contacts[index] = contact; 
    } else {
      contacts.add(contact); 
    }

    await prefs.setString(
      'emergency_contacts',
      jsonEncode(contacts.map((c) => c.toJson()).toList()),
    );

    if (uid.isNotEmpty) {
      await FirebaseFirestore.instance.collection('drivers').doc(uid).set({
        'emergencyContacts': contacts.map((c) => c.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    setState(() => _contacts = contacts);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Contact saved ✓', style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: const Color(0xFF34C759),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
      );
    }
  }

  Future<void> _removeContact(int index) async {
    final updatedList = List<EmergencyContact>.from(_contacts);
    updatedList.removeAt(index);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'emergency_contacts',
      jsonEncode(updatedList.map((c) => c.toJson()).toList()),
    );

    final uid = prefs.getString('driver_uid') ?? '';
    if (uid.isNotEmpty) {
      await FirebaseFirestore.instance.collection('drivers').doc(uid).set({
        'emergencyContacts': updatedList.map((c) => c.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    
    setState(() => _contacts = updatedList);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        title: const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A1F44)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _contacts.isEmpty 
              ? const Center(child: Text("No emergency contacts added yet.", style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _contacts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: const BoxDecoration(color: Color(0xFFE8F2FF), shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : 'C',
                                style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800, fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(contact.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
                                const SizedBox(height: 2),
                                Text('+91 ${contact.phone}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                const SizedBox(height: 2),
                                Text(contact.relation, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue, size: 20),
                            onPressed: () => _showContactScreen(existingContact: contact),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppTheme.criticalRed, size: 20),
                            onPressed: () => _removeContact(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
          if (_contacts.length < 5)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _addContact,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Contact', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditContactScreen extends StatefulWidget {
  final EmergencyContact? contact;
  final Function(EmergencyContact) onSave;

  const _EditContactScreen({this.contact, required this.onSave});

  @override
  State<_EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<_EditContactScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  String _selectedRelation = '';
  
  final List<String> _relations = ['Father', 'Mother', 'Spouse', 'Sibling', 'Friend', 'Other'];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.contact?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.contact?.phone ?? '');
    _selectedRelation = widget.contact?.relation ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool _isValid() {
    if (_nameCtrl.text.trim().length < 2) return false;
    if (_phoneCtrl.text.trim().length != 10) return false;
    if (_selectedRelation.isEmpty) return false;
    return true;
  }

  String _getInitials() {
    if (_nameCtrl.text.trim().isEmpty) return '?';
    return _nameCtrl.text.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF0A1F44)), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F2FF),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2), width: 4),
              ),
              child: Center(
                child: Text(
                  _getInitials(),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            _buildLabel('Contact Name'),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E8FF)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryBlue),
                  hintText: 'Full Name',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('Phone Number'),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E8FF)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: Color(0xFFE0E8FF))),
                    ),
                    child: const Text('+91', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: '10-digit number',
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 4),
                child: Text('${_phoneCtrl.text.length}/10 digits', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel('Relationship'),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _relations.map((r) {
                final isSelected = _selectedRelation == r;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRelation = r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryBlue : Colors.white,
                      border: Border.all(color: isSelected ? AppTheme.primaryBlue : const Color(0xFFE0E8FF)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(r, style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF0A1F44),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _isValid() && !_isSaving ? () async {
                  setState(() => _isSaving = true);
                  final newContact = EmergencyContact(
                    id: widget.contact?.id ?? '',
                    name: _nameCtrl.text.trim(),
                    phone: _phoneCtrl.text.trim(),
                    relation: _selectedRelation,
                  );
                  await widget.onSave(newContact);
                  if (!mounted) return;
                  Navigator.pop(context);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  disabledBackgroundColor: const Color(0xFFDDE3EE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: _isSaving 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 56,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
                child: const Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44))),
      ),
    );
  }
}
