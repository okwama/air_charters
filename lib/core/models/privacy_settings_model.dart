class PrivacySettingsModel {
  final bool dataSharing;
  final bool marketingEmails;
  final bool smsNotifications;
  final bool pushNotifications;
  final bool profileVisible;
  final bool locationTracking;

  PrivacySettingsModel({
    this.dataSharing = false,
    this.marketingEmails = true,
    this.smsNotifications = true,
    this.pushNotifications = true,
    this.profileVisible = false,
    this.locationTracking = true,
  });

  factory PrivacySettingsModel.fromJson(Map<String, dynamic> json) {
    return PrivacySettingsModel(
      dataSharing: json['dataSharing'] ?? false,
      marketingEmails: json['marketingEmails'] ?? true,
      smsNotifications: json['smsNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      profileVisible: json['profileVisible'] ?? false,
      locationTracking: json['locationTracking'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dataSharing': dataSharing,
      'marketingEmails': marketingEmails,
      'smsNotifications': smsNotifications,
      'pushNotifications': pushNotifications,
      'profileVisible': profileVisible,
      'locationTracking': locationTracking,
    };
  }

  PrivacySettingsModel copyWith({
    bool? dataSharing,
    bool? marketingEmails,
    bool? smsNotifications,
    bool? pushNotifications,
    bool? profileVisible,
    bool? locationTracking,
  }) {
    return PrivacySettingsModel(
      dataSharing: dataSharing ?? this.dataSharing,
      marketingEmails: marketingEmails ?? this.marketingEmails,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      profileVisible: profileVisible ?? this.profileVisible,
      locationTracking: locationTracking ?? this.locationTracking,
    );
  }
}
