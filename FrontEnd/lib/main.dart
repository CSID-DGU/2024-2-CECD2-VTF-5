import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vtfecho/model/gptchat.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController messageTextController = TextEditingController();

  final List<Messages> _historyList = List.empty(growable: true);

  String apiKey = '';
  String streamText = '';

  static const String _kStrings = "chat bot";

  ScrollController scrollController = ScrollController();

  void _scrollDown() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(microseconds: 300), curve: Curves.fastOutSlowIn);
  }

  Future requestChat(String text) async {
    ChatModel openAImodel = ChatModel(
      messages: [
        Messages(role: "system", content: "HI GPT"),
        ..._historyList,
      ],
      model: "gpt-4o",
      stream: false,
    );
    final url = Uri.https("api.openai.com","v1/chat/completions");
    final reponse = await http.post(
        url,
        headers: <String, String>{
      "Authorization":"Bearer $apiKey",
      "Content-Type":"application/json",
    },
    body: jsonEncode(openAImodel.toJson())
    );
    print(reponse.body);
    if(reponse.statusCode==200){
      final jsonData = jsonDecode(utf8.decode(reponse.bodyBytes)) as Map;
      String role = jsonData["choices"][0]["message"]["role"];
      String content = jsonData["choices"][0]["message"]["content"];
      _historyList.last = _historyList.last.copyWith(role: role, content: content);
      setState(() {
        _scrollDown();
      });
    }
  }

  Stream requestChatStream(String text)async*{
    ChatModel openAImodel = ChatModel(
      messages: [
        Messages(role: "system", content: "HI GPT"),
        ..._historyList,
      ],
      model: "gpt-4o",
      stream: true,
    );

    final url = Uri.https("api.openai.com","/v1/chat/completions");
    final request = http.Request("POST",url)
    ..headers.addAll({
      "Content-Type":"application/json; charset=UTF-8",
      "Authorization":"Bearer $apiKey",
      "Connection": "keep-alive",
      "Accept-Encoding":"gzip, deflate, br",
    });
    request.body=jsonEncode(openAImodel.toJson());

    final response = await http.Client().send(request);
    final byteStream = response.stream.asyncExpand((event)=>Rx.timer(event,
    const Duration(microseconds: 50)));

    var restext ="";

    await for (final byte in byteStream){
      var decode = (utf8.decode(byte, allowMalformed: false));
      final strings = decode.split("data: ");
      for(final string in strings){
        final trimmedString = string.trim();
        if(trimmedString.isNotEmpty&&!trimmedString.endsWith("[DONE]")){
          final map=jsonDecode(trimmedString) as Map;
          final choices = map["choices"] as List;
          final delta = choices[0]["delta"] as Map;
          if(delta["content"]!=null){
            final content = delta["content"]as String;
            restext += content;
            setState(() {
              streamText=restext;
            });
            yield content;
          }
        }
      }
    }
    if(restext.isNotEmpty){
      setState(() {

      });
    }
  }

  @override
  void dispose() {
    messageTextController.dispose();
    scrollController.dispose();


    super.dispose();
  }

  Future clearChat() async{
    showDialog(context: context, builder: (context)=>AlertDialog(
      title: const Text("new chat"),
      content: const Text('realy?'),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop();
          setState(() {
            messageTextController.clear();
            _historyList.clear();
          });
        }, child: const Text("yes"))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController messageTextController = TextEditingController();


    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: Card(
                  child: PopupMenuButton(itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                          child: ListTile(
                        title: Text("히스토리"),
                      )),
                      PopupMenuItem(
                        onTap: (){
                          clearChat();
                        },
                          child: const ListTile(
                        title: Text("새 채팅"),
                      ))
                    ];
                  }),
                ),
              ),
              Expanded(
                  child: GestureDetector(
                    onTap: ()=> FocusScope.of(context).unfocus(),
                    child: ListView.builder(
                        controller: scrollController,
                        itemCount: _historyList.length,
                        itemBuilder: (context, index){
                          if(_historyList[index].role=="user"){
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  const CircleAvatar(),
                                  const SizedBox(width: 8,),
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("User"),
                                      Text(_historyList[index].content),
                                    ],
                                  ))
                                ],
                              ),
                            );
                          }
                      return Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.green,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("ChatGPT"),
                              Text(_historyList[index].content)
                            ],
                          ))
                        ],
                      );
                    }),
                  )),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all()
                      ),
                      child: TextField(
                        controller: messageTextController,
                        decoration: const InputDecoration(
                            border: InputBorder.none, hintText: "Message"),
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: 42,
                      onPressed: () async{
                      if(messageTextController.text.isEmpty){
                        return;
                      }
                      setState(() {
                        _historyList.add(Messages(role: "user", content: messageTextController.text.trim()));
                        _historyList.add(Messages(role: "assistant", content: "content"));
                      });
                      try{
                        var text="";
                        final stream = requestChatStream(messageTextController.text.trim());
                        await for(final textChunk in stream){
                          text += textChunk;
                          setState(() {
                            _historyList.last = _historyList.last.copyWith(
                              content: text
                            );
                            _scrollDown();
                          });
                        }
                        // await requestChat(messageTextController.text.trim());
                        messageTextController.clear();
                        streamText="";
                      }catch(e){
                        print(e.toString());
                      }
                      },
                      icon: const Icon(Icons.arrow_circle_up))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
