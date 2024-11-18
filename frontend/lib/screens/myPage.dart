import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyPageWidget extends StatefulWidget {
  const MyPageWidget({Key? key}) : super(key: key);

  @override
  State<MyPageWidget> createState() => _MyPageWidgetState();
}

class _MyPageWidgetState extends State<MyPageWidget> {
  bool isMarried = true;
  bool hasChildren = true;
  String selectedVoice = '남성';

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF0F9EA),
        body: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(40, 30, 0, 0),
                    child: const Text(
                      '안녕하세요!',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(55, 40, 0, 0),
                    child: Text(
                      '개인 정보 수정',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  width: 330,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInfoRow('아이디', 'VTF'),
                        _buildDivider(),
                        _buildInfoRow('이름', '홍길동'),
                        _buildDivider(),
                        _buildInfoRow('이메일', 'aaa@abc.com'),
                        _buildDivider(),
                        _buildInfoRow('주민등록번호', '123456-1******'),
                        _buildDivider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '결혼 여부',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  children: ['기혼', '미혼'].map((option) {
                                    bool isChecked = (option == '기혼' && isMarried) || (option == '미혼' && !isMarried);
                                    return Row(
                                      children: [
                                        Checkbox(
                                          value: isChecked,
                                          onChanged: (value) {
                                            if (value == true) {
                                              setState(() {
                                                isMarried = option == '기혼';
                                              });
                                            }
                                          },
                                        ),
                                        Text(option),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '자녀유무',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  children: ['유', '무'].map((option) {
                                    bool isChecked = (option == '유' && hasChildren) || (option == '무' && !hasChildren);
                                    return Row(
                                      children: [
                                        Checkbox(
                                          value: isChecked,
                                          onChanged: (value) {
                                            if (value == true) {
                                              setState(() {
                                                hasChildren = option == '유';
                                              });
                                            }
                                          },
                                        ),
                                        Text(option),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(55, 10, 0, 0),
                    child: Text(
                      '기능 설정',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  width: 330,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () {
                            Get.toNamed('/newPassword');
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(35, 10, 0, 0),
                            child: Text(
                              '비밀번호 변경',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 1.7,
                        color: Colors.grey[300],
                        indent: 20,
                        endIndent: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                          child: const Text('목소리 변경'),
                        ),
                      ),
                      _buildVoiceSelection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      thickness: 2,
      color: Color(0xFFE4E4E4),
    );
  }

  Widget _buildVoiceSelection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 0, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ['남성', '여성', '어린이'].map((voice) {
          return Row(
            children: [
              Radio<String>(
                value: voice,
                groupValue: selectedVoice,
                onChanged: (value) {
                  setState(() {
                    selectedVoice = value!;
                  });
                },
              ),
              Text(voice),
            ],
          );
        }).toList(),
      ),
    );
  }
}
