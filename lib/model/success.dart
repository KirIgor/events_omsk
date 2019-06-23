class Success {
  bool _success;
  List<String> _errors;

  Success.fromJson(Map<String, dynamic> parsedJson) {
    _success = parsedJson["success"];
    _errors = parsedJson["errors"];
  }

  bool get success => _success;
  List<String> get errors => _errors;
}
