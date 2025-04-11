import 'package:get/get.dart';
import 'package:nex_ever_chat_app/app/controllers/chat_controller.dart';

class QuestionBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => ChatController());
    Get.put(ChatController());
  }
}
