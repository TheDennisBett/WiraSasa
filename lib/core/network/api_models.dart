import 'package:flutter/material.dart';

class AuthUser {
  const AuthUser({
    required this.userId,
    required this.phoneNumber,
    required this.displayName,
    required this.roles,
  });

  final String userId;
  final String phoneNumber;
  final String displayName;
  final List<String> roles;

  String get initials {
    final parts = displayName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'WS';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['userId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      displayName: json['displayName'] as String,
      roles: (json['roles'] as List<dynamic>).cast<String>(),
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAtUtc,
    required this.refreshTokenExpiresAtUtc,
  });

  final AuthUser user;
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAtUtc;
  final DateTime refreshTokenExpiresAtUtc;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpiresAtUtc: DateTime.parse(
        json['accessTokenExpiresAtUtc'] as String,
      ),
      refreshTokenExpiresAtUtc: DateTime.parse(
        json['refreshTokenExpiresAtUtc'] as String,
      ),
    );
  }
}

class UserLookup {
  const UserLookup({
    required this.phoneNumber,
    required this.isExistingUser,
    required this.nextAction,
    required this.userId,
    required this.displayName,
    required this.roles,
  });

  final String phoneNumber;
  final bool isExistingUser;
  final String nextAction;
  final String? userId;
  final String? displayName;
  final List<String> roles;

  factory UserLookup.fromJson(Map<String, dynamic> json) {
    return UserLookup(
      phoneNumber: json['phoneNumber'] as String,
      isExistingUser: json['isExistingUser'] as bool,
      nextAction: json['nextAction'] as String,
      userId: json['userId'] as String?,
      displayName: json['displayName'] as String?,
      roles: (json['roles'] as List<dynamic>? ?? const []).cast<String>(),
    );
  }
}

class OtpChallenge {
  const OtpChallenge({
    required this.challengeId,
    required this.phoneNumber,
    required this.expiresInSeconds,
    required this.isExistingUser,
    required this.nextAction,
    required this.devOtpCode,
    this.channel,
    this.maskedDestination,
  });

  final String challengeId;
  final String phoneNumber;
  final int expiresInSeconds;
  final bool isExistingUser;
  final String nextAction;
  final String? devOtpCode;
  final String? channel;
  final String? maskedDestination;

  String get destination {
    final masked = maskedDestination?.trim();
    if (masked != null && masked.isNotEmpty) {
      return masked;
    }
    return phoneNumber;
  }

  factory OtpChallenge.fromJson(Map<String, dynamic> json) {
    return OtpChallenge(
      challengeId: json['challengeId'] as String,
      phoneNumber: json['phoneNumber'] as String? ?? '',
      expiresInSeconds: json['expiresInSeconds'] as int? ?? 0,
      isExistingUser: json['isExistingUser'] as bool? ?? false,
      nextAction: json['nextAction'] as String? ?? '',
      devOtpCode: json['devOtpCode'] as String?,
      channel: json['channel'] as String?,
      maskedDestination: json['maskedDestination'] as String?,
    );
  }
}

class ServiceCategory {
  const ServiceCategory({
    required this.code,
    required this.name,
    required this.group,
    required this.description,
    required this.colorHex,
  });

  final String code;
  final String name;
  final String group;
  final String description;
  final String colorHex;

  Color get color {
    final value = colorHex.replaceFirst('#', '');
    final normalized = value.length == 6 ? 'FF$value' : value;
    return Color(int.parse(normalized, radix: 16));
  }

  IconData get icon {
    switch (code.toLowerCase()) {
      case 'electrician':
        return Icons.bolt_rounded;
      case 'plumber':
        return Icons.plumbing_rounded;
      case 'mechanic':
        return Icons.directions_car_filled_rounded;
      case 'gardener':
        return Icons.eco_outlined;
      default:
        return Icons.home_repair_service_rounded;
    }
  }

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      code: json['code'] as String,
      name: json['name'] as String,
      group: json['group'] as String,
      description: json['description'] as String,
      colorHex: json['colorHex'] as String,
    );
  }
}

class ProviderService {
  const ProviderService({
    required this.id,
    required this.serviceCode,
    required this.serviceName,
    required this.basePrice,
    required this.currency,
    required this.pricingUnit,
    required this.isActive,
  });

  final String id;
  final String serviceCode;
  final String serviceName;
  final double basePrice;
  final String currency;
  final String pricingUnit;
  final bool isActive;

  factory ProviderService.fromJson(Map<String, dynamic> json) {
    return ProviderService(
      id: json['id'] as String,
      serviceCode: json['serviceCode'] as String,
      serviceName: json['serviceName'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      currency: json['currency'] as String,
      pricingUnit: json['pricingUnit'] as String,
      isActive: json['isActive'] as bool,
    );
  }
}

class ProviderSummary {
  const ProviderSummary({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.bio,
    required this.verificationStatus,
    required this.rating,
    required this.completedJobs,
    required this.distance,
    required this.eta,
    required this.reviewSnippet,
    required this.isOnline,
    required this.latitude,
    required this.longitude,
    required this.services,
  });

  final String id;
  final String userId;
  final String displayName;
  final String bio;
  final String verificationStatus;
  final double rating;
  final int completedJobs;
  final String distance;
  final String eta;
  final String reviewSnippet;
  final bool isOnline;
  final double latitude;
  final double longitude;
  final List<ProviderService> services;

  String get initials {
    final parts = displayName.split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  ProviderService? get primaryService =>
      services.isEmpty ? null : services.first;

  factory ProviderSummary.fromJson(Map<String, dynamic> json) {
    return ProviderSummary(
      id: json['id'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      bio: json['bio'] as String,
      verificationStatus: json['verificationStatus'] as String,
      rating: (json['rating'] as num).toDouble(),
      completedJobs: json['completedJobs'] as int,
      distance: json['distance'] as String,
      eta: json['eta'] as String,
      reviewSnippet: json['reviewSnippet'] as String,
      isOnline: json['isOnline'] as bool,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      services: (json['services'] as List<dynamic>)
          .map((item) => ProviderService.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ServiceRequestStatusHistory {
  const ServiceRequestStatusHistory({
    required this.id,
    required this.status,
    required this.changedByUserId,
    required this.changedAtUtc,
    required this.note,
  });

  final String id;
  final String status;
  final String changedByUserId;
  final DateTime changedAtUtc;
  final String? note;

  factory ServiceRequestStatusHistory.fromJson(Map<String, dynamic> json) {
    return ServiceRequestStatusHistory(
      id: json['id'] as String,
      status: json['status'] as String,
      changedByUserId: json['changedByUserId'] as String,
      changedAtUtc: DateTime.parse(json['changedAtUtc'] as String),
      note: json['note'] as String?,
    );
  }
}

class ServiceRequest {
  const ServiceRequest({
    required this.id,
    required this.clientUserId,
    required this.providerId,
    required this.serviceCode,
    required this.serviceName,
    required this.description,
    required this.locationLabel,
    required this.latitude,
    required this.longitude,
    required this.scheduledAtUtc,
    required this.budgetAmount,
    required this.currency,
    required this.status,
    required this.bookingType,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    required this.jobId,
    required this.statusHistory,
  });

  final String id;
  final String clientUserId;
  final String? providerId;
  final String serviceCode;
  final String serviceName;
  final String description;
  final String locationLabel;
  final double latitude;
  final double longitude;
  final DateTime? scheduledAtUtc;
  final double budgetAmount;
  final String currency;
  final String status;
  final String bookingType;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final String? jobId;
  final List<ServiceRequestStatusHistory> statusHistory;

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
      clientUserId: json['clientUserId'] as String,
      providerId: json['providerId'] as String?,
      serviceCode: json['serviceCode'] as String,
      serviceName: json['serviceName'] as String,
      description: json['description'] as String,
      locationLabel: json['locationLabel'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      scheduledAtUtc: json['scheduledAtUtc'] == null
          ? null
          : DateTime.parse(json['scheduledAtUtc'] as String),
      budgetAmount: (json['budgetAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      bookingType: json['bookingType'] as String,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
      updatedAtUtc: DateTime.parse(json['updatedAtUtc'] as String),
      jobId: json['jobId'] as String?,
      statusHistory: (json['statusHistory'] as List<dynamic>)
          .map(
            (item) => ServiceRequestStatusHistory.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class ProviderDashboardRequest {
  const ProviderDashboardRequest({
    required this.requestId,
    required this.clientName,
    required this.serviceName,
    required this.locationLabel,
    required this.scheduledAtUtc,
    required this.budgetAmount,
    required this.currency,
    required this.status,
  });

  final String requestId;
  final String clientName;
  final String serviceName;
  final String locationLabel;
  final DateTime? scheduledAtUtc;
  final double budgetAmount;
  final String currency;
  final String status;

  factory ProviderDashboardRequest.fromJson(Map<String, dynamic> json) {
    return ProviderDashboardRequest(
      requestId: json['requestId'] as String,
      clientName: json['clientName'] as String,
      serviceName: json['serviceName'] as String,
      locationLabel: json['locationLabel'] as String,
      scheduledAtUtc: json['scheduledAtUtc'] == null
          ? null
          : DateTime.parse(json['scheduledAtUtc'] as String),
      budgetAmount: (json['budgetAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
    );
  }
}

class ProviderDashboard {
  const ProviderDashboard({
    required this.providerId,
    required this.isOnline,
    required this.todayEarnings,
    required this.completedJobs,
    required this.incomingRequests,
  });

  final String providerId;
  final bool isOnline;
  final double todayEarnings;
  final int completedJobs;
  final List<ProviderDashboardRequest> incomingRequests;

  factory ProviderDashboard.fromJson(Map<String, dynamic> json) {
    return ProviderDashboard(
      providerId: json['providerId'] as String,
      isOnline: json['isOnline'] as bool,
      todayEarnings: (json['todayEarnings'] as num).toDouble(),
      completedJobs: json['completedJobs'] as int,
      incomingRequests: (json['incomingRequests'] as List<dynamic>)
          .map(
            (item) =>
                ProviderDashboardRequest.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class TrackingPoint {
  const TrackingPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.speedKph,
    required this.recordedAtUtc,
  });

  final String id;
  final double latitude;
  final double longitude;
  final double heading;
  final double speedKph;
  final DateTime recordedAtUtc;

  factory TrackingPoint.fromJson(Map<String, dynamic> json) {
    return TrackingPoint(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      heading: (json['heading'] as num).toDouble(),
      speedKph: (json['speedKph'] as num).toDouble(),
      recordedAtUtc: DateTime.parse(json['recordedAtUtc'] as String),
    );
  }
}

class JobTracking {
  const JobTracking({
    required this.jobId,
    required this.serviceRequestId,
    required this.providerId,
    required this.status,
    required this.trackingPoints,
  });

  final String jobId;
  final String serviceRequestId;
  final String providerId;
  final String status;
  final List<TrackingPoint> trackingPoints;

  factory JobTracking.fromJson(Map<String, dynamic> json) {
    return JobTracking(
      jobId: json['jobId'] as String,
      serviceRequestId: json['serviceRequestId'] as String,
      providerId: json['providerId'] as String,
      status: json['status'] as String,
      trackingPoints: (json['trackingPoints'] as List<dynamic>)
          .map((item) => TrackingPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Invoice {
  const Invoice({
    required this.id,
    required this.serviceRequestId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAtUtc,
  });

  final String id;
  final String serviceRequestId;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAtUtc;

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      serviceRequestId: json['serviceRequestId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
    );
  }
}

class Payment {
  const Payment({
    required this.id,
    required this.invoiceId,
    required this.method,
    required this.status,
    required this.providerReference,
    required this.createdAtUtc,
  });

  final String id;
  final String invoiceId;
  final String method;
  final String status;
  final String providerReference;
  final DateTime createdAtUtc;

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String,
      method: json['method'] as String,
      status: json['status'] as String,
      providerReference: json['providerReference'] as String,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
    );
  }
}

class Receipt {
  const Receipt({
    required this.id,
    required this.invoiceId,
    required this.paymentId,
    required this.amount,
    required this.currency,
    required this.issuedAtUtc,
  });

  final String id;
  final String invoiceId;
  final String paymentId;
  final double amount;
  final String currency;
  final DateTime issuedAtUtc;

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String,
      paymentId: json['paymentId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      issuedAtUtc: DateTime.parse(json['issuedAtUtc'] as String),
    );
  }
}

class InitiatedPayment {
  const InitiatedPayment({
    required this.invoice,
    required this.payment,
    required this.receipt,
  });

  final Invoice invoice;
  final Payment payment;
  final Receipt? receipt;

  factory InitiatedPayment.fromJson(Map<String, dynamic> json) {
    return InitiatedPayment(
      invoice: Invoice.fromJson(json['invoice'] as Map<String, dynamic>),
      payment: Payment.fromJson(json['payment'] as Map<String, dynamic>),
      receipt: json['receipt'] == null
          ? null
          : Receipt.fromJson(json['receipt'] as Map<String, dynamic>),
    );
  }
}
