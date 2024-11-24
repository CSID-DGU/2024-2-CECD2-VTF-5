import 'package:get/get.dart';
import 'package:vtfecho/screens/chat.dart';
import 'package:vtfecho/screens/explanation.dart';
import 'package:vtfecho/screens/homePage.dart';
import 'package:vtfecho/screens/loading.dart';
import 'package:vtfecho/screens/login.dart';
import 'package:vtfecho/screens/lostPassword.dart';
import 'package:vtfecho/screens/lostPasswordUpdate.dart';
import 'package:vtfecho/screens/myAuto.dart';
import 'package:vtfecho/screens/signup.dart';
import 'package:vtfecho/screens/verificationCode.dart';
import '../screens/myPage.dart';
import '../screens/newPassword.dart';
import '../screens/question.dart';
import '../screens/nextQuestoin.dart';

// loading -> login -> (회원가입 클릭시) signup -> homePage -> 
// loading -> login -> (로그인버튼 클릭시) homePage
// homepage -> 

class AppRoutes {
  static final routes = [
    GetPage(name: '/loading', page: () => LoadingWidget()),
    GetPage(name: '/login', page: () => LoginWidget()),
    GetPage(name: '/signup', page: () => SignupWidget()),
    GetPage(name: '/lostPassword', page: () => LostPWWidget()),
    GetPage(name: '/verificationCode', page: () => VeriCodeWidget()),
    GetPage(name: '/lostPasswordUpdate', page: () => LostPasswordUpdateWidget()),
    GetPage(name: '/homePage', page: () => HomePageWidget()),
    GetPage(name: '/chat', page: () => ChatWidget()),
    GetPage(name: '/myPage', page: () => MyPageWidget()),
    GetPage(name: '/myAuto', page: () => MyAutoWidget()),
    GetPage(name: '/explanation', page: () => ExplanationWidget()),
    GetPage(name: '/newPassword', page: () => NewPasswordWidget()),
    GetPage(name: '/question', page: ()=>QuestionWidget()),
    GetPage(name: '/nextQuestoin', page: ()=>nextquestionWidget()),


  ];
}

