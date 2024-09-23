import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  var _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitMessage() async {
    final enterMessage = _messageController.text;
    if (enterMessage.trim().isEmpty) return;

    // Gửi dữ liệu đến Firebase
    final user = FirebaseAuth.instance.currentUser!;

    // Lấy dữ liệu người dùng từ Firestore
    final getUserData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // Kiểm tra xem dữ liệu có tồn tại không
    final userData = getUserData.data();
    if (userData == null) {
      print('Lỗi: Dữ liệu người dùng không tồn tại.');
      return;
    }
    print(userData['username']) ;
    // Thêm tin nhắn vào collection "chat"
    FirebaseFirestore.instance.collection("chat").add({
      'text': enterMessage,
      'time': Timestamp.now(),
      'userId': userData['username'] ,
      'userImage': userData['image_url']
    });

    // Xóa nội dung trong TextField sau khi gửi tin nhắn
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 14, bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController ,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: false,
              enableSuggestions: true,
              decoration: const InputDecoration(label: Text(("Send a message..."))),
            ),
          ),
          IconButton(
            onPressed: _submitMessage,
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
