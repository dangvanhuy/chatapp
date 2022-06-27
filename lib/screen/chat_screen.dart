import 'package:chatapp/controller/chat_controller.dart';
import 'package:chatapp/model/messages.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/colors.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Chatscreen extends StatefulWidget {
  Chatscreen({Key? key}) : super(key: key);

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  TextEditingController mgInputController = TextEditingController();
  late IO.Socket socket;
  ChatController chatController = ChatController();

  @override
  void initState() {
    socket = IO.io(
        'http://localhost:4000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket.connect();
    setUpSocketListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Column(
        children: [
          Expanded(
              child: Obx(
            () => Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                "Connected User ${chatController.connectedUser}",
                style: TextStyle(
                  color: white,
                  fontSize: 15,
                ),
              ),
            ),
          )),
          Expanded(
            flex: 9,
            child: Obx(
              () => ListView.builder(
                  itemCount: chatController.chatMessages.length,
                  itemBuilder: (context, index) {
                    var currentItem = chatController.chatMessages[index];
                    return MessageItem(
                      sentbyMe: currentItem.sentByMe == socket.id,
                      message: currentItem.message,
                    );
                  }),
            ),
          ),
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              style: TextStyle(
                color: white,
              ),
              cursorColor: purple,
              controller: mgInputController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: white),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: white),
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {
                      sendMessage(mgInputController.text);
                      mgInputController.text = "";
                    },
                    icon: Icon(
                      Icons.send,
                      color: white,
                    ),
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  void sendMessage(String text) {
    var messageJson = {
      "message": text,
      "sentByMe": socket.id,
    };
    socket.emit('message', messageJson);
    chatController.chatMessages.add(Message.fromJson(messageJson));
  }

  void setUpSocketListener() {
    socket.on('message-receive', (data) {
      print(data);
      chatController.chatMessages.add(Message.fromJson(data));
    });
    socket.on('connected-user', (data) {
      print(data);
      chatController.connectedUser.value = data;
    });
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({Key? key, required this.sentbyMe, required this.message})
      : super(key: key);
  final bool sentbyMe;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: sentbyMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: sentbyMe ? purple : white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Text(
              message,
              style: TextStyle(
                color: sentbyMe ? white : purple,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              "1:10 AM",
              style: TextStyle(
                color: sentbyMe ? white : purple,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
