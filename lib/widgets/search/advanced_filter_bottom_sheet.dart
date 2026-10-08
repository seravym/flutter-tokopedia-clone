import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../common.dart';
import '../../screens/search/search_screen.dart';

class AdvancedFilterBottomSheet extends StatefulWidget {
  final double? currentMinPrice;
  final double? currentMaxPrice;
  final bool currentFastShipping;
  final int currentMinRating;
  final SortOption currentSort;

  const AdvancedFilterBottomSheet({
    super.key,
    this.currentMinPrice,
    this.currentMaxPrice,
    this.currentFastShipping = false,
    this.currentMinRating = 0,
    this.currentSort = SortOption.defaultSort,
  });

  @override
  State<AdvancedFilterBottomSheet> createState() => _AdvancedFilterBottomSheetState();
}

class _AdvancedFilterBottomSheetState extends State<AdvancedFilterBottomSheet> {
  late TextEditingController _minPriceCtrl;
  late TextEditingController _maxPriceCtrl;
  late bool _fastShipping;
  late int _minRating;
  late SortOption _sortOption;
  
  String _selectedLocation = '';
  String _selectedSeller = '';
  String _selectedPromo = '';

  final List<Map<String, dynamic>> _pricePresets = [
    {'label': '0-75RB', 'min': 0.0, 'max': 75000.0},
    {'label': '75RB-150RB', 'min': 75000.0, 'max': 150000.0},
    {'label': '150RB-200RB', 'min': 150000.0, 'max': 200000.0},
  ];

  @override
  void initState() {
    super.initState();
    _minPriceCtrl = TextEditingController(text: widget.currentMinPrice?.toInt().toString() ?? '');
    _maxPriceCtrl = TextEditingController(text: widget.currentMaxPrice?.toInt().toString() ?? '');
    _fastShipping = widget.currentFastShipping;
    _minRating = widget.currentMinRating;
    _sortOption = widget.currentSort;
  }

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    final minPrice = double.tryParse(_minPriceCtrl.text.replaceAll('.', ''));
    final maxPrice = double.tryParse(_maxPriceCtrl.text.replaceAll('.', ''));
    Navigator.pop(context, {
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'fastShipping': _fastShipping,
      'minRating': _minRating,
      'sortOption': _sortOption,
    });
  }

  void _reset() {
    setState(() {
      _minPriceCtrl.clear();
      _maxPriceCtrl.clear();
      _fastShipping = false;
      _minRating = 0;
      _sortOption = SortOption.defaultSort;
      _selectedLocation = '';
      _selectedSeller = '';
      _selectedPromo = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close)),
                Text('Pilih Preferensi', style: T.h2),
                const SizedBox(width: 24),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _buildSectionTitle('Opsi Pengiriman'),
                Wrap(
                  spacing: 10, runSpacing: 10,
                  children: [
                    _buildChip('Instant', _fastShipping, () => setState(() => _fastShipping = !_fastShipping)),
                    _buildChip('Same Day', false, () {}),
                    _buildChip('Reguler', false, () {}),
                    _buildChip('Hemat Kargo', false, () {}),
                  ],
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle('Penilaian'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    final star = 5 - index;
                    final isSel = _minRating == star;
                    return GestureDetector(
                      onTap: () => setState(() => _minRating = isSel ? 0 : star),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.peachSoft : AppColors.bg,
                          border: Border.all(color: isSel ? AppColors.peach : AppColors.line),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            if (star < 5) Text('≥', style: T.s(12)),
                            Text('$star', style: T.s(13, w: FontWeight.w700)),
                            const Icon(Icons.star_rounded, color: AppColors.star, size: 14),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Batas Harga'),
                Row(
                  children: [
                    Expanded(child: _buildPriceInput(_minPriceCtrl, 'MIN')),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('-')),
                    Expanded(child: _buildPriceInput(_maxPriceCtrl, 'MAX')),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: _pricePresets.map((p) => _buildChip(
                    p['label'], 
                    _minPriceCtrl.text == p['min'].toInt().toString(), 
                    () => setState(() {
                      _minPriceCtrl.text = p['min'].toInt().toString();
                      if (p['max'] != null) _maxPriceCtrl.text = p['max'].toInt().toString();
                    })
                  )).toList(),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Tipe Penjual'),
                Wrap(
                  spacing: 10,
                  children: [
                    _buildChip('Mall', _selectedSeller == 'mall', () => setState(() => _selectedSeller = 'mall')),
                    _buildChip('Star+', _selectedSeller == 'star+', () => setState(() => _selectedSeller = 'star+')),
                    _buildChip('Star', _selectedSeller == 'star', () => setState(() => _selectedSeller = 'star')),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Lokasi'),
                Wrap(
                  spacing: 10, runSpacing: 10,
                  children: [
                    _buildChip('Jabodetabek', _selectedLocation == 'jabodetabek', () => setState(() => _selectedLocation = 'jabodetabek')),
                    _buildChip('DKI Jakarta', _selectedLocation == 'dki', () => setState(() => _selectedLocation = 'dki')),
                    _buildChip('Jakarta Selatan', _selectedLocation == 'jaksel', () => setState(() => _selectedLocation = 'jaksel')),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Program Promo'),
                Wrap(
                  spacing: 10, runSpacing: 10,
                  children: [
                    _buildChip('Promo XTRA+', _selectedPromo == 'xtra+', () => setState(() => _selectedPromo = 'xtra+')),
                    _buildChip('Bebas Pengembalian', _selectedPromo == 'return', () => setState(() => _selectedPromo = 'return')),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(top: BorderSide(color: AppColors.line)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.peach),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text('Atur Ulang', style: T.s(14, w: FontWeight.w700, c: AppColors.peach)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.peach,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text('Terapkan', style: T.s(14, w: FontWeight.w700, c: Colors.white)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: T.s(14, w: FontWeight.w700)),
  );

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.peachSoft : AppColors.bg,
          border: Border.all(color: isSelected ? AppColors.peach : AppColors.line),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: T.s(13, c: isSelected ? AppColors.peach : AppColors.ink)),
      ),
    );
  }

  Widget _buildPriceInput(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: T.s(13, c: AppColors.sub),
        filled: true,
        fillColor: AppColors.bg,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
      ),
    );
  }
}