import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';

class MessageController extends GetxController {
  var responseText = "".obs;
  var messages = <Map<String, dynamic>>[].obs;

  var isTypeing = false.obs;

  Future<void> sendMessage(String message) async {
    messages.add(
      {
        'text': message,
        'isUser': true,
        'time': DateFormat('hh:mm a').format(DateTime.now())
      },
    );

    responseText.value = "Thinking..";
    isTypeing.value = true;
    update();

    String reply = await GooglleApiService.getApiResponse(message);

    responseText.value = reply;

    messages.add(
      {
        'text': reply,
        'isUser': false,
        'time': DateFormat('hh:mm a').format(DateTime.now())
      },
    );

    isTypeing.value = false;
    update();
  }
}
