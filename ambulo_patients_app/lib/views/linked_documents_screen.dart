import 'package:flutter/material.dart';

class LinkedDocumentsScreen extends StatefulWidget {
  const LinkedDocumentsScreen({super.key});
  @override
  State<LinkedDocumentsScreen> createState() => _LinkedDocumentsScreenState();
}

class _LinkedDocumentsScreenState extends State<LinkedDocumentsScreen> {

  // Document state — each document has:
  // isLinked: whether it's been added
  // maskedNumber: the masked display value after linking
  // verifiedAt: date it was verified

  final Map<String, Map<String, dynamic>> _documents = {
    'aadhaar': {
      'isLinked': true,
      'title': 'Aadhaar Card',
      'subtitle': 'Government ID',
      'maskedNumber': 'XXXX XXXX 3456',
      'verifiedAt': 'Verified on 12 Jan 2026',
      'icon': Icons.credit_card_rounded,
      'color': const Color(0xFF1A6FE8),
    },
    'insurance': {
      'isLinked': false,
      'title': 'Health Insurance',
      'subtitle': 'Insurance Policy',
      'maskedNumber': '',
      'verifiedAt': '',
      'icon': Icons.health_and_safety_rounded,
      'color': const Color(0xFF12B76A),
    },
    'cghs': {
      'isLinked': false,
      'title': 'CGHS Card',
      'subtitle': 'Central Govt Health Scheme',
      'maskedNumber': '',
      'verifiedAt': '',
      'icon': Icons.local_hospital_rounded,
      'color': const Color(0xFF0047CC),
    },
    'ayushman': {
      'isLinked': false,
      'title': 'Ayushman Bharat',
      'subtitle': 'PM-JAY Health Card',
      'maskedNumber': '',
      'verifiedAt': '',
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFF59E0B),
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      body: SafeArea(
        child: Column(children: [

          // HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE8EFF8), width: 1.5),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: Color(0xFF0A0F1E)),
                ),
              ),
              const SizedBox(width: 14),
              const Text('Linked Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A0F1E),
                )),
            ]),
          ),

          // INFO BANNER
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC8D8F8), width: 1.5),
            ),
            child: const Row(children: [
              Icon(Icons.lock_rounded, color: Color(0xFF1A6FE8), size: 20),
              SizedBox(width: 10),
              Expanded(child: Text(
                'Your documents are encrypted and stored securely. Only shared with hospitals when needed.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1A6FE8),
                  height: 1.4,
                ),
              )),
            ]),
          ),

          // DOCUMENTS LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [

                // Linked section header
                _sectionHeader('Linked'),

                // Show linked documents first
                ..._documents.entries
                  .where((e) => e.value['isLinked'] == true)
                  .map((e) => _documentCard(e.key, e.value)),

                const SizedBox(height: 8),

                // Not linked section header
                _sectionHeader('Not Linked'),

                // Show unlinked documents
                ..._documents.entries
                  .where((e) => e.value['isLinked'] == false)
                  .map((e) => _documentCard(e.key, e.value)),

                const SizedBox(height: 20),
              ],
            ),
          ),

        ]),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9AA5BE),
          letterSpacing: 0.8,
        )),
    );
  }

  Widget _documentCard(String key, Map<String, dynamic> doc) {
    final bool isLinked = doc['isLinked'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLinked ? const Color(0xFFC8D8F8) : const Color(0xFFE8EFF8),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          Row(children: [
            // Icon bubble
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: (doc['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(doc['icon'] as IconData,
                color: doc['color'] as Color, size: 24),
            ),
            const SizedBox(width: 14),

            // Title + status
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A0F1E),
                  )),
                const SizedBox(height: 2),
                Text(doc['subtitle'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7A99),
                  )),
                if (isLinked) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF12B76A), size: 12),
                    const SizedBox(width: 4),
                    Text(doc['verifiedAt'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF12B76A),
                        fontWeight: FontWeight.w500,
                      )),
                  ]),
                ],
              ],
            )),

            // Linked badge or Add button
            if (isLinked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text('Linked',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A6FE8),
                  )),
              )
            else
              GestureDetector(
                onTap: () => _showAddSheet(key, doc),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A6FE8),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text('+ Add',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
                ),
              ),
          ]),

          // If linked — show masked number + action buttons
          if (isLinked) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.credit_card_rounded,
                  color: Color(0xFF9AA5BE), size: 16),
                const SizedBox(width: 8),
                Text(doc['maskedNumber'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A0F1E),
                    letterSpacing: 1,
                  )),
              ]),
            ),
            const SizedBox(height: 10),

            // Change + Delete buttons
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => _showEditSheet(key, doc),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: const Color(0xFFC8D8F8), width: 1.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_rounded,
                        color: Color(0xFF1A6FE8), size: 14),
                      SizedBox(width: 6),
                      Text('Change',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A6FE8),
                        )),
                    ],
                  ),
                ),
              )),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(
                onTap: () => _showDeleteConfirmation(key, doc),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFF04438), size: 14),
                      SizedBox(width: 6),
                      Text('Remove',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF04438),
                        )),
                    ],
                  ),
                ),
              )),
            ]),
          ],

        ]),
      ),
    );
  }

  // ADD DOCUMENT BOTTOM SHEET
  void _showAddSheet(String key, Map<String, dynamic> doc) {
    final numberController = TextEditingController();
    final providerController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Drag handle
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E5F0),
                  borderRadius: BorderRadius.circular(100),
                ),
              )),
              const SizedBox(height: 20),

              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: (doc['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(doc['icon'] as IconData,
                    color: doc['color'] as Color, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Link ${doc['title']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A0F1E),
                  )),
              ]),
              const SizedBox(height: 20),

              // Show provider field for insurance
              if (key == 'insurance') ...[
                const Text('Insurance Provider',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7A99),
                  )),
                const SizedBox(height: 8),
                TextField(
                  controller: providerController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Star Health, HDFC Ergo',
                    hintStyle: const TextStyle(color: Color(0xFFB0B8CC)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE8EFF8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF1A6FE8), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Document number field
              Text(_fieldLabel(key),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7A99),
                )),
              const SizedBox(height: 8),
              TextField(
                controller: numberController,
                keyboardType: TextInputType.number,
                maxLength: _maxLength(key),
                decoration: InputDecoration(
                  hintText: _hintText(key),
                  hintStyle: const TextStyle(color: Color(0xFFB0B8CC)),
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE8EFF8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF1A6FE8), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),

              // Link button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _documents[key]!['isLinked'] = true;
                      _documents[key]!['maskedNumber'] =
                        _maskNumber(numberController.text);
                      _documents[key]!['verifiedAt'] =
                        'Verified on ${_todayDate()}';
                    });
                    Navigator.pop(context);
                    _showSuccessToast('${doc['title']} linked successfully');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A6FE8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const Text('Link Document',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    )),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // EDIT DOCUMENT BOTTOM SHEET
  void _showEditSheet(String key, Map<String, dynamic> doc) {
    final numberController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E5F0),
                  borderRadius: BorderRadius.circular(100),
                ),
              )),
              const SizedBox(height: 20),
              Text('Update ${doc['title']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A0F1E),
                )),
              const SizedBox(height: 6),
              Text('Current: ${doc['maskedNumber']}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7A99),
                )),
              const SizedBox(height: 20),
              Text('New ${_fieldLabel(key)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7A99),
                )),
              const SizedBox(height: 8),
              TextField(
                controller: numberController,
                keyboardType: TextInputType.number,
                maxLength: _maxLength(key),
                decoration: InputDecoration(
                  hintText: _hintText(key),
                  hintStyle: const TextStyle(color: Color(0xFFB0B8CC)),
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE8EFF8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF1A6FE8), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _documents[key]!['maskedNumber'] =
                        _maskNumber(numberController.text);
                      _documents[key]!['verifiedAt'] =
                        'Updated on ${_todayDate()}';
                    });
                    Navigator.pop(context);
                    _showSuccessToast('${doc['title']} updated successfully');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A6FE8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const Text('Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DELETE CONFIRMATION
  void _showDeleteConfirmation(String key, Map<String, dynamic> doc) {
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
            Container(
              width: 56, height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFF04438), size: 28),
            ),
            const SizedBox(height: 14),
            Text('Remove ${doc['title']}?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0F1E),
              )),
            const SizedBox(height: 8),
            Text(
              'This will unlink your ${doc['title']} from Ambulao. You can add it again anytime.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7A99),
                height: 1.4,
              )),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Color(0xFFE8EFF8), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Cancel',
                  style: TextStyle(
                    color: Color(0xFF6B7A99),
                    fontWeight: FontWeight.w600,
                  )),
              )),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _documents[key]!['isLinked'] = false;
                    _documents[key]!['maskedNumber'] = '';
                    _documents[key]!['verifiedAt'] = '';
                  });
                  Navigator.pop(context);
                  _showSuccessToast('${doc['title']} removed');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF04438),
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Remove',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  )),
              )),
            ]),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // HELPER FUNCTIONS
  String _fieldLabel(String key) {
    switch (key) {
      case 'aadhaar': return 'Aadhaar Number (12 digits)';
      case 'insurance': return 'Policy Number';
      case 'cghs': return 'CGHS Beneficiary ID';
      case 'ayushman': return 'Ayushman Card Number';
      default: return 'Document Number';
    }
  }

  String _hintText(String key) {
    switch (key) {
      case 'aadhaar': return 'XXXX XXXX XXXX';
      case 'insurance': return 'e.g. POL123456789';
      case 'cghs': return 'e.g. CGHS12345678';
      case 'ayushman': return 'e.g. PMJAY12345678';
      default: return 'Enter number';
    }
  }

  int _maxLength(String key) {
    switch (key) {
      case 'aadhaar': return 12;
      default: return 20;
    }
  }

  String _maskNumber(String number) {
    if (number.length <= 4) return number;
    final visible = number.substring(number.length - 4);
    final masked = 'X' * (number.length - 4);
    return '$masked $visible';
  }

  String _todayDate() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  void _showSuccessToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(message, style: const TextStyle(color: Colors.white)),
      ]),
      backgroundColor: const Color(0xFF12B76A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }
}
