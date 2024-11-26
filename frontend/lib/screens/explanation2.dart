import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Explanation2Widget extends StatefulWidget {
  const Explanation2Widget({super.key});

  @override
  State<Explanation2Widget> createState() => _Explanation2WidgetState();
}

class _Explanation2WidgetState extends State<Explanation2Widget> {
  // GlobalKey 추가
  final GlobalKey _listeningImageKey = GlobalKey();
  final GlobalKey _homeIconKey = GlobalKey();
  final GlobalKey _nextIconKey = GlobalKey();
  // 이미지 위치
  Offset? _listeningImagePosition;
  Offset? _homeIconPosition;
  Offset? _nextIconPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getPositions();
    });
  }

  // 이미지나 박스 위치 계산
  void _getPositions() {
    final RenderBox? listeningRenderBox =
        _listeningImageKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? homeRenderBox =
        _homeIconKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? nextRenderBox =
        _nextIconKey.currentContext?.findRenderObject() as RenderBox?;

    setState(() {
      _listeningImagePosition = listeningRenderBox?.localToGlobal(Offset.zero);
      print("listening 이미지 위치: $_listeningImagePosition");
      _homeIconPosition = homeRenderBox?.localToGlobal(Offset.zero);
      print("home 아이콘 위치: $_homeIconPosition");
      _nextIconPosition = nextRenderBox?.localToGlobal(Offset.zero);
      print("next 아이콘 위치: $_nextIconPosition");
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        Get.toNamed('/homePage');
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.15,
                    decoration: BoxDecoration(
                      color: Color(0xFFB1EBB3),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Image.asset('assets/images/stt.png',
                          width: screenWidth * 0.18 ,height: screenHeight * 0.18,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            '6살 때 어떤 자전거를 타셨나요?',
                            style: TextStyle(
                              fontFamily: 'nanum',
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 300),
                        child: Container(
                          height: screenHeight * 0.09,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFCFAD),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: Text(
                                  '여기에 작가님의 답변 내용이 나타납니다!',
                                  style: TextStyle(
                                    fontFamily: 'nanum',
                                    fontSize: screenWidth * 0.07,
                                    fontWeight: FontWeight.w700
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/Listening.png',
                          key: _listeningImageKey,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.home,
                                  color: Colors.black,
                                  size: 24,
                                  key: _homeIconKey,
                                ),
                                Text(
                                  '홈화면',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Column(
                              children: [
                                GestureDetector(
                                  child: Icon(
                                    Icons.navigate_next_rounded,
                                    color: Colors.black,
                                    size: 24,
                                    key: _nextIconKey,
                                  ),
                                ),
                                Text(
                                  '다음질문',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                color: Colors.black.withOpacity(0.15),
              ),
              if (_listeningImagePosition != null)
                Positioned(
                  top: _listeningImagePosition!.dy - 170,
                  left: _listeningImagePosition!.dx - 130,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '이 버튼을 누르면 다음과 같이 테두리가 사라집니다.\n답변을 시작해주세요!',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Pretendard',
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w700
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Icon(
                        Icons.arrow_upward,
                        color: Colors.black,
                        size: 30,
                      ),
                    ],
                  ),
                ),
                if (_homeIconPosition != null)
                Positioned(
                  top: _homeIconPosition!.dy - 160,
                  left: _homeIconPosition!.dx - 25,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '이 버튼을 눌러\n홈화면으로\n이동할 수 있어요.',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Pretendard',
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w700
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Icon(
                      //   Icons.arrow_upward,
                      //   color: Colors.black,
                      //   size: 30,
                      // ),
                    ],
                  ),
                ),
                if (_nextIconPosition != null)
                Positioned(
                  top: _nextIconPosition!.dy - 160,
                  left: _nextIconPosition!.dx - 60,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '이 버튼을 눌러\n다음 질문을\n생성해보세요.',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Pretendard',
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w700
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Icon(
                      //   Icons.arrow_upward,
                      //   color: Colors.black,
                      //   size: 30,
                      // ),
                    ],
                  ),
                ),
            ],
          )
        ),
      ),
    );
  }
}