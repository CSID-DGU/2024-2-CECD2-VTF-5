import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Future.delayed(const Duration(seconds: 2), () {
      Get.offNamed('/login');
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                height: screenHeight * 0.55,
                width: screenWidth * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.08),  
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '내가 쓰는 자서전,',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Pretendard',
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '메아리',
                           style: TextStyle(
                             color: Colors.black,
                             fontFamily: 'Pretendard',
                             fontSize: screenWidth * 0.08,
                             fontWeight: FontWeight.w700,
                            ),
                          ),
                       ],
                      ),
                    ),
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/images/LoadingEcho.gif'),
                      backgroundColor: const Color(0xFFA4E6A6),
                      radius: screenWidth * 0.4,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
              child: Image.asset(
                'assets/images/1half.png',
                width: screenWidth * 0.15,
                height: screenHeight * 0.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}