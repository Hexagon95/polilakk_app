
import 'package:polilakk_app/global.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;
import 'dart:convert';
import 'dart:io';

class DataManager{
  // ---------- < Bookmarks > ----------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  void get bookMarks {beginCall;}

  // ---------- [⚡️ static variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  static const String urlPath =         'https://termeles.koat.hu/android/polilakk_app/';  
  static Map<AppAction, dynamic> data = {};
  static String customer =              'Koat2';
  static bool isServerAvailable =       true;
  static int userID =                   1;

  // ---------- [🌸 simple variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  final Map<String,String> headers = {'Content-Type': 'application/json'};
  late AppAction appAction;
  dynamic input;

  // ---------- [💎 complex variables] -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  // ---------- < Methods [Static] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  // ---------- < Constructor > ---- ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  DataManager({required this.appAction, this.input});

  // ---------- < Methods [1] > ---- ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Future<dynamic> get beginCall async{
    data[appAction] = null;
    try {isServerAvailable = true; switch(appAction){

      case AppAction.callElokezeles:
        var queryParameters = {
          'customer':   customer,
        };
        Uri uriUrl =              Uri.parse('${urlPath}elokezeles.php');
        http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
        data[appAction] =         (await jsonDecode(await jsonDecode(response.body)[0]['b'])) ?? [];
        break;
      
      case AppAction.callFinishElokezeles:
        var queryParameters = {
          'customer':   customer,
          'parameter':  jsonEncode(input['data'])
        };
        Uri uriUrl =              Uri.parse('${urlPath}finish_elokezeles.php');
        http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
        data[appAction] =         await jsonDecode(response.body);
        break;

      default: break;
    } if(kDebugMode) {dev.log('--------- $appAction --------- --------- --------- --------- --------- --------- ---------\n${data[appAction].toString()}');}}
    on SocketException{
      AudioPlayer().play(AssetSource('sounds/error.mp3'));
      isServerAvailable = false;
      return;
    }
    catch(e) {
      if(kDebugMode) dev.log('########## ERROR ########## ########## ########## ########## ########## ########## ##########\n$e');
    }
    return data[appAction];
  }
}