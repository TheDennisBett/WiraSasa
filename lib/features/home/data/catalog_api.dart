import 'package:wirasasa/core/network/api_client.dart';
import 'package:wirasasa/core/network/api_models.dart';

class CatalogApi {
  CatalogApi(this._client);

  final ApiClient _client;

  Future<List<ServiceCategory>> getServices() async {
    final response = await _client.getJson('/api/catalog/services');
    return (response as List<dynamic>)
        .map((item) => ServiceCategory.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
