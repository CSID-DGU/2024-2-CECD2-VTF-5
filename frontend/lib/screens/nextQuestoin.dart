import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/recording_service.dart';
import '../provider/question_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/responsesProvider.dart';
import '../provider/recordingServiceProvider.dart';

class nextquestionWidget extends ConsumerStatefulWidget {
  const nextquestionWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<nextquestionWidget> createState() => _nextquestionWidgetState();
}

class _nextquestionWidgetState extends ConsumerState<nextquestionWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late RecordingService _recordingService;



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildButton(context, '유사한\n질문받기', () async {
                  final recordingService = ref.read(recordingServiceProvider); // RecordingService 인스턴스 가져오기
                  final responses = ref.read(responsesProvider); // responses 리스트 가져오기
                  if (responses.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('응답이 없습니다. 녹음을 먼저 진행해주세요.')),
                    );
                    return;
                  }

                  final result = await recordingService.sendResponsesToServer();
                  if (result != null) {
                    Get.toNamed('/question'); // 페이지 이동
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('질문 생성에 실패했습니다.')),
                    );
                  }
                }),
                _buildButton(context, '다른\n질문받기', ()async{
                  final recordingService = ref.read(recordingServiceProvider); // RecordingService 인스턴스 가져오기
                  final responses = ref.read(responsesProvider); // responses 리스트 가져오기
                  if (responses.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('응답이 없습니다. 녹음을 먼저 진행해주세요.')),
                    );
                    return;
                  }

                  final result = await recordingService.sendResponsesToServerDD();
                  if (result != null) {
                    Get.toNamed('/question'); // 페이지 이동
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('질문 생성에 실패했습니다.')),
                    );
                  }
                }),
                _buildButton(context, '답변\n계속하기', () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed) {
    return SizedBox(
      width: 300,
      height: 150,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: const Color(0xFFC3E5AE),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40,
            fontFamily: 'nanum',
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
