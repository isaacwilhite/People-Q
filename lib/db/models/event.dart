class Event {
  int? eventId;
  int? contactId;
  DateTime eventDate;
  String description;

  Event({
    this.eventId,
    required this.contactId,
    required this.eventDate,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'contactId': contactId,
      'eventDate': eventDate.toIso8601String(),
      'description': description,
    };
  }

  static Event fromMap(Map<String, dynamic> map) {
    return Event(
      eventId: map['eventId'],
      contactId: map['contactId'],
      eventDate: DateTime.parse(map['eventDate']),
      description: map['description'],
    );
  }
}
