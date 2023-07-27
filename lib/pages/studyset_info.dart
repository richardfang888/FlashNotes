import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_notes/pages/home_page.dart';
import 'package:flash_notes/services/database_service.dart';
import 'package:flash_notes/widgets/widgets.dart';
import 'package:flutter/material.dart';

class StudysetInfo extends StatefulWidget {
  final String studysetId;
  final String studysetName;
  final String ownerName;
  const StudysetInfo(
      {Key? key,
      required this.studysetId,
      required this.studysetName,
      required this.ownerName})
      : super(key: key);

  @override
  State<StudysetInfo> createState() => _StudysetInfoState();
}

class _StudysetInfoState extends State<StudysetInfo> {
  Stream? sharedWith;
  @override
  void initState() {
    super.initState();
    getSharedWith();
  }

  getSharedWith() async {
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getStudysetSharedWith(widget.studysetId)
        .then((value) {
      setState(() {
        sharedWith = value;
      });
    });
  }

  String getName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Studyset Info'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Remove Studyset'),
                      content: const Text(
                          'Are you sure you want to remove this studyset?'),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: Colors.red,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            DatabaseService(
                                    uid: FirebaseAuth.instance.currentUser!.uid)
                                .toggleAddStudyset(
                                    widget.studysetId,
                                    getName(widget.ownerName),
                                    widget.studysetName)
                                .whenComplete(() {
                              nextScreenReplace(context, const HomePage());
                            });
                          },
                          icon: const Icon(
                            Icons.check_circle_outlined,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  });
            },
            icon: const Icon(Icons.delete),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.studysetName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Studyset: ${widget.studysetName}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Owner: ${getName(widget.ownerName)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            sharedWithList(),
          ],
        ),
      ),
    );
  }

  sharedWithList() {
    return StreamBuilder(
      stream: sharedWith,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['sharedWith'] != null) {
            if (snapshot.data['sharedWith'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['sharedWith'].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          getName(snapshot.data['sharedWith'][index])
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(getName(snapshot.data['sharedWith'][index])),
                      subtitle: Text(getId(snapshot.data['sharedWith'][index])),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text('NOT SHARED WITH ANY OTHER USERS'),
              );
            }
          } else {
            return const Center(
              child: Text('NOT SHARED WITH ANY OTHER USERS'),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }
}
