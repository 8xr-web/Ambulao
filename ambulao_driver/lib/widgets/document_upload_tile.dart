import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ambulao_driver/core/theme.dart';
import 'package:ambulao_driver/core/constants.dart';

class DocumentUploadTile extends StatefulWidget {
  final String title;
  final DocStatus status;
  final String? uploadedAt;
  final bool isUploading;
  final Function(File file) onFileSelected;
  final VoidCallback? onTap;

  const DocumentUploadTile({
    super.key,
    required this.title,
    required this.status,
    this.uploadedAt,
    this.isUploading = false,
    required this.onFileSelected,
    this.onTap,
  });

  @override
  State<DocumentUploadTile> createState() => _DocumentUploadTileState();
}

class _DocumentUploadTileState extends State<DocumentUploadTile> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      widget.onFileSelected(File(image.path));
    }
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                width: 48, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFDDE3EE), borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Upload ${widget.title}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0A1F44)),
            ),
            const SizedBox(height: 24),
            _buildOption(
              icon: Icons.camera_alt_outlined,
              label: 'Take Photo',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
            _buildOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDE3EE)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description, color: AppTheme.primaryBlue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0A1F44)),
                  ),
                  const SizedBox(height: 4),
                  if (widget.isUploading)
                    Row(
                      children: [
                        const SizedBox(
                          width: 12, height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(width: 8),
                        const Text('Uploading...', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    )
                  else
                    _StatusBadge(status: widget.status),
                  if (widget.uploadedAt != null && !widget.isUploading) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.uploadedAt!,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: _showUploadOptions,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.status == DocStatus.uploaded ? Icons.edit_outlined : Icons.camera_alt_outlined,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DocStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case DocStatus.uploaded:
        color = AppTheme.successGreen;
        label = '● Uploaded';
        break;
      case DocStatus.missing:
        color = const Color(0xFFFF9500);
        label = '● Missing';
        break;
      case DocStatus.expired:
        color = AppTheme.criticalRed;
        label = '● Expired';
        break;
    }
    return Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
    );
  }
}
