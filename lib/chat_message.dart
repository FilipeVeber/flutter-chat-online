import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage(this._data, this._mine);

  final Map<String, dynamic> _data;
  final bool _mine;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child:
            _mine ? _createMineMessageLayout() : _createOthersMessageLayout());
  }

  Widget _createMineMessageLayout() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              _data["imageURL"] != null
                  ? Image.network(
                      _data["imageURL"],
                      width: 250,
                    )
                  : Text(
                      _data["text"],
                      textAlign: TextAlign.end,
                      style: TextStyle(fontSize: 16),
                    ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            backgroundImage: NetworkImage(_data["senderPhotoURL"]),
          ),
        ),
      ],
    );
  }

  Widget _createOthersMessageLayout() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            backgroundImage: NetworkImage(_data["senderPhotoURL"]),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _data["imageURL"] != null
                  ? Image.network(
                      _data["imageURL"],
                      width: 250,
                    )
                  : Text(
                      _data["text"],
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 16),
                    ),
            ],
          ),
        )
      ],
    );
  }
}
