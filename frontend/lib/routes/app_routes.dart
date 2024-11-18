import 'package:get/get.dart';
import 'package:vtfecho/screens/homePage.dart';
import 'package:vtfecho/screens/loading.dart';
import 'package:vtfecho/screens/login.dart';
import 'package:vtfecho/screens/signup.dart';
import '../screens/myPage.dart';
import '../screens/newPassword.dart';

// loading -> login -> (회원가입 클릭시) signup -> homePage -> 
// loading -> login -> (로그인버튼 클릭시) homePage

class AppRoutes {
  static final routes = [
    GetPage(name: '/loading', page: () => LoadingWidget()),
    GetPage(name: '/login', page: () => LoginWidget()),
    GetPage(name: '/signup', page: () => SignupWidget()),
    GetPage(name: '/homePage', page: () => HomePageWidget()),
    GetPage(name: '/myPage', page: () => MyPageWidget()),
    GetPage(name: '/newPassword', page: () => NewPasswordWidget()),

  ];
}

