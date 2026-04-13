import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/services/driver_profile_service.dart';
import 'package:intl/intl.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final Map<String, dynamic> _profileData = {
    'name': 'Syed Rayan Hussaini',
    'phone': '9876543210',
    'email': 'hundredid3@gmail.com',
    'address': 'Flat 4B, Banjara Residency, Road No. 12, Banjara Hills, Hyderabad, Telangana 500034',
    'gender': 'Male',
    'dob': '12 Aug 1992',
    'emergency_contact': '9876100001',
    'driverId': 'AMB-DR-00247',
  };

  bool _isAnyFieldActive = false;
  bool _hasUnsavedChanges = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await DriverProfileService.loadProfile();
    setState(() {
      if (profile.isNotEmpty) {
        _profileData.addAll(profile);
      }
      _isLoading = false;
    });
  }

  void _onEditStateChanged(bool isEditing) {
    setState(() {
      _isAnyFieldActive = isEditing;
      _hasUnsavedChanges = isEditing;
    });
  }

  Future<void> _saveField(String key, String value) async {
    setState(() {
      _profileData[key] = value;
      _isAnyFieldActive = false;
      _hasUnsavedChanges = false;
    });
    await DriverProfileService.saveField(key, value);
    _showToast('Saved ✓', const Color(0xFF34C759));
  }

  void _showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    if (_isAnyFieldActive) return; // Don't pick if another field is active

    DateTime initial = DateTime(1992, 8, 12);
    try {
      initial = DateFormat('dd MMM yyyy').parse(_profileData['dob']);
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1930),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryBlue, onPrimary: Colors.white, surface: Colors.white),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      await _saveField('dob', DateFormat('dd MMM yyyy').format(picked));
    }
  }

  void _checkUnsaved() {
    if (_hasUnsavedChanges) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 48, height: 4, decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              const Text('Unsaved Changes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0040A0))),
              const SizedBox(height: 10),
              const Text('You have unsaved changes to your profile.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
                onPressed: () { Navigator.pop(ctx); },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), elevation: 0),
                child: const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              )),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, height: 52, child: OutlinedButton(
                onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.criticalRed, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), foregroundColor: AppTheme.criticalRed),
                child: const Text('Discard', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              )),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, height: 52, child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Keep Editing', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue)),
              )),
            ],
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBFF),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF0A1F44)), onPressed: _checkUnsaved),
        title: const Text('Personal Info', style: TextStyle(color: Color(0xFF0A1F44), fontSize: 18, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () { FocusScope.of(context).unfocus(); },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
          child: Column(
            children: [
              EditableField(
                label: 'Full Name',
                value: _profileData['name'],
                keyboardType: TextInputType.name,
                isGlobalEditActive: _isAnyFieldActive,
                onEditStateChanged: _onEditStateChanged,
                onSave: (v) => _saveField('name', v),
              ),
              const SizedBox(height: 16),
              EditableField(
                label: 'Mobile Number',
                value: _profileData['phone'],
                keyboardType: TextInputType.phone,
                isGlobalEditActive: _isAnyFieldActive,
                onEditStateChanged: _onEditStateChanged,
                onSave: (v) => _saveField('phone', v),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                prefix: const Padding(
                  padding: EdgeInsets.only(right: 8.0, top: 2),
                  child: Text('+91', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
                ),
              ),
              const SizedBox(height: 16),
              EditableField(
                label: 'Email Address',
                value: _profileData['email'],
                keyboardType: TextInputType.emailAddress,
                isGlobalEditActive: _isAnyFieldActive,
                onEditStateChanged: _onEditStateChanged,
                onSave: (v) => _saveField('email', v),
              ),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              EditableField(
                label: 'Gender',
                value: _profileData['gender'],
                isGlobalEditActive: _isAnyFieldActive,
                onEditStateChanged: _onEditStateChanged,
                onSave: (v) => _saveField('gender', v),
              ),
              const SizedBox(height: 16),
              EditableField(
                label: 'Address',
                value: _profileData['address'],
                keyboardType: TextInputType.streetAddress,
                isGlobalEditActive: _isAnyFieldActive,
                onEditStateChanged: _onEditStateChanged,
                onSave: (v) => _saveField('address', v),
              ),
              const SizedBox(height: 16),
              // Driver ID (locked)
               _buildLockedField(label: 'Driver ID', value: _profileData['driverId']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E8FF), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: _pickDateOfBirth,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date of Birth', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6E6E73), letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(_profileData['dob'], style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E), fontSize: 15)),
                ],
              ),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Color(0xFF007AFF)),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedField({required String label, required String value}) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Assigned by AMBULAO — cannot be changed. Contact support.'),
          behavior: SnackBarBehavior.floating,
          shape: StadiumBorder(),
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6E6E73), letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E))),
                ],
              ),
            ),
            const Icon(Icons.lock_outline, color: Color(0xFFC7C7CC), size: 18),
          ],
        ),
      ),
    );
  }
}

class EditableField extends StatefulWidget {
  final String label;
  final String value;
  final TextInputType keyboardType;
  final Function(String) onSave;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final bool isGlobalEditActive;
  final Function(bool) onEditStateChanged;

  const EditableField({
    super.key,
    required this.label,
    required this.value,
    required this.onSave,
    required this.isGlobalEditActive,
    required this.onEditStateChanged,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.prefix,
  });

  @override
  State<EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<EditableField> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant EditableField oldWidget) {
    if (oldWidget.value != widget.value && !_isEditing) {
      _controller.text = widget.value;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _isEditing ? const Color(0xFFE8F2FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEditing ? const Color(0xFF007AFF) : const Color(0xFFE0E8FF),
          width: _isEditing ? 2 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.prefix != null && !_isEditing) widget.prefix!,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.label,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF6E6E73), letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    _isEditing
                        ? Row(
                            children: [
                              if (widget.prefix != null) widget.prefix!,
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  keyboardType: widget.keyboardType,
                                  inputFormatters: widget.inputFormatters,
                                  autofocus: true,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0040A0), fontSize: 15),
                                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                                ),
                              ),
                            ],
                          )
                        : Text(widget.value, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E), fontSize: 15)),
                  ],
                ),
              ),
              if (!_isEditing)
                GestureDetector(
                  onTap: () {
                    if (!widget.isGlobalEditActive) {
                      setState(() => _isEditing = true);
                      widget.onEditStateChanged(true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please save active edits first.')));
                    }
                  },
                  child: const Icon(Icons.edit, size: 18, color: Color(0xFF007AFF)),
                ),
            ],
          ),
          if (_isEditing) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Field cannot be empty')));
                      return;
                    }
                    setState(() => _isEditing = false);
                    widget.onEditStateChanged(false);
                    widget.onSave(_controller.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    _controller.text = widget.value;
                    setState(() => _isEditing = false);
                    widget.onEditStateChanged(false);
                  },
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF6E6E73), fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
