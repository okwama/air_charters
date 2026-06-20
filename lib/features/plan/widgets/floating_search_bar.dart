import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/models/google_earth_location_model.dart';
import '../../../config/theme/app_theme.dart';

class FloatingSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;
  final List<GoogleEarthLocationModel> searchResults;
  final Function(String) onSearchChanged;
  final VoidCallback onClear;
  final Function(GoogleEarthLocationModel) onResultTap;

  const FloatingSearchBar({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.searchResults,
    required this.onSearchChanged,
    required this.onClear,
    required this.onResultTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              style: AppTheme.bodyMedium.copyWith(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search stops...',
                hintStyle: AppTheme.bodyMedium.copyWith(color: Colors.black45),
                prefixIcon: Icon(LucideIcons.search,
                    color: AppTheme.primaryColor, size: 20),
                suffixIcon: isSearching
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor),
                          ),
                        ),
                      )
                    : controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(LucideIcons.x,
                                color: Colors.black45, size: 18),
                            onPressed: onClear,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 36, minHeight: 36),
                          )
                        : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                isDense: true,
              ),
              onChanged: onSearchChanged,
            ),
          ),

          // Search results
          if (searchResults.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: searchResults.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                  indent: 56,
                ),
                itemBuilder: (context, index) {
                  final result = searchResults[index];
                  return ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.mapPin,
                        color: AppTheme.primaryColor,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      result.name,
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      result.formattedAddress,
                      style: AppTheme.caption.copyWith(
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(LucideIcons.plus,
                        size: 18, color: AppTheme.primaryColor),
                    onTap: () => onResultTap(result),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
