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
    Assumption(key: "rescuee", assumption: "no assumption found", confidence: 0),
    Assumption(key: "location", assumption: "no assumption found", confidence: 0),
    Assumption(key: "condition", assumption: "no assumption found", confidence: 0),
    Assumption(key: "datetime", assumption: "no assumption found", confidence: 0),
    Assumption(key: "weather", assumption: "no assumption found", confidence: 0),
    Assumption(key: "visibility", assumption: "no assumption found", confidence: 0),
  ];

  int progress = 0;

  Map<DateTime, String> messages = {
    DateTime.now(): "(EMKAB) Team leader, please enter a description of the scenario.",
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
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": 'true',
        "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
        "Access-Control-Allow-Methods": "POST"
      },
      body: jsonEncode(<String, String>{'text': inputController.text}));
    inputController.clear();

    if (response.statusCode == 200) {
      setState(() {
        progress += 1;
      });

      EMKABResponse emkabResponse = EMKABResponse.fromJson(jsonDecode(response.body));

      for (var v in emkabResponse.getAssumptions()) {
        for (var i = 0; i < assumptions.length; i++) {
          if (v.getKey() == assumptions[i].getKey()) {
            setState(() {
              assumptions[i].setAssumption(v.getAssumption());
              assumptions[i].setConfidence(v.getConfidence());
            });
          }
        }
      }
    } else {
      messages[DateTime.now()] = "Error in response from EMKAB";
      throw Exception('Failed to get response');
    }
  }

  void addMessage() {
    setState(() {
      messages[DateTime.now()] = inputController.text;
    });
  }

  Color getConfidenceColor(double confidence) {
    if (confidence >= -.8) {
      return Colors.green;
    } else if (confidence >= -1.6) {
      return Colors.orangeAccent;
    }
    return Colors.red;
  }

  String getConfidenceText(double confidence) {
    if (confidence == 0) {
      return "";
    } else if (confidence >= -.8) {
      return "(high conf)";
    } else if (confidence >= -1.6) {
      return "(medium conf)";
    }
    return "(low conf)";
  }

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Container(
        margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.6,
          left: MediaQuery.of(context).size.width * 0.4
        ),
        padding: EdgeInsets.only(top: 10.0),
        color: Colors.white,
        child: Row(children: [
        Flexible(
          child: Column(children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10.0),
              child: const Center(
                child: Text('Text Log', style: TextStyle(fontSize: 30.0))
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                itemCount: messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          messages.keys.toList()[index].hour.toString() + ":" + messages.keys.toList()[index].minute.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            messages.values.toList()[index],
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              )
            ),
            Row(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    style: TextStyle(fontSize: 20.0),
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
                child: const Text('Submit', style: TextStyle(fontSize: 20.0)),
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
                },
              ),
              const SizedBox(width: 10.0)
            ])
          ]),
        ),
        Expanded(
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              child: const Center(
                child: Text('Scenario Assumptions', style: TextStyle(fontSize: 30.0))
              ),
            ),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                itemCount: assumptions.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(children: [
                      Text(
                        assumptions[index].getKey() + ": " + assumptions[index].getAssumption(),
                        style: const TextStyle(fontSize: 20.0),
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        getConfidenceText(assumptions[index].getConfidence()),
                        style: TextStyle(
                          fontSize: 20.0,
                          color: getConfidenceColor(assumptions[index].getConfidence())),
                      )
                    ])
                  );
                }
              )
            ),
          ]),
        ),
      ]))
    );
  }
}
