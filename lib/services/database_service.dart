import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flash_notes/shared/constants.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  //reference for users collection
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  // reference for studysets collection
  final CollectionReference studysetCollection =
      FirebaseFirestore.instance.collection('studysets');
  // reference for flashcards collection
  final CollectionReference flashcardCollection =
      FirebaseFirestore.instance.collection('flashcards');

  //saving user data
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      'fullName': fullName,
      'email': email,
      'studysets': [],
      'uid': uid,
    });
  }

  //getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where('email', isEqualTo: email).get();
    return snapshot;
  }

  //getting user studysets
  getUserStudysets() async {
    return userCollection.doc(uid).snapshots();
  }

  //create a new studyset
  Future createStudyset(String userName, String id, String studysetName,
      String description) async {
    DocumentReference studysetDocumentReference = await studysetCollection.add({
      'studysetName': studysetName,
      'studysetIcon': '',
      'owner': '${id}_$userName',
      'sharedWith': [],
      'flashcards': [],
      'studysetId': '',
      'description': description,
    });

    //update sharedWith
    await studysetDocumentReference.update({
      'sharedWith': FieldValue.arrayUnion(['${uid}_$userName']),
      'studysetId': studysetDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      'studysets': FieldValue.arrayUnion(
          ['${studysetDocumentReference.id}_$studysetName']),
    });
  }

  //get studyset description
  Future<String> getStudysetDesc(String studysetId) async {
    DocumentReference d = studysetCollection.doc(studysetId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['description'];
  }

  //get studyset flashcards
  getFlashcards(String studysetId) async {
    return studysetCollection.doc(studysetId).snapshots();
  }

  //get flashcard list
  Future<List<String>> getFlashcardsList(String studysetId) async {
    QuerySnapshot studysetSnapshot = await studysetCollection
        .where('studysetId', isEqualTo: studysetId)
        .get();

    if (studysetSnapshot.docs.isNotEmpty) {
      DocumentSnapshot studysetDocument = studysetSnapshot.docs.first;
      List<dynamic> flashcards = studysetDocument.get('flashcards');
      List<String> flashcardStrings =
          flashcards.map((flashcard) => flashcard.toString()).toList();
      return flashcardStrings;
    } else {
      return [];
    }
  }

  //get studyset owner
  Future getStudysetOwner(String studysetId) async {
    DocumentReference d = studysetCollection.doc(studysetId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['owner'];
  }

  //get studyset sharedWith
  getStudysetSharedWith(String studysetId) async {
    return studysetCollection.doc(studysetId).snapshots();
  }

  //search studyset by name
  searchStudysetByName(String studysetName) async {
    return studysetCollection
        .where('studysetName', isEqualTo: studysetName)
        .get();
  }

  //check if studyset is sharedWith user
  Future<bool> isUserSharedWithStudyset(
      String studysetName, String studysetId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> studysets = await documentSnapshot['studysets'];
    if (studysets.contains('${studysetId}_$studysetName')) {
      return true;
    } else {
      return false;
    }
  }

  //toggling add or unadd studyset
  Future toggleAddStudyset(
      String studysetId, String userName, String studysetName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference studysetDocumentReference =
        studysetCollection.doc(studysetId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> studysets = await documentSnapshot['studysets'];

    //check user is shared -> remove them, if not -> add them
    if (studysets.contains('${studysetId}_$studysetName')) {
      await userDocumentReference.update({
        'studysets': FieldValue.arrayRemove(['${studysetId}_$studysetName']),
      });
      await studysetDocumentReference.update({
        'sharedWith': FieldValue.arrayRemove(['${uid}_$userName']),
      });
    } else {
      await userDocumentReference.update({
        'studysets': FieldValue.arrayUnion(['${studysetId}_$studysetName']),
      });
      await studysetDocumentReference.update({
        'sharedWith': FieldValue.arrayUnion(['${uid}_$userName']),
      });
    }
  }

  //create new flashcard
  Future createFlashcard(
      String studysetId, String question, String answer) async {
    DocumentReference flashcardDocumentReference =
        await flashcardCollection.add({
      'flashcardId': '',
      'question': question,
      'answer': answer,
      'seenCount': 0,
      'correctCount': 0,
      'starred': false,
    });

    await flashcardDocumentReference.update({
      'flashcardId': flashcardDocumentReference.id,
    });

    DocumentReference studysetDocumentReference =
        studysetCollection.doc(studysetId);
    return await studysetDocumentReference.update({
      'flashcards': FieldValue.arrayUnion([(flashcardDocumentReference.id)]),
    });
  }

  // remove flashcard from studyset
  Future removeFlashcard(String flashcardId, String studysetId) async {
    DocumentReference studysetDocumentReference =
        studysetCollection.doc(studysetId);
    DocumentReference flashcardDocumentReference =
        flashcardCollection.doc(flashcardId);

    DocumentSnapshot documentSnapshot = await studysetDocumentReference.get();
    List<dynamic> flashcards = await documentSnapshot['flashcards'];

    if (flashcards.contains(flashcardId)) {
      await studysetDocumentReference.update({
        'flashcards': FieldValue.arrayRemove([flashcardId]),
      });
      await flashcardDocumentReference.delete();
    }
  }

  //get flashcard question
  Future<String> getFlashcardQuestion(String flashcardId) async {
    DocumentReference d = flashcardCollection.doc(flashcardId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['question'];
  }

  //get flashcard answer
  Future<String> getFlashcardAnswer(String flashcardId) async {
    DocumentReference d = flashcardCollection.doc(flashcardId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['answer'];
  }

  //check if flashcard starred
  Future<bool> isFlashcardStarred(String flashcardId) async {
    DocumentReference d = flashcardCollection.doc(flashcardId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['starred'];
  }

  //toggle star or unstar flashcard
  Future toggleStarFlashcard(String flashcardId) async {
    DocumentReference flashcardDocumentReference =
        flashcardCollection.doc(flashcardId);
    DocumentSnapshot documentSnapshot = await flashcardDocumentReference.get();
    bool isStarred = documentSnapshot['starred'];
    await flashcardDocumentReference.update({
      'starred': !isStarred,
    });
  }

  // update flashcard
  Future updateFlashcard(
      String flashcardId, String question, String answer) async {
    DocumentReference flashcardDocumentReference =
        flashcardCollection.doc(flashcardId);
    await flashcardDocumentReference.update({
      'question': question,
      'answer': answer,
    });
  }

  // update studyset
  Future updateStudyset(
      String studysetId, String description, String studysetName) async {
    DocumentReference studysetDocumentReference =
        studysetCollection.doc(studysetId);
    await studysetDocumentReference.update({
      'description': description,
      'studysetName': studysetName,
    });
  }

  // generate studyset flashcards
  Future generateFlashcardsFromText(String text, String studysetId) async {
    final apiKey = Constants.openAIkey;
    const apiUrl = 'https://api.openai.com/v1/chat/completions';
    var prompt =
        """Generate flashcards out of the following text delimited by triple backticks. Provide the flashcards in JSON format with the following keys: question, answer.
        Text: ```$text```""";

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = {
      'model': 'gpt-3.5-turbo',
      'messages': [
        {"role": "user", "content": prompt}
      ],
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final chatResult = data['choices'][0]['message']['content'];
      final List<Map<String, dynamic>> jsonList =
          List<Map<String, dynamic>>.from(
              json.decode(chatResult) as List<dynamic>);
      for (final json in jsonList) {
        await createFlashcard(studysetId, json['question'], json['answer']);
      }
    } else {
      throw Exception(
          'Failed to query ChatGPT. Status Code: ${response.statusCode}');
    }
  }
}
