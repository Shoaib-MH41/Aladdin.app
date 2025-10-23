class DebugRequest {
  final String faultyCode;
  final String errorDescription;
  final String originalPrompt;
  final String flutterVersion;
  final String platform;

  DebugRequest({
    required this.faultyCode,
    required this.errorDescription,
    required this.originalPrompt,
    this.flutterVersion = '3.19.0',
    this.platform = 'Android',
  });

  Map<String, dynamic> toMap() {
    return {
      'faultyCode': faultyCode,
      'errorDescription': errorDescription,
      'originalPrompt': originalPrompt,
      'flutterVersion': flutterVersion,
      'platform': platform,
    };
  }
}

class DebugResponse {
  final String fixedCode;
  final String explanation;
  final String rootCause;
  final List<String> preventionTips;
  final bool success;

  DebugResponse({
    required this.fixedCode,
    required this.explanation,
    required this.rootCause,
    required this.preventionTips,
    required this.success,
  });
}
