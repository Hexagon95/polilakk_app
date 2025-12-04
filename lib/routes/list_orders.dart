// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:logistic_app/global.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:logistic_app/routes/scan_orders.dart';

class ListOrders extends StatefulWidget{
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  const ListOrders({super.key});

  @override
  State<ListOrders> createState() => ListOrdersState();
}

class ListOrdersState extends State<ListOrders>{
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static List<dynamic> rawData = List<dynamic>.empty(growable: true);
  static int? getSelectedIndex;

  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ButtonState buttonState = ButtonState.disabled;
  ButtonState buttonPrint = ButtonState.disabled;
  ButtonState buttonAdd =   ButtonState.default0;
  int? _selectedIndex;
  set selectedIndex(int? value) {if(buttonState != ButtonState.loading){
    if(value == null) {buttonState = ButtonState.disabled; buttonPrint = ButtonState.disabled; _selectedIndex = value; getSelectedIndex = _selectedIndex;}
    else if(rawData[value]['kesz'].toString() != '1') {buttonState = ButtonState.default0; buttonPrint = ButtonState.default0; _selectedIndex = value; getSelectedIndex = _selectedIndex;}
  }}
  String get title {switch(Global.currentRoute){
    case NextRoute.pickUpList:              return 'Kiszedési lista';
    case NextRoute.orderOutList:            return 'Bevételezés';
    case NextRoute.deliveryOut:             return 'Kiszállítás';
    case NextRoute.deliveryBackFromPartner: return 'Partnertől Visszaszállítás';
    case NextRoute.orderList:               return 'Kitárazás';
    default: switch(Global.previousRoute){
      case NextRoute.pickUpList:    return 'Kiszedési lista';
      case NextRoute.orderOutList:  return 'Bevételezés';
      case NextRoute.deliveryOut:   return 'Kiszállítás';
      case NextRoute.orderList:     return 'Kitárazás';
      default: return '';
    }
  }}
  int? get selectedIndex => _selectedIndex;  

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------  

  // ---------- < WidgetBuild > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context){    
    return GestureDetector(
      onTap:  () => setState(() => selectedIndex = null),
      child:  Scaffold(
        appBar: AppBar(
          title:            Center(child: Padding(padding: const EdgeInsets.fromLTRB(0, 0, 40, 0), child: Text(title))),
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
  Widget get _drawDataTable =>  Expanded(child: SingleChildScrollView(scrollDirection: Axis.vertical, child: 
    SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
      columns:            _generateColumns,
      rows:               _generateRows,
      showCheckboxColumn: false,                
      border:             const TableBorder(bottom: BorderSide(color: Color.fromARGB(255, 200, 200, 200))),                
    ))
  ));

  Widget get _drawNoConnection => Visibility(visible: !DataManager.isServerAvailable, child: Container(height: 20, color: Colors.red, child: Row(
    mainAxisAlignment:  MainAxisAlignment.center,
    children:           [Text(DataManager.serverErrorText, style: const TextStyle(color: Color.fromARGB(255, 255, 255, 150)))]
  )));

  Widget get _drawBottomBar => Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: () {switch(Global.currentRoute){
      case NextRoute.orderOutList:            return [Container(),    _drawButtonPrint,     _drawButtonContinue];
      case NextRoute.deliveryBackFromPartner: return [_drawButtonAdd, _drawButtonContinue];
      default:                                return [Container(),    _drawButtonContinue];
    }}())
  );

  // ---------- < Widgets [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _progressIndicator(Color colorInput) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(
    width:  20,
    height: 20,
    child:  CircularProgressIndicator(color: colorInput)
  ));

  // ---------- < Widgets [Buttonst] > --- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonContinue => Padding(padding: const EdgeInsets.fromLTRB(5, 0, 5, 0), child: 
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      TextButton(
        onPressed:  () => (buttonState == ButtonState.default0)? _buttonNextPress : null,
        style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
        child:      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Visibility(
            visible:  (buttonState == ButtonState.loading)? true : false,
            child:    Padding(
              padding:  const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child:    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonState)))
            )
          ),
          Icon(
            Icons.arrow_forward,
            color: Global.getColorOfIcon(buttonState),
            size:  30,
          )
        ])
      )
    ])
  );

  Widget get _drawButtonPrint => TextButton(
    onPressed:  () => (buttonPrint == ButtonState.default0)? _buttonPrintPressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
      (buttonPrint == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonPrint)) : Container(),
      Icon(Icons.print, color: Global.getColorOfIcon(buttonPrint), size: 30)
    ]))
  );

  Widget get _drawButtonAdd => Padding(padding: const EdgeInsets.fromLTRB(5, 0, 5, 0), child: 
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      TextButton(
        onPressed:  () => (buttonAdd == ButtonState.default0)? _buttonAddPressed : null,
        style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
        child:      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Visibility(
            visible:  (buttonAdd == ButtonState.loading)? true : false,
            child:    Padding(
              padding:  const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child:    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonAdd)))
            )
          ),
          Icon(
            Icons.add,
            color: Global.getColorOfIcon(buttonAdd),
            size:  30,
          )
        ])
      )
    ])
  );

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<DataColumn> get _generateColumns{
    List<DataColumn> columns = List<DataColumn>.empty(growable: true);
    for (var item in rawData[0].keys) {switch(item){
      case 'sorszam':   columns.add(const DataColumn(label: Text('Sorszám')));          break;
      case 'kesz':      columns.insert(0, const DataColumn(label: Text('')));           break;
      case 'vevo':
      case 'szallito':  columns.add(const DataColumn(label: Text('Megnevezés')));       break;
      default:                                                                          break;
    }}
    return columns; 
  }

  List<DataRow> get _generateRows{
    List<DataRow> rows = List<DataRow>.empty(growable: true);
    for (var i = 0; i < rawData.length; i++) {
      rows.add(DataRow(
        cells:            _getCells(rawData[i]),
        selected:         (i == selectedIndex),
        color:            (rawData[i]['kesz'].toString() == '1')? MaterialStateProperty.all(const Color.fromARGB(255, 240, 255, 240)) : null,
        onSelectChanged:  (bool? selected) => setState(() => selectedIndex = i),
      )); 
    }
    return rows;
  }

  Future get _buttonNextPress async {switch(Global.currentRoute){

    case NextRoute.pickUpList:
      setState(() => buttonState = ButtonState.loading);
      DataManager dataManager = DataManager();
      Global.routeNext =        NextRoute.pickUpData;
      await dataManager.beginProcess;
      if(DataManager.isServerAvailable){
        buttonState = ButtonState.default0;
        await Navigator.pushNamed(context, '/listPickUpDetails');
        setState((){});
      }
      else {setState(() {buttonState = ButtonState.default0; Global.routeNext = NextRoute.pickUpList;});}
      break;

    case NextRoute.orderList:
    case NextRoute.deliveryOut:
    case NextRoute.orderOutList:
      setState(() => buttonState = ButtonState.loading);
      ScanOrdersState.varRoute =  Global.currentRoute;
      DataManager dataManager =   DataManager(input: {'route': ScanOrdersState.varRoute});
      Global.routeNext =          NextRoute.scanTasks;
      await dataManager.beginProcess;
      if(DataManager.isServerAvailable){
        buttonState = ButtonState.default0;
        await Navigator.pushNamed(context, '/scanOrders');
        setState((){});
      }
      else {setState(() {buttonState = ButtonState.default0; Global.routeNext = NextRoute.orderList;});}
      break;

    default:break;
  }}

  Future get _buttonPrintPressed async{
    setState(() => buttonPrint = ButtonState.loading);
    await DataManager(
      quickCall:  QuickCall.printBarcodeDeliveryNote,
      input:      {'bizonylat_id': int.parse(rawData[getSelectedIndex!]['id'].toString())}
    ).beginQuickCall;
    setState(() => buttonPrint = ButtonState.default0);
    await Global.showAlertDialog(context, content: 'Tételek nyomtatás alatt.', title: 'Nyomtatás');
  }

  Future get _buttonAddPressed async{
    setState(() => buttonAdd = ButtonState.loading);
    Global.routeNext = NextRoute.addDeliveryBackFromPartner;
    await DataManager().beginProcess;
  }

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<DataCell> _getCells(Map<String, dynamic> row){
    List<DataCell> cells = List<DataCell>.empty(growable: true);
    for (var item in row.keys) {switch(item){
      case 'sorszam':
      case 'szallito':
      case 'vevo':    cells.add(DataCell(Text(row[item].toString())));  break;
      case 'kesz':    cells.insert(0, DataCell((row[item].toString() == '1')
        ? Icon(Icons.check_circle, color: Global.getColorOfButton(ButtonState.default0), size: 30)
        : Container()));                                                break;
      default:                                                          break;
    }}
    return cells;
  }
}