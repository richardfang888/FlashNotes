import 'package:flash_notes/pages/studyset_page.dart';
import 'package:flash_notes/widgets/widgets.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';

class StudysetTile extends StatefulWidget {
  final String userName;
  final String studysetId;
  final String studysetName;
  const StudysetTile(
      {Key? key,
      required this.studysetId,
      required this.studysetName,
      required this.userName})
      : super(key: key);

  @override
  State<StudysetTile> createState() => _StudysetTileState();
}

class _StudysetTileState extends State<StudysetTile> {
  String description = '';

  @override
  void initState() {
    super.initState();
    getDescr();
  }

  getDescr() async {
    DatabaseService().getStudysetDesc(widget.studysetId).then((val) {
      setState(() {
        description = val;
      });
    });
  }

  @override
  void didUpdateWidget(covariant StudysetTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.studysetId != oldWidget.studysetId) {
      getDescr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            StudysetPage(
              studysetId: widget.studysetId,
              studysetName: widget.studysetName,
              userName: widget.userName,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 5,
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.studysetName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          title: Text(
            widget.studysetName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            description,
          ),
        ),
      ),
    );
  }
}
