import 'package:wirasasa/core/network/api_client.dart';
import 'package:wirasasa/core/network/api_models.dart';

class ProvidersApi {
  ProvidersApi(this._client);

  final ApiClient _client;

  Future<List<ProviderSummary>> searchProviders({
    String? serviceCode,
    String? query,
    bool onlineOnly = true,
  }) async {
    final response = await _client.getJson(
      '/api/providers',
      query: {
        if (serviceCode != null && serviceCode.isNotEmpty)
          'serviceCode': serviceCode,
        if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
        'onlineOnly': onlineOnly.toString(),
      },
    );
    return (response as List<dynamic>)
        .map((item) => ProviderSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ProviderSummary> getProvider(String id) async {
    final response = await _client.getJson('/api/providers/$id');
    return ProviderSummary.fromJson(response as Map<String, dynamic>);
  }

  Future<ProviderDashboard> getDashboard(String bearerToken) async {
    final response = await _client.getJson(
      '/api/providers/me/dashboard',
      bearerToken: bearerToken,
    );
    return ProviderDashboard.fromJson(response as Map<String, dynamic>);
  }
}
