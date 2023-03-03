import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  Timer? _authTimer;
  String? _token;
  DateTime? _expiryDate;
  String? _userID;

  static const apiKey = 'AIzaSyDmCBzUXgbBiJZGI-aLBKdEynLrzQ4Xo6Y';

  String? get token {
    if(_token != null && _expiryDate != null && _expiryDate!.isAfter(DateTime.now()) && _token != ''){
      return _token;
    }
    return null;
  }

  bool get isAuth {
    return token != null;
  }

  String? get userID {
    return _userID;
  }

  void resetAuth() {
    _token = null;
    notifyListeners();
  }

  Future<void> authenticate(String email, String password, String method, bool isFarmer) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$method?key=$apiKey');
    final response = await http.post(
      url,
      body: json.encode(
        {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      ),
    );
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      final error = extractedData['error']['message'];
      throw HttpException(error);
    }
    _token = extractedData['idToken'];
    _userID = extractedData['localId'];
    _expiryDate = DateTime.now()
        .add(Duration(seconds: int.parse(extractedData['expiresIn'])));
    autoLogout();
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token' : _token,
      'userID' : _userID,
      'expiryDate' : _expiryDate?.toIso8601String(),
    });
    prefs.setString('userData', userData);

    if (method=='signUp' && !isFarmer){
      final url = Uri.parse("https://harvest2home-bfcd6-default-rtdb.asia-southeast1.firebasedatabase.app/users/customers/$_userID.json?auth=$_token");
      try{
        await http.put(
          url,
          body: json.encode(
            {
              'status': 'Active'
            }
          )
        );
      } catch (error){
        rethrow;
      }
    }
    else if (method=='signUp' && isFarmer){
      final url = Uri.parse("https://harvest2home-bfcd6-default-rtdb.asia-southeast1.firebasedatabase.app/users/farmers/$_userID.json?auth=$_token");
      try{
        await http.put(
            url,
            body: json.encode(
                {
                  'status': 'Active'
                }
            )
        );
      } catch (error){
        rethrow;
      }
    }
    else if (method=='signInWithPassword' && !isFarmer){
      final url = Uri.parse("https://harvest2home-bfcd6-default-rtdb.asia-southeast1.firebasedatabase.app/users/customers/$_userID.json?auth=$_token");
      try{
        var data = await http.get(url);
        if (data.body == 'null'){
          await logout();
          throw HttpException("Not registered as a user");
        }
      } catch (error){
        rethrow;
      }
    }
    else if (method=='signInWithPassword' && isFarmer){
      final url = Uri.parse("https://harvest2home-bfcd6-default-rtdb.asia-southeast1.firebasedatabase.app/users/farmers/$_userID.json?auth=$_token");
      try{
        var data = await http.get(url);
        if (data.body == 'null'){
          await logout();
          throw HttpException("Not registered as a farmer");
        }
      } catch (error){
        rethrow;
      }
    }
    notifyListeners();
  }

  Future<void> signUp(String email, String password, bool isFarmer) async {
    return authenticate(email, password, 'signUp', isFarmer);
  }

  Future<void> signIn(String email, String password, bool isFarmer) async {
    return authenticate(email, password, 'signInWithPassword', isFarmer);
  }

  Future<bool> tryAutoLogin() async{
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')){
      return false;
    }
    final extractedData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedData['expiryDate'] as String);
    if(expiryDate.isBefore(DateTime.now())){
      return false;
    }
    _token = extractedData['token'] as String;
    _userID = extractedData['userID'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    autoLogout();
    return true;
  }

  Future<void> logout() async {
    _userID = null;
    _token = null;
    _expiryDate = null;
    if(_authTimer != null){
      _authTimer?.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear(); //prefs.remove('key'); for individual.
  }

  void autoLogout(){
    if(_authTimer != null){
      _authTimer?.cancel();
    }
    final timeToExpire = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), logout);
  }
}