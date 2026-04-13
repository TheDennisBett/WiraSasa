import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wirasasa/core/network/api_client.dart';
import 'package:wirasasa/features/auth/data/auth_api.dart';
import 'package:wirasasa/features/payments/data/payments_api.dart';
import 'package:wirasasa/features/tracking/data/tracking_api.dart';

void main() {
  test('registerAccount posts the backend create-account contract', () async {
    final authApi = AuthApi(
      ApiClient(
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/auth/register-account');
          expect(jsonDecode(request.body), {
            'phoneNumber': '+254711222333',
            'firstName': 'Jane',
            'lastName': 'Doe',
            'email': 'jane@example.com',
            'password': 'StrongPass123!',
            'requestedRole': 'client',
          });
          return http.Response(
            jsonEncode({
              'userId': 'usr_1',
              'phoneNumber': '+254711222333',
              'displayName': 'Jane Doe',
              'roles': ['client'],
            }),
            200,
          );
        }),
      ),
    );

    final user = await authApi.registerAccount(
      phoneNumber: '+254711222333',
      firstName: 'Jane',
      lastName: 'Doe',
      email: 'jane@example.com',
      password: 'StrongPass123!',
      requestedRole: 'client',
    );

    expect(user.userId, 'usr_1');
    expect(user.roles, ['client']);
  });

  test(
    'tracking API maps job tracking and provider location endpoints',
    () async {
      final trackingApi = TrackingApi(
        ApiClient(
          httpClient: MockClient((request) async {
            expect(request.headers['Authorization'], 'Bearer access-token');
            if (request.method == 'GET') {
              expect(request.url.path, '/api/jobs/job_1/tracking');
              return http.Response(
                jsonEncode({
                  'jobId': 'job_1',
                  'serviceRequestId': 'req_1',
                  'providerId': 'prv_1',
                  'status': 'enRoute',
                  'trackingPoints': [
                    {
                      'id': 'trk_1',
                      'latitude': -1.26,
                      'longitude': 36.8,
                      'heading': 90,
                      'speedKph': 24,
                      'recordedAtUtc': '2026-04-13T08:00:00Z',
                    },
                  ],
                }),
                200,
              );
            }

            expect(request.method, 'POST');
            expect(request.url.path, '/api/provider-locations');
            expect(jsonDecode(request.body), {
              'jobId': 'job_1',
              'latitude': -1.26,
              'longitude': 36.8,
              'heading': 90.0,
              'speedKph': 24.0,
            });
            return http.Response(
              jsonEncode({
                'id': 'trk_2',
                'latitude': -1.26,
                'longitude': 36.8,
                'heading': 90,
                'speedKph': 24,
                'recordedAtUtc': '2026-04-13T08:01:00Z',
              }),
              200,
            );
          }),
        ),
      );

      final tracking = await trackingApi.getJobTracking(
        bearerToken: 'access-token',
        jobId: 'job_1',
      );
      final point = await trackingApi.postProviderLocation(
        bearerToken: 'access-token',
        jobId: 'job_1',
        latitude: -1.26,
        longitude: 36.8,
        heading: 90,
        speedKph: 24,
      );

      expect(tracking.trackingPoints.single.id, 'trk_1');
      expect(point.id, 'trk_2');
    },
  );

  test('payments API maps initiate, invoice, and receipt endpoints', () async {
    final paymentsApi = PaymentsApi(
      ApiClient(
        httpClient: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer access-token');
          switch (request.url.path) {
            case '/api/payments/initiate':
              expect(request.method, 'POST');
              expect(jsonDecode(request.body), {
                'serviceRequestId': 'req_1',
                'amount': 2500.0,
                'currency': 'KES',
                'paymentMethod': 'mpesa',
                'markAsPaid': true,
              });
              return http.Response(
                jsonEncode({
                  'invoice': _invoiceJson(),
                  'payment': _paymentJson(),
                  'receipt': _receiptJson(),
                }),
                200,
              );
            case '/api/invoices/inv_1':
              expect(request.method, 'GET');
              return http.Response(jsonEncode(_invoiceJson()), 200);
            case '/api/receipts/rcp_1':
              expect(request.method, 'GET');
              return http.Response(jsonEncode(_receiptJson()), 200);
          }
          return http.Response('{"message":"unexpected"}', 404);
        }),
      ),
    );

    final initiated = await paymentsApi.initiate(
      bearerToken: 'access-token',
      serviceRequestId: 'req_1',
      amount: 2500,
      currency: 'KES',
      paymentMethod: 'mpesa',
      markAsPaid: true,
    );
    final invoice = await paymentsApi.getInvoice(
      bearerToken: 'access-token',
      invoiceId: 'inv_1',
    );
    final receipt = await paymentsApi.getReceipt(
      bearerToken: 'access-token',
      receiptId: 'rcp_1',
    );

    expect(initiated.invoice.id, 'inv_1');
    expect(initiated.receipt?.id, 'rcp_1');
    expect(invoice.status, 'paid');
    expect(receipt.paymentId, 'pay_1');
  });
}

Map<String, Object> _invoiceJson() {
  return {
    'id': 'inv_1',
    'serviceRequestId': 'req_1',
    'amount': 2500,
    'currency': 'KES',
    'status': 'paid',
    'createdAtUtc': '2026-04-13T08:00:00Z',
  };
}

Map<String, Object> _paymentJson() {
  return {
    'id': 'pay_1',
    'invoiceId': 'inv_1',
    'method': 'mpesa',
    'status': 'paid',
    'providerReference': 'mock_ref',
    'createdAtUtc': '2026-04-13T08:00:01Z',
  };
}

Map<String, Object> _receiptJson() {
  return {
    'id': 'rcp_1',
    'invoiceId': 'inv_1',
    'paymentId': 'pay_1',
    'amount': 2500,
    'currency': 'KES',
    'issuedAtUtc': '2026-04-13T08:00:02Z',
  };
}
