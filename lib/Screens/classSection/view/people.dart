import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pesuclassrooms/helpers.dart';

import '../../createAssignment/controller.dart';

class People extends StatefulWidget {
  final int classID;
  const People({Key? key, required this.classID}) : super(key: key);

  @override
  State<People> createState() => _PeopleState();
}

class _PeopleState extends State<People> {
  final StreamController<List<dynamic>> _membersController = StreamController();
  Stream get membersStream => _membersController.stream;
  bool isLoading = false;
  @override
  void initState() {
    fetchParticipants(widget.classID);
    super.initState();
  }

  Future fetchParticipants(classId) async {
    setState(() {
      isLoading = true;
    });
    final params = {"ClassId": classId};
    await callLambdaFunction2(dotenv.env["FETCH_PARTICIPANTS"]!, params)
        .then((value) {
      _membersController.add(value);
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _membersController.close();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: RefreshIndicator(
        onRefresh: () => fetchParticipants(widget.classID),
        child: Column(children: [
          Visibility(
              visible: isLoading, child: const LinearProgressIndicator()),
          StreamBuilder(
            stream:
                _membersController.stream, // Replace with your class instance
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No members found');
              }

              List members = snapshot.data!;

              return SizedBox(
                height: responsiveSize(1000, context),
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    var member = members[index];
                    String role =
                        member.containsKey("teacher") ? "Teacher" : "Student";
                    var details = member[role.toLowerCase()];

                    return ListTile(
                      onTap: () {},
                      title: Text(
                        details["name"],
                        style: TextStyle(fontSize: responsiveSize(21, context)),
                      ),
                      subtitle: Text(
                        "Role : $role",
                        style: TextStyle(
                            fontSize: responsiveSize(18, context),
                            color: Colors.grey),
                      ),
                      leading: Icon(
                        Icons.account_circle,
                        color: Colors.blueAccent,
                        size: responsiveSize(52, context),
                      ),
                      // Add other details you want to display
                    );
                  },
                ),
              );
            },
          )
        ]),
      ),
    );
  }
}
