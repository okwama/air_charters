import 'passenger_model.dart';
import 'booking_stop_model.dart';

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

enum PaymentMethod {
  card,
  mpesa,
  wallet,
}

class BookingModel {
  final String? id;
  final String? referenceNumber;
  final String userId;
  final int dealId;
  final int? companyId; // Added: Company ID from backend
  final double totalPrice;
  final BookingStatus bookingStatus;
  final PaymentStatus paymentStatus;
  final bool onboardDining;
  final bool groundTransportation;
  final String? specialRequirements;
  final String? billingRegion;
  final PaymentMethod? paymentMethod;
  final String? paymentTransactionId; // Added: Payment transaction ID
  final int loyaltyPointsEarned; // Added: Loyalty points earned
  final int loyaltyPointsRedeemed; // Added: Loyalty points redeemed
  final double walletAmountUsed; // Added: Wallet amount used
  final List<PassengerModel> passengers;
  final List<BookingStopModel> stops;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Deal-related data (populated from backend relations)
  final String? departure;
  final String? destination;
  final DateTime? departureDate;
  final String? departureTime;
  final int? duration;
  final double? basePrice;
  final String? aircraftName;
  final String? companyName;

  const BookingModel({
    this.id,
    this.referenceNumber,
    required this.userId,
    required this.dealId,
    this.companyId,
    required this.totalPrice,
    this.bookingStatus = BookingStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.onboardDining = false,
    this.groundTransportation = false,
    this.specialRequirements,
    this.billingRegion,
    this.paymentMethod,
    this.paymentTransactionId,
    this.loyaltyPointsEarned = 0,
    this.loyaltyPointsRedeemed = 0,
    this.walletAmountUsed = 0.0,
    this.passengers = const [],
    this.stops = const [],
    this.createdAt,
    this.updatedAt,
    // Deal-related data
    this.departure,
    this.destination,
    this.departureDate,
    this.departureTime,
    this.duration,
    this.basePrice,
    this.aircraftName,
    this.companyName,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    try {
      print('=== PARSING BOOKING MODEL ===');
      print('JSON keys: ${json.keys.toList()}');

      // Parse basic fields
      final id = json['id']?.toString();
      final referenceNumber = json['referenceNumber'] as String?;
      final userId = json['userId'] as String? ?? '';
      final dealId = json['dealId'] as int? ?? 0;
      final companyId = json['companyId'] as int?;
      final totalPrice =
          double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0;
      final bookingStatus =
          _parseBookingStatus(json['bookingStatus'] as String?);
      final paymentStatus =
          _parsePaymentStatus(json['paymentStatus'] as String?);
      final onboardDining = (json['onboardDining'] as int?) == 1;
      final groundTransportation = (json['groundTransportation'] as int?) == 1;
      final specialRequirements = json['specialRequirements'] as String?;
      final billingRegion = json['billingRegion'] as String?;
      print('=== PARSING PAYMENT METHOD FIELD ===');
      print('Payment method field: ${json['paymentMethod']}');
      print('Payment method field type: ${json['paymentMethod'].runtimeType}');
      final paymentMethod =
          _parsePaymentMethod(json['paymentMethod'] as String?);
      final paymentTransactionId = json['paymentTransactionId'] as String?;
      final loyaltyPointsEarned = json['loyaltyPointsEarned'] as int? ?? 0;
      final loyaltyPointsRedeemed = json['loyaltyPointsRedeemed'] as int? ?? 0;
      final walletAmountUsed =
          double.tryParse(json['walletAmountUsed']?.toString() ?? '0') ?? 0.0;

      // Parse passengers with detailed logging
      print('Parsing passengers...');
      print('Passengers field type: ${json['passengers']?.runtimeType}');
      print('Passengers field value: ${json['passengers']}');
      final passengers = _parsePassengersList(json['passengers']);
      print('Passengers parsed successfully: ${passengers.length} passengers');

      // Parse stops with detailed logging
      print('Parsing stops...');
      print('Stops field type: ${json['stops']?.runtimeType}');
      print('Stops field value: ${json['stops']}');
      final stops = _parseStopsList(json['stops']);
      print('Stops parsed successfully: ${stops.length} stops');

      // Parse dates
      DateTime? createdAt;
      if (json['createdAt'] != null) {
        createdAt = DateTime.parse(json['createdAt'] as String);
      }

      DateTime? updatedAt;
      if (json['updatedAt'] != null) {
        updatedAt = DateTime.parse(json['updatedAt'] as String);
      }

      // Parse deal-related data from nested structure
      // For trips API: booking.deal.route.origin and booking.deal.route.destination
      // For bookings API: direct departure/destination fields
      String? departure;
      String? destination;
      DateTime? departureDate;
      String? departureTime;
      int? duration;
      double? basePrice;
      String? aircraftName;
      String? companyName;

      // Check if we have nested deal data (from trips API)
      if (json['deal'] != null) {
        final deal = json['deal'] as Map<String, dynamic>;

        // Get route data
        if (deal['route'] != null) {
          final route = deal['route'] as Map<String, dynamic>;
          departure = route['origin'] as String?;
          destination = route['destination'] as String?;
          duration = route['duration'] as int?;
        }

        // Get deal data
        departureDate = deal['date'] != null
            ? DateTime.parse(deal['date'] as String)
            : null;
        departureTime = deal['time'] as String?;
        basePrice = double.tryParse(deal['pricePerSeat']?.toString() ?? '0');

        // Get aircraft data
        if (deal['aircraft'] != null) {
          final aircraft = deal['aircraft'] as Map<String, dynamic>;
          aircraftName = aircraft['name'] as String?;
        }

        // Get company data
        if (deal['company'] != null) {
          final company = deal['company'] as Map<String, dynamic>;
          companyName = company['name'] as String?;
        }
      } else if (json['directCharter'] != null) {
        // Handle direct charter shape from trips API
        final direct = json['directCharter'] as Map<String, dynamic>;
        // Route nested under directCharter.route
        if (direct['route'] != null) {
          final route = direct['route'] as Map<String, dynamic>;
          departure = route['origin'] as String?;
          destination = route['destination'] as String?;
        }
        // Derive departure date/time from booking.departureDateTime when present
        if (json['departureDateTime'] != null) {
          try {
            final dt = DateTime.parse(json['departureDateTime'] as String);
            departureDate = dt;
            // Simple HH:mm formatting
            final hh = dt.hour.toString().padLeft(2, '0');
            final mm = dt.minute.toString().padLeft(2, '0');
            departureTime = '$hh:$mm';
          } catch (_) {}
        }
        // Optional: pick up aircraft/company names if provided
        if (direct['aircraft'] != null) {
          final ac = direct['aircraft'] as Map<String, dynamic>;
          aircraftName = (ac['name'] ?? ac['model'])?.toString();
        }
        if (direct['company'] != null) {
          final comp = direct['company'] as Map<String, dynamic>;
          companyName = (comp['name'] ?? comp['companyName'])?.toString();
        }
      } else {
        // Fallback to direct fields (from bookings API)
        departure = json['departure'] as String? ?? json['origin'] as String?;
        destination = json['destination'] as String?;

        if (json['departureDate'] != null) {
          departureDate = DateTime.parse(json['departureDate'] as String);
        } else if (json['departureDateTime'] != null) {
          try {
            final dt = DateTime.parse(json['departureDateTime'] as String);
            departureDate = dt;
            final hh = dt.hour.toString().padLeft(2, '0');
            final mm = dt.minute.toString().padLeft(2, '0');
            departureTime = '$hh:$mm';
          } catch (_) {}
        }

        departureTime = json['departureTime'] as String?;
        duration = json['duration'] as int?;
        basePrice = double.tryParse(json['basePrice']?.toString() ?? '0');
        aircraftName = json['aircraftName'] as String?;
        companyName = json['companyName'] as String?;
      }

      print('All fields parsed successfully');

      return BookingModel(
        id: id,
        referenceNumber: referenceNumber,
        userId: userId,
        dealId: dealId,
        companyId: companyId,
        totalPrice: totalPrice,
        bookingStatus: bookingStatus,
        paymentStatus: paymentStatus,
        onboardDining: onboardDining,
        groundTransportation: groundTransportation,
        specialRequirements: specialRequirements,
        billingRegion: billingRegion,
        paymentMethod: paymentMethod,
        paymentTransactionId: paymentTransactionId,
        loyaltyPointsEarned: loyaltyPointsEarned,
        loyaltyPointsRedeemed: loyaltyPointsRedeemed,
        walletAmountUsed: walletAmountUsed,
        passengers: passengers,
        stops: stops,
        createdAt: createdAt,
        updatedAt: updatedAt,
        departure: departure,
        destination: destination,
        departureDate: departureDate,
        departureTime: departureTime,
        duration: duration,
        basePrice: basePrice,
        aircraftName: aircraftName,
        companyName: companyName,
      );
    } catch (e, stackTrace) {
      print('=== ERROR PARSING BOOKING MODEL ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
      'userId': userId,
      'dealId': dealId,
      if (companyId != null) 'companyId': companyId,
      'totalPrice': totalPrice,
      'bookingStatus': bookingStatus.name,
      'paymentStatus': paymentStatus.name,
      'onboardDining': onboardDining,
      'groundTransportation': groundTransportation,
      if (specialRequirements != null)
        'specialRequirements': specialRequirements,
      if (billingRegion != null) 'billingRegion': billingRegion,
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.name,
      if (paymentTransactionId != null)
        'paymentTransactionId': paymentTransactionId,
      'loyaltyPointsEarned': loyaltyPointsEarned,
      'loyaltyPointsRedeemed': loyaltyPointsRedeemed,
      'walletAmountUsed': walletAmountUsed,
      'passengers': passengers.map((p) => p.toCreateJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Create JSON for booking creation (without server-generated fields)
  Map<String, dynamic> toCreateJson() {
    print('=== BOOKING MODEL TO CREATE JSON ===');
    print('Deal ID: $dealId (${dealId.runtimeType})');
    print('Total price: $totalPrice (${totalPrice.runtimeType})');
    print('Onboard dining: $onboardDining (${onboardDining.runtimeType})');
    print(
        'Ground transportation: $groundTransportation (${groundTransportation.runtimeType})');
    print(
        'Special requirements: $specialRequirements (${specialRequirements.runtimeType})');
    print('Billing region: $billingRegion (${billingRegion.runtimeType})');
    print('Payment method: $paymentMethod (${paymentMethod.runtimeType})');
    print(
        'Payment method name: ${paymentMethod?.name} (${paymentMethod?.name.runtimeType})');
    print('Passengers count: ${passengers.length}');

    final passengerJsonList = passengers.map((p) => p.toCreateJson()).toList();
    print('Passenger JSON list type: ${passengerJsonList.runtimeType}');
    print(
        'First passenger JSON: ${passengerJsonList.isNotEmpty ? passengerJsonList.first : 'No passengers'}');

    final json = {
      'dealId': dealId,
      'totalPrice': totalPrice,
      'onboardDining': onboardDining,
      // Removed groundTransportation - not in database schema
      if (specialRequirements != null)
        'specialRequirements': specialRequirements,
      if (billingRegion != null) 'billingRegion': billingRegion,
      // Removed paymentMethod - not in database schema
      'passengers': passengerJsonList,
    };

    print('Final JSON: $json');
    return json;
  }

  BookingModel copyWith({
    String? id,
    String? referenceNumber,
    String? userId,
    int? dealId,
    int? companyId,
    double? totalPrice,
    BookingStatus? bookingStatus,
    PaymentStatus? paymentStatus,
    bool? onboardDining,
    bool? groundTransportation,
    String? specialRequirements,
    String? billingRegion,
    PaymentMethod? paymentMethod,
    String? paymentTransactionId,
    int? loyaltyPointsEarned,
    int? loyaltyPointsRedeemed,
    double? walletAmountUsed,
    List<PassengerModel>? passengers,
    List<BookingStopModel>? stops,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Deal-related data
    String? departure,
    String? destination,
    DateTime? departureDate,
    String? departureTime,
    int? duration,
    double? basePrice,
    String? aircraftName,
    String? companyName,
  }) {
    return BookingModel(
      id: id ?? this.id,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      userId: userId ?? this.userId,
      dealId: dealId ?? this.dealId,
      companyId: companyId ?? this.companyId,
      totalPrice: totalPrice ?? this.totalPrice,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      onboardDining: onboardDining ?? this.onboardDining,
      groundTransportation: groundTransportation ?? this.groundTransportation,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      billingRegion: billingRegion ?? this.billingRegion,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentTransactionId: paymentTransactionId ?? this.paymentTransactionId,
      loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
      loyaltyPointsRedeemed:
          loyaltyPointsRedeemed ?? this.loyaltyPointsRedeemed,
      walletAmountUsed: walletAmountUsed ?? this.walletAmountUsed,
      passengers: passengers ?? this.passengers,
      stops: stops ?? this.stops,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // Deal-related data
      departure: departure ?? this.departure,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      duration: duration ?? this.duration,
      basePrice: basePrice ?? this.basePrice,
      aircraftName: aircraftName ?? this.aircraftName,
      companyName: companyName ?? this.companyName,
    );
  }

  // Helper methods
  String get formattedPrice => '\$${totalPrice.toFixed(2)}';

  String get formattedDate =>
      '${departureDate?.day}/${departureDate?.month}/${departureDate?.year}';

  bool get isConfirmed =>
      bookingStatus == BookingStatus.confirmed ||
      bookingStatus == BookingStatus.completed;

  bool get isPaid => paymentStatus == PaymentStatus.paid;

  bool get canBeCancelled =>
      bookingStatus == BookingStatus.pending ||
      bookingStatus == BookingStatus.confirmed;

  // Computed properties for UI display
  int get totalPassengers => passengers.length;

  String get aircraft => aircraftName ?? 'Aircraft #$dealId';

  String? get bookingReference => referenceNumber;

  // New computed properties for loyalty and wallet
  double get netAmount => totalPrice - walletAmountUsed;

  int get netLoyaltyPoints => loyaltyPointsEarned - loyaltyPointsRedeemed;

  bool get hasLoyaltyPoints =>
      loyaltyPointsEarned > 0 || loyaltyPointsRedeemed > 0;

  bool get hasWalletUsage => walletAmountUsed > 0;

  String get statusDisplayText {
    switch (bookingStatus) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  String get paymentStatusDisplayText {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  // Helper method to get primary passenger (user)
  PassengerModel? get primaryPassenger {
    try {
      return passengers.firstWhere(
        (p) => p.isUser == true,
      );
    } catch (e) {
      return null;
    }
  }

  // Helper method to get additional passengers
  List<PassengerModel> get additionalPassengers {
    return passengers.where((p) => p.isUser != true).toList();
  }

  static BookingStatus _parseBookingStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  static PaymentMethod? _parsePaymentMethod(String? method) {
    print('=== PARSING PAYMENT METHOD ===');
    print('Input method: $method');
    print('Input method type: ${method.runtimeType}');

    if (method == null) {
      print('Method is null, returning null');
      return null;
    }

    final lowerMethod = method.toLowerCase();
    print('Lowercase method: $lowerMethod');

    PaymentMethod? result;
    switch (lowerMethod) {
      case 'card':
        result = PaymentMethod.card;
        break;
      case 'mpesa':
        result = PaymentMethod.mpesa;
        break;
      case 'wallet':
        result = PaymentMethod.wallet;
        break;
      default:
        result = null;
        break;
    }

    print('Parsed result: $result');
    return result;
  }

  static List<PassengerModel> _parsePassengersList(dynamic value) {
    try {
      print('=== PARSING PASSENGERS LIST ===');
      print('Value type: ${value.runtimeType}');
      print('Value: $value');

      if (value == null) {
        print('Value is null, returning empty list');
        return [];
      }

      if (value is List) {
        print('Value is List, processing ${value.length} items');
        final passengers = value.whereType<Map<String, dynamic>>().map((p) {
          print('Parsing passenger: $p');
          return PassengerModel.fromJson(p);
        }).toList();
        print('Successfully parsed ${passengers.length} passengers');
        return passengers;
      }

      print('Value is not a List, returning empty list');
      return [];
    } catch (e, stackTrace) {
      print('=== ERROR PARSING PASSENGERS LIST ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('Value: $value');
      rethrow;
    }
  }

  static List<BookingStopModel> _parseStopsList(dynamic value) {
    try {
      print('=== PARSING STOPS LIST ===');
      print('Value type: ${value.runtimeType}');
      print('Value: $value');

      if (value == null) {
        print('Value is null, returning empty list');
        return [];
      }

      if (value is List) {
        print('Value is List, processing ${value.length} items');
        final stops = value.whereType<Map<String, dynamic>>().map((s) {
          print('Parsing stop: $s');
          return BookingStopModel.fromJson(s);
        }).toList();
        print('Successfully parsed ${stops.length} stops');
        return stops;
      }

      print('Value is not a List, returning empty list');
      return [];
    } catch (e, stackTrace) {
      print('=== ERROR PARSING STOPS LIST ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('Value: $value');
      rethrow;
    }
  }
}

extension DoubleExtension on double {
  String toFixed(int places) {
    return toStringAsFixed(places);
  }
}
