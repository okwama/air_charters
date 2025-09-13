import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ThemePage extends StatefulWidget {
  final String currentTheme;
  final Function(String) onThemeSelected;

  const ThemePage({
    super.key,
    required this.currentTheme,
    required this.onThemeSelected,
  });

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  late String _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Theme Settings',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _applyTheme,
            child: Text(
              'Apply',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      LucideIcons.palette,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Choose Your Theme',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your preferred app appearance',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Theme Options
            _buildThemeOption(
              value: 'light',
              title: 'Light Mode',
              subtitle: 'Clean and bright interface',
              description:
                  'Perfect for daytime use with high contrast and clear visibility',
              icon: LucideIcons.sun,
              color: Colors.orange.shade600,
            ),
            const SizedBox(height: 16),
            _buildThemeOption(
              value: 'dark',
              title: 'Dark Mode',
              subtitle: 'Easy on the eyes in low light',
              description:
                  'Reduces eye strain and saves battery on OLED screens',
              icon: LucideIcons.moon,
              color: Colors.indigo.shade600,
            ),
            const SizedBox(height: 16),
            _buildThemeOption(
              value: 'auto',
              title: 'Auto (System)',
              subtitle: 'Follows your device settings',
              description:
                  'Automatically switches based on your system preferences',
              icon: LucideIcons.settings,
              color: Colors.green.shade600,
            ),

            const SizedBox(height: 40),

            // Preview Section
            _buildPreviewSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required String value,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedTheme == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTheme = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.eye, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Preview',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getPreviewBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getPreviewAccentColor(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.plane,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sample Card',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _getPreviewTextColor(),
                            ),
                          ),
                          Text(
                            'This is how your app will look',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: _getPreviewSecondaryTextColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPreviewBackgroundColor() {
    switch (_selectedTheme) {
      case 'dark':
        return Colors.grey.shade800;
      case 'light':
        return Colors.grey.shade50;
      default:
        return Colors.grey.shade50; // Auto defaults to light for preview
    }
  }

  Color _getPreviewAccentColor() {
    switch (_selectedTheme) {
      case 'dark':
        return Colors.blue.shade400;
      case 'light':
        return Colors.blue.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  Color _getPreviewTextColor() {
    switch (_selectedTheme) {
      case 'dark':
        return Colors.white;
      case 'light':
        return Colors.black;
      default:
        return Colors.black;
    }
  }

  Color _getPreviewSecondaryTextColor() {
    switch (_selectedTheme) {
      case 'dark':
        return Colors.grey.shade300;
      case 'light':
        return Colors.grey.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  void _applyTheme() {
    widget.onThemeSelected(_selectedTheme);
    Navigator.pop(context);
  }
}
