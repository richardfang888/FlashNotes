import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_notes/pages/studyset_page.dart';
import 'package:flash_notes/services/database_service.dart';
import 'package:flash_notes/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../helper/helper_function.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = '';
  User? user;
  bool isShared = false;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdAndName();
  }

  getCurrentUserIdAndName() async {
    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
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
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          centerTitle: true,
          title: const Text(
            'Search',
            style: TextStyle(
                color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
          )),
      body: Column(children: [
        Container(
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: searchController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search study sets...',
                  hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                initiateSearchMethod();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
            ),
          ]),
        ),
        _isLoading
            ? Center(
                child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ))
            : studysetList()
      ]),
    );
  }

  initiateSearchMethod() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DatabaseService()
          .searchStudysetByName(searchController.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          _isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  studysetList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return studysetTile(
                  userName,
                  searchSnapshot!.docs[index]['studysetId'],
                  searchSnapshot!.docs[index]['studysetName'],
                  searchSnapshot!.docs[index]['owner']);
            },
          )
        : Container();
  }

  sharedOrNot(String userName, String studysetId, String studysetName,
      String ownerName) async {
    await DatabaseService(uid: user!.uid)
        .isUserSharedWithStudyset(studysetName, studysetId, userName)
        .then((value) {
      setState(() {
        isShared = value;
      });
    });
  }

  Widget studysetTile(String userName, String studysetId, String studysetName,
      String ownerName) {
    //check whether user already shared with this studyset
    sharedOrNot(userName, studysetId, studysetName, ownerName);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          studysetName.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      title: Text(
        studysetName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text('Owner: ${getName(ownerName)}'),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: user!.uid)
              .toggleAddStudyset(studysetId, userName, studysetName);
          if (isShared) {
            setState(() {
              isShared = !isShared;
            });
            showSnackBar(context, Colors.green,
                'Successfully added studyset $studysetName');
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  StudysetPage(
                      studysetId: studysetId,
                      studysetName: studysetName,
                      userName: userName));
            });
          } else {
            setState(() {
              isShared = !isShared;
            });
            showSnackBar(context, Colors.red, 'Removed studyset $studysetName');
          }
        },
        child: isShared
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child:
                    const Text('Added', style: TextStyle(color: Colors.white)))
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }
}
