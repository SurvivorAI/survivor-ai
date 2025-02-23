class Message {
  final String text;
  final bool isUser;
  final List<String>? symptoms; // Nullable for AI responses with symptom lists
  final int? checklistId; // Add this line
  Message(
      {required this.text,
      required this.isUser,
      this.symptoms,
      this.checklistId}); // Add this line
}
