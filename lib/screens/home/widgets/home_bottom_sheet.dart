// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../../core/data.dart';
import '../../../utils/app_color.dart';
import '../../../widgets/rounded_button.dart';
import '../../../widgets/rounded_image.dart';

/// Open when the user wants to create a new room.

class HomeBottomSheet extends StatefulWidget {
  final Function onButtonTap;

  const HomeBottomSheet({Key key, this.onButtonTap}) : super(key: key);

  @override
  State<HomeBottomSheet> createState() => _HomeBottomSheetState();
}

class _HomeBottomSheetState extends State<HomeBottomSheet> {
  var selectedButtonIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // List of 3 rooms: Open, Social, and Closed
              for (var i = 0, len = 3; i < len; i++) roomCard(i),
            ],
          ),
          Divider(thickness: 1, height: 60, indent: 20, endIndent: 20),
          Text(
            bottomSheetData[selectedButtonIndex]['selectedMessage'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          letsGoButton()
        ],
      ),
    );
  }

  Widget roomCard(int i) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        setState(() {
          selectedButtonIndex = i;
        });
      },
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: i == selectedButtonIndex
              ? AppColor.SelectedItemGrey
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: i == selectedButtonIndex
                ? AppColor.SelectedItemBorderGrey
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 5),
              child: RoundedImage(
                width: 70,
                height: 70,
                borderRadius: 20,
                path: bottomSheetData[i]['image'],
              ),
            ),
            Text(
              bottomSheetData[i]['text'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget letsGoButton() {
    return RoundedButton(
        color: AppColor.AccentGreen,
        onPressed: widget.onButtonTap,
        text: '🎉 Go Chat');
  }
}
