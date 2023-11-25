import 'package:flutter/material.dart';

import '../../helpers.dart';
import '../createAssignment/studentViewAssignment.dart';

class DetailedAnnouncement extends StatefulWidget {
  final announcementAttachmentURLs;
  final String? name;
  final String? content;
  final String? postedOn;
  const DetailedAnnouncement(
      {Key? key,
      required this.announcementAttachmentURLs,
      required this.name,
      required this.postedOn,
      required this.content})
      : super(key: key);

  @override
  State<DetailedAnnouncement> createState() => _DetailedAnnouncementState();
}

class _DetailedAnnouncementState extends State<DetailedAnnouncement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.close,
            color: Colors.black,
            size: responsiveSize(30, context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.account_circle,
                        color: Colors.blueAccent,
                        size: responsiveSize(50, context),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.name}",
                            style: TextStyle(
                                fontSize: responsiveSize(20, context),
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "Posted on : ${widget.postedOn}",
                            style: TextStyle(
                                fontSize: responsiveSize(15, context)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  verticalGap(context, 0.008),
                  SizedBox(
                    child: Text(
                      " ${widget.content}",
                      style: TextStyle(
                        fontSize: responsiveSize(18, context),
                      ),
                    ),
                  ),
                  verticalGap(context, 0.005),
                  AttachmentsList(
                      attachments: widget.announcementAttachmentURLs)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
