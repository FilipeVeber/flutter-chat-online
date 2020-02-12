import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_online/text_composer.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseUser _currentUser;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text(
            _currentUser != null ? "${_currentUser.displayName}" : "Chat App"),
        centerTitle: true,
        actions: <Widget>[
          _currentUser != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    _googleSignIn.signOut();

                    _globalKey.currentState.showSnackBar(SnackBar(
                      content: Text("Você saiu com sucesso!"),
                    ));
                  },
                )
              : Container()
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection("messages")
                      .orderBy("time")
                      .snapshots(),
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
                            return ChatMessage(documents[index].data, true);
                          },
                        );
                    }
                  })),
          TextComposer(_sendMessage)
        ],
      ),
    );
  }

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    try {
      final GoogleSignInAccount googleSignInAccount =
          await _googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;

//      _currentUser = user;
      return user;
    } catch (error) {
      return null;
    }
  }

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  void _sendMessage({String text, File imageFile}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _globalKey.currentState.showSnackBar(SnackBar(
        content: Text("Não foi possível fazer o login. Tente novamente"),
        backgroundColor: Colors.red,
      ));
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoURL": user.photoUrl,
      "time": Timestamp.now()
    };

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
