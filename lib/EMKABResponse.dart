import 'package:emkab/Assumption.dart';

class EMKABResponse {
  // EMKABResponse(
  //     {required this.resume, required this.message, required this.assumptions});

  EMKABResponse({required this.assumptions});

  //final bool resume;
  //final String message;
  final List<Assumption> assumptions;

  factory EMKABResponse.fromJson(Map<String, dynamic> data) {
    //final resume = data['resume'] as bool;

    List<Assumption> input = [];
    for (String k in data.keys) {
      input.add(
          Assumption(key: k, assumption: data[k][0], confidence: data[k][1]));
    }
    //final message = data['message'] as String;
    // final assumptions = (data['assumptions'] as List)
    //     .map((i) => Assumption.fromJson(i))
    //     .toList();

    // return EMKABResponse(
    //     resume: resume, message: message, assumptions: assumptions);

    return EMKABResponse(assumptions: input);
  }
  //
  // bool getResume() {
  //   return resume;
  // }

  // String getMessage() {
  //   return message;
  // }

  List<Assumption> getAssumptions() {
    return assumptions;
  }
}
