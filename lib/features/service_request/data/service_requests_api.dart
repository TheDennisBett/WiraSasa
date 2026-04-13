import 'package:wirasasa/core/network/api_client.dart';
import 'package:wirasasa/core/network/api_models.dart';

class ServiceRequestsApi {
  ServiceRequestsApi(this._client);

  final ApiClient _client;

  Future<ServiceRequest> create({
    required String bearerToken,
    required String serviceCode,
    required String serviceName,
    required String description,
    required String locationLabel,
    required double latitude,
    required double longitude,
    required DateTime? scheduledAtUtc,
    required double budgetAmount,
    required String currency,
    required String providerId,
  }) async {
    final response = await _client.postJson(
      '/api/service-requests',
      bearerToken: bearerToken,
      body: {
        'serviceCode': serviceCode,
        'serviceName': serviceName,
        'description': description,
        'locationLabel': locationLabel,
        'latitude': latitude,
        'longitude': longitude,
        'scheduledAtUtc': scheduledAtUtc?.toUtc().toIso8601String(),
        'budgetAmount': budgetAmount,
        'currency': currency,
        'providerId': providerId,
      },
    );
    return ServiceRequest.fromJson(response as Map<String, dynamic>);
  }

  Future<List<ServiceRequest>> list(String bearerToken) async {
    final response = await _client.getJson(
      '/api/service-requests',
      bearerToken: bearerToken,
    );
    return (response as List<dynamic>)
        .map((item) => ServiceRequest.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ServiceRequest> getById({
    required String bearerToken,
    required String id,
  }) async {
    final response = await _client.getJson(
      '/api/service-requests/$id',
      bearerToken: bearerToken,
    );
    return ServiceRequest.fromJson(response as Map<String, dynamic>);
  }

  Future<ServiceRequest> updateStatus({
    required String bearerToken,
    required String id,
    required String status,
    String? note,
  }) async {
    final response = await _client.patchJson(
      '/api/service-requests/$id/status',
      bearerToken: bearerToken,
      body: {
        'status': status,
        'note': note,
      },
    );
    return ServiceRequest.fromJson(response as Map<String, dynamic>);
  }
}
