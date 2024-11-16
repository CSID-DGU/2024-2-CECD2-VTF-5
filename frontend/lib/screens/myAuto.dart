import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyAutoWidget extends StatefulWidget {
  const MyAutoWidget({Key? key}) : super(key: key);

  @override
  State<MyAutoWidget> createState() => _MyAutoWidgetState();
}

class _MyAutoWidgetState extends State<MyAutoWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white, // Replace with your desired background color
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional(1, 0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.windowClose,
                      color: Colors.black, // Replace with your desired icon color
                      size: 24,
                    ),
                    onPressed: () {
                      // Add close functionality if needed
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 10, 50, 30),
                child: Container(
                  height: 700,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Text(
                        '자서전 내용\n.\n.\n.\n.\n..\n.\n\n.\n.\n\n\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n.\n',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black, // Replace with your desired text color
                          letterSpacing: 0.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 150,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFC3E5AE), // Replace with your desired button color
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '***글자 작성',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black, // Replace with your desired text color
                          fontFamily: 'nanum'
                        ),
                      ),
                    ),
                    Container(
                      width: 150,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFC3E5AE), // Replace with your desired button color
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '**개 질문 답변함',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black, // Replace with your desired text color
                          letterSpacing: 0.0,
                          fontFamily: 'nanum'
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
