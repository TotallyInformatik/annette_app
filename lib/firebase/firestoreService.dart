import 'package:annette_app/fundamentals/timetableUnit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final User currentUser;

  FirestoreService({required this.currentUser});

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addUserDocument() {
    return users.doc(currentUser.uid).set({
      'configuration': null,
      'timetableVersion': DateTime(0, 0, 0).toString(),
      'changingLkSubject': '---',
      'changingLkWeekNumber': 2,
      'unspecificOccurences': true,
    }).catchError((error) => print("Failed to add user: $error"));
  }

  Future<bool> checkIfUserDocumentExists() async {
    return (await users
            .doc(currentUser.uid)
            .get(GetOptions(source: Source.serverAndCache)))
        .exists;
  }

  Future<void> updateDocument(String key, Object value) async {
    return users.doc(currentUser.uid).update({key: value}).catchError(
        (error) => print("Failed to update user: $error"));
  }

  Future<void> deleteUserCollection(String collectionName) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection(collectionName)
        .get(GetOptions(source: Source.serverAndCache));

    for (DocumentSnapshot ds in snapshot.docs) {
      ds.reference.delete();
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> insertInUserCollection(
      String collectionName, Map<String, dynamic> data) async {
    return users.doc(currentUser.uid).collection(collectionName).add(data);
  }

  Future<Object> readValue(String key) async {
    return users
        .doc(currentUser.uid)
        .get(GetOptions(source: Source.serverAndCache))
        .then((value) => value[key]);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserCollection(
      String collectionName) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection(collectionName)
        .get(GetOptions(source: Source.serverAndCache));
  }

  Stream<DocumentSnapshot<Object?>> documentStream() =>
      users.doc(currentUser.uid).snapshots();

  ///TimetableUnits
  Future<DocumentReference<Map<String, dynamic>>> insertTimetableUnit(
      TimeTableUnit timeTableUnit) async {
    return insertInUserCollection('timetable', <String, dynamic>{
      'subject': timeTableUnit.subject,
      'room': timeTableUnit.room,
      'dayNumber': timeTableUnit.dayNumber,
      'lessonNumber': timeTableUnit.lessonNumber,
    });
  }

  Future<List<TimeTableUnit>> getAllTimetableUnits() async {
    List<TimeTableUnit> list = [];
    var snapshot = await getUserCollection('timetable');
    for (DocumentSnapshot ds in snapshot.docs) {
      list.add(new TimeTableUnit(
        subject: ds.get('subject'),
        room: ds.get('room'),
        lessonNumber: ds.get('lessonNumber'),
        dayNumber: ds.get('dayNumber'),
      ));
    }
    return list;
  }
}
