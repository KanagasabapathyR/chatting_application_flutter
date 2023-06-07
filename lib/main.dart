import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:workmanager/workmanager.dart';
import 'controller/binder.dart';
import 'firebase_options.dart';
import 'screens/dashboard/home.dart';
import 'screens/onboarding/onboarding_page.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return Future.value(false);
    } else {
      await Firebase.initializeApp();
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(inputData!['currentUserId'])
          .get();
      for (var a = 0; a < inputData['messages'].length; a++) {
        FirebaseFirestore.instance
            .collection('messages')
            .doc(inputData['cid'])
            .collection("channelChat")
            .add({
          'message': inputData['messages'][a],
          'messageType': inputData['type'][a],
          'createdTime': Timestamp.now(),
          'senderId': inputData['currentUserId'],
          'senderName': userData['username'],
        });
        FirebaseFirestore.instance
            .collection('messages')
            .doc(inputData['cid'])
            .update({
          'recentMessage': inputData['messages'][a],
          'time': Timestamp.now(),
        });
        FirebaseFirestore.instance
            .collection('users')
            .doc(inputData['currentUserId'])
            .collection("userChannels")
            .doc(inputData['cid'])
            .update({
          'recentMessage': inputData['messages'][a],
          'time': Timestamp.now(),
        });
      }
      return Future.value(true);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Jabber",
      initialBinding: Binder(),
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _auth.currentUser == null ? const OnBoardingPage() : const Home(),
    );
  }
}
