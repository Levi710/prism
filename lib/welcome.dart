import 'package:flutter/material.dart';
import 'styles/gradients.dart'; // Ensure the path is correct

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.sunsetGradient, // Applying gradient
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Find Deals',
                style: TextStyle(color: Colors.white, fontSize: 32),
              ),
              const SizedBox(height: 10),
              const Text(
                'Discover better prices effortlessly.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              ExploreButton(), // Using the Stateful Explore button
            ],
          ),
        ),
      ),
    );
  }
}

class ExploreButton extends StatefulWidget {
  const ExploreButton({super.key});

  @override
  _ExploreButtonState createState() => _ExploreButtonState();
}

class _ExploreButtonState extends State<ExploreButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to the HomeScreen when the button is pressed
        Navigator.pushNamed(context, '/signup');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:Colors.blueAccent, // Button color
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: const Text('Explore'),
    );
  }
}
