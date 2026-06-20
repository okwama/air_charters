import 'dart:convert';
import 'package:http/http.dart' as http;
import '../error/network_error_handler.dart';
import '../../config/env/app_config.dart';

class Yacht {
  final int id;
  final int companyId;
  final String name;
  final String type;
  final String description;
  final int capacity;
  final bool isAvailable;
  final String pricePerHour;
  final String pricePerDay;
  final String maintenanceStatus;
  final String location;
  final String city;
  final int yachtTypeImagePlaceholderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final YachtCompany company;
  final List<YachtImage> images;

  Yacht({
    required this.id,
    required this.companyId,
    required this.name,
    required this.type,
    required this.description,
    required this.capacity,
    required this.isAvailable,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.maintenanceStatus,
    required this.location,
    required this.city,
    required this.yachtTypeImagePlaceholderId,
    required this.createdAt,
    required this.updatedAt,
    required this.company,
    required this.images,
  });

  factory Yacht.fromJson(Map<String, dynamic> json) {
    return Yacht(
      id: json['id'] as int,
      companyId: json['companyId'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      capacity: json['capacity'] as int,
      isAvailable: (json['isAvailable'] as int) == 1,
      pricePerHour: json['pricePerHour'] as String,
      pricePerDay: json['pricePerDay'] as String,
      maintenanceStatus: json['maintenanceStatus'] as String,
      location: json['location'] as String,
      city: json['city'] as String,
      yachtTypeImagePlaceholderId: json['yachtTypeImagePlaceholderId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      company: YachtCompany.fromJson(json['company'] as Map<String, dynamic>),
      images: (json['images'] as List<dynamic>)
          .map((image) => YachtImage.fromJson(image as Map<String, dynamic>))
          .toList(),
    );
  }
}

class YachtCompany {
  final int id;
  final String companyName;
  final String email;
  final String contactPersonFirstName;
  final String contactPersonLastName;
  final String mobileNumber;
  final String logo;
  final String country;
  final String licenseNumber;
  final String logoPublicId;
  final String onboardedBy;
  final int adminId;
  final String status;
  final String agreementForm;
  final String agreementFormPublicId;
  final String? license;
  final String? licensePublicId;
  final String approvedBy;
  final DateTime approvedAt;
  final String reviewRemarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  YachtCompany({
    required this.id,
    required this.companyName,
    required this.email,
    required this.contactPersonFirstName,
    required this.contactPersonLastName,
    required this.mobileNumber,
    required this.logo,
    required this.country,
    required this.licenseNumber,
    required this.logoPublicId,
    required this.onboardedBy,
    required this.adminId,
    required this.status,
    required this.agreementForm,
    required this.agreementFormPublicId,
    this.license,
    this.licensePublicId,
    required this.approvedBy,
    required this.approvedAt,
    required this.reviewRemarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory YachtCompany.fromJson(Map<String, dynamic> json) {
    return YachtCompany(
      id: json['id'] as int,
      companyName: json['companyName'] as String,
      email: json['email'] as String,
      contactPersonFirstName: json['contactPersonFirstName'] as String,
      contactPersonLastName: json['contactPersonLastName'] as String,
      mobileNumber: json['mobileNumber'] as String,
      logo: json['logo'] as String,
      country: json['country'] as String,
      licenseNumber: json['licenseNumber'] as String,
      logoPublicId: json['logoPublicId'] as String,
      onboardedBy: json['onboardedBy'] as String,
      adminId: json['adminId'] as int,
      status: json['status'] as String,
      agreementForm: json['agreementForm'] as String,
      agreementFormPublicId: json['agreementFormPublicId'] as String,
      license: json['license'] as String?,
      licensePublicId: json['licensePublicId'] as String?,
      approvedBy: json['approvedBy'] as String,
      approvedAt: DateTime.parse(json['approvedAt'] as String),
      reviewRemarks: json['reviewRemarks'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class YachtImage {
  final int id;
  final int yachtId;
  final String category;
  final String url;
  final String publicId;
  final DateTime createdAt;
  final DateTime updatedAt;

  YachtImage({
    required this.id,
    required this.yachtId,
    required this.category,
    required this.url,
    required this.publicId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory YachtImage.fromJson(Map<String, dynamic> json) {
    return YachtImage(
      id: json['id'] as int,
      yachtId: json['yachtId'] as int,
      category: json['category'] as String,
      url: json['url'] as String,
      publicId: json['publicId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class YachtType {
  final int id;
  final String type;
  final String? placeholderImageUrl;
  final String? placeholderImagePublicId;
  final DateTime createdAt;
  final DateTime updatedAt;

  YachtType({
    required this.id,
    required this.type,
    this.placeholderImageUrl,
    this.placeholderImagePublicId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory YachtType.fromJson(Map<String, dynamic> json) {
    return YachtType(
      id: json['id'] as int,
      type: json['type'] as String,
      placeholderImageUrl: json['placeholderImageUrl'] as String?,
      placeholderImagePublicId: json['placeholderImagePublicId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class YachtService {
  static String get _baseUrl => AppConfig.baseUrl;

  /// Get all yacht types (derived from available yachts)
  Future<List<YachtType>> getYachtTypes() async {
    try {
      // Get all yachts to extract unique types
      final result = await getYachts(page: 1, limit: 100);
      final yachts = result['yachts'] as List<Yacht>;

      // Extract unique types
      final Set<String> uniqueTypes = yachts.map((yacht) => yacht.type).toSet();

      // Create YachtType objects
      final List<YachtType> yachtTypes = uniqueTypes.map((type) {
        return YachtType(
          id: type.hashCode,
          type: type,
          placeholderImageUrl: null,
          placeholderImagePublicId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();

      return yachtTypes;
    } catch (e) {
      print('Error fetching yacht types: $e');
      final networkError = NetworkErrorResult.fromException(e);
      throw NetworkException(networkError.message, networkError);
    }
  }

  /// Get all yachts with pagination and filtering
  Future<Map<String, dynamic>> getYachts({
    int page = 1,
    int limit = 10,
    String? type,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (type != null) {
        queryParams['type'] = type;
      }

      final uri = Uri.parse('$_baseUrl/api/yachts')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.authToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> yachtsJson = data['yachts'];
        final yachts = yachtsJson.map((json) => Yacht.fromJson(json)).toList();

        return {
          'yachts': yachts,
          'total': data['total'] as int,
          'page': data['page'] as int,
          'limit': data['limit'] as int,
          'totalPages': data['totalPages'] as int,
        };
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error fetching yachts: $e');
      final networkError = NetworkErrorResult.fromException(e);
      throw NetworkException(networkError.message, networkError);
    }
  }

  /// Get yacht by ID
  Future<Yacht> getYachtById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/yachts/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.authToken}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Yacht.fromJson(data);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error fetching yacht by ID: $e');
      final networkError = NetworkErrorResult.fromException(e);
      throw NetworkException(networkError.message, networkError);
    }
  }

  /// Filter yachts
  Future<Map<String, dynamic>> filterYachts(
      Map<String, dynamic> filters) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/yachts/filter'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.authToken}',
        },
        body: jsonEncode(filters),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> yachtsJson = data['yachts'];
        final yachts = yachtsJson.map((json) => Yacht.fromJson(json)).toList();

        return {
          'yachts': yachts,
          'total': data['total'] as int,
          'page': data['page'] as int,
          'limit': data['limit'] as int,
          'totalPages': data['totalPages'] as int,
        };
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error filtering yachts: $e');
      final networkError = NetworkErrorResult.fromException(e);
      throw NetworkException(networkError.message, networkError);
    }
  }
}
