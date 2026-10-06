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

  final List<Map<String, dynamic>> _pricePresets = [
    {'label': '< Rp 50rb', 'min': null, 'max': 50000.0},
    {'label': 'Rp 50rb - 200rb', 'min': 50000.0, 'max': 200000.0},
    {'label': '> Rp 200rb', 'min': 200000.0, 'max': null},
  ];

  @override
  void initState() {
    super.initState();
    _minPriceCtrl = TextEditingController(
      text: widget.currentMinPrice != null ? widget.currentMinPrice!.toInt().toString() : '',
    );
    _maxPriceCtrl = TextEditingController(
      text: widget.currentMaxPrice != null ? widget.currentMaxPrice!.toInt().toString() : '',
    );
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
    });
  }

  void _applyPreset(double? min, double? max) {
    setState(() {
      _minPriceCtrl.text = min != null ? min.toInt().toString() : '';
      _maxPriceCtrl.text = max != null ? max.toInt().toString() : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
         
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter & Urutkan', style: T.h2),
                TextButton(
                  onPressed: _reset,
                  child: Text('Reset', style: T.s(14, w: FontWeight.w700, c: AppColors.peach)),
                ),
              ],
            ),
            const Divider(color: AppColors.line),
            
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  Text('Urutkan Berdasarkan', style: T.h3),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSortChip('Paling Sesuai', SortOption.defaultSort),
                      _buildSortChip('Harga Terendah', SortOption.lowestPrice),
                      _buildSortChip('Harga Tertinggi', SortOption.highestPrice),
                      _buildSortChip('Ulasan Terbaik', SortOption.topRating),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text('Rentang Harga (Rp)', style: T.h3),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriceInput(_minPriceCtrl, 'Minimum'),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('-', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: _buildPriceInput(_maxPriceCtrl, 'Maksimum'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _pricePresets.map((preset) {
                      return ActionChip(
                        label: Text(preset['label'], style: T.s(12, c: AppColors.ink)),
                        backgroundColor: AppColors.bg,
                        side: const BorderSide(color: AppColors.line),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        onPressed: () => _applyPreset(preset['min'], preset['max']),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text('Ulasan Pembeli', style: T.h3),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) {
                      final starValue = 4 - index;
                      final isSelected = _minRating == starValue;
                      return GestureDetector(
                        onTap: () => setState(() => _minRating = _minRating == starValue ? 0 : starValue),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.mint : AppColors.bg,
                            border: Border.all(color: isSelected ? AppColors.green : AppColors.line),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.star, size: 16),
                              const SizedBox(width: 4),
                              Text('$starValue+', style: T.s(13, w: FontWeight.w700)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text('Layanan Pengiriman', style: T.h3),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: AppColors.lilacSoft, shape: BoxShape.circle),
                              child: const Icon(Icons.bolt_rounded, color: AppColors.lilac, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pengiriman Kilat', style: T.s(14, w: FontWeight.w700)),
                                Text('Tiba dalam 1 hari', style: T.small),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _fastShipping,
                          activeColor: AppColors.green,
                          activeTrackColor: AppColors.mint,
                          onChanged: (val) => setState(() => _fastShipping = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Tampilkan Produk',
                onPressed: _apply,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, SortOption option) {
    final isSelected = _sortOption == option;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _sortOption = option),
      selectedColor: AppColors.mint,
      backgroundColor: AppColors.bg,
      labelStyle: T.s(13, w: isSelected ? FontWeight.w700 : FontWeight.w600, c: isSelected ? AppColors.green : AppColors.ink),
      side: BorderSide(color: isSelected ? AppColors.green : AppColors.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      showCheckmark: false,
    );
  }

  Widget _buildPriceInput(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: T.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: T.s(13, c: AppColors.sub),
        filled: true,
        fillColor: AppColors.bg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixText: 'Rp ',
        prefixStyle: T.s(13, w: FontWeight.w700),
      ),
    );
  }
}