import 'package:flutter/material.dart';
import 'package:path/path.dart' as p; 
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();

  String? recordingPath;
  bool isRecording = false, isPlaying = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _recordingButton(),
      body: _buildUI(), 
    );
  }

  Widget _buildUI() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 녹음경로 있을때
          if (recordingPath != null)
           MaterialButton(
            onPressed: () async {
              // 녹음 플레이중
              if (audioPlayer.playing) {
                audioPlayer.stop();
                setState(() {
                  isPlaying = false;
                });
              } else {
                await audioPlayer.setFilePath(recordingPath!);
                audioPlayer.play();
                setState(() {
                  isPlaying = true;
                });
              }
            },
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              isPlaying 
              ? "Stop Playing Recording" 
              : "Start Playing Recording",
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          // 녹음경로 없을때
          if (recordingPath == null)
            const Text(
              "No Recording Found :("
            ),
        ],
      ),
    );
  }

  Widget _recordingButton() {
    return FloatingActionButton(
      onPressed: () async {
        if (isRecording) {
          // 녹음 중지
          String? filePath = await audioRecorder.stop();
          if (filePath != null) {
            setState(() {
              isRecording = false;
              recordingPath = filePath;
            });
            // await sendFileToServer(filePath);
          }
        } else {
          if (await audioRecorder.hasPermission()) {
            // 녹음 시작
            final Directory appDocumentsDir =
                await getApplicationDocumentsDirectory();
            final String filePath = 
                p.join(appDocumentsDir.path, "recording.aac");
            await audioRecorder.start(
              const RecordConfig(),
              path: filePath,
            );
            setState(() {
              isRecording = true;
              recordingPath = null;
            });
          }
          }
      },
      child: Icon(
        isRecording ? Icons.stop : Icons.mic,
      ),
    );
  }
}


//   //녹음파일 서버로 전송
//   Future<void> sendFileToServer(String filePath) async {
//     File audioFile = File(filePath);
//     String url = "http://127.0.0.1:8000/generate_question"; // 서버주소 넣기

//     var request = http.MultipartRequest('POST', Uri.parse(url));
//     request.files.add(await http.MultipartFile.fromPath('file', audioFile.path));

//     try {
//       var response = await request.send();
//       if (response.statusCode == 200) {
//         print('File uploaded successfully');
//       } else {
//         print('File upload failed with status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error uploading file: $e');
//     }

//   }
// }
