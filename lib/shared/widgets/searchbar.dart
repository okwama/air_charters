import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final String? hintText;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool showFilter;
  final bool enabled;

  const SearchBar({
    super.key,
    this.hintText = 'Plan your charter flight',
    this.onFilterTap,
    this.onChanged,
    this.controller,
    this.showFilter = true,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.grey.shade100, width: 0.5),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                enabled: enabled,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade700,
                    size: 22,
                  ),
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          if (showFilter) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: const Icon(
                  Icons.tune,
                  color: Colors.black,
                  size: 22,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
