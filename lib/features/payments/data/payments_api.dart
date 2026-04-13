import 'package:wirasasa/core/network/api_client.dart';
import 'package:wirasasa/core/network/api_models.dart';

class PaymentsApi {
  PaymentsApi(this._client);

  final ApiClient _client;

  Future<InitiatedPayment> initiate({
    required String bearerToken,
    required String serviceRequestId,
    required double amount,
    required String currency,
    required String paymentMethod,
    bool markAsPaid = false,
  }) async {
    final response = await _client.postJson(
      '/api/payments/initiate',
      bearerToken: bearerToken,
      body: {
        'serviceRequestId': serviceRequestId,
        'amount': amount,
        'currency': currency,
        'paymentMethod': paymentMethod,
        'markAsPaid': markAsPaid,
      },
    );
    return InitiatedPayment.fromJson(response as Map<String, dynamic>);
  }

  Future<Invoice> getInvoice({
    required String bearerToken,
    required String invoiceId,
  }) async {
    final response = await _client.getJson(
      '/api/invoices/$invoiceId',
      bearerToken: bearerToken,
    );
    return Invoice.fromJson(response as Map<String, dynamic>);
  }

  Future<Receipt> getReceipt({
    required String bearerToken,
    required String receiptId,
  }) async {
    final response = await _client.getJson(
      '/api/receipts/$receiptId',
      bearerToken: bearerToken,
    );
    return Receipt.fromJson(response as Map<String, dynamic>);
  }
}
