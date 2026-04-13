import 'package:flutter/material.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/core/constants.dart';
import 'package:ambulao_driver/widgets/document_upload_tile.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final List<_DocItem> _docs = [
    _DocItem(name: 'Driving Licence', status: DocStatus.uploaded, uploadedAt: 'Mar 10, 2026'),
    _DocItem(name: 'Vehicle RC', status: DocStatus.missing, uploadedAt: null),
    _DocItem(name: 'Insurance', status: DocStatus.uploaded, uploadedAt: 'Feb 28, 2026'),
    _DocItem(name: 'Medical Certificate', status: DocStatus.expired, uploadedAt: 'Jan 15, 2025'),
    _DocItem(name: 'ID Proof', status: DocStatus.missing, uploadedAt: null),
  ];

  void _simulateUpload(int index) async {
    setState(() => _docs[index] = _docs[index].copyWith(status: DocStatus.missing, isUploading: true, uploadedAt: null));
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _docs[index] = _docs[index].copyWith(status: DocStatus.uploaded, isUploading: false, uploadedAt: 'Uploaded just now'));
  }

  void _showDocumentViewer(int index) {
    final doc = _docs[index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle + close
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: 48, height: 4,
                      decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(doc.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44))),
            const SizedBox(height: 4),
            Text(
              doc.uploadedAt != null ? 'Uploaded: ${doc.uploadedAt}' : 'Not uploaded',
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            // Document preview placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.description_outlined, color: AppTheme.primaryBlue, size: 72),
                    const SizedBox(height: 16),
                    Text(
                      doc.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0040A0)),
                    ),
                    const SizedBox(height: 8),
                    const Text('Document Preview', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () { Navigator.pop(context); _simulateUpload(_docs.indexOf(doc)); },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        foregroundColor: AppTheme.primaryBlue,
                      ),
                      child: const Text('Re-upload', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        final i = _docs.indexOf(doc);
                        Navigator.pop(context);
                        setState(() => _docs[i] = _docs[i].copyWith(status: DocStatus.missing, uploadedAt: null));
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.criticalRed, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        foregroundColor: AppTheme.criticalRed,
                      ),
                      child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0A1F44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Documents',
          style: TextStyle(color: Color(0xFF0A1F44), fontSize: 18, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _docs.length + 1,
        separatorBuilder: (_, i) => i < _docs.length ? const SizedBox(height: 16) : const SizedBox(),
        itemBuilder: (_, i) {
          if (i == _docs.length) {
            return const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                'All documents must be valid and up to date to accept trips',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
            );
          }
          final doc = _docs[i];
          return DocumentUploadTile(
            title: doc.name,
            status: doc.status,
            uploadedAt: doc.uploadedAt,
            isUploading: doc.isUploading,
            onFileSelected: (file) => _simulateUpload(i),
            onTap: doc.status == DocStatus.uploaded ? () => _showDocumentViewer(i) : null,
          );
        },
      ),
    );
  }
}

class _DocItem {
  final String name;
  final DocStatus status;
  final String? uploadedAt;
  final bool isUploading;

  const _DocItem({
    required this.name,
    required this.status,
    this.uploadedAt,
    this.isUploading = false,
  });

  _DocItem copyWith({DocStatus? status, String? uploadedAt, bool? isUploading}) {
    return _DocItem(
      name: name,
      status: status ?? this.status,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}
