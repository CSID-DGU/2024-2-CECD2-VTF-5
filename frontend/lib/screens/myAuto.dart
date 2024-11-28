import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/complete_service.dart';
import '../services/numOfCharacters.dart';

class MyAutoWidget extends StatefulWidget {
  const MyAutoWidget({Key? key}) : super(key: key);

  @override
  State<MyAutoWidget> createState() => _MyAutoWidgetState();
}

class _MyAutoWidgetState extends State<MyAutoWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final AutobiographyService _service = AutobiographyService();
  final numOfCharacters _characters = numOfCharacters();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(
                      Icons.close,
                      size: 24
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 10, 50, 30),
                child: Container(
                  height: screenHeight * 0.7,
                  child: FutureBuilder<String?>(
                    future: _service.fetchAutobiographyContent(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.red,),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        return ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            Text(
                              snapshot.data!,
                              style: TextStyle(
                                fontFamily: 'nanum',
                                fontSize: 16,
                                color: Colors.black,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Center(
                          child: Text(
                            'No content available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: screenHeight * 0.07,
                      width: screenWidth * 0.7,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFC3E5AE), // Replace with your desired button color
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                          child: FutureBuilder<int?>(
                            future: _characters.fetchNumber(),
                            builder: (context, snapshot){
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator(); // 로딩 표시
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}'); // 에러 처리
                              } else if (snapshot.hasData) {
                                return Text(
                                  '${snapshot.data}자 작성',
                                  style: TextStyle(
                                    fontFamily: 'nanum',
                                    fontWeight: FontWeight.w600,
                                    fontSize: screenWidth * 0.06,
                                    color: Colors.black,
                                  ),
                                );
                              } else {
                                return Text(
                                  '데이터 없음',
                                  style: TextStyle(
                                    fontFamily: 'nanum',
                                    fontWeight: FontWeight.w600,
                                    fontSize: screenWidth * 0.06,
                                    color: Colors.black,
                                  ),
                                );
                              }
                            }
                          )
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
