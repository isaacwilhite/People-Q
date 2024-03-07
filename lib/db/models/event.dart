class Event {
  int? eventId;
  int? contactId;
  String eventDate;
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
      'eventDate': eventDate,
      'description': description,
    };
  }

  static Event fromMap(Map<String, dynamic> map) {
    return Event(
      eventId: map['eventId'],
      contactId: map['contactId'],
      eventDate: map['eventDate'],
      description: map['description'],
    );
  }
}
