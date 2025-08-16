class DirectCharterAircraft {
  final int id;
  final String name;
  final String model;
  final int capacity;
  final double pricePerHour;
  final String baseAirport;
  final String baseCity;
  final String companyName;
  final String? imageUrl;
  final double totalPrice;
  final double repositioningCost;
  final double flightDurationHours;
  final double totalHours;
  final int priority;

  DirectCharterAircraft({
    required this.id,
    required this.name,
    required this.model,
    required this.capacity,
    required this.pricePerHour,
    required this.baseAirport,
    required this.baseCity,
    required this.companyName,
    this.imageUrl,
    required this.totalPrice,
    required this.repositioningCost,
    required this.flightDurationHours,
    required this.totalHours,
    required this.priority,
  });

  factory DirectCharterAircraft.fromJson(Map<String, dynamic> json) {
    return DirectCharterAircraft(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      model: json['model'] ?? '',
      capacity: json['capacity'] ?? 0,
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
      baseAirport: json['baseAirport'] ?? '',
      baseCity: json['baseCity'] ?? '',
      companyName: json['companyName'] ?? '',
      imageUrl: json['imageUrl'],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      repositioningCost: (json['repositioningCost'] ?? 0).toDouble(),
      flightDurationHours: (json['flightDurationHours'] ?? 0).toDouble(),
      totalHours: (json['totalHours'] ?? 0).toDouble(),
      priority: json['priority'] ?? 999,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'model': model,
      'capacity': capacity,
      'pricePerHour': pricePerHour,
      'baseAirport': baseAirport,
      'baseCity': baseCity,
      'companyName': companyName,
      'imageUrl': imageUrl,
      'totalPrice': totalPrice,
      'repositioningCost': repositioningCost,
      'flightDurationHours': flightDurationHours,
      'totalHours': totalHours,
      'priority': priority,
    };
  }
}

class DirectCharterBooking {
  final String bookingId;
  final String status;
  final String message;
  final String referenceNumber;
  final double totalPrice;

  DirectCharterBooking({
    required this.bookingId,
    required this.status,
    required this.message,
    required this.referenceNumber,
    required this.totalPrice,
  });

  factory DirectCharterBooking.fromJson(Map<String, dynamic> json) {
    return DirectCharterBooking(
      bookingId: json['bookingId'] ?? '',
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      referenceNumber: json['referenceNumber'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'status': status,
      'message': message,
      'referenceNumber': referenceNumber,
      'totalPrice': totalPrice,
    };
  }
}

class DirectCharterPaymentIntent {
  final String id;
  final String clientSecret;
  final String status;
  final bool requiresAction;
  final Map<String, dynamic>? nextAction;

  DirectCharterPaymentIntent({
    required this.id,
    required this.clientSecret,
    required this.status,
    required this.requiresAction,
    this.nextAction,
  });

  factory DirectCharterPaymentIntent.fromJson(Map<String, dynamic> json) {
    return DirectCharterPaymentIntent(
      id: json['id'] ?? '',
      clientSecret: json['clientSecret'] ?? '',
      status: json['status'] ?? '',
      requiresAction: json['requiresAction'] ?? false,
      nextAction: json['nextAction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientSecret': clientSecret,
      'status': status,
      'requiresAction': requiresAction,
      'nextAction': nextAction,
    };
  }
}

class DirectCharterPaymentInstructions {
  final double amount;
  final String currency;
  final List<String> paymentMethods;
  final List<String> nextSteps;
  final Map<String, String?> apiEndpoints;

  DirectCharterPaymentInstructions({
    required this.amount,
    required this.currency,
    required this.paymentMethods,
    required this.nextSteps,
    required this.apiEndpoints,
  });

  factory DirectCharterPaymentInstructions.fromJson(Map<String, dynamic> json) {
    return DirectCharterPaymentInstructions(
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      paymentMethods: List<String>.from(json['paymentMethods'] ?? []),
      nextSteps: List<String>.from(json['nextSteps'] ?? []),
      apiEndpoints: Map<String, String?>.from(json['apiEndpoints'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'paymentMethods': paymentMethods,
      'nextSteps': nextSteps,
      'apiEndpoints': apiEndpoints,
    };
  }
}

class DirectCharterBookingResponse {
  final Map<String, dynamic> booking;
  final DirectCharterPaymentIntent? paymentIntent;
  final DirectCharterPaymentInstructions paymentInstructions;
  final String message;

  DirectCharterBookingResponse({
    required this.booking,
    this.paymentIntent,
    required this.paymentInstructions,
    required this.message,
  });

  factory DirectCharterBookingResponse.fromJson(Map<String, dynamic> json) {
    return DirectCharterBookingResponse(
      booking: Map<String, dynamic>.from(json['booking'] ?? {}),
      paymentIntent: json['paymentIntent'] != null
          ? DirectCharterPaymentIntent.fromJson(json['paymentIntent'])
          : null,
      paymentInstructions: DirectCharterPaymentInstructions.fromJson(
          json['paymentInstructions'] ?? {}),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking': booking,
      'paymentIntent': paymentIntent?.toJson(),
      'paymentInstructions': paymentInstructions.toJson(),
      'message': message,
    };
  }
} 