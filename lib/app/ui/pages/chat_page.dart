import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/chat_controller.dart';
import '../../data/models/q_model.dart';

class ChatPage extends StatelessWidget {
  final ChatController controller = Get.put(ChatController());

/*  final TextEditingController textController = TextEditingController();
  final RxList<String> selectedCheckboxes = <String>[].obs;*/

  final selectedRadioOption = ''.obs;
  final selectedCheckboxes = <String>[].obs;
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat Q&A")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: controller.currentQuestionIndex.value + 1,
            itemBuilder: (context, index) {
              final question = controller.questions[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bubble(isUser: false, text: question.question ?? ""),
                  if (index == controller.currentQuestionIndex.value)
                    buildAnswerWidget(question)
                ],
              );
            },
          ),
        );
      }),
    );
  }

  Widget buildAnswerWidget(Data question) {
    switch (question.typeOfAns) {
      case 'input':
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: 'Enter your answer...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  controller.selectAnswer(
                    question,
                    textController.text,
                    customAnswer: textController.text,
                  );
                  textController.clear();
                }
              },
            )
          ],
        );

      case 'checkbox':
        return Column(
          children: [
            ...?question.options?.map((option) => Obx(() => CheckboxListTile(
                  title: Text(option.option ?? ""),
                  value: selectedCheckboxes.contains(option.option),
                  onChanged: (value) {
                    value == true
                        ? selectedCheckboxes.add(option.option!)
                        : selectedCheckboxes.remove(option.option);
                  },
                ))),
            ElevatedButton(
              onPressed: () {
                controller.selectAnswer(
                  question,
                  selectedCheckboxes.join(", "),
                  customAnswer: selectedCheckboxes.join(", "),
                );
                selectedCheckboxes.clear();
              },
              child: Text("Submit"),
            )
          ],
        );

      case 'radio':
        return Obx(() => Column(
              children: [
                ...?question.options?.map((option) => RadioListTile<String>(
                      title: Text(option.option ?? ""),
                      value: option.option ?? "",
                      groupValue: selectedRadioOption.value,
                      onChanged: (value) {
                        selectedRadioOption.value = value ?? "";
                        final selected = question.options?.firstWhere(
                            (e) => e.option == selectedRadioOption.value);
                        controller.selectAnswer(
                          question,
                          selected,
                          customAnswer: selected?.option,
                        );
                        selectedRadioOption.value = '';
                      },
                    )),
              ],
            ));

      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: question.options
                  ?.map((opt) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: ElevatedButton(
                          onPressed: () =>
                              controller.selectAnswer(question, opt),
                          child: Text(opt.option ?? ""),
                        ),
                      ))
                  .toList() ??
              [],
        );
    }
  }
}

class Bubble extends StatelessWidget {
  final String text;
  final bool isUser;

  Bubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text),
      ),
    );
  }
}

void showSuccessDialog() {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.done_all, color: Colors.green, size: 64),
          SizedBox(height: 16),
          Text("Submitted Successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    ),
    barrierDismissible: true,
  );

  Future.delayed(Duration(seconds: 2), () {
    Get.back(); // Close the dialog
  });
}
