import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelegramService {
  static const String _botToken = 'YOUR_BOT_TOKEN';

  static Future<String?> _getTrustedContactChatId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('settings')
            .doc('trusted_contact')
            .get();

    if (!doc.exists) return null;
    return doc.data()?['telegram_chat_id'] as String?;
  }

  static Future<void> sendAlertWithLocation(double heartRate) async {
    try {
      final chatId = await _getTrustedContactChatId();
      if (chatId == null) {
        print('Не указан доверенный контакт в Telegram');
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (!serviceEnabled) {
        print('Геолокация отключена на устройстве');
        return;
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          print('Нет разрешения на геолокацию');
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final message = '🚨 Пульс $heartRate bpm. Срочно вызовите скорую!';

      final Uri msgUrl = Uri.parse(
        'https://api.telegram.org/bot$_botToken/sendMessage?chat_id=$chatId&text=${Uri.encodeComponent(message)}',
      );

      final Uri locUrl = Uri.parse(
        'https://api.telegram.org/bot$_botToken/sendLocation?chat_id=$chatId&latitude=${position.latitude}&longitude=${position.longitude}',
      );

      final msgResp = await http.get(msgUrl);
      final locResp = await http.get(locUrl);

      if (msgResp.statusCode == 200 && locResp.statusCode == 200) {
        print('✅ Сообщение и локация успешно отправлены');
      } else {
        print('❌ Ошибка отправки в Telegram');
      }
    } catch (e) {
      print('Ошибка при отправке в Telegram: $e');
    }
  }
}
