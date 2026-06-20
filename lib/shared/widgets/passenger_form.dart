import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/models/passenger_model.dart';
import '../../core/providers/passengers_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../config/theme/app_theme.dart';
import 'enhanced_text_field.dart';

enum PassengerFormMode {
  single,    // Single passenger entry
  multi,     // Multiple passengers with pagination
  modal,     // Modal form
  experience // Experience-specific form
}

class PassengerForm extends StatefulWidget {
  final PassengerFormMode mode;
  final int passengerCount;
  final List<PassengerModel>? existingPassengers;
  final PassengerModel? passenger; // For editing
  final String? bookingId;
  final bool isInternationalFlight;
  final String? origin;
  final String? destination;
  final VoidCallback? onSuccess;
  final Function(List<PassengerModel>)? onPassengersChanged;
  final bool showUserAsFirstPassenger;

  const PassengerForm({
    super.key,
    required this.mode,
    this.passengerCount = 1,
    this.existingPassengers,
    this.passenger,
    this.bookingId,
    this.isInternationalFlight = false,
    this.origin,
    this.destination,
    this.onSuccess,
    this.onPassengersChanged,
    this.showUserAsFirstPassenger = true,
  });

  @override
  State<PassengerForm> createState() => _PassengerFormState();
}

class _PassengerFormState extends State<PassengerForm> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  
  List<PassengerModel> _passengers = [];
  int _currentPassengerIndex = 0;
  bool _isLoading = false;

  // Form controllers for all passengers
  final Map<int, Map<String, TextEditingController>> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializePassengers();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final passengerControllers in _controllers.values) {
      for (final controller in passengerControllers.values) {
        controller.dispose();
      }
    }
    _pageController.dispose();
    super.dispose();
  }

  void _initializePassengers() {
    if (widget.mode == PassengerFormMode.single && widget.passenger != null) {
      // Single passenger editing mode
      _passengers = [widget.passenger!];
    } else if (widget.existingPassengers != null && widget.existingPassengers!.isNotEmpty) {
      // Use existing passengers
      _passengers = List.from(widget.existingPassengers!);
    } else {
      // Create new passengers
      _passengers = List.generate(widget.passengerCount, (index) {
        if (index == 0 && widget.showUserAsFirstPassenger) {
          final authProvider = context.read<AuthProvider>();
          final user = authProvider.currentUser;
          
          if (user != null) {
            final age = user.dateOfBirth != null 
                ? _calculateAge(user.dateOfBirth!)
                : 25;
                
            return PassengerModel.fromUser(
              firstName: user.firstName ?? '',
              lastName: user.lastName ?? '',
              age: age,
              nationality: user.nationality ?? 'Kenyan',
            );
          }
        }
        return PassengerModel.empty();
      });
    }

    // Initialize controllers for all passengers
    for (int i = 0; i < _passengers.length; i++) {
      _controllers[i] = {
        'firstName': TextEditingController(text: _passengers[i].firstName),
        'lastName': TextEditingController(text: _passengers[i].lastName),
        'age': TextEditingController(text: (_passengers[i].age ?? 0).toString()),
        'nationality': TextEditingController(text: _passengers[i].nationality ?? ''),
        'idPassportNumber': TextEditingController(text: _passengers[i].idPassportNumber ?? ''),
      };
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.mode) {
      case PassengerFormMode.single:
        return _buildSingleForm();
      case PassengerFormMode.multi:
        return _buildMultiForm();
      case PassengerFormMode.modal:
        return _buildModalForm();
      case PassengerFormMode.experience:
        return _buildExperienceForm();
    }
  }

  Widget _buildSingleForm() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.passenger != null ? 'Edit Passenger' : 'Add Passenger',
          style: AppTheme.heading3.copyWith(color: AppTheme.textPrimaryColor),
        ),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimaryColor),
      ),
      body: _buildFormContent(),
    );
  }

  Widget _buildMultiForm() {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Passenger Details (${_currentPassengerIndex + 1}/${widget.passengerCount})',
          style: AppTheme.heading3.copyWith(color: AppTheme.textPrimaryColor),
        ),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimaryColor),
        actions: [
          if (_currentPassengerIndex > 0)
            IconButton(
              icon: const Icon(LucideIcons.chevronLeft),
              onPressed: _previousPassenger,
            ),
          if (_currentPassengerIndex < widget.passengerCount - 1)
            IconButton(
              icon: const Icon(LucideIcons.chevronRight),
              onPressed: _nextPassenger,
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          // International flight banner
          if (widget.isInternationalFlight) _buildInternationalBanner(),
          // Form content
          Expanded(child: _buildFormContent()),
        ],
      ),
    );
  }

  Widget _buildModalForm() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Text(
                widget.passenger != null ? 'Edit Passenger' : 'Add Passenger',
                style: AppTheme.heading3.copyWith(color: AppTheme.textPrimaryColor),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(LucideIcons.x, color: AppTheme.textPrimaryColor),
              ),
            ],
          ),
          Divider(color: AppTheme.borderColor),
          // Form content
          Expanded(child: _buildFormContent()),
        ],
      ),
    );
  }

  Widget _buildExperienceForm() {
    return _buildFormContent();
  }

  Widget _buildFormContent() {
    if (widget.mode == PassengerFormMode.multi) {
      return PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPassengerIndex = index;
          });
        },
        itemCount: widget.passengerCount,
        itemBuilder: (context, index) {
          return _buildPassengerForm(index);
        },
      );
    } else {
      return _buildPassengerForm(0);
    }
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: List.generate(widget.passengerCount, (index) {
              final isActive = index <= _currentPassengerIndex;
              final isCompleted = index < _currentPassengerIndex;
              
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < widget.passengerCount - 1 ? 8 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? AppTheme.successColor
                        : isActive 
                            ? AppTheme.primaryColor
                            : AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Passenger ${_currentPassengerIndex + 1} of ${widget.passengerCount}',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternationalBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.globe,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'International flight: All passenger details are required',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerForm(int index) {
    final passenger = _passengers[index];
    final controllers = _controllers[index]!;
    final isUserPassenger = index == 0 && widget.showUserAsFirstPassenger;

    return Form(
      key: index == _currentPassengerIndex ? _formKey : null,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Passenger header
            _buildPassengerHeader(index, isUserPassenger),
            const SizedBox(height: 24),

            // Name fields
            Row(
              children: [
                Expanded(
                  child: EnhancedTextField(
                    controller: controllers['firstName']!,
                    label: 'First Name',
                    hintText: 'Enter first name',
                    prefixIcon: LucideIcons.user,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: EnhancedTextField(
                    controller: controllers['lastName']!,
                    label: 'Last Name',
                    hintText: 'Enter last name',
                    prefixIcon: LucideIcons.user,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Age and Nationality
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: EnhancedTextField(
                    controller: controllers['age']!,
                    label: 'Age',
                    hintText: 'Age',
                    prefixIcon: LucideIcons.calendar,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Age is required';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age <= 0 || age > 150) {
                        return 'Valid age required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: EnhancedTextField(
                    controller: controllers['nationality']!,
                    label: 'Nationality',
                    hintText: 'Enter nationality',
                    prefixIcon: LucideIcons.flag,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nationality is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Passport/ID Number
            EnhancedTextField(
              controller: controllers['idPassportNumber']!,
              label: 'Passport/ID Number',
              hintText: 'Enter passport or ID number',
              prefixIcon: LucideIcons.fileText,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Passport/ID number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Action buttons
            _buildActionButtons(index),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerHeader(int index, bool isUserPassenger) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              isUserPassenger ? LucideIcons.user : LucideIcons.users,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUserPassenger ? 'Primary Passenger (You)' : 'Passenger ${index + 1}',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                if (isUserPassenger)
                  Text(
                    'Your details will be used for this passenger',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActionButtons(int index) {
    if (widget.mode == PassengerFormMode.multi) {
      return Row(
        children: [
          if (_currentPassengerIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPassenger,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.primaryColor),
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentPassengerIndex > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextOrConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(_currentPassengerIndex < widget.passengerCount - 1 ? 'Next' : 'Confirm'),
            ),
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _savePassenger,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(widget.passenger != null ? 'Update Passenger' : 'Add Passenger'),
        ),
      );
    }
  }

  void _updateCurrentPassenger() {
    final controllers = _controllers[_currentPassengerIndex]!;
    
    // Log the raw controller values before processing
    print('PASSENGER_FORM: Raw controller values:');
    print('  firstName: "${controllers['firstName']!.text}" (type: ${controllers['firstName']!.text.runtimeType})');
    print('  lastName: "${controllers['lastName']!.text}" (type: ${controllers['lastName']!.text.runtimeType})');
    print('  age: "${controllers['age']!.text}" (type: ${controllers['age']!.text.runtimeType})');
    print('  nationality: "${controllers['nationality']!.text}" (type: ${controllers['nationality']!.text.runtimeType})');
    print('  idPassportNumber: "${controllers['idPassportNumber']!.text}" (type: ${controllers['idPassportNumber']!.text.runtimeType})');
    
    // Process the values
    final firstName = controllers['firstName']!.text.trim();
    final lastName = controllers['lastName']!.text.trim();
    final ageText = controllers['age']!.text;
    final age = int.tryParse(ageText) ?? 25;
    final nationality = controllers['nationality']!.text.trim();
    final idPassportText = controllers['idPassportNumber']!.text.trim();
    final idPassportNumber = idPassportText.isEmpty ? null : idPassportText;
    
    print('PASSENGER_FORM: Processed values:');
    print('  firstName: "$firstName" (type: ${firstName.runtimeType})');
    print('  lastName: "$lastName" (type: ${lastName.runtimeType})');
    print('  age: $age (type: ${age.runtimeType})');
    print('  nationality: "$nationality" (type: ${nationality.runtimeType})');
    print('  idPassportNumber: "$idPassportNumber" (type: ${idPassportNumber.runtimeType})');
    
    _passengers[_currentPassengerIndex] = _passengers[_currentPassengerIndex].copyWith(
      firstName: firstName,
      lastName: lastName,
      age: age,
      nationality: nationality,
      idPassportNumber: idPassportNumber,
    );

    try {
      print('PASSENGER_FORM: Updated passenger index=$_currentPassengerIndex data=' 
          '${_passengers[_currentPassengerIndex].toJson()}');
    } catch (e) {
      print('PASSENGER_FORM: Error logging passenger data: $e');
    }
  }

  void _nextPassenger() {
    if (!_formKey.currentState!.validate()) {
      print('PASSENGER_FORM: Next pressed but validation failed at index=$_currentPassengerIndex');
      return;
    }

    _updateCurrentPassenger();
    
    if (_currentPassengerIndex < widget.passengerCount - 1) {
      setState(() {
        _currentPassengerIndex++;
      });
      print('PASSENGER_FORM: Navigating to next passenger index=$_currentPassengerIndex');
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      print('PASSENGER_FORM: Last passenger reached, proceeding to confirm');
      _confirmPassengers();
    }
  }

  void _previousPassenger() {
    if (_currentPassengerIndex > 0) {
      _updateCurrentPassenger();
      setState(() {
        _currentPassengerIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextOrConfirm() {
    if (widget.mode == PassengerFormMode.multi) {
      _nextPassenger();
    } else {
      _savePassenger();
    }
  }

  void _confirmPassengers() {
    if (!_formKey.currentState!.validate()) {
      print('PASSENGER_FORM: Confirm pressed but validation failed at index=$_currentPassengerIndex');
      return;
    }

    _updateCurrentPassenger();
    
    // Validate all passengers
    final errors = <String>[];
    for (int i = 0; i < _passengers.length; i++) {
      final passengerErrors = _passengers[i].getValidationErrors(
        isInternationalFlight: true, // Always require all fields now
      );
      if (passengerErrors.isNotEmpty) {
        errors.add('Passenger ${i + 1}: ${passengerErrors.join(', ')}');
      }
    }
    
    if (errors.isNotEmpty) {
      print('PASSENGER_FORM: Validation errors: $errors');
      _showErrorDialog(errors);
      return;
    }

    print('PASSENGER_FORM: All passengers validated successfully');
    print('PASSENGER_FORM: Calling onPassengersChanged with ${_passengers.length} passengers');
    widget.onPassengersChanged?.call(_passengers);
    print('PASSENGER_FORM: Calling onSuccess');
    widget.onSuccess?.call();
    
    if (widget.mode == PassengerFormMode.multi) {
      Navigator.pop(context, _passengers);
    }
  }

  void _savePassenger() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _updateCurrentPassenger();
      final passenger = _passengers[0];

      if (widget.mode == PassengerFormMode.modal || widget.mode == PassengerFormMode.single) {
        // Handle provider-based flows
        final provider = Provider.of<PassengerProvider>(context, listen: false);

        bool success = true;
        String actionText = '';

        if (provider.isLocalMode) {
          // Handle local mode (before booking is created)
          if (widget.passenger != null) {
            // Update existing local passenger
            final index = provider.passengers.indexOf(widget.passenger!);
            if (index >= 0) {
              provider.updatePassengerLocally(index, passenger);
              actionText = 'updated';
            }
          } else {
            // Add new local passenger
            provider.addPassengerLocally(passenger);
            actionText = 'added';
          }
        } else {
          // Handle backend mode (after booking is created)
          if (widget.passenger != null) {
            // Update existing passenger
            if (widget.passenger!.id != null) {
              await provider.updatePassenger(widget.passenger!.id!, passenger);
              actionText = 'updated';
            } else {
              // If no ID, treat as new passenger
              await provider.addPassenger(passenger);
              actionText = 'added';
            }
          } else {
            // Add new passenger
            await provider.addPassenger(passenger);
            actionText = 'added';
          }
        }

        if (success) {
          widget.onSuccess?.call();
          if (widget.mode == PassengerFormMode.modal) {
            Navigator.pop(context, passenger);
          } else {
            Navigator.pop(context, passenger);
          }
        }
      } else {
        // Handle direct charter flows
        widget.onPassengersChanged?.call([passenger]);
        widget.onSuccess?.call();
        Navigator.pop(context, passenger);
      }
    } catch (e) {
      print('PASSENGER_FORM: Error saving passenger: $e');
      _showErrorDialog(['Failed to save passenger: $e']);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Validation Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: errors.map((error) => Text('• $error')).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
