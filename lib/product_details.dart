import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding API response
import 'notifications.dart'; // Import NotificationScreen

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _productDetails = {};
  List<dynamic> _priceHistory = [];

  // Function to fetch product details based on productId
  Future<void> _fetchProductDetails() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products/${widget.productId}'));

    if (response.statusCode == 200) {
      final productData = json.decode(response.body);
      setState(() {
        _productDetails = productData;
        _priceHistory = [
          {"price": productData['price'], "date": DateTime.now().toString()},
        ]; // Simulating price history
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Failed to load product details');
    }
  }

  // Function to show the confirmation dialog
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Alert"),
          content: const Text("Are you sure you want to add this product to notifications?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Add to notifications (simulated here by static list)
                _addToNotifications();
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  // Simulated list to store products to be notified about
  void _addToNotifications() {
    // You can replace this with a state management solution or shared preferences
    notificationProducts.add(_productDetails);
    print("Product added to notifications");
  }

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_productDetails.isEmpty ? 'Loading...' : _productDetails['title']),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price: \$${_productDetails['price']}'),
                  const SizedBox(height: 10),
                  const Text('Product Details:'),
                  const SizedBox(height: 5),
                  Text(_productDetails['description']),
                  const SizedBox(height: 20),
                  const Text('Price History:'),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _priceHistory.length,
                      itemBuilder: (context, index) {
                        final history = _priceHistory[index];
                        return ListTile(
                          title: Text('Price: \$${history['price']}'),
                          subtitle: Text('Date: ${history['date']}'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showConfirmationDialog,
                    child: const Text('Add Alert for Price Change'),
                  ),
                ],
              ),
            ),
    );
  }
}
