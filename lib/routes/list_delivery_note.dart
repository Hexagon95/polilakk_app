// ignore_for_file: use_build_context_synchronously, recursive_getters, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:signature/signature.dart';
import 'package:flutter/material.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:logistic_app/global.dart';

class ListDeliveryNote extends StatefulWidget{//-------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <QrScan>
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  const ListDeliveryNote({super.key});

  @override
  State<ListDeliveryNote> createState() => ListDeliveryNoteState();
}

class ListDeliveryNoteState extends State<ListDeliveryNote>{  
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <QrScanState>
  static List<dynamic> rawData =                          List<dynamic>.empty(growable: true);
  static TextEditingController signatureTextController =  TextEditingController();
  static String signatureBase64 =                         '';
  static String storageId =                               '';
  static Map<String, dynamic>? currentItem;
  static List<dynamic>? barcodeResult;
  static String? result;
  static String? getSelectedId;
  static String? pdfPath;
 
  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final GlobalKey qrKey =                           GlobalKey(debugLabel: 'QR');
  NumberFormat numberFormat =                       NumberFormat("###,###.00#", "hu_HU");
  TextStyle formTextStyle =                         const TextStyle(fontSize: 14);
  TaskState taskState =                             TaskState.listDeliveryNotes;
  ButtonState buttonSignature =                     ButtonState.default0;
  ButtonState buttonPickFile =                      ButtonState.default0;
  ButtonState buttonContinue =                      ButtonState.disabled;
  ButtonState buttonClear =                         ButtonState.disabled;
  ButtonState buttonCheck =                         ButtonState.disabled;
  bool isSignatureDisabled =                        false;
  bool isProcessIndicator =                         false;

  int? _selectedIndex; int? get selectedIndex => _selectedIndex; set selectedIndex(int? value){
    if(buttonContinue == ButtonState.loading) return;
    buttonContinue =  (value == null)? ButtonState.disabled : ButtonState.default0;
    _selectedIndex =  value;
    getSelectedId =   (value == null)? null : rawData[value]['id'].toString();
  }
  final SignatureController _controller = SignatureController(
    penStrokeWidth:         1,
    penColor:               Colors.black,
    exportBackgroundColor:  Colors.white,
    onDrawStart:            (){},
    onDrawEnd:              (){}
  );
  BoxDecoration customBoxDecoration = BoxDecoration(            
    border:       Border.all(color: const Color.fromARGB(130, 184, 184, 184), width: 1),
    color:        Colors.white,
    borderRadius: const BorderRadius.all(Radius.circular(8))
  );

  // ---------- < WidgetBuild [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context) {  
    return WillPopScope(
      onWillPop:  () => _handlePop,
      child:      (){switch(taskState){
        case TaskState.listDeliveryNotes: return _drawListDeliveryNotes;
        case TaskState.showPDF:           return _drawShowPdf;
        case TaskState.signature:         return _drawSignaureCanvas;
        default: return Container();
      }}()      
    );
  }
  
  // ---------- < WidgetBuild [2] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawListDeliveryNotes => GestureDetector(
    onTap: () => setState(() => selectedIndex = null),
    child: Scaffold(
      appBar: AppBar(
        title:            const Center(child: Padding(padding: EdgeInsets.fromLTRB(0, 0, 40, 0), child: Text('Szállítólevél átvétel'))),
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

  Widget get _drawShowPdf => Scaffold(
    appBar: AppBar(
      title:            Center(child: Padding(padding: const EdgeInsets.fromLTRB(0, 0, 40, 0), child: Text('Sorszám: ${rawData[selectedIndex!]['Sorszám']}'))),
      backgroundColor:  Global.getColorOfButton(ButtonState.default0),
      foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
    ),
    body: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      (pdfPath == null)
      ? Expanded(child: SfPdfViewer.network(DataManager.getPdfUrl(rawData[selectedIndex!]['id'].toString()), key: _pdfViewerKey))
      : Expanded(child: SfPdfViewer.file(File(pdfPath!), key: _pdfViewerKey)),
      _drawBottomBar
    ])
  );

  Widget get _drawSignaureCanvas =>  Scaffold(
    appBar:           AppBar(
      title:            Center(child: Padding(padding: const EdgeInsets.fromLTRB(0, 0, 40, 0), child: Text('Sorszám: ${rawData[selectedIndex!]['Sorszám']}'))),
      backgroundColor:  Global.getColorOfButton(ButtonState.default0),
      foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
    ),
    backgroundColor:  (isSignatureDisabled)? Colors.grey : Colors.white,
    body:             OrientationBuilder(builder: (context, orientation) {
      return Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[ //ListView(children: <Widget>[ 
        (isSignatureDisabled)? Container() : Expanded(child: Signature( //SIGNATURE CANVAS0
          controller:       _controller,
          backgroundColor:  Colors.white,
        )),
        _drawTextInput,
        _drawBottomBar
      ]);
    })
  );

// ---------- < WidgetBuild [3] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawDataTable => (rawData.isNotEmpty)
  ? Expanded(child: SingleChildScrollView(scrollDirection: Axis.vertical, child:
    SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      columns:            _generateColumns,
      rows:               _generateRows,                
      showCheckboxColumn: false,                
      border:             const TableBorder(bottom: BorderSide(color: Color.fromARGB(255, 200, 200, 200))),                
    ))
  ))
  : const Expanded(child: Center(child: Text('Üres', style: TextStyle(fontSize: 20))));

  Widget get _drawTextInput => Padding(padding: const EdgeInsets.all(5), child: Container(
      decoration: customBoxDecoration,
      child:      SizedBox(height: 55, child: TextFormField(
        controller: signatureTextController,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          labelText:      (isSignatureDisabled)? 'Csomagszám' : 'Aláíró Neve',
          border:         InputBorder.none,
        ),
        style:      const TextStyle(color:  Color.fromARGB(255, 51, 51, 51)),
        onChanged:  (value) => setState(() {if(isSignatureDisabled) buttonCheck = (value.isEmpty)? ButtonState.disabled : ButtonState.default0;}),
      ))
    ));

  Widget get _drawBottomBar{ switch(taskState){

    case TaskState.listDeliveryNotes: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _drawButtonContinue
      ])
    );

    case TaskState.showPDF: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _drawButtonPickFile,
        (pdfPath == null)
        ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          _drawButtonDeliveryNote,
          _drawButtonSignature
        ])
        : Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: _drawButtonCheck)
      ])
    );

    case TaskState.signature: return Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(),
        _drawButtonClear,
        Container(),
        _drawButtonCheck,
        Container()
      ])
    );

    default: return Container();
  }}
  
  // ---------- < WidgetBuild [4] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _progressIndicator(Color colorInput) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(
    width:  20,
    height: 20,
    child:  CircularProgressIndicator(color: colorInput)
  ));

  // ---------- < WidgetBuild [Buttons] >  ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonPickFile => TextButton(
    onPressed:  () => (buttonPickFile == ButtonState.default0)? _buttonPickFilePressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Row(children: [
      Visibility(visible: (buttonPickFile == ButtonState.loading), child: _progressIndicator(Global.getColorOfIcon(ButtonState.loading))),
      Text('PDF Csatolás ', style: TextStyle(fontSize: 20, color: Global.getColorOfIcon(buttonPickFile))),
      Icon(Icons.file_present, color: Global.getColorOfIcon(buttonPickFile))
    ])
  );

  Widget get _drawButtonDeliveryNote => TextButton(
    onPressed:  () => (buttonSignature == ButtonState.default0)? _buttonSignaturePressed(delivery: true) : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Row(children: [
      Visibility(visible: (buttonSignature == ButtonState.loading), child: _progressIndicator(Global.getColorOfIcon(ButtonState.loading))),
      Text('Csomagszám ', style: TextStyle(fontSize: 20, color: Global.getColorOfIcon(buttonSignature))),
      Icon(Icons.delivery_dining, color: Global.getColorOfIcon(buttonSignature))
    ])
  );

  Widget get _drawButtonSignature => TextButton(
    onPressed:  () => (buttonSignature == ButtonState.default0)? _buttonSignaturePressed() : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Row(children: [
      Visibility(visible: (buttonSignature == ButtonState.loading), child: _progressIndicator(Global.getColorOfIcon(ButtonState.loading))),
      Text('Aláírás ', style: TextStyle(fontSize: 20, color: Global.getColorOfIcon(buttonSignature))),
      Icon(Icons.edit_document, color: Global.getColorOfIcon(buttonSignature))
    ])
  );

  Widget get _drawButtonContinue => TextButton(
    onPressed:  () => (buttonContinue == ButtonState.default0)? _buttonContinuePressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Row(children: [
      Visibility(visible: (buttonContinue == ButtonState.loading), child: _progressIndicator(Global.getColorOfIcon(ButtonState.loading))),
      Text('Tovább ', style: TextStyle(fontSize: 20, color: Global.getColorOfIcon(buttonContinue))),
      Icon(Icons.arrow_forward_ios, color: Global.getColorOfIcon(buttonContinue))
    ])
  );

  Widget get _drawButtonClear => IconButton(
    icon:       const Icon(Icons.clear),
    color:      Global.getColorOfIcon(buttonClear),
    onPressed:  () => (buttonClear == ButtonState.default0)? setState(() => _controller.clear()) : null
  );

  Widget get _drawButtonCheck => Row(children: [
    Visibility(
      visible:  (buttonCheck == ButtonState.loading),
      child:    Padding(padding: const EdgeInsets.all(5), child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: Global.getColorOfIcon(ButtonState.loading))))
    ),
    IconButton(
      icon:       const Icon(Icons.save),
      color:      Global.getColorOfIcon(buttonCheck),
      onPressed:  () => (buttonCheck == ButtonState.default0)? (pdfPath == null)? _checkPressed : _uploadPDF : null
    )
  ]);

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  void initState() {
    super.initState();
    _controller.addListener((){
      if(_controller.isEmpty) {setState((){
        buttonCheck = ButtonState.disabled;
        buttonClear = ButtonState.disabled;
      });}
      else {setState((){
        buttonCheck = ButtonState.default0;
        buttonClear = ButtonState.default0;
      });}
    });
  }

  List<DataColumn> get _generateColumns{
    List<DataColumn> columns = List<DataColumn>.empty(growable: true);
    for (var item in rawData[0].keys) {switch(item){
      case 'ip':            
      case 'Sorszám':
      case 'Vevő':
      case 'Kelte':
      case 'Pénznem':
      case 'Bruttó érték':  columns.add(DataColumn(label: Text(item))); break;
      default:break;
    }}
    return columns;
  }

  List<DataRow> get _generateRows{
    List<DataRow> rows = List<DataRow>.empty(growable: true);
    for (var i = 0; i < rawData.length; i++) {rows.add(DataRow(
      selected:         (selectedIndex == i),
      onSelectChanged:  (value) => setState(() => selectedIndex = i),
      cells:            _getCells(rawData[i])
    ));}
    return rows;
  }

  Future get _buttonContinuePressed async => setState(() => taskState = TaskState.showPDF);

  Future get _buttonPickFilePressed async{
    try {
      var paths = (await FilePicker.platform.pickFiles(
        type:             FileType.any,
        allowMultiple:    false,
        onFileLoading:    (FilePickerStatus status) {
          if(kDebugMode) print(status);
        },
        dialogTitle:      'PDF kiválasztása',
        lockParentWindow: false,
      ))?.files;
      if(paths != null && paths[0].path != null){
        String varString = paths[0].path!;
        if(varString.substring(varString.length - 3).toLowerCase() != 'pdf') return;
        setState(() {pdfPath = paths[0].path!; buttonCheck = ButtonState.default0;});
      }
      else{setState(() => buttonCheck = ButtonState.disabled);}
    }
    catch (e) {
      if(kDebugMode)print(e);
    }
  }

  Future _buttonSignaturePressed({bool delivery = false}) async{
    isSignatureDisabled = delivery;
    setState(() => taskState = TaskState.signature);
  }

  Future get _checkPressed async {if(_controller.isNotEmpty || isSignatureDisabled){
    setState(() => buttonCheck = ButtonState.loading);
    if(isSignatureDisabled){
      DataManager dataManager = DataManager(quickCall: QuickCall.saveSignature, input: {'mode': 'deliveryNote'});
      await dataManager.beginQuickCall;
      buttonCheck =             ButtonState.default0;
      taskState =               TaskState.listDeliveryNotes;
      await dataManager.beginProcess;
      selectedIndex =           null;
      _controller.clear();
      signatureTextController.clear();
      setState((){});
    }
    else{
      final Uint8List? data = await _controller.toPngBytes();
      if (data != null) {       
        signatureBase64 =         base64.encode(data);        
        DataManager dataManager = DataManager(quickCall: QuickCall.saveSignature, input: {'mode': 'signature'});
        await dataManager.beginQuickCall;
        buttonCheck =             ButtonState.default0;
        taskState =               TaskState.listDeliveryNotes;
        await dataManager.beginProcess;
        selectedIndex =           null;
        _controller.clear();
        signatureTextController.clear();
        setState((){});
      }
    }
  }}

  Future get _uploadPDF async{
    setState(() => buttonCheck = ButtonState.loading);
    DataManager dataManager = DataManager(quickCall: QuickCall.savePdf);
    await dataManager.beginQuickCall;
    _selectedIndex =          null;
    await _handlePop;
  }

  Future<bool> get _handlePop async {
    _controller.clear();
    signatureTextController.clear();
    buttonCheck = ButtonState.disabled;
    buttonClear = ButtonState.disabled;
    pdfPath =     null;
    switch(taskState) {
      case TaskState.signature: setState(() => taskState = TaskState.showPDF);            return false;
      case TaskState.showPDF:   setState(() => taskState = TaskState.listDeliveryNotes);  return false;
      default:                                                                            return true;
    }
  }

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<DataCell> _getCells(Map<String, dynamic> row){
    String formatedNumber(String input) {try{return numberFormat.format(double.parse(input));} catch(e){return input;}}
    List<DataCell> cells =      List<DataCell>.empty(growable: true);
    for (var item in row.keys) {switch(item){
      case 'ip':
      case 'Sorszám':
      case 'Vevő':
      case 'Kelte':
      case 'Pénznem':       cells.add(DataCell(Text(row[item].toString()))); break;
      case 'Bruttó érték':  cells.add(DataCell(Align(
        alignment:  Alignment.centerRight,
        child:      Text(formatedNumber(row[item].toString()))
      ))); break;
      default:break;
    }}
    return cells;
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