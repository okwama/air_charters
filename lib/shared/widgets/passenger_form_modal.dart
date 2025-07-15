import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/models/passenger_model.dart';
import '../../core/providers/passengers_provider.dart';

class PassengerFormModal extends StatefulWidget {
  final String bookingId;
  final PassengerModel? passenger; // For editing existing passenger
  final VoidCallback? onSuccess;

  const PassengerFormModal({
    super.key,
    required this.bookingId,
    this.passenger,
    this.onSuccess,
  });

  @override
  State<PassengerFormModal> createState() => _PassengerFormModalState();
}

class _PassengerFormModalState extends State<PassengerFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _documentController = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _ageFocus = FocusNode();
  final _nationalityFocus = FocusNode();
  final _documentFocus = FocusNode();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _nationalityController.dispose();
    _documentController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _ageFocus.dispose();
    _nationalityFocus.dispose();
    _documentFocus.dispose();
    super.dispose();
  }

  void _initializeFormData() {
    if (widget.passenger != null) {
      _firstNameController.text = widget.passenger!.firstName;
      _lastNameController.text = widget.passenger!.lastName;
      _ageController.text = widget.passenger!.age?.toString() ?? '';
      _nationalityController.text = widget.passenger!.nationality ?? '';
      _documentController.text = widget.passenger!.idPassportNumber ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _buildHeader(),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Name field
                    _buildTextField(
                      controller: _firstNameController,
                      focusNode: _firstNameFocus,
                      label: 'First Name *',
                      hint: 'Enter first name',
                      icon: Icons.person_outline,
                      isRequired: true,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_lastNameFocus);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Last Name field
                    _buildTextField(
                      controller: _lastNameController,
                      focusNode: _lastNameFocus,
                      label: 'Last Name *',
                      hint: 'Enter last name',
                      icon: Icons.person_outline,
                      isRequired: true,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_ageFocus);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Age field
                    _buildTextField(
                      controller: _ageController,
                      focusNode: _ageFocus,
                      label: 'Age',
                      hint: 'Enter age (optional)',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_nationalityFocus);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Nationality field
                    _buildTextField(
                      controller: _nationalityController,
                      focusNode: _nationalityFocus,
                      label: 'Nationality',
                      hint: 'Enter nationality (optional)',
                      icon: Icons.flag_outlined,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_documentFocus);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Document field
                    _buildTextField(
                      controller: _documentController,
                      focusNode: _documentFocus,
                      label: 'ID/Passport Number',
                      hint: 'Enter ID or passport number (optional)',
                      icon: Icons.credit_card_outlined,
                      onFieldSubmitted: (_) {
                        _submitForm();
                      },
                    ),

                    const SizedBox(height: 30),

                    // Submit button
                    _buildSubmitButton(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF666666),
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.passenger != null ? 'Edit Passenger' : 'Add Passenger',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onFieldSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF888888),
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF666666),
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Must be at least 2 characters';
                  }
                  return null;
                }
              : (value) {
                  // Age validation
                  if (keyboardType == TextInputType.number &&
                      value != null &&
                      value.isNotEmpty) {
                    final age = int.tryParse(value);
                    if (age == null || age < 0 || age > 120) {
                      return 'Please enter a valid age (0-120)';
                    }
                  }
                  return null;
                },
          onFieldSubmitted: onFieldSubmitted,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          disabledBackgroundColor: const Color(0xFFE5E5E5),
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0xFF888888),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF888888)),
                ),
              )
            : Text(
                widget.passenger != null ? 'Update Passenger' : 'Add Passenger',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<PassengerProvider>(context, listen: false);

      // Check for duplicate names (only when creating new passenger)
      if (widget.passenger == null) {
        final isDuplicate = provider.hasPassengerWithName(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
        );

        if (isDuplicate) {
          _showErrorDialog('A passenger with this name already exists');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      final passenger = PassengerModel(
        id: widget.passenger?.id,
        bookingId: widget.bookingId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: _ageController.text.isNotEmpty
            ? int.tryParse(_ageController.text)
            : null,
        nationality: _nationalityController.text.trim().isNotEmpty
            ? _nationalityController.text.trim()
            : null,
        idPassportNumber: _documentController.text.trim().isNotEmpty
            ? _documentController.text.trim()
            : null,
      );

      bool success = true;

      if (provider.isLocalMode) {
        // Handle local mode (before booking is created)
        if (widget.passenger != null) {
          // Update existing local passenger
          final index = provider.passengers.indexOf(widget.passenger!);
          if (index >= 0) {
            provider.updatePassengerLocally(index, passenger);
          }
        } else {
          // Add new local passenger
          provider.addPassengerLocally(passenger);
        }
      } else {
        // Handle backend mode (after booking is created)
        if (widget.passenger != null) {
          // Update existing passenger
          success =
              await provider.updatePassenger(widget.passenger!.id!, passenger);
        } else {
          // Create new passenger
          success = await provider.addPassenger(passenger);
        }
      }

      if (success) {
        widget.onSuccess?.call();
        Navigator.pop(context);
      } else {
        _showErrorDialog(provider.errorMessage ?? 'Failed to save passenger');
      }
    } catch (e) {
      _showErrorDialog('An unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Error',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF666666),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
