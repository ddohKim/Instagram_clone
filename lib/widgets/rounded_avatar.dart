import 'package:flutter/cupertino.dart';
import 'package:test_1/constants/common_size.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RoundedAvatar extends StatelessWidget {
  final double size;
  const RoundedAvatar( {Key? key,this.size=avatar_size,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: 'https://picsum.photos/100',
        width: size,
        height: size,
      ),
    );
  }
}
