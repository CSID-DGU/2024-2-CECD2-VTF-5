import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: AlignmentDirectional(0, 0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 70, top: 10),
                        child: Image.asset(
                          'assets/icons/HomeIcon.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          '홈',
                          style: TextStyle(
                            fontFamily: 'nanum',
                            fontSize: screenWidth * 0.15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 20),
                child: InkWell(
                  onTap: () {
                    Get.toNamed('/chat');
                  },
                  child: Container(
                    width: 300,
                    height: 190,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB1EBB3),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Image.asset(
                            'assets/images/write_auto.png',
                            width: 70,
                            height: 70,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '자서전',
                              style: TextStyle(
                                fontFamily: 'nanum',
                                fontSize: screenWidth * 0.09,
                                fontWeight: FontWeight.w700
                              ),
                            ),
                            Text(
                              '만들러 가기',
                              style: TextStyle(
                                fontFamily: 'nanum',
                                fontSize: screenWidth * 0.09,
                                fontWeight: FontWeight.w700
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 15),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: InkWell(
                  onTap: () {
                    Get.toNamed('/myPage');
                  },
                  child: Container(
                    width: 300,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB0DCB2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/mypage.png',
                            width: 70,
                            height: 70,
                          ),
                          // SizedBox(width: 5),
                          Text(
                            '나의 정보 보기',
                            style: TextStyle(
                              fontFamily: 'nanum',
                              fontSize: screenWidth * 0.09,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: InkWell(
                  onTap: () {
                    Get.toNamed('/myAuto');
                  },
                  child: Container(
                    width: 300,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB0DCB2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/my_auto.png',
                            width: 70,
                            height: 70,
                          ),
                          // SizedBox(width: 5),
                          Text(
                            '나의 자서전 보기',
                            style: TextStyle(
                              fontFamily: 'nanum',
                              fontSize: screenWidth * 0.09,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: InkWell(
                  onTap: () {
                    Get.toNamed('/explanation');
                  },
                  child: Container(
                    width: 300,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB0DCB2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/explanation.png',
                            width: 70,
                            height: 70,
                          ),
                          Text(
                            '설명 다시 보기',
                            style: TextStyle(
                              fontFamily: 'nanum',
                              fontSize: screenWidth * 0.09,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
