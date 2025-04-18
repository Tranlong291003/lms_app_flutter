import 'package:flutter/material.dart';
import 'package:lms/apps/utils/app_bar.dart';
import 'package:lms/apps/utils/searchBarWidget.dart';
import 'package:lms/screens/home/widget/discountSlider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, 'title'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SearchBarWidget(),
              const SizedBox(height: 20),
              DiscountSlider(),
              const Text(
                'Welcome to the Home Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle button press
                },
                child: const Text('Go to Next Screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
