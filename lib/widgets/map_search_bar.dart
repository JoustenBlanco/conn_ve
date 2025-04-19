import 'package:flutter/material.dart';
import '../shared/styles/app_text_styles.dart';
import '../shared/styles/app_decorations.dart';
import '../shared/styles/app_colors.dart';

class MapSearchBar extends StatelessWidget {
  final VoidCallback? onFilterPressed;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const MapSearchBar({
    Key? key,
    this.onFilterPressed,
    this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: AppTextStyles.cardContent.copyWith(
              color: AppColors.textColor,
            ),
            cursorColor: AppColors.purplePrimary,
            decoration: InputDecoration(
              hintText: 'Buscar...',
              hintStyle: AppTextStyles.subtitle.copyWith(
                color: AppColors.hintColor,
              ),
              prefixIcon: Container(
                decoration: AppDecorations.iconCircle,
                margin: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              filled: true,
              fillColor: AppColors.darkCard,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: AppDecorations.iconCircle,
          child: ElevatedButton(
            onPressed: onFilterPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(0),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(
                Icons.filter_alt,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
