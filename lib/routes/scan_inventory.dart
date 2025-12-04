// ignore_for_file: use_build_context_synchronously, recursive_getters, deprecated_member_use

import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:logistic_app/global.dart';

class ScanInventory extends StatefulWidget{//-------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <QrScan>
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  const ScanInventory({super.key});

  @override
  State<ScanInventory> createState() => ScanInventoryState();
}

class ScanInventoryState extends State<ScanInventory>{  
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <QrScanState>
  static List<dynamic> rawData =  List<dynamic>.empty(growable: true);
  static List<dynamic>? barcodeResult;
  static String storageId =       '';  
  static Map<String, dynamic>? currentItem;
  static String? result;
  static int? getSelectedIndex;
 
  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  final GlobalKey qrKey =         GlobalKey(debugLabel: 'QR');
  TaskState taskState =           TaskState.default0;  
  TextStyle formTextStyle =       const TextStyle(fontSize: 14);
  ButtonState buttonEditAmount =  ButtonState.disabled;
  ButtonState buttonDelete =      ButtonState.disabled;
  bool isProcessIndicator =       false;
  QRViewController? controller;
  double? qrScanCutOutSize;  
  double? width;
  int? _selectedIndex; int? get selectedIndex => _selectedIndex; set selectedIndex(int? value) {if(buttonDelete != ButtonState.loading){
    buttonDelete =      (value == null)? ButtonState.disabled : ButtonState.default0;
    buttonEditAmount =  (value == null)? ButtonState.disabled : ButtonState.default0;
    _selectedIndex =    value;
    getSelectedIndex =  _selectedIndex;
  }}

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------  

  // ---------- < WidgetBuild [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context) {
    if(taskState == TaskState.default0) taskState = TaskState.scanStorage;
    width ??= _setWidth;    
    if(taskState == TaskState.scanProduct || taskState == TaskState.scanStorage){
      if(width != MediaQuery.of(context).size.width) width = _setWidth;
    }    
    return WillPopScope(
      onWillPop:  () => _handlePop,
      child:      () {switch(taskState){
        case TaskState.scanStorage: 
        case TaskState.scanProduct:   return _drawQrScanRoute;
        case TaskState.barcodeManual: return _drawBarcodeManual;
        case TaskState.inventory:     return _drawInventory;
        case TaskState.itemData:      return _drawItemData;
        case TaskState.wrongItem:     return _drawWrongItem;
        default: return Container();
      }}()      
    );
  }
  
  // ---------- < WidgetBuild [2] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawQrScanRoute => Scaffold(
    appBar: AppBar(
      title:            Center(child: Text((taskState == TaskState.scanStorage)? 'Tárolóhely Azonosítása' : 'Termék Azonosítása')),
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
      Center(child: Visibility(visible: isProcessIndicator, child: _progressIndicator(Colors.lightBlue)))
    ])
  );

Widget get _drawBarcodeManual => Scaffold(
    appBar: AppBar(
      title:            const Center(child: Padding(padding: EdgeInsets.fromLTRB(0, 0, 40, 0), child: Text('Vonalkód Manuálisan'))),
      backgroundColor:  Global.getColorOfButton(ButtonState.default0),
      foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
    ),
    backgroundColor:  Colors.white,
    body:             LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _drawBarcodeManualForm,
          _drawBottomBar
        ]);
      }
    )    
  );

  Widget get _drawInventory =>  GestureDetector(
    onTap: () => setState(() => selectedIndex = null),
    child: Scaffold(
      appBar: AppBar(
        title:            Center(child: Padding(padding: const EdgeInsets.fromLTRB(0, 0, 40, 0), child: Text('Tárhely: $storageId'))),
        backgroundColor:  Global.getColorOfButton(ButtonState.default0),
        foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
      ),
      backgroundColor:  Colors.white,
      body:             LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return (rawData.isNotEmpty) 
          ? Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _drawDataTable,          
            _drawBottomBar
          ])
          : const Center(child: Text('Nincs adat'));
        }
      )
    )
  );

  Widget get _drawItemData => Scaffold(
    appBar: AppBar(
      title:            Center(child: Padding(padding: const EdgeInsets.fromLTRB(0, 0, 40, 0), child: Text('Készlet megadás IP: ${barcodeResult![0]['IP'].toString()}'))),
      backgroundColor:  Global.getColorOfButton(ButtonState.default0),
      foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
    ),
    backgroundColor:  Colors.white,
    body:             LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _drawItemDataForm,
          _drawBottomBar
        ]);
      }
    )    
  );

  Widget get _drawWrongItem => Scaffold(
    appBar: AppBar(
      title:            const Center(child: Padding(padding: EdgeInsets.fromLTRB(0, 0, 40, 0), child: Text('Készlet megadás'))),
      backgroundColor:  Global.getColorOfButton(ButtonState.default0),
      foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
    ),
    backgroundColor:  Colors.white,
    body:             LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Center(child: Text('Ismeretlen vonalkód: $result')))
        ]);
      }
    )    
  );

// ---------- < WidgetBuild [3] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawItemDataForm => Expanded(child: Center(child: Table(
    columnWidths: const <int, TableColumnWidth>{0: IntrinsicColumnWidth(), 1: IntrinsicColumnWidth()},                  
    children:     _generateDataRows
  )));
  
  Widget get _drawBarcodeManualForm => Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(5), child: TextFormField(
    enabled:      true,
    initialValue: '',
    onChanged:    (String? newValue) => setState(() => result = newValue!),
    style:        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    textAlign:    TextAlign.center,
  ))));

  Widget get _drawDataTable =>  Expanded(child: SingleChildScrollView(scrollDirection: Axis.vertical, child: 
    SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      columns:            _generateColumns,
      rows:               _generateRows,                
      showCheckboxColumn: false,                
      border:             const TableBorder(bottom: BorderSide(color: Color.fromARGB(255, 200, 200, 200))),                
    ))
  ));

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
        _drawButtonBarcodeManual,
        const SizedBox(height: 1)
      ])
    );
    
    case TaskState.barcodeManual: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [        
        _drawButtonOk
      ])
    );

    case TaskState.inventory: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _drawButtonEditAmount,
        _drawButtonDelete,
        _drawNewItem
      ])
    );

    case TaskState.itemData: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _drawButtonOk
      ])
    );

    default: return Container();
  }}

  Widget get _drawErrorMessaggeBottomline => Visibility(
    visible:  !DataManager.isServerAvailable,
    child:    Container(height: 20, color: Colors.red, child: Row(
      mainAxisAlignment:  MainAxisAlignment.center,
      children:           [Text(DataManager.serverErrorText, style: const TextStyle(color: Color.fromARGB(255, 255, 255, 150)))]
    )) 
  );

  List<TableRow> get _generateDataRows{
    var rows = List<TableRow>.empty(growable: true);
    for (var element in currentItem!.keys) {switch(element){

      case 'cikkszam':
        rows.add(TableRow(children: <Widget>[
          Padding(padding: const EdgeInsets.all(5), child: Text('Cikkszám: ', style: formTextStyle)),
          Text(currentItem!['cikkszam'].toString(), style: formTextStyle)
        ]));
        break;
      
      case 'megnevezes':
        rows.add(TableRow(children: <Widget>[
          Padding(padding: const EdgeInsets.all(5), child: Text('Megnevezés: ', style: formTextStyle)),
          Text(currentItem!['megnevezes'].toString(), style: formTextStyle)
        ]));
        break;

      case 'keszlet':
        rows.add(TableRow(children: <Widget>[
          Padding(padding: const EdgeInsets.all(5), child: Text('Készlet: ', style: formTextStyle)),
          TextFormField(
            enabled:      true,
            initialValue: '',
            onChanged:    (String? newValue) => setState(() => currentItem!['keszlet'] = newValue!),
            style:        formTextStyle,
            keyboardType: TextInputType.number,
          )
        ]));
        break;

      default:break;
    }}
    return rows;
  }

  // ---------- < WidgetBuild [4] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawTaskScanStorageText => const Padding(padding: EdgeInsets.all(5), child: Center(child: Text(
    'Tárolóhely QR kódjának leolvasása',
    style: TextStyle(color: Colors.white, fontSize: 16),
  )));

  Widget get _drawTaskScanProductText => const Padding(padding: EdgeInsets.all(5), child: Center(child: Text(
    'Kérem olvasson be egy terméket',
    style: TextStyle(color: Colors.white, fontSize: 16),
  )));
  
  // ---------- < WidgetBuild [5] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _progressIndicator(Color colorInput) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(
    width:  20,
    height: 20,
    child:  CircularProgressIndicator(color: colorInput)
  ));

  // ---------- < WidgetBuild [Buttons] >  ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonOk => TextButton(
    onPressed:  () => _buttonOkPressed,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Icon(Icons.check,
      color: Global.getColorOfIcon(ButtonState.default0),
      size: 30,
      )
    )
  );

  Widget get _drawNewItem => Padding(padding: const EdgeInsets.all(5), child: TextButton(
    onPressed:  () => _newItemPressed,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Icon(Icons.add,
      color: Global.getColorOfIcon(ButtonState.default0),
      size: 30,      
    )
  ));
  
  Widget get _drawButtonBarcodeManual => Padding(padding: const EdgeInsets.all(5), child: TextButton(
    onPressed:  () => _buttonBarcodeManualPressed,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Row(children: [
      Visibility(visible: (buttonDelete == ButtonState.loading), child: _progressIndicator(Global.getColorOfIcon(buttonDelete))),
      Icon(Icons.keyboard,
        color: Global.getColorOfIcon(ButtonState.default0),
        size: 30,      
      )
    ])
  ));

  Widget get _drawButtonDelete => Padding(padding: const EdgeInsets.all(5), child: TextButton(
    onPressed:  () => (buttonDelete == ButtonState.default0)? _buttonDeletePressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Row(children: [
      Visibility(visible: (buttonDelete == ButtonState.loading), child: _progressIndicator(Global.getColorOfIcon(buttonDelete))),
      Icon(Icons.delete,
        color: Global.getColorOfIcon(buttonDelete),
        size: 30,      
      )
    ])
  ));

  Widget get _drawButtonEditAmount => Padding(padding: const EdgeInsets.all(5), child: TextButton(
    onPressed:  () => (buttonEditAmount == ButtonState.default0)? _buttonEditAmountPressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Row(children: [
      Visibility(visible: (buttonEditAmount == ButtonState.loading), child: _progressIndicator(Global.getColorOfIcon(buttonEditAmount))),
      Icon(Icons.edit_note,
        color: Global.getColorOfIcon(buttonEditAmount),
        size: 30,      
      )
    ])
  ));

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

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- 
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }
  
  List<DataColumn> get _generateColumns{
    List<DataColumn> columns = List<DataColumn>.empty(growable: true);
    for (var item in rawData[0].keys) {switch(item){
      case 'cikkszam':    columns.add(const DataColumn(label: Text('Cikkszám'))); break;
      case 'megnevezes':  columns.add(const DataColumn(label: Text('Megnevezés'))); break;
      case 'keszlet':     columns.add(const DataColumn(label: Text('Készlet')));  break;
      default:break;
    }}
    return columns;
  }

  List<DataRow> get _generateRows{
    List<DataRow> rows = List<DataRow>.empty(growable: true);
    for (var i = 0; i < rawData.length; i++) {if(rawData[i]['cikkszam'].isNotEmpty){rows.add(DataRow(
      cells:            _getCells(rawData[i]),
      selected:         (i == selectedIndex),
      onSelectChanged:  (bool? selected) => setState(() => selectedIndex = i)
    ));}}
    return rows;
  }

  void _onQRViewCreated(QRViewController controller) {    
    setState(() => this.controller = controller);    
    controller.scannedDataStream.listen((scanData){      
      result = scanData.code;      
      _checkResult;      
    });
    this.controller?.resumeCamera();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if(!p) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nincs hozzáférés!')));
  }  

  double get _setWidth{
    qrScanCutOutSize = (MediaQuery.of(context).size.width <= MediaQuery.of(context).size.height)
    ? MediaQuery.of(context).size.width   * 0.5
    : MediaQuery.of(context).size.height  * 0.5;
    return MediaQuery.of(context).size.width;
  }  

  Future get _toggleFlash async{
    try       {await controller?.toggleFlash(); setState((){});}
    catch(e)  {if(kDebugMode)print(e);}
  }

  Future get _flipCamera async{
    try       {await controller?.flipCamera(); setState((){});}
    catch(e)  {if(kDebugMode)print(e);}
  }

  void get _newItemPressed => (buttonDelete != ButtonState.loading)? setState(() {selectedIndex = null; taskState = TaskState.scanProduct;}) : null;

  Future get _buttonDeletePressed async{
    setState(() => buttonDelete = ButtonState.loading);    
    DataManager dataManager =     DataManager(quickCall: QuickCall.deleteItem);
    await dataManager.beginQuickCall;
    await dataManager.beginProcess;
    setState(() {buttonDelete = ButtonState.default0;});
  }
  
  Future get _buttonEditAmountPressed async{
    setState(() => buttonEditAmount = ButtonState.loading);
    int? varInt = await Global.integerDialog(context, title: 'Készlet módosítása', content: 'Mennyiség');
    if(varInt != null) {rawData[selectedIndex!]['keszlet'] = (varInt > 0)? '$varInt.00' : '0.00';}
    setState(() {buttonEditAmount = ButtonState.default0;});
  }

  void get _buttonBarcodeManualPressed => setState(() {controller!.stopCamera(); taskState = TaskState.barcodeManual;});

  Future get _buttonOkPressed async{switch(taskState){

    case TaskState.barcodeManual:
      setState((){isProcessIndicator = true;});
      DataManager dataManager = DataManager(quickCall: QuickCall.askBarcode);
      await dataManager.beginQuickCall;
      if(barcodeResult == null){
        setState(() {isProcessIndicator = false; taskState = TaskState.wrongItem;});
      }
      else{        
        if(!_checkCikkszam) {currentItem = {
          'kod':                barcodeResult![0]['id'],
          'cikkszam':           barcodeResult![0]['IP'],
          'megnevezes':         barcodeResult![0]['megnevezes'],
          'keszlet':            '',
          'mennyisegi_egyseg':  'db'
        };}
        setState((){isProcessIndicator = false; taskState = TaskState.itemData;});
      }
      return;

    case TaskState.itemData:
      void insertCurrentItem(){
        for (var i = 0; i < rawData.length; i++){
          if(rawData[i]['cikkszam'].toString() == currentItem!['cikkszam'].toString()) {rawData[i] = currentItem; return;}
        }
      }
      insertCurrentItem();
      DataManager dataManager = DataManager(quickCall: QuickCall.saveInventory);
      await dataManager.beginQuickCall;
      await dataManager.beginProcess;
      setState(() => taskState = TaskState.inventory);
      return;

    default:return;
  }}

  Future<bool> get _handlePop async{switch(taskState){
    
    case TaskState.inventory: switch(await customDialog(context,
      title:    '$storageId tárolóhely elhagyása?',
      content:  'El kívánja hagyni az agkutális tárolóhelyet: $storageId és szkennelni egy másikat?'
    )){      
      case DialogResult.back:   setState(() => taskState = TaskState.scanStorage);  return false;
      case DialogResult.cancel:                                                     return false;
      default: Global.routeBack;                                                    return true;
    }

    case TaskState.scanProduct:
      setState(() => taskState = TaskState.inventory);
      return false;
    
    case TaskState.barcodeManual:
      setState(() => taskState = TaskState.scanProduct);
      return false;

    case TaskState.itemData:
      if(await Global.yesNoDialog(context,
        title:    'A(z) $result cikkszámú termék visszavonása',
        content:  'Vissza kívánja vonni a(z) $result cikkszámú termék leltárfelvitelét és visszatér a leltárhoz?'
      )) setState(() => taskState = TaskState.inventory);
      return false;

    case TaskState.wrongItem:
      setState(() => taskState = TaskState.inventory);
      return false;

    default:
      controller?.stopCamera();
      return true;
  }}

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<DataCell> _getCells(Map<String, dynamic> row){
    List<DataCell> cells = List<DataCell>.empty(growable: true);
    for (var item in row.keys) {switch(item){
      case 'cikkszam':  
      case 'megnevezes':
      case 'keszlet':     cells.add(DataCell(Text(row[item].toString()))); break;
      default:break;
    }}   
    return cells;
  }

  Future get _checkResult async{switch(taskState){

    case TaskState.scanStorage:
      DataManager dataManager = DataManager();
      setState((){controller!.stopCamera(); isProcessIndicator = true;});
      storageId = result!;             
      await dataManager.beginProcess;
      if(kDebugMode)print(rawData);
      setState((){isProcessIndicator = false; taskState = TaskState.inventory;});
      break;
    
    case TaskState.scanProduct:
      setState((){controller!.stopCamera(); isProcessIndicator = true;});
      DataManager dataManager = DataManager(quickCall: QuickCall.askBarcode);
      await dataManager.beginQuickCall;
      if(barcodeResult == null){
        setState(() {isProcessIndicator = false; taskState = TaskState.wrongItem;});
      }
      else{        
        if(!_checkCikkszam) {currentItem = {
          'kod':                barcodeResult![0]['id'],
          'cikkszam':           barcodeResult![0]['IP'],
          'megnevezes':         barcodeResult![0]['megnevezes'],
          'keszlet':            '',
          'mennyisegi_egyseg':  'db'
        };}
        setState((){isProcessIndicator = false; taskState = TaskState.itemData;});
      }
      break;

    default:break;
  }}  
  
  // ---------- < Methods [3] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  bool get _checkCikkszam{
    for (var element in rawData) {
      if(element['cikkszam'] == barcodeResult![0]['IP']){
        currentItem = element;
        return true;
      }
    }
    currentItem = null;
    return false;
  }

// ---------- < Dialogs > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future<DialogResult> customDialog(BuildContext context, {String title = '', String content = ''}) async{
    Widget back = TextButton(
      child: const Text('Másik Tárolóhely'),
      onPressed: () => Navigator.pop(context, DialogResult.back)
    );

    Widget mainMenu = TextButton(
      child: const Text('Főmenü'),
      onPressed: () => Navigator.pop(context, DialogResult.mainMenu)
    );

    Widget cancel = TextButton(
      child: const Text('Mégsem'),
      onPressed: () => Navigator.pop(context, DialogResult.cancel)
    );

    AlertDialog infoRegistry = AlertDialog(
      title:    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      content:  Text(content, style: const TextStyle(fontSize: 12)),
      actions:  [back, mainMenu, cancel]
    );

    return await showDialog(
      context: context,
      builder: (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  }
}