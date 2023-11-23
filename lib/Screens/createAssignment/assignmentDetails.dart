import 'package:flutter/material.dart';

class AssignmentDetails extends StatefulWidget {
  final maxMarks;
  final dueDate;
  final desc;
  final title;
  final attachment;
  final isAdmin;
  const AssignmentDetails(
      {Key? key,
      required this.maxMarks,
      required this.dueDate,
      required this.desc,
      required this.title,
      required this.attachment,
      required this.isAdmin})
      : super(key: key);

  @override
  State<AssignmentDetails> createState() => _AssignmentDetailsState();
}

class _AssignmentDetailsState extends State<AssignmentDetails>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your App Title'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Instructors'),
            Tab(text: 'Student Work'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          InstructorsTabContent(), // Replace with your custom widget for instructors
          StudentWorkTabContent(), // Replace with your custom widget for student work
        ],
      ),
    );
  }
}

class InstructorsTabContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Content for Instructors'),
    );
  }
}

class StudentWorkTabContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Content for Student Work'),
    );
  }
}
