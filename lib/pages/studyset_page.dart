import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_notes/pages/studyset_info.dart';
import 'package:flash_notes/services/database_service.dart';
import 'package:flash_notes/widgets/widgets.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/flashcard_list.dart';
import '../widgets/flashcard_tile.dart';
import 'package:flash_notes/pages/document_scan.dart';

class StudysetPage extends StatefulWidget {
  final String studysetId;
  final String studysetName;
  final String userName;
  const StudysetPage(
      {Key? key,
      required this.studysetId,
      required this.studysetName,
      required this.userName})
      : super(key: key);

  @override
  State<StudysetPage> createState() => _StudysetPageState();
}

class _StudysetPageState extends State<StudysetPage> {
  bool _isLoading = false;
  AuthService authService = AuthService();
  String ownerName = '';
  Stream? flashcards;
  String question = '';
  String answer = '';

  List<String> _flashcards = [];

  @override
  void initState() {
    super.initState();
    getFlashcardsAndOwner();
  }

  getFlashcardsAndOwner() async {
    await DatabaseService().getFlashcards(widget.studysetId).then((snapshot) {
      setState(() {
        flashcards = snapshot;
      });
    });
    await DatabaseService().getStudysetOwner(widget.studysetId).then((value) {
      setState(() {
        ownerName = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.studysetName,
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(
                context,
                StudysetInfo(
                    studysetId: widget.studysetId,
                    studysetName: widget.studysetName,
                    ownerName: ownerName),
              );
            },
            icon: const Icon(Icons.info),
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: flashcardStack(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = _currentIndex == 0
                        ? _flashcards.length - 1
                        : _currentIndex - 1;
                  });
                },
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(Icons.chevron_left,
                          color: Theme.of(context).primaryColor),
                      Text(
                        'Prev',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ]),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = (_currentIndex + 1) % _flashcards.length;
                  });
                },
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      Icon(Icons.chevron_right,
                          color: Theme.of(context).primaryColor),
                    ]),
              ),
            ],
          ),
          const SizedBox(
            height: 16.3,
          ),
          const Divider(color: Colors.black),
          Expanded(
            child: Scrollbar(
              child: Container(
                child: flashcardList(),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    nextScreen(
                      context,
                      DocumentScanPage(
                        studysetId: widget.studysetId,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.document_scanner,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    addTextDialog(context);
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  addTextDialog(BuildContext context) {
    if (mounted) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              title: const Text(
                'Add flashcard',
                textAlign: TextAlign.left,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : Column(
                          children: [
                            TextField(
                              onChanged: (val) {
                                setState(() {
                                  question = val;
                                });
                              },
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Question',
                                hintText: 'Enter question',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextField(
                              onChanged: (val) {
                                setState(() {
                                  answer = val;
                                });
                              },
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Answer',
                                hintText: 'Enter answer',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (question != '') {
                      setState(() {
                        _isLoading = true;
                      });
                      DatabaseService(
                              uid: FirebaseAuth.instance.currentUser!.uid)
                          .createFlashcard(widget.studysetId, question, answer)
                          .whenComplete(() {
                        _isLoading = false;
                      });
                      Navigator.of(context).pop();
                      showSnackBar(context, Colors.green,
                          'Flashcard created successfully');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  child: const Text('CREATE'),
                ),
              ],
            );
          }));
        },
      ).then((value) {
        if (mounted) {
          // Check if the widget is still mounted
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  int _currentIndex = 0;

  Widget flashcardStack() {
    return StreamBuilder(
      stream: flashcards,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['flashcards'] != null) {
            _flashcards = List<String>.from(snapshot.data['flashcards']);
          }
          if (_flashcards.isEmpty) {
            return noFlashcardWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }

        return Stack(
          children: [
            FlashcardTile(
              flashcardId: _flashcards[_currentIndex],
            ),
          ],
        );
      },
    );
  }

  flashcardList() {
    return StreamBuilder(
      stream: flashcards,
      builder: (context, AsyncSnapshot snapshot) {
        //make checks
        if (snapshot.hasData) {
          if (snapshot.data['flashcards'] != null) {
            if (snapshot.data['flashcards'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['flashcards'].length,
                itemBuilder: (context, index) {
                  //show must recently added first
                  int reverseIndex =
                      snapshot.data['flashcards'].length - index - 1;
                  return FlashcardListView(
                    flashcardId: snapshot.data['flashcards'][reverseIndex],
                    studysetId: widget.studysetId,
                  );
                },
              );
            } else {
              return const SizedBox(
                height: 20,
              );
            }
          } else {
            return const SizedBox(
              height: 20,
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
      },
    );
  }

  noFlashcardWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              addTextDialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'You have no flashcards!',
            textAlign: TextAlign.center,
          ),
          const Text(
            'Tap on add icon to create new flashcard',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
