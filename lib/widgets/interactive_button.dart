import 'package:flutter/material.dart';

class InteractiveButton extends StatefulWidget {
  final String label;
  final IconData icon;

  const InteractiveButton({super.key, required this.label, required this.icon});

  @override
  _InteractiveButtonState createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<InteractiveButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isPressed = !isPressed;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isPressed ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: isPressed ? Colors.white : Colors.black),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(color: isPressed ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
