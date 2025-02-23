import 'package:flutter/material.dart';
import 'package:frontend/core/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/message_model.dart';
import '../viewmodels/chat_provider.dart';
import 'symptom_selector.dart'; // Import the SymptomSelector widget

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final hasSymptoms = message.symptoms != null;
    final chatProvider = Provider.of<ChatProvider>(context);
    final bool isLatestChecklist =
        message.checklistId == chatProvider.latestChecklistId;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isUser ? PrimaryColor(userPromptColor) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          border:
              isUser ? null : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: hasSymptoms
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.nunito(
                      color: message.isUser ? Colors.white : Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  SymptomSelector(
                    symptoms: message.symptoms!,
                    checklistId: message.checklistId!,
                    isLatest: isLatestChecklist,
                  ), // ✅ Passes checklist info to SymptomSelector
                ],
              )
            : Text(
                message.text,
                style: GoogleFonts.nunito(
                  color: isUser ? Colors.white : Colors.black,
                  fontSize: 16.0,
                ),
              ),
      ),
    );
  }
}
