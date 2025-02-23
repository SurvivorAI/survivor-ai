import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/symptom_model.dart';
import '../core/api_service.dart'; // Now uses mock data

class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  final List<Symptom> _symptoms = [];
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false; // New: Tracks submission state
  int _latestChecklistId = 0; // New: Tracks latest checklist ID

  List<Message> get messages => _messages;
  List<Symptom> get symptoms => _symptoms;
  TextEditingController get promptController => _promptController;
  bool get isLoading => _isLoading;
  bool get isSubmitted => _isSubmitted;
  int get latestChecklistId => _latestChecklistId;

  //provider function
  Future<void> sendMessage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    _messages.add(Message(text: prompt, isUser: true));
    _promptController.clear();

    _symptoms.clear();
    _isSubmitted = false;
    _latestChecklistId++;
    notifyListeners();

    _setLoading(true);

    try {
      final symptomList = await ApiService.getSymptoms(prompt);

      _messages.add(Message(
        text: "Please select your symptoms:",
        isUser: false,
        symptoms: symptomList,
        checklistId: _latestChecklistId,
      ));

      _symptoms.clear();
      _symptoms.addAll(symptomList.map((s) => Symptom(name: s)));
    } catch (e) {
      _messages.add(Message(
        text: "Failed to fetch symptoms. Please try again.",
        isUser: false,
      ));
    } finally {
      _setLoading(false);
    }
  }

  //provider function
  void toggleSymptom(String symptomName, int checklistId) {
    if (checklistId != _latestChecklistId) {
      return; // ✅ Prevent outdated selections
    }
    if (!_isSubmitted) {
      // ✅ Only allow selection if symptoms are not submitted
      final index = _symptoms.indexWhere((s) => s.name == symptomName);
      if (index != -1) {
        _symptoms[index].isSelected = !_symptoms[index].isSelected;
        notifyListeners();
      }
    }
  }

  Future<void> submitSymptoms(int checklistId) async {
    if (checklistId != _latestChecklistId) {
      return; // ✅ Prevent outdated submissions
    }
    if (_isSubmitted) return; // ✅ Prevent multiple submissions
    _isSubmitted = true;
    final selectedSymptoms =
        _symptoms.where((s) => s.isSelected).map((s) => s.name).toList();

    if (selectedSymptoms.isEmpty) {
      _messages.add(Message(text: "No symptoms selected.", isUser: false));
      notifyListeners();
      return;
    }

    _messages.add(Message(
      text: "Selected Symptoms: ${selectedSymptoms.join(', ')}",
      isUser: true,
    ));
    notifyListeners();

    _setLoading(true);

    try {
      final success = await ApiService.submitSymptoms(selectedSymptoms);
      _messages.add(Message(
        text: success[0],
        isUser: false,
      ));
    } catch (e) {
      _messages.add(Message(
        text: "Submission failed. Check your connection and try again.",
        isUser: false,
      ));
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
