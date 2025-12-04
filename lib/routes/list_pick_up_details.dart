// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logistic_app/global.dart';
import 'package:logistic_app/data_manager.dart';

class ListPickUpDetails extends StatefulWidget{
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  const ListPickUpDetails({super.key});

  @override
  State<ListPickUpDetails> createState() => ListPickUpDetailsState();
}

class ListPickUpDetailsState extends State<ListPickUpDetails>{  
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static List<dynamic> rawData =  List<dynamic>.empty(growable: true);  
  static List<bool> selections =  List<bool>.empty(growable: true);
  static String orderNumber =     '';

  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ----------  
  List<int> originalAmounts = List<int>.empty(growable: true);
  ButtonState buttonOk =      ButtonState.disabled;
  int? currentlyEditingIndex;
  late List<TextEditingController> amountTextEditingControllers;  

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------  

  // ---------- < WidgetBuild > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context){    
    return WillPopScope(
      onWillPop: () => _handlePop,
      child: Scaffold(
        appBar: AppBar(
          title:            Center(child: Padding(padding: const EdgeInsets.fromLTRB(0, 0, 40, 0), child: Text('Rendelés: $orderNumber'))),
          backgroundColor:  Global.getColorOfButton(ButtonState.default0),
          foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
        ),
        backgroundColor:  Colors.white,
        body:             LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return (rawData.isNotEmpty) 
            ? Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _drawDataTable,
              _drawNoConnection,
              _drawBottomBar
            ])
            : const Center(child: Text('Nincs adat'));
          }
        )
      )
    );
  }  
  
  // ---------- < Widgets [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawDataTable =>  Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: 
    SingleChildScrollView(scrollDirection: Axis.vertical, child: DataTable(
      columns:            _generateColumns,
      rows:               _generateRows,
      showCheckboxColumn: true,
      border:             const TableBorder(bottom: BorderSide(color: Color.fromARGB(255, 200, 200, 200))),
    ))
  ));

  Widget get _drawNoConnection => Visibility(visible: !DataManager.isServerAvailable, child: Container(height: 20, color: Colors.red, child: Row(
    mainAxisAlignment:  MainAxisAlignment.center,
    children:           [Text(DataManager.serverErrorText, style: const TextStyle(color: Color.fromARGB(255, 255, 255, 150)))]
  )));

  Widget get _drawBottomBar => Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Padding(padding: const EdgeInsets.fromLTRB(5, 0, 5, 0), child: 
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [_drawButtonOk])
      )
    ])
  );
  
  // ---------- < WidgetBuild [Buttons]> - ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonOk => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 5),
    child:    TextButton(          
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(ButtonState.default0))),
      onPressed:  (buttonOk == ButtonState.default0)? () => _buttonOkPressed : null,
      child:      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonOk == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 5, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonOk))))
        ),
        Text((buttonOk == ButtonState.loading)? 'Betöltés...' : 'Ok', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonOk)))
      ])
    )
  );

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future<bool> get _handlePop async {Global.routeBack; return true;}

  @override
  void initState(){    
    super.initState();    
    originalAmounts =               List<int>.generate(rawData.length, (int index) => double.parse(rawData[index]['mennyiseg'].toString()).toInt());
    selections =                    List<bool>.generate(rawData.length, (int index) => (rawData[index]['pipa'].toString() == '1'));
    amountTextEditingControllers =  List<TextEditingController>.generate(rawData.length, (index) => TextEditingController(text: (rawData[index]['pipa'].toString() == '1')
      ? double.parse(rawData[index]['mennyiseg_kiszedni'].toString()).toInt().toString()
      : originalAmounts[index].toString()
    ));
    for(var item in rawData) {if(item['pipa'].toString() == '1') item['mennyiseg'] = item['mennyiseg_kiszedni'];}
  }

  List<DataColumn> get _generateColumns{
    List<DataColumn> columns = List<DataColumn>.empty(growable: true);
    for (var item in rawData[0].keys) {switch(item){
      case 'tetel_id':
      case 'cikk_id':
      case 'mennyiseg_kiszedni':
      case 'pipa':                                                  break;
      default:          columns.add(DataColumn(label: Text(item))); break;
    }}
    return columns;
  }

  List<DataRow> get _generateRows{
    List<DataRow> rows = List<DataRow>.empty(growable: true);
    for (var i = 0; i < rawData.length; i++) {rows.add(DataRow(
      cells:            _getCells(rawData[i], i),
      selected:         selections[i],
      onSelectChanged:  (bool? value) {if(buttonOk != ButtonState.loading) {setState(() {
        selections[i] = value!;
        _setButtonOk;
        if(value) {_setAmount(amountTextEditingControllers[i].text, i);}
        else      {_handleDeselect(i);}
      });}}
    ));}
    return rows;
  }

  Future get _buttonOkPressed async{
    setState(() => buttonOk = ButtonState.loading);
    DataManager dataManager = DataManager();
    Global.routeNext =        NextRoute.pickUpDataFinish;
    await dataManager.beginProcess;
    if(DataManager.isServerAvailable){
      Global.routeBack;
      Global.routeBack;
      _setButtonOk;
      Navigator.popUntil(context, ModalRoute.withName('/listOrders'));
      await Navigator.pushReplacementNamed(context, '/listOrders');
    }
    else {setState(() => _setButtonOk);}
  }

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  void _handleDeselect(int index) {amountTextEditingControllers[index].text = originalAmounts[index].toString();}

  void get _setButtonOk {switch(_numberOfSelectedItems){
    case 0:   buttonOk = ButtonState.disabled;  break;
    default:  buttonOk = ButtonState.default0;  break;
  }}

  List<DataCell> _getCells(Map<String, dynamic> row, int index){
    List<DataCell> cells = List<DataCell>.empty(growable: true);
    for (var item in row.keys) {switch(item){
      case 'tetel_id':
      case 'cikk_id':
      case 'mennyiseg_kiszedni':
      case 'pipa':                                                        break;
      case 'mennyiseg': cells.add(DataCell(TextFormField(
        controller:   amountTextEditingControllers[index],
        onChanged:    (value) => _setAmount(value, index),
        enabled:      (selections[index]),
        keyboardType: TextInputType.number,
      )));                                                                break;
      default:          cells.add(DataCell(Text(row[item].toString())));  break;
    }}
    return cells;
  }

  // ---------- < Methods [3] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  void _setAmount(String value, int index){
    try {int valueInt = double.parse(value).toInt();
      if(valueInt <= originalAmounts[index] && valueInt >= 0 && valueInt <= getStock(rawData[index]['cikkszam'], index)){
        rawData[index]['mennyiseg'] = value;
      }
      else {
        if(originalAmounts[index] <= getStock(rawData[index]['cikkszam'], index)){
          amountTextEditingControllers[index].text =  originalAmounts[index].toString();
          rawData[index]['mennyiseg'] =               originalAmounts[index].toString();
        }
        else{
          int varAmount = getStock(rawData[index]['cikkszam'], index);
          amountTextEditingControllers[index].text = varAmount.toString();
          rawData[index]['mennyiseg'] =              varAmount;
        }
      }
    }
    catch(e) {if(kDebugMode)print(e);}
  }

  int get _numberOfSelectedItems{
    int varInt = 0;
    for (bool isTrue in selections) {
      if(isTrue) varInt++;
    }
    return varInt;
  }

  // ---------- < Methods [4] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  int getStock(String cikkszam, int index){
    if(kDebugMode)print('Cikkszám: $cikkszam\nIdnex: $index\n\n');    
    int? stock;
    for (int i = 0; i < rawData.length; i++) {if(rawData[i]['cikkszam'] == cikkszam){
      stock ??= double.parse(rawData[i]['keszlet'].toString()).toInt();
      if(i != index && selections[i]) stock -= double.parse(rawData[i]['mennyiseg'].toString()).toInt();
    }}
    if(kDebugMode)print(stock);
    return (stock != null)? stock : 0;
  }
}