import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../services/database_service.dart';

class FlashcardTile extends StatefulWidget {
  final String flashcardId;

  const FlashcardTile({Key? key, required this.flashcardId}) : super(key: key);

  @override
  State<FlashcardTile> createState() => _FlashcardTileState();
}

class _FlashcardTileState extends State<FlashcardTile> {
  String question = '';
  String answer = '';
  bool _isStarred = false;

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
        _isStarred = val;
      });
    });
  }

  @override
  void didUpdateWidget(covariant FlashcardTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flashcardId != oldWidget.flashcardId) {
      getFlashcardInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 20,
      ),
      height: 300,
      width: 395,
      child: FlipCard(
        alignment: Alignment.center,
        fill: Fill.fillBack,
        direction: FlipDirection.HORIZONTAL,
        front: Card(
          elevation: 4,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Text(
                    question,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: _getFontSize(question, constraints),
                    ),
                    maxLines: null,
                  );
                },
              ),
            ),
          ),
        ),
        back: Card(
          elevation: 4,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Text(
                    answer,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _getFontSize(answer, constraints),
                    ),
                    maxLines: null,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getFontSize(String text, BoxConstraints constraints) {
    double fontSize = 20.0;
    if (text.isNotEmpty) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(
          text: text,
          style: TextStyle(fontSize: fontSize),
        ),
      )..layout(maxWidth: constraints.maxWidth);
      while (textPainter.size.height > constraints.maxHeight) {
        fontSize -= 1;
        textPainter.text = TextSpan(
          text: text,
          style: TextStyle(fontSize: fontSize),
        );
        textPainter.layout(maxWidth: constraints.maxWidth);
      }
    }
    return fontSize;
  }
}
