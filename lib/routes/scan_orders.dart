// ignore_for_file: use_build_context_synchronously, recursive_getters, deprecated_member_use

import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:logistic_app/src/scanner_datawedge.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:logistic_app/global.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:audioplayers/audioplayers.dart';

class ScanOrders extends StatefulWidget{//---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <QrScan>
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  const ScanOrders({super.key});

  @override
  State<ScanOrders> createState() => ScanOrdersState();
}

class ScanOrdersState extends State<ScanOrders>{  
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <QrScanState>
  static List<dynamic> pickUpList =     List<dynamic>.empty(growable: true);
  static List<dynamic> rawData =        List<dynamic>.empty(growable: true);
  static List<dynamic> completedTasks = List<dynamic>.empty(growable: true);
  static List<String> listOfStorages =  List<String>.empty(growable: true);
  static List<bool> progressOfTasks =   List<bool>.empty(growable: true);
  static NextRoute varRoute =           NextRoute.default0;
  static int currentStorage =           0;
  static int? currentTask;
 
  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  TaskState _taskState = (varRoute == NextRoute.orderList)? TaskState.askStorage : TaskState.askProduct;
  TaskState get taskState => _taskState; set taskState(TaskState value){_taskState = value; switch(value){

    case TaskState.scanProduct:
      buttonNoBarcode =       ButtonState.default0;
      buttonSkip =            ButtonState.default0;
      buttonOkHandleProduct = ButtonState.hidden;
    break;

    case TaskState.handleProduct:
      buttonOkHandleProduct = ButtonState.default0;
      buttonSkip =            ButtonState.default0;
      buttonNoBarcode =       ButtonState.hidden;
    break;

    default:
      buttonNoBarcode =       ButtonState.hidden;
      buttonOkHandleProduct = ButtonState.hidden;
      buttonSkip =            ButtonState.hidden;
    break;
  }}
  ButtonState buttonContinue =        ButtonState.disabled;
  ButtonState buttonAskOk =           ButtonState.default0;
  ButtonState buttonNoBarcode =       ButtonState.hidden;
  ButtonState buttonOkHandleProduct = ButtonState.hidden;
  ButtonState buttonSkip =            ButtonState.hidden;
  bool isProperStorageCode =          true;
  bool isProgressIndicator =          false;
  bool isAskScanProductOpen =         false;
  final GlobalKey qrKey =             GlobalKey(debugLabel: 'QR');
  double? width;
  double? qrScanCutOutSize;
  String? result;
  QRViewController? controller;
  ScannerDatawedge? scannerDatawedge;
  ValueNotifier<ScannerDatas>? scannerDatas;

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ScanOrdersState() {if(Global.isScannerDevice){
    scannerDatas =      ValueNotifier(ScannerDatas(scanData: ''));
    scannerDatawedge =  ScannerDatawedge(scannerDatas: scannerDatas!, profileName: 'ScanOrders');
  }}

  // ---------- < WidgetBuild [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override  
  Widget build(BuildContext context) {switch(Global.isScannerDevice){

    case true: return WillPopScope(
      onWillPop:  () => _handlePop,
      child:      () {switch(taskState){
        case TaskState.askStorage:  return _drawAskStorageOrProduct;
        case TaskState.askProduct:  return _drawProduckInventory;
        default:                    return Container();
      }}()
    );

    case false:
      if(currentTask != null) {if(taskState == TaskState.default0) taskState = TaskState.askStorage;}
      else {_endTask;}
      width ??= _setWidth;    
      if(taskState == TaskState.scanProduct || taskState == TaskState.scanStorage){
        if(width != MediaQuery.of(context).size.width) width = _setWidth;
      }
      return WillPopScope(
        onWillPop:  () => _handlePop,
        child:      (Global.currentRoute == NextRoute.scanTasks)
        ? (){switch(taskState){
          case TaskState.askStorage:
          case TaskState.askProduct:  return _drawAskStorageOrProduct;
          default:                    return (!Global.isScannerDevice)? _drawQrScanRoute : _drawAskStorageOrProduct;
        }}()
        : _drawWaitingForFinishTask
      );

    default: return Container();
  }}
  
  // ---------- < WidgetBuild [2] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawAskStorageOrProduct {switch(Global.isScannerDevice){

    case true:
      String qrCodeScannerScan = 'Szkennelje be az alábbi tárhelyet:';
      return Scaffold(
        appBar: AppBar(
          title:            const Center(child: Text('Kitárazás')),
          backgroundColor:  Global.getColorOfButton(ButtonState.default0),
          foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
        ),
        body:   Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.max, children: [
          Text(qrCodeScannerScan, style: const TextStyle(fontSize: 16)),
          Text(listOfStorages[currentStorage], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Visibility(visible: !isProperStorageCode, child: Padding(padding: const EdgeInsets.fromLTRB(0, 20, 0, 0), child: Container(
            decoration:   const BoxDecoration(color: Color.fromARGB(90, 0, 0, 0),
            borderRadius: BorderRadius.all(Radius.circular(10))),
            child:        const Padding(padding: EdgeInsets.all(5), child: Text('Nem megfelelő QR kód!', style: TextStyle(color: Colors.yellow)))
          )))
        ]))
      );

    case false:
      String cameraScan = (taskState == TaskState.askStorage)
      ? 'A(z) ${rawData[currentTask!]['tarhely']} számú tárjhely QR kódjának leolvasása.'
      :'Kérem olvassa le a vonalkódját az alábbi terméknek:\n${rawData[currentTask!]['cikkszam']}\n${rawData[currentTask!]['megnevezes']}';
      //: 'A(z) ${rawData[currentTask!]['cikkszam']} cikkszámú termék vonalkódjának leolvasása.';
      return Scaffold(
        appBar: AppBar(
          title:            const Text('Rendelések Összeszedése'),
          backgroundColor:  Global.getColorOfButton(ButtonState.default0),
          foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
        ),
        body:   Center(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(cameraScan, style: const TextStyle(fontSize: 16)),
            _drawButtonAskOk
          ])),
        _drawErrorMessaggeBottomline
        ]))
      );
    default: return Container();
  }}

  Widget get _drawQrScanRoute => Scaffold(
    appBar: AppBar(
      title:            const Text('Rendelések Összeszedése'),
      backgroundColor:  Global.getColorOfButton(ButtonState.default0),
      foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
    ),
    body:   Stack(children: [
      Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Expanded(child: _buildQrView),
        Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          _drawBottomBar,
          _drawErrorMessaggeBottomline
        ])            
      ]),
      Column(mainAxisAlignment: MainAxisAlignment.end, children:[
        Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 10), child: Container(
          decoration: const BoxDecoration(color: Color.fromARGB(90, 0, 0, 0), borderRadius: BorderRadius.all(Radius.circular(10))),
          child:      _getDrawTask
        )))
      ]),
    ])
  );

  Widget get _drawProduckInventory => Stack(children: [
    Scaffold(
      appBar: AppBar(
        title:            Center(child: Text((){switch(varRoute){
          case NextRoute.orderList:     return 'Kitárazás';
          case NextRoute.deliveryOut:   return 'Kiszállítás';
          case NextRoute.orderOutList:  return 'Bevételezés';
          default:                      return '';
        }}(),
        style: const TextStyle(color: Colors.white),)),
        backgroundColor:  Global.getColorOfButton(ButtonState.default0),
        foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
      ),
      backgroundColor:  Colors.white,
      body:             LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return (rawData.isNotEmpty) 
          ? Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _drawDataTable,          
            _drawBottomBar,
            _drawErrorMessaggeBottomline
          ]) 
          : const Center(child: Text('Nincs adat'));
        }
      )
    ),
    _drawCounter
  ]);

  Widget get _drawWaitingForFinishTask => Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
    Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [_progressIndicator(Colors.lightBlue)])),
    _drawErrorMessaggeBottomline
  ])));

// ---------- < WidgetBuild [3] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawCounter{
    int amount() => (rawData.isNotEmpty && rawData[0]['tetelek'] != null)? rawData[0]['tetelek'].length : rawData.length;
    return Padding(padding: const EdgeInsets.fromLTRB(0, 70, 0, 0), child: Container(
      height:     25,
      decoration: BoxDecoration(
        color:        Global.getColorOfButton(ButtonState.default0),
        borderRadius: BorderRadius.circular(10),
        boxShadow:    const[BoxShadow(color: Colors.grey, offset: Offset(5, 5), blurRadius: 5)]
      ),
      child:      Text(' Beolvasva: ${completedTasks.length}/${amount()} ', style: TextStyle(color: Global.getColorOfIcon(ButtonState.default0), fontSize: 16, decoration: TextDecoration.none))
    ));
  }

  Widget get _drawDataTable => (rawData.isNotEmpty)
  ? Expanded(child: SingleChildScrollView(scrollDirection: Axis.vertical, child:
    SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      columns:            [DataColumn(label: Expanded(child: Center(child: Text(
        (){switch(varRoute){
          case NextRoute.orderList:     return listOfStorages[currentStorage];
          case NextRoute.deliveryOut:
          case NextRoute.orderOutList:  return rawData[0]['id'].toString();
          default: return '';
        }}(),
        style: const TextStyle(fontSize: 16)
      ))))],
      headingRowHeight:   30,
      dataRowMinHeight:   30,
      dataRowMaxHeight:   70,
      rows:               _generateRows,
      showCheckboxColumn: true,
      border:             const TableBorder(bottom: BorderSide(color: Color.fromARGB(255, 200, 200, 200))),                
    ))
  ))
  : const Expanded(child: Center(child: Text('Üres', style: TextStyle(fontSize: 20))));

  Widget get _buildQrView => QRView(
    key:              qrKey,
    onQRViewCreated:  _onQRViewCreated,
    overlay:          QrScannerOverlayShape(
      borderColor:  Global.getColorOfIcon(ButtonState.default0),
      borderRadius: 10,
      borderLength: 30,
      borderWidth:  10,
      cutOutSize:   qrScanCutOutSize!
    ),
    onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
  );

  Widget get _getDrawTask{ switch(taskState){
    case TaskState.scanStorage:   return _drawTaskScanStorageText;
    case TaskState.scanProduct:   return _drawTaskScanProductText;
    case TaskState.handleProduct: return _drawTaskHandleProductText;
    default:                      return Container();
  }}

  Widget get _drawBottomBar{ switch(taskState){

    case TaskState.scanStorage: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        _drawFlash,
        _drawFlipCamera
      ])
    );

    case TaskState.scanProduct: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          _drawFlash,
          _drawFlipCamera,        
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _drawSkip,
          _drawNoBarcode
        ])
      ])
    );

    case TaskState.handleProduct: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _drawSkip,
        _drawOkHandleProduct
      ])
    );

    case TaskState.askProduct: return (Global.isScannerDevice)
    ? Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        //_drawButtonContinue
      ])
    )
    : Container();

    default: return Container();
  }}

  Widget get _drawErrorMessaggeBottomline => Visibility(
    visible:  !DataManager.isServerAvailable,
    child:    Container(height: 20, color: Colors.red, child: Row(
      mainAxisAlignment:  MainAxisAlignment.center,
      children:           [Text(DataManager.serverErrorText, style: const TextStyle(color: Color.fromARGB(255, 255, 255, 150)))]
    )) 
  );

  // ---------- < WidgetBuild [4] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawTaskScanStorageText => Padding(padding: const EdgeInsets.all(5), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(
      'Kérem olvassa be a(z) ${rawData[currentTask!]['tarhely']} számú tárjhely QR kódját.',
      style: const TextStyle(color: Colors.white, fontSize: 16),
    ),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: (result != null)      
      ? (result! == rawData[currentTask!]['tarhely'])
        ? [
          const Icon(Icons.check_circle_outline, color: Color.fromARGB(200, 100, 255, 100), size: 30),
          const SizedBox(width: 10),
          const Text('Betöltés  ', style: TextStyle(color: Color.fromARGB(200, 100, 255, 100), fontSize: 16)),
          _progressIndicator(const Color.fromARGB(200, 100, 255, 100))
        ]
        : [
          (isProgressIndicator)? _progressIndicator(Colors.lightBlue) : Container(),
          const Icon(Icons.error_outline, color: Color.fromARGB(200, 255, 150, 0), size: 30),
          const SizedBox(width: 10),          
          const Text('Nem megfelelő QR kód!', style: TextStyle(color: Color.fromARGB(200, 255, 150, 0), fontSize: 16)),
        ]      
      : []
    )
  ]));

  Widget get _drawTaskScanProductText => Padding(padding: const EdgeInsets.all(5), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(
      'Kérem olvassa be a(z) ${rawData[currentTask!]['cikkszam']} cikkszámú termék vonalkódját.\n${rawData[currentTask!]['megnevezes']}',
      style: const TextStyle(color: Colors.white, fontSize: 16),
    ),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: (result != null)      
      ? (result! == rawData[currentTask!]['vonalkod'])
        ? [
          const Icon(Icons.check_circle_outline, color: Color.fromARGB(200, 100, 255, 100), size: 30),
          const SizedBox(width: 10),
          const Text('Betöltés  ', style: TextStyle(color: Color.fromARGB(200, 100, 255, 100), fontSize: 16)),
          _progressIndicator(const Color.fromARGB(200, 100, 255, 100))
        ]
        : [
          (isProgressIndicator)? _progressIndicator(Colors.lightBlue) : Container(),
          const Icon(Icons.error_outline, color: Color.fromARGB(200, 255, 150, 0), size: 30),
          const SizedBox(width: 10),          
          const Text('Nem megfelelő vonalkód!', style: TextStyle(color: Color.fromARGB(200, 255, 150, 0), fontSize: 16)),
        ]      
      : []
    )
  ]));

  List<DataRow> get _generateRows{
    List<DataRow> rows = List<DataRow>.empty(growable: true);
      for(var item in (varRoute == NextRoute.orderList)? pickUpList : rawData[0]['tetelek']) {rows.add(DataRow(
      cells:            _getCells(item),
      selected:         (completedTasks.contains(item)),
      onSelectChanged:  (value) => setState((){})
    ));}
    return rows;
  }

  Widget get _drawTaskHandleProductText => Padding(padding: const EdgeInsets.all(5), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(
      'Helyezzen ${rawData[currentTask!]['mennyiseg']}db ${rawData[currentTask!]['cikkszam']} cikkszámú terméket a gyűjtőterületre.',
      style: const TextStyle(color: Colors.white, fontSize: 16),
    ),
  ]));
  
  // ---------- < WidgetBuild [5] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<DataCell> _getCells(Map<String, dynamic> item) => [DataCell(Column(children: [
    Text(item['cikkszam'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    Text(item['megnevezes']),
    Text('(${item['cikk_id'].toString()})', style: const TextStyle(fontWeight: FontWeight.bold))
  ]))];

  Widget _progressIndicator(Color colorInput) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(
    width:  20,
    height: 20,
    child:  CircularProgressIndicator(color: colorInput)
  ));

  // ---------- < WidgetBuild [Buttons] >  ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonAskOk => (!Global.isScannerDevice)
  ? Padding(
    padding:  const EdgeInsets.fromLTRB(20, 40, 20, 40),
    child:    SizedBox(height: 40, width: 100, child: TextButton(          
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonAskOk))),
      onPressed:  (buttonAskOk == ButtonState.default0)? () => _buttonAskOkPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonAskOk == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonAskOk))))
        ),
        Text((buttonAskOk == ButtonState.loading)? 'Betöltés...' : 'Ok', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonAskOk)))
      ])
    ))
  )
  : Container();

  Widget get _drawFlash => TextButton(
    onPressed:  () => _toggleFlash,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: FutureBuilder(
      future:     controller?.getFlashStatus(),
      builder:    (context, snapshot) => Icon(
        (snapshot.data.toString() == 'true')? Icons.flash_on : Icons.flash_off,
        color: (snapshot.data.toString() == 'true')
          ? Global.getColorOfIcon(ButtonState.default0)
          : Global.getColorOfIcon(ButtonState.disabled),
        size: 30,
      ),
    ))
  );

  Widget get _drawFlipCamera => TextButton(
    onPressed:  () => _flipCamera,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: FutureBuilder(
      future:   controller?.getCameraInfo(),
      builder:  (context, snapshot) => Icon(
        (snapshot.data != null)
          ? (describeEnum(snapshot.data!) == 'back')? Icons.camera_rear : Icons.camera_front
          : Icons.error,
        color:  Global.getColorOfIcon(ButtonState.default0),
        size:   30,
      ),
    ))
  );
  
  Widget get _drawSkip => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(height: 40, child: TextButton(          
    style:      TextButton.styleFrom(
      foregroundColor:  Global.getColorOfButton(buttonSkip),
      side:             BorderSide(color: Global.getColorOfIcon(ButtonState.loading), width: 1)
    ),
    onPressed:  (buttonSkip == ButtonState.default0)? () => _skipToNextTask : null,          
    child:      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Visibility(
        visible:  (buttonSkip == ButtonState.loading)? true : false,
        child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: _progressIndicator(Global.getColorOfIcon(ButtonState.loading)))
      ),
      Text((buttonSkip == ButtonState.loading)? 'Betöltés...' : 'Kihagyás', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonSkip)))
    ])
  )));

  Widget get _drawNoBarcode => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(height: 40, child: TextButton(          
    style:      TextButton.styleFrom(
      foregroundColor:  Global.getColorOfButton(buttonNoBarcode),
      side:             BorderSide(color: Global.getColorOfIcon(ButtonState.loading), width: 1)
    ),
    onPressed:  (buttonNoBarcode == ButtonState.default0)? () => _goToHandleProduct : null,          
    child:      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Visibility(
        visible:  (buttonNoBarcode == ButtonState.loading)? true : false,
        child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: _progressIndicator(Global.getColorOfIcon(ButtonState.loading)))
      ),
      Text((buttonNoBarcode == ButtonState.loading)? 'Betöltés...' : 'Nincs vonalkód', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonNoBarcode)))
    ])
  )));

  Widget get _drawOkHandleProduct => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(height: 40, child: TextButton(          
    style:      TextButton.styleFrom(
      foregroundColor:  Global.getColorOfButton(buttonOkHandleProduct),
      side:             BorderSide(color: Global.getColorOfIcon(ButtonState.loading), width: 1)
    ),
    onPressed:  (buttonOkHandleProduct == ButtonState.default0)? () => _goToNextTask : null,          
    child:      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Visibility(
        visible:  (buttonOkHandleProduct == ButtonState.loading)? true : false,
        child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: _progressIndicator(Global.getColorOfIcon(ButtonState.loading)))
      ),
      Text((buttonOkHandleProduct == ButtonState.loading)? 'Betöltés...' : 'Ok', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonOkHandleProduct)))
    ])
  )));

  /*Widget get _drawButtonContinue => Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    TextButton(
      onPressed:  () => (buttonContinue == ButtonState.default0)? _buttonContinuePressed : null,
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
      child:      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Visibility(
          visible:  (buttonContinue == ButtonState.loading)? true : false,
          child:    Padding(
            padding:  const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child:    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonContinue)))
          )
        ),
        Icon(
          Icons.arrow_forward,
          color: Global.getColorOfIcon(buttonContinue),
          size:  30,
        )
      ])
    )
  ]);*/

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  void initState(){
    super.initState();
    if(Global.isScannerDevice) scannerDatas!.addListener(_triggerScan);
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      if(!Global.isScannerDevice)controller!.pauseCamera();
    }
    if(!Global.isScannerDevice)controller!.resumeCamera();
  }
  
  void _onQRViewCreated(QRViewController controller) {    
    setState(() => this.controller = controller);    
    controller.scannedDataStream.listen((scanData){
      if(isProgressIndicator || buttonNoBarcode == ButtonState.loading) return;      
      setState(() => isProgressIndicator = true);
      result = scanData.code;      
      _checkResult;
      if(isProgressIndicator) Future.delayed(const Duration(milliseconds: 500), () => setState(() => isProgressIndicator = false));      
    });
    this.controller?.resumeCamera();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if(!p) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nincs hozzáférés!')));
  }

  Future<bool> get _handlePop async{
    if(!Global.isScannerDevice)controller?.stopCamera();
    if (await Global.yesNoDialog(context,
      title:    'Munka elvetése?',
      content:  'El kívánja vetni az idáigi munkát és visszatér a rendelésekhez?'
    )){
      DataManager.isServerAvailable = true;
      String varString = '';
      for (var i = 0; i < progressOfTasks.length; i++){
        if(progressOfTasks[i]) varString += '${rawData[i]['cikkszam']}\tMennyiség: ${rawData[i]['mennyiseg']}\tTárhely: ${rawData[i]['tarhely']}\n';
      }
      if(varString.isEmpty) {Global.routeBack; completedTasks.clear(); rawData = List<dynamic>.empty(growable: true); return true;}
      else{
        if( await Global.showAlertDialog(context,
          title:    'Termékek visszahelyezése',
          content:  'Kérem helyezze vissza az alábbi termékeket a helyükre:\n$varString'
        )) {Global.routeBack; rawData = List<dynamic>.empty(growable: true); return true;}
        return false;
      }
    }
    else {
      setState((){});
      return false;
    }
  }

  double get _setWidth{
    qrScanCutOutSize = (MediaQuery.of(context).size.width <= MediaQuery.of(context).size.height)
    ? MediaQuery.of(context).size.width   * 0.5
    : MediaQuery.of(context).size.height  * 0.5;
    return MediaQuery.of(context).size.width;
  }

  void get _buttonAskOkPressed => setState(() => taskState = (taskState == TaskState.askStorage)? TaskState.scanStorage : TaskState.scanProduct);

  Future get _buttonContinuePressed async{
    bool allCompleted() {for(var item in (varRoute == NextRoute.orderList)? pickUpList : rawData[0]['tetelek']) {if(!completedTasks.contains(item)) return false;} return true;}
    
    setState(() => buttonContinue = ButtonState.loading);
    if(varRoute == NextRoute.orderList){
      if(allCompleted() || await Global.yesNoDialog(context,
        title:    'Tovább lépés',
        content:  'Nem került minden tétel kitárazásra, folytatja?'
      )){
        if(currentStorage < listOfStorages.length - 1){
          await DataManager(quickCall: QuickCall.kiszedesFelviteleTarhely).beginQuickCall;
          if(!DataManager.isServerAvailable) {setState(() => buttonContinue = ButtonState.default0); return;}
          currentStorage++;
          buttonContinue = ButtonState.default0;
          setState(() => taskState = TaskState.askStorage);
        }
        else {
          await DataManager(quickCall: QuickCall.kiszedesFelviteleTarhely).beginQuickCall;
          if(!DataManager.isServerAvailable) {setState(() => buttonContinue = ButtonState.default0); return;}
          _endTask;
        }
      }
    }
    else{
      if(!allCompleted()){
        await Global.showAlertDialog(context,
          title:    'Tovább lépés',
          content:  'Nem került minden tétel bevételezésre!'
        );
        buttonContinue = ButtonState.default0;
        if(buttonContinue == ButtonState.default0) await _buttonContinuePressed;
      }
      else{_endTask;}
    }
  }

  Future get _toggleFlash async{
    try       {await controller?.toggleFlash(); setState((){});}
    catch(e)  {if(kDebugMode)print(e);}
  }

  Future get _flipCamera async{
    try       {await controller?.flipCamera(); setState((){});}
    catch(e)  {if(kDebugMode)print(e);}
  }

  void get _goToHandleProduct{    
    setState((){if(!Global.isScannerDevice)controller?.stopCamera(); taskState = TaskState.handleProduct;});
  }

  void get _goToNextTask{    
    progressOfTasks[currentTask!] = true;
    currentTask = (currentTask! < rawData.length - 1)? currentTask! + 1 : null;
    setState(() => taskState = TaskState.askStorage);
  }

  Future get _skipToNextTask async{
    if(!await Global.yesNoDialog( context,
      title:    'Kihagyás?',
      content:  'Biztosan kihagyja a ${rawData[currentTask!]['cikkszam']} cikkszámú terméket?'
    )) return;
    progressOfTasks[currentTask!] = false;
    currentTask = (currentTask! < rawData.length - 1)? currentTask! + 1 : null;
    setState(() => taskState = TaskState.askStorage);
  }

  Future get _endTask async{
    controller =              null;
    Global.routeNext =        NextRoute.finishTasks;
    DataManager dataManager = DataManager(input: {'route': varRoute});
    await dataManager.beginProcess;
    if(!DataManager.isServerAvailable) {setState(() => buttonContinue = ButtonState.default0); return;}
    completedTasks.clear();
    Global.routeBack;
    Global.currentRoute;
    await dataManager.beginProcess;
    buttonContinue = ButtonState.default0;
    Navigator.popUntil(context, ModalRoute.withName('/listOrders'));
    await Navigator.pushReplacementNamed(context, '/listOrders');
    setState((){});
  }

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future _triggerScan() async{
    bool contains(List<dynamic> listBase, List<dynamic> listExam) {for(dynamic item in listExam) {if(!listBase.contains(item)) return false;} return true;}
    String getVonalkodOf(String inputId) {for(dynamic item in rawData) {if(item['tarhely'].toString() == inputId)return item['tarhely_vonalkod'].toString();} return '';}

    switch(taskState){

      case TaskState.askStorage:
        if(scannerDatas!.value.scanData.trim() == getVonalkodOf(listOfStorages[currentStorage].toString())){
          isProperStorageCode = true;
          pickUpList =          List<dynamic>.empty(growable: true);
          for(var item in rawData) {if(item['tarhely'].toString() == listOfStorages[currentStorage]) pickUpList.add(item);}
          setState(() => taskState = TaskState.askProduct);
        }
        else{
          AudioPlayer().play(AssetSource('sounds/buzzer.wav'));
          isProperStorageCode = false; 
          setState((){});
        }
      break;
      
      case TaskState.askProduct:
        bool noMatch = true;
        for(var item in (varRoute == NextRoute.orderList)? pickUpList : rawData[0]['tetelek']){
          if(item['vonalkod'].toString() == scannerDatas!.value.scanData.trim()){
            noMatch = false;
            if(!completedTasks.contains(item)){
              completedTasks.add(item);
              if(varRoute == NextRoute.orderList) {buttonContinue = (contains(completedTasks, pickUpList))? ButtonState.default0 : ButtonState.disabled;}
              else {buttonContinue = (contains(completedTasks, rawData[0]['tetelek']))? ButtonState.default0 : ButtonState.disabled;}
              if(buttonContinue == ButtonState.default0) await _buttonContinuePressed;
              break;
            }
            else {AudioPlayer().play(AssetSource('sounds/okay.mp3')); break;}
          }
        }
        if(noMatch) AudioPlayer().play(AssetSource('sounds/buzzer.wav'));
        setState((){}); break;

      default: break;
    }
  }

  void get _checkResult{switch(taskState){

    case TaskState.scanStorage:
      if(result != null && result == rawData[currentTask!]['tarhely']){        
        Future.delayed(const Duration(milliseconds: 500), () => setState(() => isProgressIndicator = false));
        Future.delayed(const Duration(seconds: 1), () => setState(() {if(!Global.isScannerDevice)controller?.stopCamera(); result = null; taskState = TaskState.askProduct;}));
      }
      break;
    
    case TaskState.scanProduct:
      if(result != null && (result == rawData[currentTask!]['vonalkod'])){        
        Future.delayed(const Duration(milliseconds: 500), () => setState(() => isProgressIndicator = false));
        Future.delayed(const Duration(seconds: 1), () {result = null; _goToHandleProduct;});        
      }
      break;

    default:break;
  }}

  // ---------- < Methods [3] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
}