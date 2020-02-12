import 'package:flutter/material.dart';
import 'package:flutter_chat_online/text_composer.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Olá"),
      ),
      body: TextComposer(),
    );
  }
}
