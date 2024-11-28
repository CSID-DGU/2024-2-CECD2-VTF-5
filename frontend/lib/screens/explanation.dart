import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExplanationWidget extends StatefulWidget {
  const ExplanationWidget({super.key});

  @override
  State<ExplanationWidget> createState() => _ExplanationWidgetState();
}

class _ExplanationWidgetState extends State<ExplanationWidget> {
  // GlobalKey 추가
  final GlobalKey _sttImageKey = GlobalKey();
  final GlobalKey _listeningImageKey = GlobalKey();
  final GlobalKey _responseBoxKey = GlobalKey();
  // 이미지 위치
  Offset? _sttImagePosition; 
  Offset? _listeningImagePosition;
  Offset? _responseBoxPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getPositions();
    });
  }

  // 이미지나 박스 위치 계산
  void _getPositions() {
    final RenderBox? sttRenderBox =
        _sttImageKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? listeningRenderBox =
        _listeningImageKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? responseRenderBox =
        _responseBoxKey.currentContext?.findRenderObject() as RenderBox?;

    setState(() {
      _sttImagePosition = sttRenderBox?.localToGlobal(Offset.zero);
      _listeningImagePosition = listeningRenderBox?.localToGlobal(Offset.zero);
      _responseBoxPosition = responseRenderBox?.localToGlobal(Offset.zero);
      print("stt 이미지 위치: $_sttImagePosition");
      print("listening 이미지 위치: $_listeningImagePosition");
      print("response 박스 위치: $_responseBoxPosition");
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        Get.toNamed('/explanation2');
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
                          key: _sttImageKey, // 이미지에 GlobalKey 할당
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
                            key: _responseBoxKey,
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
                                    fontSize: screenWidth * 0.06,
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
                          'assets/images/Listening2.png',
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
                                ),
                                Text(
                                  '홈화면',
                                  style: TextStyle(
                                    fontFamily: 'nanum',
                                    fontSize: screenWidth * 0.06,
                                    fontWeight: FontWeight.w600
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
                                  ),
                                ),
                                Text(
                                  '다음질문',
                                  style: TextStyle(
                                    fontFamily: 'nanum',
                                    fontSize: screenWidth * 0.06,
                                    fontWeight: FontWeight.w600
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
              // stt 이미지 설명
              if (_sttImagePosition != null)
                Positioned(
                  top: _sttImagePosition!.dy + 40,
                  left: _sttImagePosition!.dx + 20,
                  child: Column(
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: Colors.black,
                        size: 30,
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '왼쪽 버튼을 누르면 질문을 소리로 들을 수 있어요.\n질문이 잘려서 안보이신다면\n손가락으로 질문을 위로 쓸어보세요! ',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Pretendard',
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w700
                          ),
                          textAlign: TextAlign.center,
                        )
                      ),
                    ],
                  ),
                ),
                if (_listeningImagePosition != null)
                  Positioned(
                    top: _listeningImagePosition!.dy - 130,
                    left: _listeningImagePosition!.dx - 15,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '이 버튼을 눌러\n답변을 해주세요.',
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
                  if (_responseBoxPosition != null)
                    Positioned(
                      top: _listeningImagePosition!.dy - 330,
                      left: _listeningImagePosition!.dx - 100 ,
                      child: Column(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            color: Colors.black,
                            size: 30,
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '말풍선을 눌러\n 작가님의 답변을 글자로도 입력 가능해요.',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Pretendard',
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w700
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
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