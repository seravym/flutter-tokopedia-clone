import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final VoidCallback onClear;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            focusNode.unfocus();
            Navigator.pop(context);
          },
          child: const Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.ink,
              size: 20,
            ),
          ),
        ),
        
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
             
                color: focusNode.hasFocus ? AppColors.green : AppColors.line, 
                width: 1.5
              ),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              style: T.body,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari barang impianmu...',
                hintStyle: T.s(14, c: AppColors.sub),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.sub,
                  size: 20,
                ),

                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.sub),
                        onPressed: onClear,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}