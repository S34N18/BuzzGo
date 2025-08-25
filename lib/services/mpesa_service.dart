import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import '../models/payment_model.dart';
import '../utils/constants.dart';

class MpesaService {
  static const String sandboxBaseUrl = 'https://sandbox.safaricom.co.ke';
  static const String productionBaseUrl = 'https://api.safaricom.co.ke';
  
  final String consumerKey = AppConstants.mpesaConsumerKey;
  final String consumerSecret = AppConstants.mpesaConsumerSecret;
  final String shortCode = AppConstants.mpesaShortCode;
  final String passkey = AppConstants.mpesaPasskey;
  final String callbackUrl = AppConstants.mpesaCallbackUrl;
  
  bool get isProduction => AppConstants.isProduction;
  String get baseUrl => isProduction ? productionBaseUrl : sandboxBaseUrl;

  // Generate access token
  Future<String> generateAccessToken() async {
    try {
      String credentials = base64Encode(utf8.encode('$consumerKey:$consumerSecret'));
      
      final response = await http.get(
        Uri.parse('$baseUrl/oauth/v1/generate?grant_type=client_credentials'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      } else {
        throw Exception('Failed to generate access token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Access token generation error: ${e.toString()}');
    }
  }

  // Generate password for STK push
  String generatePassword() {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String dataToEncode = shortCode + passkey + timestamp;
    return base64Encode(utf8.encode(dataToEncode));
  }

  // Get timestamp
  String getTimestamp() {
    DateTime now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'
           '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}'
           '${now.second.toString().padLeft(2, '0')}';
  }

  // Initiate STK Push
  Future<Map<String, dynamic>> initiateSTKPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    try {
      String accessToken = await generateAccessToken();
      String password = generatePassword();
      String timestamp = getTimestamp();

      // Format phone number (remove leading 0 and add 254)
      String formattedPhone = phoneNumber.startsWith('0') 
          ? '254${phoneNumber.substring(1)}' 
          : phoneNumber;

      Map<String, dynamic> requestBody = {
        'BusinessShortCode': shortCode,
        'Password': password,
        'Timestamp': timestamp,
        'TransactionType': 'CustomerPayBillOnline',
        'Amount': amount.toInt(),
        'PartyA': formattedPhone,
        'PartyB': shortCode,
        'PhoneNumber': formattedPhone,
        'CallBackURL': callbackUrl,
        'AccountReference': accountReference,
        'TransactionDesc': transactionDesc,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('STK Push failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('STK Push error: ${e.toString()}');
    }
  }

  // Query STK Push status
  Future<Map<String, dynamic>> querySTKPushStatus(String checkoutRequestId) async {
    try {
      String accessToken = await generateAccessToken();
      String password = generatePassword();
      String timestamp = getTimestamp();

      Map<String, dynamic> requestBody = {
        'BusinessShortCode': shortCode,
        'Password': password,
        'Timestamp': timestamp,
        'CheckoutRequestID': checkoutRequestId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/mpesa/stkpushquery/v1/query'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('STK Push query failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('STK Push query error: ${e.toString()}');
    }
  }

  // Process payment for event
  Future<PaymentModel> processEventPayment({
    required String userId,
    required String eventId,
    required String phoneNumber,
    required double amount,
    required String eventTitle,
  }) async {
    try {
      // Create payment record
      PaymentModel payment = PaymentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        eventId: eventId,
        amount: amount,
        paymentMethod: 'M-Pesa',
        transactionId: '',
        status: PaymentStatus.pending,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Initiate STK Push
      Map<String, dynamic> stkResponse = await initiateSTKPush(
        phoneNumber: phoneNumber,
        amount: amount,
        accountReference: eventId,
        transactionDesc: 'Payment for $eventTitle',
      );

      if (stkResponse['ResponseCode'] == '0') {
        // Update payment with checkout request ID
        payment = payment.copyWith(
          transactionId: stkResponse['CheckoutRequestID'],
          status: PaymentStatus.processing,
          updatedAt: DateTime.now(),
        );
      } else {
        payment = payment.copyWith(
          status: PaymentStatus.failed,
          updatedAt: DateTime.now(),
        );
      }

      return payment;
    } catch (e) {
      throw Exception('Payment processing error: ${e.toString()}');
    }
  }

  // Handle M-Pesa callback
  Map<String, dynamic> handleCallback(Map<String, dynamic> callbackData) {
    try {
      final stkCallback = callbackData['Body']['stkCallback'];
      final resultCode = stkCallback['ResultCode'];
      final checkoutRequestId = stkCallback['CheckoutRequestID'];
      
      Map<String, dynamic> result = {
        'checkoutRequestId': checkoutRequestId,
        'success': resultCode == 0,
        'resultCode': resultCode,
        'resultDesc': stkCallback['ResultDesc'],
      };

      if (resultCode == 0) {
        // Payment successful, extract callback metadata
        final callbackMetadata = stkCallback['CallbackMetadata']['Item'];
        
        for (var item in callbackMetadata) {
          switch (item['Name']) {
            case 'Amount':
              result['amount'] = item['Value'];
              break;
            case 'MpesaReceiptNumber':
              result['mpesaReceiptNumber'] = item['Value'];
              break;
            case 'TransactionDate':
              result['transactionDate'] = item['Value'];
              break;
            case 'PhoneNumber':
              result['phoneNumber'] = item['Value'];
              break;
          }
        }
      }

      return result;
    } catch (e) {
      throw Exception('Callback processing error: ${e.toString()}');
    }
  }

  // Validate phone number format
  bool isValidPhoneNumber(String phoneNumber) {
    // Remove any spaces or special characters
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid Kenyan number
    if (cleanNumber.startsWith('254') && cleanNumber.length == 12) {
      return true;
    } else if (cleanNumber.startsWith('0') && cleanNumber.length == 10) {
      return true;
    } else if (cleanNumber.startsWith('7') && cleanNumber.length == 9) {
      return true;
    }
    
    return false;
  }

  // Format phone number for display
  String formatPhoneNumber(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanNumber.startsWith('254')) {
      return '+254 ${cleanNumber.substring(3, 6)} ${cleanNumber.substring(6, 9)} ${cleanNumber.substring(9)}';
    } else if (cleanNumber.startsWith('0')) {
      return '${cleanNumber.substring(0, 4)} ${cleanNumber.substring(4, 7)} ${cleanNumber.substring(7)}';
    }
    
    return phoneNumber;
  }

  // Get payment status description
  String getPaymentStatusDescription(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Payment initiated';
      case PaymentStatus.processing:
        return 'Processing payment';
      case PaymentStatus.completed:
        return 'Payment successful';
      case PaymentStatus.failed:
        return 'Payment failed';
      case PaymentStatus.cancelled:
        return 'Payment cancelled';
      case PaymentStatus.refunded:
        return 'Payment refunded';
    }
  }
}