import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.push('/complaints'),
              child: const Text("Make Complaint"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/reviews'),
              child: const Text("Leave Review"),
            ),
          ],
        ),
      ),
    );
  }
}
