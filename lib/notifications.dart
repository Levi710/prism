import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

// Global list to hold products added for notifications
List<dynamic> notificationProducts = [];

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to show the dialog for removing a product
 void _showRemoveDialog(BuildContext context, int index) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Remove Product"),
        content: const Text("Are you sure you want to remove this product from notifications?"),
        actions: [
          TextButton(
            onPressed: () async {
              // Remove the product from the notification list and update Firestore
              final removedProduct = notificationProducts[index];
              
              try {
                // Remove product from the list
                setState(() {
                  notificationProducts.removeAt(index);
                });

                // Update Firestore with removed_at timestamp
                await _firestore.collection('products').doc(removedProduct['id']).update({
                  'removed_at': Timestamp.now(),
                });

                // Close the dialog after successful Firestore update
                Navigator.pop(context);
              } catch (error) {
                // Show error if Firestore update fails
                print("Error updating removed_at timestamp: $error");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to update database. Try again.")),
                );
              }
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog without changes
            },
            child: const Text("No"),
          ),
        ],
      );
    },
  );
}


  // Function to show the dialog for setting a time for price fluctuation tracking
  void _showSetTimeDialog(BuildContext context, int index) {
    TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Set Time for Price Fluctuations"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter the time period for tracking price fluctuations (format: Y:M:D:H:M:S)"),
              TextField(
                controller: timeController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: 'e.g., 1:00:12:07:00:02 for 1 year 12 days 7 hours 2 seconds',
                  fillColor: Colors.black,
                  filled: true,
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (timeController.text.isNotEmpty) {
                  final timerParts = timeController.text.split(':');
                  if (timerParts.length == 6) {
                    final years = int.tryParse(timerParts[0]);
                    final months = int.tryParse(timerParts[1]);
                    final days = int.tryParse(timerParts[2]);
                    final hours = int.tryParse(timerParts[3]);
                    final minutes = int.tryParse(timerParts[4]);
                    final seconds = int.tryParse(timerParts[5]);

                    if (years != null && months != null && days != null &&
                        hours != null && minutes != null && seconds != null) {
                      // Store the time for tracking price fluctuations (simulate by adding a field)
                      setState(() {
                        notificationProducts[index]['trackTime'] = DateTime.now().add(
                          Duration(
                            days: (years * 365) + (months * 30) + days,
                            hours: hours,
                            minutes: minutes,
                            seconds: seconds,
                          ),
                        );
                      });
                      _startTimer(index); // Start the timer countdown
                      Navigator.pop(context); // Close the dialog
                    } else {
                      // Show error message if the input is invalid
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid time format.')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a time period.')),
                  );
                }
              },
              child: const Text("Set Time"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // Start the timer countdown and update the product list
  void _startTimer(int index) {
    final targetTime = notificationProducts[index]['trackTime'];

    Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = targetTime.difference(DateTime.now());

      if (remaining.isNegative) {
        timer.cancel(); // Stop the timer once the countdown is over
        _showTimerExpiredDialog(index);
      } else {
        setState(() {
          notificationProducts[index]['remainingTime'] = remaining;
        });
      }
    });
  }

  // Dialog for when the timer expires
  void _showTimerExpiredDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Timer Expired"),
          content: const Text("No price change found in the set timer. Do you want to extend the timer or remove this product from notifications?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSetTimeDialog(context, index); // Show set time dialog again
              },
              child: const Text("Extend Timer"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  notificationProducts.removeAt(index); // Remove the product
                });
                Navigator.pop(context);
              },
              child: const Text("Remove from Notifications"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notificationProducts.isEmpty
          ? const Center(child: Text('No notifications added.'))
          : ListView.builder(
              itemCount: notificationProducts.length,
              itemBuilder: (context, index) {
                final product = notificationProducts[index];
                final remainingTime = product['remainingTime'];
                final timeString = remainingTime != null
                    ? '${remainingTime.inDays} days ${remainingTime.inHours % 24} hours ${remainingTime.inMinutes % 60} minutes ${remainingTime.inSeconds % 60} seconds'
                    : '';

                return ListTile(
                  title: Text(product['title']),
                  subtitle: Text('Price: \$${product['price']}'),
                  trailing: Text(timeString, style: const TextStyle(color: Colors.green)),
                  onTap: () {
                    // Show a bottom sheet with options to set time or remove the product
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return ListTile(
                          title: const Text('Options'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: const Text('Set Time for Price Fluctuations'),
                                onTap: () {
                                  Navigator.pop(context); // Close the bottom sheet
                                  _showSetTimeDialog(context, index);
                                },
                              ),
                              ListTile(
                                title: const Text('Remove from Notifications'),
                                onTap: () {
                                  Navigator.pop(context); // Close the bottom sheet
                                  _showRemoveDialog(context, index);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
