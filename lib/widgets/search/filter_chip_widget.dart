import 'package:flutter/material.dart';
import '../../core/theme.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green : Colors.white,
          borderRadius: BorderRadius.circular(100), 
          border: Border.all(
            color: isSelected ? AppColors.green : AppColors.line,
            width: 1.5,
          ),
      
          boxShadow: isSelected ? softShadow(0.1) : null, 
        ),
        child: Center(
          child: Text(
            label,
            style: T.s(
              13,
              w: isSelected ? FontWeight.w800 : FontWeight.w600,
              c: isSelected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}