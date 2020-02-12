import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
      body: Column(
        children: <Widget>[
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection("messages").snapshots(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      default:
                        List<DocumentSnapshot> documents =
                            snapshot.data.documents.reversed.toList();
                        return ListView.builder(
                          itemCount: documents.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(documents[index].data["text"]),
                            );
                          },
                        );
                    }
                  })),
          TextComposer(_sendMessage)
        ],
      ),
    );
  }

  void _sendMessage({String text, File imageFile}) async {
    Map<String, dynamic> data = Map();

    if (imageFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imageFile);

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      data["imageURL"] = await taskSnapshot.ref.getDownloadURL();
    }

    if (text != null) {
      data["text"] = text;
    }

    Firestore.instance.collection("messages").document().setData(data);
  }
}
