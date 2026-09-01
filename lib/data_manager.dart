
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
  static const String thisVersion =     '0.1d';
  static int verzioTest =               0;            // <--- Anything other than 0 will draw "[Teszt #]" at the LogIn screen.
  static String actualVersion =         thisVersion;
  static String customer =              'Koat2';

  static const String urlPath =         'https://termeles.koat.hu/android/polilakk_app/';
  static const String installerLink =   'https://app.mosaic.hu/ota/polilakk_app/$thisVersion/app-release.apk';
  static Map<AppAction, dynamic> data = {};
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

      case AppAction.callTermelesKosar:
        var queryParameters = {
          'customer':   customer,
        };
        Uri uriUrl =              Uri.parse('${urlPath}termeles_kosar.php');
        http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
        data[appAction] =         (await jsonDecode(await jsonDecode(response.body)[0]['b'])) ?? [];
        break;
      
      case AppAction.callFinishTermelsKosar:
        var queryParameters = {
          'customer': customer,
          'id':       input['id'],
          'user_id':  input['user_id']
        };
        Uri uriUrl =              Uri.parse('${urlPath}finish_termeles_kosar.php');
        http.Response response =  await http.post(uriUrl, body: json.encode(queryParameters), headers: headers);
        data[appAction] =         await jsonDecode(response.body);
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