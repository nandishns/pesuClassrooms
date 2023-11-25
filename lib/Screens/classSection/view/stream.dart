import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pesuclassrooms/Screens/announcements/detailedAnnouncements.dart';
import 'package:pesuclassrooms/Screens/createAssignment/controller.dart';

import '../../../helpers.dart';
import '../../announcements/announcements.dart';
import '../modal/model.dart';

class Stream extends StatefulWidget {
  final ClassDetail classDetial;
  const Stream({Key? key, required this.classDetial}) : super(key: key);

  @override
  State<Stream> createState() => _StreamState();
}

class _StreamState extends State<Stream> {
  bool isLoading = false;
  final StreamController _announcementController = StreamController();
  @override
  void initState() {
    fetchAnnouncements();
    super.initState();
  }

  Future fetchAnnouncements() async {
    setState(() {
      isLoading = true;
    });
    final params = {"ClassId": widget.classDetial.classId};
    await callLambdaFunction2(dotenv.env["FETCH_ANNOUNCEMENT"]!, params)
        .then((value) {
      _announcementController.add(value);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: RefreshIndicator(
        onRefresh: () => fetchAnnouncements(),
        child: Column(
          children: [
            Visibility(
                visible: isLoading, child: const LinearProgressIndicator()),
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
            Container(
              margin: const EdgeInsets.all(8),
              child: Ink(
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
                    Navigator.push(
                        context,
                        PageTransition(
                            child: Announcement(
                              classId: widget.classDetial.classId,
                            ),
                            type: PageTransitionType.rightToLeft));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.account_circle,
                          color: Colors.blueAccent,
                          size: responsiveSize(50, context),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Share with your class ...",
                          style: TextStyle(
                              fontSize: responsiveSize(16, context),
                              color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            StreamBuilder(
              stream: _announcementController.stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No announcements found');
                }

                List announcements = snapshot.data!;

                return ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    var announcement = announcements[index];
                    return Container(
                        margin: const EdgeInsets.all(8),
                        child: announcementTile(
                            announcement['TeacherName'],
                            announcement['PostedDate'],
                            announcement['Description'],
                            announcement["AnnouncementAttachmentURLs"]));
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget announcementTile(name, postedOn, content, announcementAttachmentURLs) {
    return Ink(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
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
          Navigator.push(
              context,
              PageTransition(
                  child: DetailedAnnouncement(
                    announcementAttachmentURLs: announcementAttachmentURLs,
                    name: name,
                    postedOn: postedOn,
                    content: content,
                  ),
                  type: PageTransitionType.rightToLeft));
        },
        child: Padding(
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
                        "$name",
                        style: TextStyle(
                            fontSize: responsiveSize(20, context),
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Posted on : $postedOn",
                        style: TextStyle(fontSize: responsiveSize(15, context)),
                      ),
                    ],
                  ),
                ],
              ),
              verticalGap(context, 0.008),
              SizedBox(
                child: Text(
                  "$content",
                  style: TextStyle(
                    fontSize: responsiveSize(18, context),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 6,
                ),
              ),
              announcementAttachmentURLs == null
                  ? Container()
                  : Text(
                      "Tap to view attachments....",
                      style: TextStyle(fontSize: responsiveSize(15, context)),
                    ),
              verticalGap(context, 0.005),
            ],
          ),
        ),
      ),
    );
  }
}
