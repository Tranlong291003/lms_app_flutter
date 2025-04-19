import 'package:flutter/material.dart';
import 'package:lms/apps/utils/searchBarWidget.dart';
import 'package:lms/screens/home/widget/app_bar.dart';
import 'package:lms/screens/home/widget/discountSlider.dart';
import 'package:lms/screens/home/widget/topMentors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHome(context, 'title'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SearchBarWidget(),
              const SizedBox(height: 10),
              DiscountSlider(),
              const SizedBox(height: 10),
              TopMentors(),
            ],
          ),
        ),
      ),
    );
  }
}
