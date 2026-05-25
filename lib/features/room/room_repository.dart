import 'package:soulfood_front/core/app_bootstrap.dart';
import 'package:soulfood_front/features/room/room_models.dart';

class RoomRepository {
  RoomRepository() : _api = AppServices.I.api;

  final dynamic _api;

  Future<RoomDetail> createRoom({
    required String topic,
    int maxPeople = 4,
    int durationMin = 20,
    List<String>? initialOptions,
  }) async {
    final created = await _api.postData<Map<String, dynamic>>(
      '/api/v1/rooms',
      data: {
        'topic': topic,
        'maxPeople': maxPeople,
        'durationMin': durationMin,
        if (initialOptions != null && initialOptions.isNotEmpty)
          'initialOptions': initialOptions,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
    return getRoom(created['code'] as String);
  }

  Future<RoomDetail> joinRoom(String code) async {
    return _api.postData(
      '/api/v1/rooms/$code/join',
      parser: (json) => RoomDetail.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<RoomDetail> getRoom(String code) async {
    return _api.getData(
      '/api/v1/rooms/$code',
      parser: (json) => RoomDetail.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<RoomDetail> addOption(String code, String title, {String source = 'manual'}) async {
    await _api.postData<Map<String, dynamic>>(
      '/api/v1/rooms/$code/options',
      data: {'title': title, 'source': source},
      parser: (json) => json as Map<String, dynamic>,
    );
    return getRoom(code);
  }

  Future<RoomDetail> vote(String code, int optionId) async {
    return _api.postData(
      '/api/v1/rooms/$code/votes',
      data: {'optionId': optionId},
      parser: (json) => RoomDetail.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<RoomResult> result(String code) async {
    return _api.getData(
      '/api/v1/rooms/$code/result',
      parser: (json) => RoomResult.fromJson(json as Map<String, dynamic>),
    );
  }
}
