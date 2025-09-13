import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:air_charters/core/services/notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final NotificationService _notificationService = NotificationService();
  
  // Notification channel toggles
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;

  // Notification category toggles
  bool _bookingNotifications = true;
  bool _promotionNotifications = true;
  bool _updateNotifications = true;
  bool _securityNotifications = true;
  bool _marketingNotifications = false;

  // Time-based preferences
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _notificationService.loadNotificationSettings();
      
      setState(() {
        _emailNotifications = settings['emailNotifications'] ?? true;
        _pushNotifications = settings['pushNotifications'] ?? true;
        _smsNotifications = settings['smsNotifications'] ?? false;
        _bookingNotifications = settings['bookingNotifications'] ?? true;
        _promotionNotifications = settings['promotionNotifications'] ?? true;
        _updateNotifications = settings['updateNotifications'] ?? true;
        _securityNotifications = settings['securityNotifications'] ?? true;
        _marketingNotifications = settings['marketingNotifications'] ?? false;
        _quietHoursEnabled = settings['quietHoursEnabled'] ?? false;
        
        // Parse quiet hours times
        final startTime = settings['quietHoursStart'] ?? '22:00';
        final endTime = settings['quietHoursEnd'] ?? '08:00';
        _quietHoursStart = _parseTimeString(startTime);
        _quietHoursEnd = _parseTimeString(endTime);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading notification settings: $e');
      }
    }
  }

  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
          'Notification Settings',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              'Save',
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
            _buildHeader(colorScheme),

            const SizedBox(height: 32),

            // Notification Channels Section
            _buildNotificationChannelsSection(colorScheme),

            const SizedBox(height: 24),

            // Notification Categories Section
            _buildNotificationCategoriesSection(colorScheme),

            const SizedBox(height: 24),

            // Quiet Hours Section
            _buildQuietHoursSection(colorScheme),

            const SizedBox(height: 32),

            // Save Button
            _buildSaveButton(colorScheme),

            const SizedBox(height: 16),

            // Test Notification Button
            _buildTestNotificationButton(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Center(
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
              LucideIcons.bell,
              size: 40,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Manage Your Notifications',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how and when you want to be notified',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationChannelsSection(ColorScheme colorScheme) {
    return _buildSectionCard(
      colorScheme,
      title: 'Notification Channels',
      subtitle: 'Choose how you want to receive notifications',
      children: [
        _buildNotificationToggle(
          colorScheme,
          icon: LucideIcons.mail,
          title: 'Email Notifications',
          subtitle: 'Receive notifications via email',
          value: _emailNotifications,
          onChanged: (value) {
            setState(() {
              _emailNotifications = value;
            });
          },
        ),
        _buildNotificationToggle(
          colorScheme,
          icon: LucideIcons.smartphone,
          title: 'Push Notifications',
          subtitle: 'Receive push notifications on your device',
          value: _pushNotifications,
          onChanged: (value) {
            setState(() {
              _pushNotifications = value;
            });
          },
        ),
        _buildNotificationToggle(
          colorScheme,
          icon: LucideIcons.messageSquare,
          title: 'SMS Notifications',
          subtitle: 'Receive notifications via SMS',
          value: _smsNotifications,
          onChanged: (value) {
            setState(() {
              _smsNotifications = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotificationCategoriesSection(ColorScheme colorScheme) {
    return _buildSectionCard(
      colorScheme,
      title: 'Notification Categories',
      subtitle: 'Choose what types of notifications to receive',
      children: [
        _buildNotificationToggle(
          colorScheme,
          icon: LucideIcons.calendar,
          title: 'Booking Updates',
          subtitle: 'Flight confirmations, changes, and reminders',
          value: _bookingNotifications,
          onChanged: (value) {
            setState(() {
              _bookingNotifications = value;
            });
          },
        ),
        _buildNotificationToggle(
          colorScheme,
          icon: LucideIcons.tag,
          title: 'Promotions & Deals',
          subtitle: 'Special offers and exclusive deals',
          value: _promotionNotifications,
          onChanged: (value) {
            setState(() {
              _promotionNotifications = value;
            });
          },
        ),
        _buildNotificationToggle(
          colorScheme,
          icon: LucideIcons.info,
          title: 'App Updates',
          subtitle: 'New features and app improvements',
          value: _updateNotifications,
          onChanged: (value) {
            setState(() {
              _updateNotifications = value;
            });
          },
        ),
        _buildNotificationToggle(
          colorScheme,
          icon: LucideIcons.shield,
          title: 'Security Alerts',
          subtitle: 'Account security and login notifications',
          value: _securityNotifications,
          onChanged: (value) {
            setState(() {
              _securityNotifications = value;
            });
          },
        ),
        _buildNotificationToggle(
          colorScheme,
          icon: LucideIcons.megaphone,
          title: 'Marketing Communications',
          subtitle: 'Newsletters and promotional content',
          value: _marketingNotifications,
          onChanged: (value) {
            setState(() {
              _marketingNotifications = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuietHoursSection(ColorScheme colorScheme) {
    return _buildSectionCard(
      colorScheme,
      title: 'Quiet Hours',
      subtitle: 'Set times when you don\'t want to be disturbed',
      children: [
        SwitchListTile(
          title: Text(
            'Enable Quiet Hours',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            'Pause notifications during specific hours',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          value: _quietHoursEnabled,
          onChanged: (value) {
            setState(() {
              _quietHoursEnabled = value;
            });
          },
          activeColor: colorScheme.primary,
        ),
        if (_quietHoursEnabled) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimePickerTile(
                  colorScheme,
                  title: 'Start Time',
                  time: _quietHoursStart,
                  onTap: () => _selectTime(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePickerTile(
                  colorScheme,
                  title: 'End Time',
                  time: _quietHoursEnd,
                  onTap: () => _selectTime(false),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSectionCard(
    ColorScheme colorScheme, {
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.settings,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerTile(
    ColorScheme colorScheme, {
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              time.format(context),
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Save Notification Settings',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTestNotificationButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _notificationService.sendTestNotification();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Test notification sent!',
                  style: GoogleFonts.outfit(),
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Send Test Notification',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _quietHoursStart : _quietHoursEnd,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _quietHoursStart = picked;
        } else {
          _quietHoursEnd = picked;
        }
      });
    }
  }

  void _saveSettings() async {
    try {
      await _notificationService.saveNotificationSettings(
        emailNotifications: _emailNotifications,
        pushNotifications: _pushNotifications,
        smsNotifications: _smsNotifications,
        bookingNotifications: _bookingNotifications,
        promotionNotifications: _promotionNotifications,
        updateNotifications: _updateNotifications,
        securityNotifications: _securityNotifications,
        marketingNotifications: _marketingNotifications,
        quietHoursEnabled: _quietHoursEnabled,
        quietHoursStart: _formatTimeOfDay(_quietHoursStart),
        quietHoursEnd: _formatTimeOfDay(_quietHoursEnd),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notification settings saved successfully',
              style: GoogleFonts.outfit(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save notification settings',
              style: GoogleFonts.outfit(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (kDebugMode) {
        print('Error saving notification settings: $e');
      }
    }
  }
}
