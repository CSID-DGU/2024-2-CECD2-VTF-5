import 'package:flutter/material.dart';

class NewPasswordWidget extends StatelessWidget {
  const NewPasswordWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
                    Text(
                      '새로운 비밀번호로',
                      style: TextStyle(
                        color: Color(0xFF424242),
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '변경해 주세요!',
                      style: TextStyle(
                        color: Color(0xFF424242),
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 60.0),
                    Center(
                      child: Column(
                        children: [
                          TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(
                                color:Color(0xFF424242),
                              ),
                              labelText: "기존 비밀번호를 입력해 주세요.",
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF424242)
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF5AB15B),
                                  width: 2.0
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(
                                color: Color(0xFF424242),
                              ),
                              labelText: "새로운 비밀번호를 입력해 주세요.",
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF424242)
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF5AB15B),
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelStyle: TextStyle(
                                color: Color(0xFF424242),
                              ),
                              labelText: "새로운 비밀번호를 한 번 더 입력해 주세요.",
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF424242)
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF5AB15B),
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 50.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF99D69B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              minimumSize: Size(200, 60),
                            ),
                            onPressed: () {},
                            child: Text(
                              '변경완료',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ) ,
          ),
        ],
      ),
    );
  }
}



      // theme: ThemeData(
      //   textSelectionTheme: TextSelectionThemeData(
      //     cursorColor: Color(0xFF878787)
      //   ),
      //   inputDecorationTheme: InputDecorationTheme(
      //     labelStyle: TextStyle(color: Color(0xFF878787)),
      //     enabledBorder: OutlineInputBorder(
      //       borderSide: BorderSide(
      //         color: Color(0xFFA0A0A0),
      //       ),
      //       borderRadius: BorderRadius.circular(15),
      //     ),
      //     focusedBorder: OutlineInputBorder(
      //       borderSide: BorderSide(
      //         color: Color(0xFF99D69B),
      //         width: 2.0,
      //       ),
      //       borderRadius: BorderRadius.circular(15),
      //     ),
      //   ),
      // ),


// 밑에 코드 materialApp으로 뺐는데 main과 겹침 => 정리하기

// TextField(
//   obscureText: true,
//   decoration: InputDecoration(
//     labelStyle: TextStyle(
//       color:Color(0xFF424242),
//     ),
//     labelText: "기존 비밀번호를 입력해 주세요",
//     enabledBorder: OutlineInputBorder(
//       borderSide: BorderSide(
//         color: Color(0xFF424242)
//       ),
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderSide: BorderSide(
//         color: Color(0xFF5AB15B),
//         width = 2.0
//       ),
//     ),
//   ),
// ),
// SizedBox(height:20)