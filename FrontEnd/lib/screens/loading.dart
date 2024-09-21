import 'package:flutter/material.dart';


class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                              fontSize: screenWidth * 0.06,
                            ),
                          ),
                          Text(
                            '메아리',
                           style: TextStyle(
                             color: Colors.black,
                             fontSize: screenWidth * 0.08,
                             fontWeight: FontWeight.bold,
                            ),
                          ),
                       ],
                      ),
                    ),
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/images/LoadingEcho.gif'),
                      backgroundColor: const Color.fromARGB(255, 164, 230, 166),
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