import 'package:flutter/material.dart';
import 'package:test_1/constants/common_size.dart';
import 'package:test_1/widgets/rounded_avatar.dart';

class Comment extends StatelessWidget {
  final bool showImage;
  final String username;
  final String text;
  final DateTime? dateTime;

  const Comment({Key? key, this.showImage=true, required this.username, required this.text, this.dateTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showImage) RoundedAvatar(size: 24),
        if (showImage) SizedBox(width: common_xxs_gap),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: username,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              TextSpan(text: '    '),
              TextSpan(text: text, style: TextStyle(color: Colors.black)),
            ])),
            if(dateTime!=null)
              Text(
                dateTime!.toIso8601String(),style: TextStyle(color: Colors.grey[600],fontSize: 10),
              )
          ],
        )
      ],
    );
  }
}
