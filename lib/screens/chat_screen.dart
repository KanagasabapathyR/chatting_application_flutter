import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widget/chat_profile_sheet.dart';
import '../widget/message_bubble.dart';

class ChatScreen extends StatelessWidget {
  final name;
  final image;
  final number;
  final receiverId;
  final channelId;
  final isFromContact;
  ChatScreen(this.name, this.receiverId, this.image, this.number,
      this.isFromContact, this.channelId);

  @override
  Widget build(BuildContext context) {
    print(channelId);
    Future<bool> _onWillPop() async {
      Get.back();
      isFromContact ? Get.back() : null;
      return false;
    }

    var _enteredMessage = ''.obs;
    TextEditingController _controller = TextEditingController();

    void _sendMessage() async {
      print("got CLick");
      _controller.clear();
      FocusScope.of(context).unfocus();
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      FirebaseFirestore.instance
          .collection('messages')
          .doc(channelId)
          .collection("channelChat")
          .add({
        'message': _enteredMessage.value,
        'createdTime': Timestamp.now(),
        'senderId': user.uid,
        'senderName': userData['username'],
        'receiverId': receiverId,
        'receiverName': name,
      });
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: Colors.white,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.black,
            ),
            onPressed: () {
              Get.back();
              isFromContact ? Get.back() : null;
            },
          ),
          title: GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return FractionallySizedBox(
                    heightFactor: 0.70,
                    child: ChatProfileSheet(name, image, number),
                  );
                },
              );
            },
            child: Row(
              children: [
                Hero(
                  tag: name,
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFFd6e2ea),
                    backgroundImage: image == null ? null : NetworkImage(image),
                    child: image == null
                        ? const Icon(
                            Icons.person_rounded,
                            color: Colors.grey,
                            size: 30,
                          )
                        : null,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF86898f),
                ),
                child: const Icon(Icons.phone),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF86898f),
                ),
                child: const Icon(Icons.search),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .doc(channelId)
                    .collection('channelChat')
                    .orderBy(
                      'createdTime',
                      descending: true,
                    )
                    .snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    List docs = snapshot.data.docs;
                    print(docs);
                    final currentUser = FirebaseAuth.instance.currentUser?.uid;
                    return ListView.builder(
                      reverse: true,
                      itemCount: docs.length,
                      itemBuilder: (ctx, index) => MessageBubble(
                        docs[index]['message'],
                        docs[index]['senderId'] == currentUser,
                        docs[index]['senderName'],
                      ),
                    );
                  }
                },
              ),
            ),
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 8.0, bottom: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFf7f7f7),
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(25.0),
                          ),
                        ),
                        child: SizedBox(
                          height: 45.0,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              FloatingActionButton.small(
                                heroTag: const Text("btn1"),
                                elevation: 0,
                                disabledElevation: 0,
                                hoverElevation: 0,
                                highlightElevation: 0,
                                focusElevation: 0,
                                onPressed: () {},
                                backgroundColor: Colors.transparent,
                                child: const Icon(
                                  Icons.insert_emoticon,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  maxLines: 1,
                                  onChanged: (value) {
                                    _enteredMessage.value = value;
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Type your message here",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              FloatingActionButton.small(
                                heroTag: const Text("btn2"),
                                elevation: 0,
                                disabledElevation: 0,
                                hoverElevation: 0,
                                highlightElevation: 0,
                                focusElevation: 0,
                                onPressed: () {},
                                backgroundColor: Colors.transparent,
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => FloatingActionButton.small(
                      heroTag: const Text("btn3"),
                      elevation: 0,
                      disabledElevation: 0,
                      hoverElevation: 0,
                      highlightElevation: 0,
                      focusElevation: 0,
                      onPressed: _enteredMessage.trim().isEmpty
                          ? null
                          : () {
                              _sendMessage();
                            },
                      backgroundColor: Colors.deepOrange,
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
