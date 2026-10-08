import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_colors.dart';
import '../core/format.dart';
import '../services/image_search_service.dart';

typedef ImageSearchSelect = void Function({String? category, String? query});

/// Buka sheet "cari lewat foto". [onSelect] dipanggil setelah user memilih
/// salah satu objek yang terdeteksi.
Future<void> showImageSearchSheet(
  BuildContext context, {
  required ImageSearchSelect onSelect,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ImageSearchSheet(onSelect: onSelect),
  );
}

enum _Stage { choose, loading, result, error }

class _ImageSearchSheet extends StatefulWidget {
  final ImageSearchSelect onSelect;
  const _ImageSearchSheet({required this.onSelect});

  @override
  State<_ImageSearchSheet> createState() => _ImageSearchSheetState();
}

class _ImageSearchSheetState extends State<_ImageSearchSheet> {
  _Stage _stage = _Stage.choose;
  String? _imagePath;
  List<DetectedObject> _objects = [];
  String _error = '';

  Future<void> _start(ImageSource source) async {
    var step = 'ambil foto';
    try {
      final file = await ImageSearchService.pick(source);
      if (file == null) return; // user batal
      if (!mounted) return;
      setState(() {
        _imagePath = file.path;
        _stage = _Stage.loading;
      });
      step = 'kenali objek';
      final objects = await ImageSearchService.detect(file.path);
      if (!mounted) return;
      setState(() {
        _objects = objects;
        _stage = _Stage.result;
      });
    } catch (e, st) {
      debugPrint('IMAGE SEARCH ERROR di tahap "$step": $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = 'Gagal di tahap "$step".\n$e';
        _stage = _Stage.error;
      });
    }
  }

  void _choose(DetectedObject o) {
    Navigator.pop(context);
    if (o.categorySlug != null) {
      widget.onSelect(category: o.categorySlug);
    } else {
      widget.onSelect(query: o.label);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cari lewat foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Foto barangnya, nanti kami kenali objeknya dan tampilkan produk yang mirip.',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            _body(),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    switch (_stage) {
      case _Stage.choose:
        return Row(
          children: [
            Expanded(
              child: _SourceButton(
                icon: Icons.camera_alt_outlined,
                label: 'Kamera',
                onTap: () => _start(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SourceButton(
                icon: Icons.photo_library_outlined,
                label: 'Galeri',
                onTap: () => _start(ImageSource.gallery),
              ),
            ),
          ],
        );

      case _Stage.loading:
        return Column(
          children: [
            _preview(),
            const SizedBox(height: 20),
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Mengenali objek…',
                style: TextStyle(fontSize: 12.5, color: AppColors.muted),
              ),
            ),
          ],
        );

      case _Stage.result:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _preview(),
            const SizedBox(height: 16),
            if (_objects.isEmpty) ...[
              const Text(
                'Objek tidak dikenali. Coba foto lebih dekat dengan cahaya yang cukup.',
                style: TextStyle(fontSize: 13, color: AppColors.ink),
              ),
            ] else ...[
              const Text(
                'Objek terdeteksi — pilih untuk memfilter produk',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _objects.map(_chip).toList(),
              ),
            ],
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () => setState(() => _stage = _Stage.choose),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Ambil foto lain'),
              style: TextButton.styleFrom(foregroundColor: AppColors.ink),
            ),
          ],
        );

      case _Stage.error:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_error, style: const TextStyle(color: AppColors.danger)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => _stage = _Stage.choose),
              child: const Text('Coba lagi'),
            ),
          ],
        );
    }
  }

  Widget _preview() {
    final path = _imagePath;
    if (path == null) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.file(
        File(path),
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _chip(DetectedObject o) {
    final mapped = o.categorySlug != null;
    final text = mapped
        ? '${o.label} → ${kategoriLabel(o.categorySlug!)}'
        : o.label;
    return ActionChip(
      onPressed: () => _choose(o),
      backgroundColor: mapped ? AppColors.accent : AppColors.bg,
      side: BorderSide(color: mapped ? AppColors.accent : AppColors.border),
      label: Text(
        '$text · ${(o.confidence * 100).round()}%',
        style: TextStyle(
          fontSize: 12.5,
          color: mapped ? Colors.white : AppColors.ink,
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: AppColors.ink),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}