import 'package:flutter/material.dart';

class RoutePage extends StatelessWidget {
  const RoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Planner'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select Start and End Points',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Start Point',
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'End Point',
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.directions_car),
                      onPressed: () {
                        // Implement car button functionality here
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.local_shipping),
                      onPressed: () {
                        // Implement truck button functionality here
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.directions_bike),
                      onPressed: () {
                        // Implement bicycle button functionality here
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.directions_walk),
                      onPressed: () {
                        // Implement walking button functionality here
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Implement logic to calculate routes here.
                    // You can use the entered start and end points.
                    // Display the calculated route or navigate to a new page.
                  },
                  child: const Text('Calculate Route'),
                ),
              ],
            ),
          ),
          // Button to the right of text fields
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.swap_horiz), // Replace with your interchange icon
              onPressed: () {
                // Implement your interchange button functionality here
              },
            ),
          ),
        ],
      ),
    );
  }
}
