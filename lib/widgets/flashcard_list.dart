import 'package:flutter/material.dart';
import '../services/database_service.dart';

class FlashcardListView extends StatefulWidget {
  final String flashcardId;
  final String studysetId;

  const FlashcardListView(
      {Key? key, required this.flashcardId, required this.studysetId})
      : super(key: key);

  @override
  State<FlashcardListView> createState() => _FlashcardListViewState();
}

class _FlashcardListViewState extends State<FlashcardListView> {
  String question = '';
  String answer = '';
  bool isStarred = false;

  @override
  void initState() {
    super.initState();
    getFlashcardInfo();
  }

  getFlashcardInfo() async {
    DatabaseService().getFlashcardQuestion(widget.flashcardId).then((val) {
      setState(() {
        question = val;
      });
    });
    DatabaseService().getFlashcardAnswer(widget.flashcardId).then((val) {
      setState(() {
        answer = val;
      });
    });
    DatabaseService().isFlashcardStarred(widget.flashcardId).then((val) {
      setState(() {
        isStarred = val;
      });
    });
  }

  void _toggleStarred() {
    setState(() {
      isStarred = !isStarred;
    });
    DatabaseService().toggleStarFlashcard(widget.flashcardId);
  }

  //make sure it updates the current view in studyset_page
  void editFlashcard() {
    TextEditingController questionController =
        TextEditingController(text: question);
    TextEditingController answerController =
        TextEditingController(text: answer);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Text('Edit Flashcard'),
              const SizedBox(
                width: 80,
              ),
              IconButton(
                onPressed: deleteFlashcard,
                icon: const Icon(Icons.delete),
                alignment: Alignment.centerRight,
                color: Colors.red,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: InputDecoration(
                  labelText: 'Question',
                  hintText: 'Enter question',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: answerController,
                decoration: InputDecoration(
                  labelText: 'Answer',
                  hintText: 'Enter answer',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  question = questionController.text;
                  answer = answerController.text;
                });
                DatabaseService()
                    .updateFlashcard(widget.flashcardId, question, answer);
                Navigator.pop(context);
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  void deleteFlashcard() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Flashcard'),
          content: const Text('Are you sure? This action is not reversible.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                DatabaseService()
                    .removeFlashcard(widget.flashcardId, widget.studysetId);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('CONFIRM'),
            ),
          ],
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant FlashcardListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flashcardId != oldWidget.flashcardId) {
      getFlashcardInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 70, 67, 67),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: Text(
                  question,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 70,
                  height: 30,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: editFlashcard,
                          icon: const Icon(Icons.edit, size: 18),
                          padding: const EdgeInsets.all(0),
                          alignment: Alignment.topRight,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: _toggleStarred,
                          icon: Icon(
                            isStarred ? Icons.star : Icons.star_border,
                            color: isStarred ? Colors.yellow : null,
                            size: 18,
                          ),
                          padding: const EdgeInsets.all(0),
                          alignment: Alignment.topRight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Text(
            answer,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
