import 'package:carl_api/carl_api.dart';

class BusinessCountForDateResponse implements Serializable {
  BusinessCountForDateResponse(
      {this.count, this.weekCounts, this.correspondingDaysOfWeek, this.evolution, this.hasEvolve});

  final int count;
  final List<int> weekCounts;
  final List<int> correspondingDaysOfWeek;
  final double evolution;
  final bool hasEvolve;

  @override
  Map<String, dynamic> asMap() {
    final map = {
      "count": count,
      "weekCounts": weekCounts.toList(),
      "correspondingDaysOfWeek": correspondingDaysOfWeek.toList(),
      "evolution": evolution,
      "hasEvolve": hasEvolve
    };

    return map;
  }

  @override
  APISchemaObject documentSchema(APIDocumentContext context) {
    // TODO: implement documentSchema
    return null;
  }

  @override
  void read(Map<String, dynamic> object, {Iterable<String> ignore, Iterable<String> reject, Iterable<String> require}) {
    // TODO: implement read
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
    // TODO: implement readFromMap
  }
}
