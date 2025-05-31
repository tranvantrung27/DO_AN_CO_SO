import 'dart:convert';
import 'package:http/http.dart' as http;

class MailjetService {
  final String apiKey;
  final String apiSecret;

  MailjetService(this.apiKey, this.apiSecret);

  Future<bool> sendEmail({
    required String fromEmail,
    required String toEmail,
    required String subject,
    required String content,
  }) async {
    try {
      final url = Uri.parse('https://api.mailjet.com/v3.1/send');

      final body = jsonEncode({
        'Messages': [
          {
            'From': {
              'Email': fromEmail,
              'Name': 'Medicinal Leaf App'
            },
            'To': [
              {'Email': toEmail}
            ],
            'Subject': subject,
            'TextPart': content,
                'HTMLPart': '<p>${content.replaceAll('\n', '<br>')}</p>', // <-- Thêm dòng này
            // Thêm tracking
            'TrackOpens': 'enabled',
            'TrackClicks': 'enabled',
          }
        ]
      });

      final credentials = base64Encode(utf8.encode('$apiKey:$apiSecret'));

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('=== MAILJET RESPONSE ===');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final messages = responseData['Messages'] as List;
        
        if (messages.isNotEmpty) {
          final message = messages[0];
          final messageId = message['To'][0]['MessageID'];
          final messageUUID = message['To'][0]['MessageUUID'];
          
          print('=== EMAIL SENT SUCCESSFULLY ===');
          print('Message ID: $messageId');
          print('Message UUID: $messageUUID');
          print('Recipient: $toEmail');
          print('Time: ${DateTime.now()}');
          
          // Optional: Track message status
          _trackMessageStatus(messageId);
          
          return true;
        }
      } else {
        print('=== EMAIL SEND FAILED ===');
        print('Error: ${response.body}');
      }

      return false;
    } catch (e) {
      print('=== EXCEPTION OCCURRED ===');
      print('Exception: $e');
      return false;
    }
  }

  // Kiểm tra trạng thái message
  Future<void> _trackMessageStatus(int messageId) async {
    try {
      // Đợi 2 giây trước khi check status
      await Future.delayed(Duration(seconds: 2));
      
      final url = Uri.parse('https://api.mailjet.com/v3/REST/message/$messageId');
      final credentials = base64Encode(utf8.encode('$apiKey:$apiSecret'));

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('=== MESSAGE STATUS ===');
        print('Status response: ${response.body}');
      }
    } catch (e) {
      print('Error tracking message: $e');
    }
  }

  // Lấy thống kê gửi email
  Future<void> getEmailStats() async {
    try {
      final now = DateTime.now();
      final fromDate = now.subtract(Duration(hours: 1));
      
      final url = Uri.parse(
        'https://api.mailjet.com/v3/REST/statcounters?FromTS=${fromDate.millisecondsSinceEpoch ~/ 1000}&ToTS=${now.millisecondsSinceEpoch ~/ 1000}'
      );
      
      final credentials = base64Encode(utf8.encode('$apiKey:$apiSecret'));

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );

      print('=== EMAIL STATISTICS ===');
      print('Stats response: ${response.body}');
    } catch (e) {
      print('Error getting stats: $e');
    }
  }
}