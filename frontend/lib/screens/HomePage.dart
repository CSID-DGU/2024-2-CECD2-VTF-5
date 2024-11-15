import 'package:flutter/material.dart';


class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
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
                        padding: const EdgeInsets.only(left: 50),
                        child: Image.asset('assets/icons/HomeIcon.png',
                          width: 60,height: 60,),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 30),
                        child: Text(
                          '홈',
                          style: TextStyle(
                            fontFamily: 'Inter Tight',
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
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
                    Navigator.pushNamed(context, 'chat');
                  },
                  child: Container(
                    width: 300,
                    height: 190,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC3E5AE),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 65, top: 20),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Image.asset('assets/icons/QuestionBoy.png',
                                  width: 70,height: 70,),

                              ),
                              const Text(
                                ' 질문',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'nanum',
                                  fontSize: 55,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          '만들러 가기',
                          style: TextStyle(
                            fontFamily: 'nanum',
                            fontSize: 55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, 'myPage');
                  },
                  child: Container(
                    width: 300,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0x80B1D39C),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Icon(
                              Icons.person_sharp,
                              color: Colors.black,
                              size: 50
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              '마이 페이지',
                              style: TextStyle(
                                fontFamily: 'nanum',
                                fontSize: 50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 300,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0x80B1D39C),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Icon(
                            Icons.edit_document,
                            color: Colors.black,
                            size: 50,
                          ),
                        ),
                        Text(
                          ' 내 자서전 보기',
                          style: TextStyle(
                            fontFamily: 'nanum',
                            fontSize: 50,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 300,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0x80B1D39C),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Image.asset('assets/icons/ExplainMan.png',
                          width: 45,height: 45,),
                        const Padding(
                          padding: EdgeInsets.only(left: 30),
                          child: Text(
                            '설명 다시보기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'nanum',
                              fontSize: 50,
                            ),
                          ),
                        ),
                      ],
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
