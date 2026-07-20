class GenerateRecommendationRequestDto {
  final String? tripDate; // YYYY-MM-DD
  final double? startLongitude;
  final double? startLatitude;
  final int? availableMinutes;

  GenerateRecommendationRequestDto({
    this.tripDate,
    this.startLongitude,
    this.startLatitude,
    this.availableMinutes,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (tripDate != null) data['tripDate'] = tripDate;
    if (startLongitude != null) data['startLongitude'] = startLongitude;
    if (startLatitude != null) data['startLatitude'] = startLatitude;
    if (availableMinutes != null) data['availableMinutes'] = availableMinutes;
    return data;
  }
}

class RecommendationAcceptedResponseDto {
  final String runId;
  final String status;
  final String statusUrl;

  RecommendationAcceptedResponseDto({
    required this.runId,
    required this.status,
    required this.statusUrl,
  });

  factory RecommendationAcceptedResponseDto.fromJson(Map<String, dynamic> json) {
    return RecommendationAcceptedResponseDto(
      runId: json['runId'] as String,
      status: json['status'] as String,
      statusUrl: json['statusUrl'] as String,
    );
  }
}

class RecommendationRunResponseDto {
  final String runId;
  final String status;
  final RecommendationResponseDto? result;

  RecommendationRunResponseDto({
    required this.runId,
    required this.status,
    this.result,
  });

  factory RecommendationRunResponseDto.fromJson(Map<String, dynamic> json) {
    return RecommendationRunResponseDto(
      runId: json['runId'] as String,
      status: json['status'] as String,
      result: json['result'] != null 
          ? RecommendationResponseDto.fromJson(json['result']) 
          : null,
    );
  }
}

class RecommendationResponseDto {
  final String runId;
  final String status;
  final String overallExplanation;
  final List<TimelineRecommendationResponseDto> timeline;

  RecommendationResponseDto({
    required this.runId,
    required this.status,
    required this.overallExplanation,
    required this.timeline,
  });

  factory RecommendationResponseDto.fromJson(Map<String, dynamic> json) {
    return RecommendationResponseDto(
      runId: json['runId'] as String,
      status: json['status'] as String,
      overallExplanation: json['overallExplanation'] as String? ?? '',
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((e) => TimelineRecommendationResponseDto.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TimelineRecommendationResponseDto {
  final int sequence;
  final String placeId;
  final String placeName;
  final String startTime;
  final int durationMinutes;
  final String explanation;

  TimelineRecommendationResponseDto({
    required this.sequence,
    required this.placeId,
    required this.placeName,
    required this.startTime,
    required this.durationMinutes,
    required this.explanation,
  });

  factory TimelineRecommendationResponseDto.fromJson(Map<String, dynamic> json) {
    return TimelineRecommendationResponseDto(
      sequence: json['sequence'] as int? ?? 0,
      placeId: json['placeId'] as String? ?? '',
      placeName: json['placeName'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }
}
