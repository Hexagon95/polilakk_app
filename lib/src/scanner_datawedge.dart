import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class ScannerDatawedge{
  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ----------
    ValueNotifier<ScannerDatas> scannerDatas;
    late FlutterDataWedge flutterDatawedge;
    late final StreamSubscription<ScanResult> scanResultSubscription;
    //late final StreamSubscription<ActionResult> scannerEventSubscription;
    //late final StreamSubscription<ScannerStatus> scannerStatusSubscription;


  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ScannerDatawedge({required this.scannerDatas, required String profileName}){
    _initFlutterDatawedge(profileName);
    scanResultSubscription = flutterDatawedge.onScanResult.listen(onScanResult);
  }

  // ---------- < Methods [Public] > ----- ---------- ---------- ---------- ---------- ---------- ----------
  void onScanResult(ScanResult event){
    try{
      scannerDatas.value = ScannerDatas(scanData: event.data);
    }
    catch(e) {scannerDatas.value = ScannerDatas(scanData: '', errorMessage: e.toString());}
  }
  void dispose() => scanResultSubscription.cancel();

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future _initFlutterDatawedge(String profileName) async{
    flutterDatawedge = FlutterDataWedge();
    await flutterDatawedge.initialize();
    await flutterDatawedge.createDefaultProfile(profileName: profileName);
  }
}


class ScannerDatas{
  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ----------
  String scanData =   "";
  String? errorMessage;

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ScannerDatas({required this.scanData, String? errorMessage});
}