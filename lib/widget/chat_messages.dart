import 'package:chatappfirebase/widget/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {

 Future<void> setupPushNoitifications() async {
   final fcm = FirebaseMessaging.instance;
   await fcm.requestPermission();
   // final  token  = await fcm.getToken();
   // print(token);


   fcm.subscribeToTopic("chat");
 }

  @override
  void initState() {
    super.initState();
    setupPushNoitifications();
  }


  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;


    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return  Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No messages found.'),
          );
        }
        final chatDocs = chatSnapshot.data!.docs;
        return ListView.builder(
          padding: EdgeInsets.only(bottom: 40, left: 20),
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) {
            final chatMessage = chatDocs[index].data() as Map<String, dynamic>;
            final nextChatMessage = index + 1 < chatDocs.length
                ? chatDocs[index + 1].data() as Map<String, dynamic>
                : null;

            final currentMessageUid = chatMessage['userId'];
            final nextMessageUid =
                nextChatMessage != null ? nextChatMessage['userId'] : null;
            final nextUserIsSame = nextMessageUid == currentMessageUid;

            if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUid);
            } else {
              return MessageBubble.first(
                  userImage: chatMessage['userImage'],
                  username:  chatMessage['userId'],
                  message:  chatMessage['text'],
                  isMe: authenticatedUser.uid == currentMessageUid);
            }
    },
        );
      },
    );
  }
}
