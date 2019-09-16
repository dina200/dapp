import 'package:d_app/models/time_range.dart';
import 'package:d_app/models/user.dart';
import 'package:d_app/store_iteractor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/subjects.dart';

class FireBase {
  final StoreInteractor _storeInteractor;
  final FirebaseAuth _fireBaseAuth;
  final Firestore _fireStore;

  final _onLoginSubject = PublishSubject<void>();
  final _onRegisterSubject = PublishSubject<void>();

  StoreInteractor get storeInteractor => _storeInteractor;

  Stream<void> get onLoginStream => _onLoginSubject.stream;

  Stream<void> get onRegisterStream => _onRegisterSubject.stream;

  Stream<FirebaseUser> get onAuthStateChanged =>
      _fireBaseAuth.onAuthStateChanged;

  Stream<DocumentSnapshot> get accountStream => _fireStore
      .collection('users')
      .document(_storeInteractor.token)
      .snapshots();

  Stream<QuerySnapshot> get statisticStream => _fireStore
      .collection('users')
      .document(_storeInteractor.token)
      .collection('statistica')
      .snapshots();

  FireBase(StoreInteractor storeInteractor)
      : _storeInteractor = storeInteractor,
        _fireBaseAuth = FirebaseAuth.instance,
        _fireStore = Firestore.instance;

  Future<void> setName(String name) async {
    try {
      _fireStore.collection('users').document(_storeInteractor.token)
        ..setData({
          'name': name,
        });
      await _storeInteractor.setName(name);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> setSugarInBlood(double measure) async {
    try {
      var now = DateTime.now();
      var milliseconds = now.millisecondsSinceEpoch;
      _fireStore.collection('users').document(_storeInteractor.token)
        ..collection('statistica').document(milliseconds.toString()).setData({
          'timeMeasure': milliseconds,
          'sugarInBlood': measure,
        });
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> sighIn(String email, String password) async {
    try {
      final authResult = await _fireBaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _storeInteractor.setToken(authResult.user.uid);
      await _storeInteractor.setEmail(email);
      await _storeInteractor.setPassword(password);
      _onLoginSubject.add(null);
    } on PlatformException catch (e) {
      _onLoginSubject.addError(e.message);
    }
  }

  Future<void> sighUp(String name, String email, String password) async {
    try {
      await _fireBaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _setEmail(email);
      _onRegisterSubject.add(null);
    } on PlatformException catch (e) {
      _onRegisterSubject.addError(e.message);
    }
  }

  Future<void> _setEmail(String email) async {
    try {
      _fireStore.collection('users').document(_storeInteractor.token)
        ..setData({
          'email': email,
        });
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> sighOut() async {
    try {
      await _fireBaseAuth.signOut();
      await _storeInteractor.setToken(null);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  dispose() {
    _onLoginSubject.close();
    _onRegisterSubject.close();
  }
}
