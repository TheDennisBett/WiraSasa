import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wirasasa/core/network/api_client.dart';

void main() {
  test('sends JSON headers and bearer token', () async {
    final client = ApiClient(
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/auth/send-otp');
        expect(request.headers['Accept'], 'application/json');
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.headers['Authorization'], 'Bearer access-token');
        expect(request.body, '{"phoneNumber":"+254711222333"}');
        return http.Response('{"challengeId":"otp_1"}', 200);
      }),
    );

    final response = await client.postJson(
      '/api/auth/send-otp',
      bearerToken: 'access-token',
      body: {'phoneNumber': '+254711222333'},
    );

    expect(response, {'challengeId': 'otp_1'});
  });

  test('maps backend problem shape to ApiException message', () async {
    final client = ApiClient(
      httpClient: MockClient(
        (_) async => http.Response(
          '{"code":"invalid_operation","message":"Phone number is already registered."}',
          400,
        ),
      ),
    );

    await expectLater(
      client.postJson('/api/auth/register-account', body: const {}),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'statusCode', 400)
            .having(
              (error) => error.message,
              'message',
              'Phone number is already registered.',
            ),
      ),
    );
  });

  test('fails closed on invalid JSON response', () async {
    final client = ApiClient(
      httpClient: MockClient((_) async => http.Response('not-json', 200)),
    );

    await expectLater(
      client.getJson('/api/catalog/services'),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          'API returned an invalid JSON response.',
        ),
      ),
    );
  });
}
