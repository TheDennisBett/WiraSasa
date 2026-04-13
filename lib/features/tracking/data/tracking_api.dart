import 'package:wirasasa/core/network/api_client.dart';
import 'package:wirasasa/core/network/api_models.dart';

class TrackingApi {
  TrackingApi(this._client);

  final ApiClient _client;

  Future<JobTracking> getJobTracking({
    required String bearerToken,
    required String jobId,
  }) async {
    final response = await _client.getJson(
      '/api/jobs/$jobId/tracking',
      bearerToken: bearerToken,
    );
    return JobTracking.fromJson(response as Map<String, dynamic>);
  }

  Future<TrackingPoint> postProviderLocation({
    required String bearerToken,
    required String jobId,
    required double latitude,
    required double longitude,
    required double heading,
    required double speedKph,
  }) async {
    final response = await _client.postJson(
      '/api/provider-locations',
      bearerToken: bearerToken,
      body: {
        'jobId': jobId,
        'latitude': latitude,
        'longitude': longitude,
        'heading': heading,
        'speedKph': speedKph,
      },
    );
    return TrackingPoint.fromJson(response as Map<String, dynamic>);
  }
}
