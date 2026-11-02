import 'package:alumni_connect/core/network/alumni_api.dart';
import 'package:alumni_connect/features/events/data/models/event_attendee_model.dart';
import 'package:alumni_connect/features/events/data/models/event_model.dart';

class EventPage {
  const EventPage({required this.items, required this.totalCount});
  final List<EventModel> items;
  final int totalCount;
}

class EventRepository {
  EventRepository(this.api);
  final AlumniApi api;

  Future<EventPage> getEvents({
    String? campus,
    bool upcomingOnly = true,
    int page = 1,
  }) async {
    final response = await api.forum.get(
      '/api/v1/events',
      query: {
        'page': '$page',
        'pageSize': '100',
        'upcomingOnly': '$upcomingOnly',
        if (campus != null && campus != 'All') 'campus': campus,
      },
    );
    final rows = response['items'] as List<dynamic>? ?? const [];
    return EventPage(
      items: rows
          .whereType<Map<String, dynamic>>()
          .map(EventModel.fromJson)
          .toList(),
      totalCount: response['totalCount'] as int? ?? rows.length,
    );
  }

  Future<EventModel> getEvent(String id) async =>
      EventModel.fromJson(await api.forum.get('/api/v1/events/$id'));

  Future<List<EventAttendeeModel>> getAttendees(String id) async =>
      (await api.forum.getList('/api/v1/events/$id/attendees'))
          .whereType<Map<String, dynamic>>()
          .map(EventAttendeeModel.fromJson)
          .toList();

  Future<EventModel> createEvent({
    required String title,
    required String description,
    required String location,
    required String campus,
    required DateTime startTime,
    required DateTime endTime,
    required int? maxAttendees,
    required String bannerUrl,
  }) async => EventModel.fromJson(
    await api.forum.post(
      '/api/v1/events',
      body: {
        'title': title,
        'description': description,
        'location': location,
        'campus': campus,
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
        'maxAttendees': maxAttendees,
        'bannerUrl': bannerUrl,
      },
    ),
  );

  Future<void> rsvp(String id, String status) async {
    await api.forum.post('/api/v1/events/$id/rsvp', body: {'status': status});
  }

  Future<void> deleteEvent(String id) => api.forum.delete('/api/v1/events/$id');

  static String campusCode(String label) => switch (label) {
    'Hòa Lạc' || 'FPT Hòa Lạc' => 'FU-HL',
    'TP. Hồ Chí Minh' || 'TP.HCM' || 'FPT TP.HCM' => 'FU-HCM',
    'Đà Nẵng' || 'FPT Đà Nẵng' => 'FU-DN',
    'Cần Thơ' || 'FPT Cần Thơ' => 'FU-CT',
    'Quy Nhơn' || 'FPT Quy Nhơn' => 'FU-QN',
    _ => 'All',
  };

  static String campusLabel(String code) => switch (code) {
    'FU-HL' => 'Hòa Lạc',
    'FU-HCM' => 'TP. Hồ Chí Minh',
    'FU-DN' => 'Đà Nẵng',
    'FU-CT' => 'Cần Thơ',
    'FU-QN' => 'Quy Nhơn',
    _ => 'Tất cả cơ sở',
  };
}
