import 'dart:async';
import 'dart:convert';

import 'package:emkab/Assumption.dart';
import 'package:emkab/EMKABResponse.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EMKAB',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'EMKAB'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Assumption> assumptions = [
    //comment out later on
    // Assumption(key: "condition", assumption: "assumption 1", confidence: 0.85),
    // Assumption(key: "datetime", assumption: "assumption 2", confidence: 0.9),
    // Assumption(key: "location", assumption: "assumption 3", confidence: 0.5),
    // Assumption(key: "rescuee", assumption: "assumption 4", confidence: 0.3),
    // Assumption(key: "weather", assumption: "assumption 5", confidence: 0.85),
    // Assumption(key: "visibility", assumption: "assumption 6", confidence: 0.1),
  ];

  int progress = 0;

  Map<DateTime, String> messages = {
    DateTime.now(): "Team Leader, please enter a description of the scenario: ",
  };

  TextEditingController inputController = TextEditingController();

  Future submitResponse() async {
    //TODO: make sure that this url is updated when working on different computer
    String host = 'http://127.0.0.1:8080/';
    String route = '';
    if (progress == 0) {
      route = 'init';
    } else if (inputController.text == "quit") {
      route = 'reset';
    } else {
      route = 'update';
    }

    final response = await http.post(Uri.parse(host + route),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Access-Control-Allow-Origin":
              "*", // Required for CORS support to work
          "Access-Control-Allow-Credentials":
              'true', // Required for cookies, authorization headers with HTTPS
          "Access-Control-Allow-Headers":
              "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
          "Access-Control-Allow-Methods": "POST"
        },
        body: jsonEncode(<String, String>{'text': inputController.text}));
    inputController.clear();

    if (response.statusCode == 200) {
      EMKABResponse emkabResponse =
          EMKABResponse.fromJson(jsonDecode(response.body));

      setState(() {
        assumptions = emkabResponse.getAssumptions();
        //messages[DateTime.now()] = emkabResponse.getMessage();
      });
    } else {
      messages[DateTime.now()] = "Error in response from EMKAB";
      throw Exception('Failed to get response');
    }
  }

  void addMessage() {
    setState(() {
      messages[DateTime.now()] = inputController.text;
      //inputController.clear();
    });
  }

  Color getConfidenceColor(double confidence) {
    if (confidence >= .8) {
      return Colors.green;
    } else if (confidence >= .5) {
      return Colors.orangeAccent;
    }
    return Colors.red;
  }

  final ScrollController scrollController = ScrollController();

  // void _scrollDown() {
  //   _controller.jumpTo(_controller.position.maxScrollExtent);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('EMKAB'),
        ),
        body: Row(
          children: [
            Expanded(
              //assumptions
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: const Center(
                        child: Text('Assumptions',
                            style: TextStyle(fontSize: 20.0))),
                  ),
                  Flexible(
                      child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          itemCount: assumptions.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                  children: [
                                    Text(
                                      assumptions[index].getKey() +
                                          ": " +
                                          assumptions[index].getAssumption(),
                                      style: const TextStyle(fontSize: 12.0),
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      "(" +
                                          (assumptions[index].getConfidence() *
                                                  100)
                                              .toString() +
                                          "% conf)",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: getConfidenceColor(
                                              assumptions[index]
                                                  .getConfidence())),
                                    )
                                  ],
                                ));
                          })),
                ],
              ),
            ), //assumptions
            Flexible(
              //messages
              child: Column(children: <Widget>[
                Expanded(
                    child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        itemCount: messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          //final DateFormat formatter = DateFormat('jm');

                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  //messages.key.toList()[index]
                                  messages.keys
                                          .toList()[index]
                                          .hour
                                          .toString() +
                                      ":" +
                                      messages.keys
                                          .toList()[index]
                                          .minute
                                          .toString(),
                                  style: const TextStyle(fontSize: 8),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                  child: Text(
                                    messages.values.toList()[index],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          );
                        })),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextField(
                          style: TextStyle(fontSize: 12.0),
                          controller: inputController,
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Type response here...',
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      child: const Text('Submit'),
                      onPressed: () async {
                        addMessage();
                        submitResponse(); //submits the get request
                        //also the clear message got moved to the submit response so make sure to comment out later
                        Timer(Duration(milliseconds: 100), () {
                          scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            curve: Curves.easeOut,
                            duration: const Duration(milliseconds: 150),
                          ); //scrolls it down
                        });
                        progress++;
                      },
                    ),
                    const SizedBox(
                      width: 10.0,
                    )
                  ],
                )
              ]),
            ), //messages
          ],
        ));
  }
}
