class Assumption {
  Assumption(
      {required this.key, required this.assumption, required this.confidence});

  String key;
  String assumption;
  double confidence;

  String getKey() {
    return key;
  }

  void setKey(String key) {
    this.key = key;
  }

  String getAssumption() {
    return assumption;
  }

  void setAssumption(String assumption) {
    this.assumption = assumption;
  }

  double getConfidence() {
    return confidence;
  }

  void setConfidence(double confidence) {
    this.confidence = confidence;
  }
}
