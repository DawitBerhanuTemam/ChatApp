import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/message_controller.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageController chatMessageController = Get.put(MessageController());
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listen to changes in messages and auto-scroll
    chatMessageController.messages.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        excludeHeaderSemantics: true,
        title: const Text("TechiBot"),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                shrinkWrap: true,
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: chatMessageController.messages.length,
                itemBuilder: (context, index) {
                  final message = chatMessageController.messages[index];
                  final isUser = message['isUser'];
                  final time = message['time'];

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        BubbleSpecialTwo(
                          isSender: isUser,
                          color: isUser
                              ? const Color(0XFF25D366)
                              : const Color(0XFFE5E5E5),
                          seen: true,
                          text: message['text'],
                          tail: true,
                          textStyle: const TextStyle(
                            fontSize: 14.0,
                            color: Color(0XFF000000),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10, left: 20),
                          child: Text(
                            time,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0XFF808080),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Obx(
            () => chatMessageController.isTypeing.value
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          chatMessageController.responseText.value,
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.grey),
                        )
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          //Text field for message

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {},
                        // ignore: prefer_const_constructors
                        icon: Icon(Icons.emoji_emotions_outlined),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                FloatingActionButton(
                  heroTag: "send_button",
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      chatMessageController
                          .sendMessage(messageController.text.trim());
                      messageController.clear();
                    }
                  },
                  backgroundColor: const Color(0XFF25D366),
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.send),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
