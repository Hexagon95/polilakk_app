// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:logistic_app/routes/scan_check_stock.dart';
import 'package:logistic_app/data_manager.dart';
import '../global.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:masked_text/masked_text.dart';
import 'package:flutter/material.dart';

class DataForm extends StatefulWidget {//-------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <DataForm>
  const DataForm({super.key});

  @override
  State<DataForm> createState() => DataFormState();
}

class DataFormState extends State<DataForm> {//-- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <DataFormState>
  // ---------- < Wariables [Static] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static List<dynamic> rawData =                  List<dynamic>.empty();
  static List<dynamic> rawData2 =                 List<dynamic>.empty();
  static Map<String, dynamic> listOfLookupDatas = <String, dynamic>{};
  static TaskState taskState =                    TaskState.dataForm;
  static String carId =                           '';
  static String title =                           '';
  static int? amount;

  // ---------- < Wariables [1] > ---- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<TextEditingController> controller =  List<TextEditingController>.empty(growable: true);
  ButtonState buttonContinue =              ButtonState.default0;
  ButtonState buttonSave =                  ButtonState.disabled;
  bool enableInteraction =                  true;
  BoxDecoration customBoxDecoration =       BoxDecoration(            
    border:       Border.all(color: const Color.fromARGB(130, 184, 184, 184), width: 1),
    color:        Colors.white,
    borderRadius: const BorderRadius.all(Radius.circular(8))
  );
  BoxDecoration customMandatoryBoxDecoration = BoxDecoration(            
    border:       Border.all(color: const Color.fromARGB(255, 255, 0, 0), width: 1),
    color:        const Color.fromARGB(255, 255, 230, 230),
    borderRadius: const BorderRadius.all(Radius.circular(8))
  );
  String get titleText {switch(Global.currentRoute){
    case NextRoute.dataFormGiveDatas: switch(taskState){
      case TaskState.dataList:  return 'Abroncsok kiválasztása';
      default:                  return (ScanCheckStockState.scannedCode == ScannedCodeIs.storage)
        ? (ScanCheckStockState.selectedIndex != null)
          ? ScanCheckStockState.rawData[0]['tetelek'][ScanCheckStockState.selectedIndex]['ip']
          : 'Új cikk hozzáadása'
        : '${ScanCheckStockState.rawData[1]['ertek'].toString()} - ${ScanCheckStockState.rawData[2]['ertek'].toString()}'
      ;
    }
    case NextRoute.dataFormMonetization:  return 'Ellenörzés';
    default:                              return 'Adja meg a mennyiséget';
  }}

  // ---------- < Constructor > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  DataFormState() {
    for(int i = 0; i < rawData.length; i++) {controller.add(TextEditingController(text: rawData[i]['value']));}
    buttonSave = setButtonSave;
  }

  // ---------- < WidgetBuild [1] > -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
   Widget build(BuildContext context){
    Widget display() {switch(Global.currentRoute){
      case NextRoute.dataFormMonetization: return _drawDoubleColumn;
      default: switch(taskState){
        case TaskState.dataList:  return _drawDataList;
        default:                  return _drawFormList;
      }
    }}

    return GestureDetector(
      onTap:  () => setState((){}),
      child:  WillPopScope(
        onWillPop:  _handlePop,
        child:      Scaffold(
          appBar: AppBar(
            title:            Center(child: Text(titleText)),
            backgroundColor:  Global.getColorOfButton(ButtonState.default0),
            foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
          ),
          backgroundColor:  Colors.white,
          body:             LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                display(),
                _drawBottomBar
              ]);
            }
          )
        )
      )
    );
  }

  // ---------- < WidgetBuild [2] > -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawFormList{
    List<Widget> varListWidget = List<Widget>.empty(growable: true);
    int maxSor() {int maxSor = 1; for(var item in rawData) {if(item['sor'] > maxSor) maxSor = item['sor'];} return maxSor;}
    
    if(rawData[0]['sor'] == null){
      for(int i = 0; i < rawData.length; i++) {if(rawData[i]['visible'] == null || rawData[i]['visible'].toString() == '1') {varListWidget.add(Padding(
        padding:  const EdgeInsets.fromLTRB(5, 5, 5, 0),
        child:    Container(
          decoration: (_isItemAcceptable(i))? customBoxDecoration : customMandatoryBoxDecoration,
          child:      Padding(padding: const EdgeInsets.all(5), child: _getWidget(rawData[i], i))
        )
        //child:    Padding(padding: const EdgeInsets.all(5), child: _getWidget(rawData[i], i))
      ));}}
    }
    else {for(int sor = 1; sor <= maxSor(); sor++) {
      List<Widget> row = List<Widget>.empty(growable: true);
      for(int i = 0; i < rawData.length; i++) {if(rawData[i]['sor'] == sor){
        if(rawData[i]['visible'] == null || rawData[i]['visible'].toString() == '1') {row.add(Padding(
          padding:  const EdgeInsets.fromLTRB(5, 5, 5, 0),
          child:    Container(
            decoration: (_isItemAcceptable(i))? customBoxDecoration : customMandatoryBoxDecoration,
            child:      Padding(padding: const EdgeInsets.all(5), child: _getWidget(rawData[i], i))
          )
          //child:    Padding(padding: const EdgeInsets.all(5), child: _getWidget(rawData[i], i))
        ));
      }}}
      varListWidget.add(SizedBox(width: MediaQuery.of(context).size.width, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: row)));
    }}
    return Expanded(child: SingleChildScrollView(child: Column(
      mainAxisAlignment:  MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children:           varListWidget
    )));
  }

  Widget get _drawDataList => (rawData2[0]['tetelek'].isNotEmpty)
  ? Expanded(child: SingleChildScrollView(scrollDirection: Axis.vertical, child:
    SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      columns:            _generateColumns,
      rows:               _generateRows,                
      showCheckboxColumn: false,                
      border:             const TableBorder(bottom: BorderSide(color: Color.fromARGB(255, 200, 200, 200))),                
    ))
  ))
  : const Expanded(child: Center(child: Text('Üres', style: TextStyle(fontSize: 20))));

  Widget get _drawDoubleColumn{
    Widget decor({required String name, required double ratio, required Widget input}) {return Padding(
      padding:  const EdgeInsets.all(5),
      child:    Container(
        width:      MediaQuery.of(context).size.width * ratio - 10,
        decoration: customBoxDecoration,
        child:      Stack(children: [
          Padding(padding: const EdgeInsets.all(16), child: input),
          Padding(padding: const EdgeInsets.all(2), child: Text(name, style: const TextStyle(fontSize: 12, color: Colors.grey)))
        ])
      ),
    );}

    List<Widget> columnText =   List<Widget>.empty(growable: true);
    List<Widget> columnAmount = List<Widget>.empty(growable: true);
    String varString =          '';

    if(ScanCheckStockState.scannedCode == ScannedCodeIs.storage){
      for(int i = 0; i < ScanCheckStockState.selectionList.length; i++) {if(ScanCheckStockState.selectionList[i]){
        varString = '';
        for(String key in ScanCheckStockState.rawData[0]['tetelek'][i].keys){
          if(!['id', 'hiba', 'keszlet'].contains(key)) {varString += ScanCheckStockState.rawData[0]['tetelek'][i][key].toString();}
        }
        columnText.add(decor(
          name:   'Tétel:',
          ratio:  3.0 / 4.0,
          input:  Text(varString, style: const TextStyle(fontSize: 16))
        ));
        columnAmount.add(decor(
          name:   'Mennyiség:',
          ratio:  1.0 / 4.0,
          input:  Text(ScanCheckStockState.rawData[0]['tetelek'][i]['keszlet'].toString(), style: const TextStyle(fontSize: 16))
        ));
      }}
    }
    else{
      columnText.add(decor(
        name:   'Tétel:',
        ratio:  3.0 / 4.0,
        input:  Text(
          //'${ScanCheckStockState.rawData[1]['ertek'].toString()} - ${ScanCheckStockState.rawData[2]['ertek'].toString()} ${ScanCheckStockState.rawData[3]['ertek'].toString()}',
          '${Global.getErtek(ScanCheckStockState.rawData, 'megnevezes', 'Rendszám')} - ${Global.getErtek(ScanCheckStockState.rawData, 'megnevezes', 'Pozíció')} ${Global.getErtek(ScanCheckStockState.rawData, 'megnevezes', 'Megnevezés')}',
          style:    const TextStyle(fontSize: 16),
          softWrap: true,
        )
      ));
      columnAmount.add(decor(
        name:   'Mennyiség:',
        ratio:  1.0 / 4.0,
        input:  const Text('1', style: TextStyle(fontSize: 16))
      ));
    }
    return Expanded(child: SingleChildScrollView(child: Row(
      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children:           [
        Column(children: columnText),
        Column(children: columnAmount)
      ]
    )));
  }

  Widget get _drawBottomBar => Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child: (){switch(Global.currentRoute){
    case NextRoute.dataFormGiveDatas: return Row(mainAxisAlignment: MainAxisAlignment.end, children: [_drawButtonSave]);
    default:                          return Row(mainAxisAlignment: MainAxisAlignment.end, children: [_drawButtonQRCode]);
  }}());

  // ---------- < WidgetBuild [3] > -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _progressIndicator(Color colorInput) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(
    width:  20,
    height: 20,
    child:  CircularProgressIndicator(color: colorInput)
  ));

  // ---------- < WidgetBuild [Buttons] > ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonQRCode => TextButton(
    onPressed:  () => (buttonContinue == ButtonState.default0)? _buttonContinuePressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
      (buttonContinue == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonContinue)) : Container(),
      Text(' Cél tárhelyhez ', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonContinue))),
      Icon(Icons.arrow_forward_ios, color: Global.getColorOfIcon(buttonContinue), size: 30)
    ]))
  );

  Widget get _drawButtonSave => TextButton(
    onPressed:  () async => (buttonSave == ButtonState.default0)? await _buttonSavePressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
      (buttonSave == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonSave)) : Container(),
      Text(' Mentés ', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonSave))),
      Icon(Icons.save_as, color: Global.getColorOfIcon(buttonSave), size: 30)
    ]))
  );

  // ---------- < Methods [1] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _getWidget(dynamic input, int index){
    bool editable =           (input['editable'].toString() == '1');
    controller[index].text =  (rawData[index]['value'] == null)? '' : rawData[index]['value'].toString();
    double getWidth(int index) {int sorDB = 0; for(var item in rawData) {if(item['sor'] == rawData[index]['sor']) sorDB++;} return MediaQuery.of(context).size.width / sorDB - 22;}

    switch(input['input_field']){

      case 'search':
        List<String> items =    List<String>.empty(growable: true);
        for(var item in listOfLookupDatas[input['id']]) {items.add(item['megnevezes'].toString());}
        return (items.isNotEmpty && editable)
        ? Stack(alignment: AlignmentDirectional.centerStart, children: [
            Visibility(visible: (rawData[index]['value'] == null), child: Padding(padding: const EdgeInsets.all(10), child: Text(
              rawData[index]['name'],
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ))),
            SizedBox(height: 55, width: getWidth(index), child: DropdownSearch<String>(
              items:                  items,
              selectedItem:           controller[index].text,
              popupProps:             const PopupProps.menu(showSearchBox: true),
              onChanged:              (String? newValue) => _handleSelectChange(newValue, index),
              dropdownButtonProps:    const DropdownButtonProps(
                icon:                     Row(mainAxisSize: MainAxisSize.min, children:[Icon(Icons.search), Icon(Icons.arrow_downward)]),
                padding:                  EdgeInsets.symmetric(vertical: 16),
              ),
              dropdownDecoratorProps: const DropDownDecoratorProps(
                baseStyle:                TextStyle(color: Colors.black),
                textAlign:                TextAlign.start,
                textAlignVertical:        TextAlignVertical.center,
                dropdownSearchDecoration: InputDecoration(border: InputBorder.none)
              ),
            ))
          ])
        : SizedBox(height: 55, width: getWidth(index), child: TextFormField(
          enabled:      false,          
          controller:   controller[index],
          decoration:   InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            labelText:      rawData[index]['name'],
            border:         InputBorder.none,
          ),
          onChanged:  null,
        ));

      case 'select':
        bool isInLookupData(String input, List<dynamic>? list) {if(list != null)for(var item in list) {if(item['id'].toString() == input) return true;} return false;}
        
        List<DropdownMenuItem<String>> items =  List<DropdownMenuItem<String>>.empty(growable: true);
        List<dynamic>? lookupData =             listOfLookupDatas[input['id']];
        if(lookupData != null) for(var item in lookupData) {items.add(DropdownMenuItem(value: item['id'].toString(), child: Text(item['megnevezes'] ?? item['id'], textAlign: TextAlign.start)));}
        String? selectedItem =    (isInLookupData(rawData[index]['value'].toString(), lookupData))? rawData[index]['value'].toString() : null;
        return (lookupData != null && lookupData.isNotEmpty && editable)
        ? Stack(children: [
            SizedBox(height: 55, width: getWidth(index), child: Padding(padding: const EdgeInsets.all(15), child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value:      selectedItem,
            hint:       Text(rawData[index]['name'].toString(), textAlign: TextAlign.start),
            icon:       const Icon(Icons.arrow_downward),
            iconSize:   24,
            elevation:  16,
            isExpanded: false,
            alignment:  AlignmentDirectional.centerStart,
            onChanged:  (String? newValue) async => await _handleSelectChange(newValue, index),
            items:      items
          )))),
          (selectedItem != null)
          ? Text(rawData[index]['name'].toString(), style: const TextStyle(color: Colors.grey))
          : Container()
        ])
        : SizedBox(height: 55, width: getWidth(index), child: TextFormField(
          enabled:      false,          
          controller:   controller[index],
          decoration:   InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            labelText:      rawData[index]['name'],
            border:         InputBorder.none,
          ),
          onChanged:  null,
        ));

      case 'number':
      case 'integer': switch(input['name']){

        case 'DOT-szám': return SizedBox(height: 55, width: getWidth(index), child: Focus(
          onFocusChange:  (value) => setState((){rawData[index]['value'] = controller[index].text; buttonSave = setButtonSave;}),
          child:          MaskedTextField(
            enabled:            editable,          
            controller:         controller[index],
            mask:               '####',
            keyboardType:       TextInputType.number,
            decoration:         InputDecoration(
              contentPadding:     const EdgeInsets.all(10),
              labelText:          input['name'],
              hintText:           '####',
              border:             InputBorder.none,
            ),
            style:      TextStyle(color: (editable)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
          )
        ));

        case 'Profilmélység': return SizedBox(height: 55, width: getWidth(index), child: Focus(
          onFocusChange:  (value) => setState(() {rawData[index]['value'] = controller[index].text; _replaceCommas(index); buttonSave = setButtonSave;}),
          child:          TextFormField(
            enabled:            editable,          
            controller:         controller[index],
            keyboardType:       TextInputType.number,
            decoration:         InputDecoration(
              contentPadding:     const EdgeInsets.all(10),
              labelText:          input['name'],
              border:             InputBorder.none,
            ),
            style:      TextStyle(color: (editable)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
          )
        ));

        default: return SizedBox(height: 55, width: getWidth(index), child: Focus(
          onFocusChange:  (value) => setState(() {rawData[index]['value'] = controller[index].text; _checkInteger(rawData[index]['value'], input, index); buttonSave = setButtonSave;}),
          child:          TextFormField(
            enabled:            editable,          
            controller:         controller[index],
            decoration:         InputDecoration(
              contentPadding:     const EdgeInsets.all(10),
              labelText:          input['name'],
              border:             InputBorder.none,
            ),
            style:        TextStyle(color: (editable)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
            keyboardType: TextInputType.number,
          )
        ));
      }

      default: return SizedBox(height: 55, width: getWidth(index), child: Focus(
        onFocusChange:  (value) => setState(() {rawData[index]['value'] = controller[index].text; buttonSave = setButtonSave;}),
        child:          TextFormField(
          enabled:        editable,
          controller:     controller[index],
          decoration:     InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            labelText:      input['name'],
            border:         InputBorder.none,
          ),
          style:  TextStyle(color: (editable)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
        )
      ));
    }
  }

  List<DataColumn> get _generateColumns{
    List<DataColumn> columns = List<DataColumn>.empty(growable: true);
    for(var item in rawData2[0]['oszlop']) {columns.add(DataColumn(label: Text(item['text'])));}
    return columns;
  }

  List<DataRow> get _generateRows{
    String swap(String input) {return (input == '1')? '0' : '1';}

    List<DataRow> rows = List<DataRow>.empty(growable: true);
    for (var i = 0; i < rawData2[0]['tetelek'].length; i++) {
      rows.add(DataRow(
        onSelectChanged:  (value) => setState(() => rawData2[0]['tetelek'][i]['tarolas'] = swap(rawData2[0]['tetelek'][i]['tarolas'].toString())),
        selected:         (rawData2[0]['tetelek'][i]['tarolas'].toString() == '1'),
        cells:            _getCells(rawData2[0]['tetelek'][i]),
      ));
    }
    return rows;
  }

  Future get _buttonContinuePressed async {
    setState(() => buttonContinue = ButtonState.loading);
    ScanCheckStockState.taskState =       TaskState.scanDestinationStorage;
    buttonContinue =                      ButtonState.default0;
    Navigator.popUntil(context, ModalRoute.withName('/scanCheckStock'));
    await Navigator.pushReplacementNamed(context, '/scanCheckStock');
  }

  Future get _buttonSavePressed async {switch(taskState){

    case TaskState.dataForm:
      setState(() {buttonSave = ButtonState.loading; enableInteraction = false;});
      DataManager dataManager = DataManager(quickCall: QuickCall.askAbroncs);
      await dataManager.beginQuickCall;
      // ignore: recursive_getters
      if(carId.isEmpty && ScanCheckStockState.storageId == DataManager.newEntryId) {taskState = TaskState.dataList; await _buttonSavePressed;}
      else {setState(() {buttonSave = ButtonState.default0; enableInteraction = true;});}
      break;

    case TaskState.dataList:
      if(carId.isNotEmpty) setState(() {buttonSave = ButtonState.loading; enableInteraction = false;});
      DataManager dataManager = DataManager(quickCall: QuickCall.finishGiveDatas);
      await dataManager.beginQuickCall;
      dataManager =             DataManager(quickCall: QuickCall.checkStock);
      await dataManager.beginQuickCall;
      taskState =               TaskState.dataForm;
      buttonSave =              ButtonState.disabled;
      enableInteraction =       true;
      await Navigator.of(context).pushNamedAndRemoveUntil('/scanCheckStock', ModalRoute.withName('/menu'));
      break;

    default: break;
  }}

  Future<bool> _handlePop() async {switch(taskState){

    case TaskState.dataList:
      setState(() => taskState = TaskState.dataForm);
      return false;    

    default:
      setState(() => ScanCheckStockState.storageId = ScanCheckStockState.savedStorageId);
      return true;
  }}

  // ---------- < Methods [2] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<DataCell> _getCells(Map<String, dynamic> row){
    List<DataCell> cells = List<DataCell>.empty(growable: true);
    for(var item in rawData2[0]['oszlop']) {switch(item['id'].toString()){

      case 'tarolas':
        cells.add(DataCell((row['tarolas'].toString() == '1')
          ? const Icon(Icons.check, color: Colors.blue)
          : Container()
        ));
        break;

      default:
        cells.add(DataCell(Text(row[item['id'].toString()].toString())));
        break;
    }}
    return cells;
  }

  Future maskEditingComplete(List<dynamic> thisData, dynamic input, int index) async{
    switch(thisData[index]['name']){
      default:
        if(controller[index].text.length == input['input_mask'].length){
          thisData[index]['value'] = controller[index].text;
          _handleSelectChange(thisData[index]['value'], index);
        }
        else {thisData[index]['value'] = '';}
        break;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState((){});
  }

  void _checkInteger(String value, dynamic input, int index){ //Check if integer and is between 0 and limit.
    if(input['limit'] == null) {setState(() {rawData[index]['value'] = value; buttonSave = setButtonSave;}); return;}
    int? varInt;
    try{varInt = int.parse(value);}
    // ignore: empty_catches
    catch(e){}
    finally{
      if(varInt != null) {
        if(varInt < 1) {controller[index].text = '1'; input['value'] = 1;}
        else if(varInt > input['limit']) {
          controller[index].text =  input['limit'].toString();
          input['value'] =          input['limit'];
        }
        else {input['value'] = varInt;}
      }
      else if(value != '') {controller[index].text = input['value'].toString();}
    }
  }

  Future _handleSelectChange(String? newValue, int index) async{ if(enableInteraction){
    enableInteraction = false;
    if(newValue == null) {rawData[index]['kod'] = null;}
    else {for(dynamic item in listOfLookupDatas[rawData[index]['id']]) {if(item['megnevezes'] == newValue) rawData[index]['kod'] = item['id'];}}
    if(rawData[index]['id'] == 'id_34' && rawData[index]['kod'] != null) carId = rawData[index]['kod'].toString();
    setState(() => rawData[index]['value'] = newValue);
    DataManager dataManager = DataManager(quickCall: QuickCall.chainGiveDatas, input: {'index': index});
    await dataManager.beginQuickCall;
    buttonSave = setButtonSave;
    setState((){});
    enableInteraction = true;
  }}

  void _replaceCommas(int index){
    List<String> listString = rawData[index]['value'].toString().split('');
    for(int i = 0; i < listString.length; i++){
      if(listString[i] == ',' || listString[i] == '.'){
        listString[i] = '.';
        listString =    listString.sublist(0, i + 2);
        break;
      }
    }
    rawData[index]['value'] = listString.join('');
  }

  // ---------- < Methods [3] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ButtonState get setButtonSave {
    for(int i = 0; i < rawData.length; i++){
      if(!_isItemAcceptable(i)){
        return ButtonState.disabled;
      }
    }
    return ButtonState.default0;
  }
  
  // ---------- < Methods [4] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  bool _isItemAcceptable(int index) => (rawData[index]['mandatory'] != null && rawData[index]['mandatory'].toString() == '1')? isValueCorrect(index) : true;

  // ---------- < Methods [5] > ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  bool isValueCorrect(int index) {switch(rawData[index]['name']){

    case 'DOT-szám':
      try{
        bool isDotNumberWrong() => (
          int.parse(controller[index].text.substring(0,2)) < 1  ||
          int.parse(controller[index].text.substring(0,2)) > 53 ||
          int.parse(controller[index].text.substring(2)) > int.parse(DateTime.now().year.toString().substring(2))
        );
        bool varBool = !(controller[index].text.length != 4 || isDotNumberWrong());
        return varBool;
      }
      catch(e) {return false;}

     case 'Profilmélység':
      try{
        double varDouble = double.parse(rawData[index]['value'].toString());
        if(varDouble < 0.0 || varDouble >= 15) throw Exception();
        return true;
      }
      catch(e) {return false;}

    default: return (rawData[index]['value'] != null && rawData[index]['value'].toString().isNotEmpty);
  }}
}