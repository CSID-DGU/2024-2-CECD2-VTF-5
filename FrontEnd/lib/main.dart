import 'package:flutter/material.dart';

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


  static const String _kStrings = "chat bot";
  String get _currentString => _kStrings;

  @override
  void dispose() {
    messageTextController.dispose();

    super.dispose();
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
                      PopupMenuItem(
                          child: ListTile(
                        title: const Text("히스토리"),
                      )),
                      PopupMenuItem(
                          child: ListTile(
                            title: const Text("새 채팅"),
                          ))
                    ];
                  }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
