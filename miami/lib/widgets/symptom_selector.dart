import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_provider.dart';

class SymptomSelector extends StatelessWidget {
  final int checklistId; // ✅ Changed to `int` to match the correct type
  final bool isLatest;
  final List<String> symptoms; // ✅ Holds symptom names

  const SymptomSelector({
    super.key,
    required this.checklistId,
    required this.isLatest,
    required this.symptoms,
  });

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    // ✅ Show loading indicator while fetching symptoms
    if (chatProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...symptoms.map((symptom) {
          final bool isSelected = chatProvider.symptoms
              .any((s) => s.name == symptom && s.isSelected);

          return CheckboxListTile(
            title: Text(
              symptom,
              style: TextStyle(
                color: isLatest
                    ? Colors.black
                    : Colors.grey, // ✅ Disable old checklists
              ),
            ),
            value: isSelected,
            onChanged: isLatest
                ? (_) => chatProvider.toggleSymptom(symptom, checklistId)
                : null, // ✅ Prevent changes to old checklists
            activeColor: Colors.black, // ✅ Ensures checkbox color
            checkColor: Colors.white,
          );
        }).toList(),

        // ✅ Show submit button ONLY for the latest checklist
        if (isLatest && symptoms.isNotEmpty)
          ElevatedButton(
            onPressed: chatProvider.isSubmitted
                ? null
                : () => chatProvider.submitSymptoms(checklistId),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  chatProvider.isSubmitted ? Colors.grey : Colors.black,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              "Submit Symptoms",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
