import 'package:flutter/material.dart';
import '../../config/theme/app_theme.dart';

class BiometricDialog extends StatefulWidget {
  final bool isEnabled;
  final String biometricName;
  final String biometricIcon;
  final VoidCallback? onEnable;
  final VoidCallback? onDisable;
  final VoidCallback? onCancel;

  const BiometricDialog({
    super.key,
    required this.isEnabled,
    required this.biometricName,
    required this.biometricIcon,
    this.onEnable,
    this.onDisable,
    this.onCancel,
  });

  @override
  State<BiometricDialog> createState() => _BiometricDialogState();
}

class _BiometricDialogState extends State<BiometricDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonScaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleAction() async {
    setState(() {
      _isLoading = true;
    });

    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    // Add a small delay for visual feedback
    await Future.delayed(const Duration(milliseconds: 200));

    if (widget.isEnabled) {
      widget.onDisable?.call();
    } else {
      widget.onEnable?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient background
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.isEnabled
                              ? [
                                  Colors.red.shade50,
                                  Colors.red.shade100.withOpacity(0.3),
                                ]
                              : [
                                  AppTheme.primaryColor.withOpacity(0.1),
                                  AppTheme.primaryColor.withOpacity(0.05),
                                ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Biometric Icon with animation
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: widget.isEnabled
                                  ? Colors.red.shade50
                                  : AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: widget.isEnabled
                                    ? Colors.red.shade200
                                    : AppTheme.primaryColor.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              widget.biometricIcon,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${widget.biometricName} Authentication',
                            style: AppTheme.heading3.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description text
                          Text(
                            widget.isEnabled
                                ? 'Disable ${widget.biometricName} authentication?'
                                : 'Enable ${widget.biometricName} authentication for faster and more secure login?',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondaryColor,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Status card
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: widget.isEnabled
                                    ? [
                                        Colors.green.shade50,
                                        Colors.green.shade100.withOpacity(0.3),
                                      ]
                                    : [
                                        Colors.blue.shade50,
                                        Colors.blue.shade100.withOpacity(0.3),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: widget.isEnabled
                                    ? Colors.green.shade200
                                    : Colors.blue.shade200,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: widget.isEnabled
                                        ? Colors.green.shade100
                                        : Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    widget.isEnabled
                                        ? Icons.check_circle_rounded
                                        : Icons.info_outline_rounded,
                                    color: widget.isEnabled
                                        ? Colors.green.shade600
                                        : Colors.blue.shade600,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.isEnabled
                                            ? 'Currently Enabled'
                                            : 'Benefits',
                                        style: AppTheme.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: widget.isEnabled
                                              ? Colors.green.shade700
                                              : Colors.blue.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.isEnabled
                                            ? 'You can login with ${widget.biometricName}'
                                            : '• Faster login experience\n• Enhanced security\n• No password needed',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: widget.isEnabled
                                              ? Colors.green.shade600
                                              : Colors.blue.shade600,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        children: [
                          // Cancel button
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _buttonScaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _buttonScaleAnimation.value,
                                  child: OutlinedButton(
                                    onPressed: _isLoading ? null : widget.onCancel,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      side: BorderSide(
                                        color: AppTheme.textSecondaryColor.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: Colors.transparent,
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: AppTheme.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Action button
                          Expanded(
                            flex: 2,
                            child: AnimatedBuilder(
                              animation: _buttonScaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _buttonScaleAnimation.value,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleAction,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      backgroundColor: widget.isEnabled
                                          ? Colors.red.shade500
                                          : AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Colors.white.withOpacity(0.8),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            widget.isEnabled ? 'Disable' : 'Enable',
                                            style: AppTheme.bodyMedium.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper function to show the biometric dialog
Future<void> showBiometricDialog({
  required BuildContext context,
  required bool isEnabled,
  required String biometricName,
  required String biometricIcon,
  VoidCallback? onEnable,
  VoidCallback? onDisable,
  VoidCallback? onCancel,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (BuildContext context) {
      return BiometricDialog(
        isEnabled: isEnabled,
        biometricName: biometricName,
        biometricIcon: biometricIcon,
        onEnable: onEnable,
        onDisable: onDisable,
        onCancel: onCancel,
      );
    },
  );
}
