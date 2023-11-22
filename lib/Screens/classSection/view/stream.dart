import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../helpers.dart';
import '../modal/model.dart';

class Stream extends StatefulWidget {
  final ClassDetail classDetial;
  const Stream({Key? key, required this.classDetial}) : super(key: key);

  @override
  State<Stream> createState() => _StreamState();
}

class _StreamState extends State<Stream> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 2,
          margin: const EdgeInsets.all(8),
          child: CachedNetworkImage(
            imageUrl: widget.classDetial.bgUrl,
            imageBuilder: (context, imageProvider) => Container(
              width: responsiveSize(800, context),
              height: responsiveSize(150, context),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: responsiveSize(30, context),
                    horizontal: responsiveSize(20, context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalGap(context, 0.02),
                    Text(
                      firstLetterCapital(widget.classDetial.name),
                      style: TextStyle(
                          fontSize: responsiveSize(24, context),
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        verticalGap(context, 0.004),
        Ink(
          height: responsiveSize(80, context),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              // Your onTap action
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.account_circle,
                    color: Colors.blueAccent,
                    size: responsiveSize(40, context),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Share with your class ...",
                    style: TextStyle(fontSize: responsiveSize(17, context)),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
