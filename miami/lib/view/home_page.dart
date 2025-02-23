import 'package:flutter/material.dart';
import 'package:frontend/core/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/chat_provider.dart';
import '../widgets/chat_bubble.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56), // Standard AppBar height
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.8), // Darker at the top
                PrimaryColor(appBarColor)
                    .withOpacity(0.9), // Lighter towards bottom
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5), // ✅ Smooth shadow effect
                blurRadius: 10, // ✅ Softens shadow edges
                spreadRadius: 2,
                offset: const Offset(0, 4), // ✅ Moves shadow downward
              ),
            ],
          ),
          child: AppBar(
            backgroundColor:
                Colors.transparent, // ✅ Transparent to show gradient
            elevation: 0, // ✅ Removes default AppBar shadow
            title: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icon2.png',
                    height: 36, // ✅ Slightly bigger for better balance
                  ),
                  const SizedBox(width: 8),
                  Text("Survivor ",
                      style: GoogleFonts.oswald(color: Colors.white)),
                  Text(
                    "AI",
                    style: GoogleFonts.oswald(
                      color: PrimaryColor(aiText),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: PrimaryColor(backGroundColor),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: chatProvider.messages[index]);
              },
            ),
          ),
          _buildInputSection(chatProvider),
        ],
      ),
    );
  }

  Widget _buildInputSection(ChatProvider chatProvider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // ✅ Smooth transition effect
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.95), // ✅ Soft white at the top
            Colors.grey.shade200.withOpacity(0.9), // ✅ Light grey at the bottom
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15), // ✅ Smooth shadow effect
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, -2), // ✅ Moves shadow slightly upwards
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: chatProvider.promptController,
              style: GoogleFonts.nunito(color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors
                    .grey.shade100, // ✅ Lighter background inside input field
                hintText: "Enter your disease...",
                hintStyle: GoogleFonts.nunito(color: PrimaryColor(aiText)),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          GestureDetector(
            onTap: chatProvider.sendMessage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: PrimaryColor(aiText), // ✅ Matches AI text color
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PrimaryColor(aiText)
                        .withOpacity(0.6), // ✅ Glowing effect
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
