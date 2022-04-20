class Assumption {
  Assumption(
      {required this.key, required this.assumption, required this.confidence});

  final String key;
  final String assumption;
  final double confidence;

  String getKey() {
    return key;
  }

  String getAssumption() {
    return assumption;
  }

  double getConfidence() {
    return confidence;
  }
}
