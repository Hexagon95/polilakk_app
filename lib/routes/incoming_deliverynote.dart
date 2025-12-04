// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:flutter/foundation.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:logistic_app/global.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:logistic_app/routes/menu.dart';
import 'package:masked_text/masked_text.dart';
import 'package:flutter/material.dart';

class IncomingDeliveryNote extends StatefulWidget{
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  const IncomingDeliveryNote({super.key}); 

  @override
  State<IncomingDeliveryNote> createState() => IncomingDeliveryNoteState();
}

class IncomingDeliveryNoteState extends State<IncomingDeliveryNote>{
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static Map<String, dynamic> listOfLookupDatas =         <String, dynamic>{};
  static List<TextEditingController> controller =         List<TextEditingController>.empty(growable: true);
  static List<dynamic> rawDataListDeliveryNotes =         List<dynamic>.empty(growable: true);
  static List<dynamic> rawDataListItems         =         List<dynamic>.empty(growable: true);
  static List<dynamic> rawDataDataForm =                  List<dynamic>.empty(growable: true);
  static List<dynamic> rawDataSelectList =                List<dynamic>.empty(growable: true);
  static InDelNoteState taskState =                       InDelNoteState.default0;
  static Work work =                                      Work.incomingDeliveryNote;
  static String plateNumberTest =                         '';
  static int? getSelectedIndexDeliveryNote;
  static int? getSelectedIndexItem;

  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ButtonState buttonAdd =       ButtonState.default0;
  ButtonState buttonEdit =      ButtonState.disabled;
  ButtonState buttonRemove =    ButtonState.disabled;
  ButtonState buttonContinue =  ButtonState.disabled;
  ButtonState buttonPrint =     ButtonState.disabled;
  ButtonState buttonSave =      ButtonState.disabled;
  int? _selectedIndexDeliveryNote;
  int? _selectedIndexItem;
  
  set selectedIndexDeliveryNote(int? value) {if(buttonContinue != ButtonState.loading){
    if(value == null){
      buttonContinue =                ButtonState.disabled;
      buttonPrint =                   ButtonState.disabled;
      buttonSave =                    ButtonState.disabled;
      _selectedIndexDeliveryNote =    value;
      getSelectedIndexDeliveryNote =  _selectedIndexDeliveryNote;
    }
    else if(rawDataListDeliveryNotes[value]['kesz'].toString() != '1'){
      buttonContinue =                ButtonState.default0;
      buttonPrint =                   ButtonState.default0;
      buttonSave =                    ButtonState.default0;
      _selectedIndexDeliveryNote =    value;
      getSelectedIndexDeliveryNote =  _selectedIndexDeliveryNote;
    }
  }}
  int? get selectedIndexDeliveryNote => _selectedIndexDeliveryNote;

  set selectedIndexItem(int? value) {if(buttonContinue != ButtonState.loading){
    if(value == null){
      buttonContinue =        ButtonState.disabled;
      buttonPrint =           ButtonState.disabled;
      buttonSave =            ButtonState.disabled;
      buttonEdit =            ButtonState.disabled;
      buttonRemove =          ButtonState.disabled;
      _selectedIndexItem =    value;
      getSelectedIndexItem =  _selectedIndexItem;
    }
    else if(rawDataListItems[value]['kesz'].toString() != '1'){
      buttonContinue =        ButtonState.default0;
      buttonPrint =           ButtonState.default0;
      buttonSave =            ButtonState.default0;
      buttonEdit =            ButtonState.default0;
      buttonRemove =          ButtonState.default0;
      _selectedIndexItem =    value;
      getSelectedIndexItem =  _selectedIndexItem;
    }
  }}
  int? get selectedIndexItem => _selectedIndexItem;

  BoxDecoration customBoxDecoration = BoxDecoration(            
    border:       Border.all(color: const Color.fromARGB(130, 184, 184, 184), width: 1),
    color:        Colors.white,
    borderRadius: const BorderRadius.all(Radius.circular(8))
  );

  BoxDecoration customMandatoryBoxDecoration = BoxDecoration(            
    border:       Border.all(color: const Color.fromARGB(255, 255, 0, 0), width: 1),
    color:        const Color.fromARGB(255, 255, 230, 230),
    borderRadius: const BorderRadius.all(Radius.circular(8))
  );

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------  

  // ---------- < WidgetBuild > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context){    
    return WillPopScope(onWillPop: _handlePop, child: GestureDetector(
      //onTap:  () => setState(() => selectedIndex = null),
      child:  Scaffold(
        appBar: AppBar(
          title:            Center(child: Padding(padding: const EdgeInsets.fromLTRB(0, 0, 40, 0), child: Text((){switch(taskState){
            case InDelNoteState.addNew:                         return  'Új bizonylat';
            case InDelNoteState.listItems:                      return  'Tételek';
            case InDelNoteState.listSelectEditItemDeliveryNote:
            case InDelNoteState.listSelectAddItemDeliveryNote:  return  'Abroncsok kiválasztása';
            case InDelNoteState.addItem:                        return  'Új cikk';
            case InDelNoteState.editItem:                       return  'Cikk módosítása';
            default:                                            return  (Global.getRouteAt(2) == NextRoute.deliveryBackFromPartner)? MenuState.menuList[11]['megnevezes'].toString() : (work == Work.incomingDeliveryNote)? 'Bejövő szállítólevelek' : 'Helyszíni szerelések';
          }}()))),
          backgroundColor:  Global.getColorOfButton(ButtonState.default0),
          foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
        ),
        backgroundColor:  Colors.white,
        body:             LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              (){switch(taskState){
                case InDelNoteState.addItem:
                case InDelNoteState.addNew:                         return  _drawDataForm;
                case InDelNoteState.editItem:                       return  _drawDataForm;
                case InDelNoteState.listSelectEditItemDeliveryNote:
                case InDelNoteState.listSelectAddItemDeliveryNote:  return  _drawDataList;
                case InDelNoteState.listItems:                      return  _drawListDeliveryNotes(rawDataListItems);
                case InDelNoteState.default0:                       return  _drawListDeliveryNotes(rawDataListDeliveryNotes);
                default:                                            return  Container();
              }}(),
              _drawBottomBar
            ]);
          }
        )
      )
    ));
  }  
  
  // ---------- < Widgets [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _drawListDeliveryNotes(List<dynamic> rawData) => rawData.isNotEmpty
    ? Expanded(child: SingleChildScrollView(scrollDirection: Axis.vertical, child: 
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
          columns:            _generateColumns(rawData),
          rows:               _generateRows(rawData),
          showCheckboxColumn: false,
          border:             const TableBorder(bottom: BorderSide(color: Color.fromARGB(255, 200, 200, 200))),                
        ))
      ))
    : Container()
  ;

  Widget get _drawDataList => (rawDataSelectList[0]['tetelek'].isNotEmpty)
    ? Expanded(child: SingleChildScrollView(scrollDirection: Axis.vertical, child:
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
        columns:            _generateColumns2,
        rows:               _generateRows2,                
        showCheckboxColumn: false,                
        border:             const TableBorder(bottom: BorderSide(color: Color.fromARGB(255, 200, 200, 200))),                
      ))
    ))
    : const Expanded(child: Center(child: Text('Üres', style: TextStyle(fontSize: 20))))
  ;

  Widget get _drawDataForm{
    rawDataDataForm;
    rawDataListDeliveryNotes;
    rawDataListItems;
    rawDataSelectList;
    int maxSor() {int maxSor = 1; for(var item in rawDataDataForm) {if(item['sor'] > maxSor) maxSor = item['sor'];} return maxSor;}

    List<Widget> varListWidget = List<Widget>.empty(growable: true);
    for(int sor = 1; sor <= maxSor(); sor++) {
      List<Widget> row = List<Widget>.empty(growable: true);
      for(int i = 0; i < rawDataDataForm.length; i++) {if(rawDataDataForm[i]['sor'] == sor){
        if(rawDataDataForm[i]['visible'] == null || rawDataDataForm[i]['visible'].toString() == '1') {row.add(Padding(
          padding:  const EdgeInsets.fromLTRB(5, 5, 5, 0),
          child:    Container(
            decoration: (_isItemAcceptable(i))? customBoxDecoration : customMandatoryBoxDecoration,
            child:      Padding(padding: const EdgeInsets.all(5), child: _getWidget(rawDataDataForm[i], i))
          )
        ));}
      }}
      varListWidget.add(SizedBox(width: MediaQuery.of(context).size.width, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: row)));
    }
    return Expanded(child: SingleChildScrollView(child: Column(
      mainAxisAlignment:  MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children:           varListWidget
    )));
  }

  Widget get _drawBottomBar => Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child: (){switch(taskState){
    case InDelNoteState.default0:                       return  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: ([Work.incomingDeliveryNote, Work.localMaintenance].contains(work))
      ? [_drawButtonAdd, _drawButtonPrint, _drawButtonSave, _drawButtonContinue]
      : [_drawButtonAdd, _drawButtonPrint, _drawButtonContinue])
    ;
    case InDelNoteState.editItem:
    case InDelNoteState.addNew:                         return  Row(mainAxisAlignment: MainAxisAlignment.end, children:           [_drawButtonContinue]);
    case InDelNoteState.listItems:                      return  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:  [_drawButtonEdit, _drawButtonAdd, _drawButtonRemove]);
    case InDelNoteState.addItem:                        return  Row(mainAxisAlignment: MainAxisAlignment.end, children:           [_drawButtonContinue]);
    case InDelNoteState.listSelectEditItemDeliveryNote:
    case InDelNoteState.listSelectAddItemDeliveryNote:  return  Row(mainAxisAlignment: MainAxisAlignment.end, children:           [_drawButtonContinue]);
    default:                                            return  Container();
  }}());

  // ---------- < Buttons > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
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

  Widget get _drawButtonEdit => Padding(padding: const EdgeInsets.fromLTRB(5, 0, 5, 0), child: 
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      TextButton(
        onPressed:  () => (buttonEdit == ButtonState.default0)? _buttonEditPressed : null,
        style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
        child:      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Visibility(
            visible:  (buttonEdit == ButtonState.loading)? true : false,
            child:    Padding(
              padding:  const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child:    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonEdit)))
            )
          ),
          Icon(
            Icons.edit_document,
            color: Global.getColorOfIcon(buttonEdit),
            size:  30,
          )
        ])
      )
    ])
  );

  Widget get _drawButtonRemove => Padding(padding: const EdgeInsets.fromLTRB(5, 0, 5, 0), child: 
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      TextButton(
        onPressed:  () => (buttonRemove == ButtonState.default0)? _buttonRemovePressed : null,
        style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
        child:      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Visibility(
            visible:  (buttonRemove == ButtonState.loading)? true : false,
            child:    Padding(
              padding:  const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child:    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonRemove)))
            )
          ),
          Icon(
            Icons.delete,
            color: Global.getColorOfIcon(buttonRemove),
            size:  30,
          )
        ])
      )
    ])
  );

  Widget get _drawButtonContinue => Padding(padding: const EdgeInsets.fromLTRB(5, 0, 5, 0), child: 
    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
            (){switch(taskState){
              case InDelNoteState.addItem:
              case InDelNoteState.addNew:
              case InDelNoteState.listSelectAddItemDeliveryNote: return Icons.save_as;
              default:                                           return Icons.arrow_forward;
            }}(),
            color: Global.getColorOfIcon(buttonContinue),
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

  Widget get _drawButtonSave => TextButton(
    onPressed:  () => (buttonSave == ButtonState.default0)? _butonSavePressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
      (buttonSave == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonSave)) : Container(),
      Icon(Icons.check_box, color: Global.getColorOfIcon(buttonSave), size: 30)
    ]))
  );

  // ---------- < Widgets [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _progressIndicator(Color colorInput) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(
    width:  20,
    height: 20,
    child:  CircularProgressIndicator(color: colorInput)
  ));

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  List<DataColumn> _generateColumns(List<dynamic> rawData){
    List<DataColumn> columns = List<DataColumn>.empty(growable: true);
    for (var item in rawData[0].keys) {switch(item){
      case 'cikkszam':
      case 'sorszam':     columns.add(const DataColumn(label: Text('Azonosító')));    break;
      case 'kesz':        columns.add(const DataColumn(label: Text('')));           break;
      case 'vevo':
      case 'megnevezes':
      case 'szallito':    columns.add(const DataColumn(label: Text('Megnevezés'))); break;
      default:                                                                      break;
    }}
    return columns; 
  }

  List<DataColumn> get _generateColumns2{
    List<DataColumn> columns = List<DataColumn>.empty(growable: true);
    for(var item in rawDataSelectList[0]['oszlop']) {columns.add(DataColumn(label: Text(item['text'])));}
    return columns;
  }

  List<DataRow> get _generateRows2{
    String swap(String input) {return (input == '1')? '0' : '1';}

    List<DataRow> rows = List<DataRow>.empty(growable: true);
    for (var i = 0; i < rawDataSelectList[0]['tetelek'].length; i++) {
      rows.add(DataRow(
        onSelectChanged:  (value) => setState(() => rawDataSelectList[0]['tetelek'][i]['tarolas'] = swap(rawDataSelectList[0]['tetelek'][i]['tarolas'].toString())),
        selected:         (rawDataSelectList[0]['tetelek'][i]['tarolas'].toString() == '1'),
        cells:            _getCells2(rawDataSelectList[0]['tetelek'][i]),
      ));
    }
    return rows;
  }

  List<DataRow> _generateRows(List<dynamic> rawData){
    List<DataRow> rows = List<DataRow>.empty(growable: true);
    for (var i = 0; i < rawData.length; i++) {
      rows.add(DataRow(
        cells:            _getCells(rawData[i]),
        selected:         (taskState == InDelNoteState.default0)? (i == selectedIndexDeliveryNote) : (i == selectedIndexItem),
        onSelectChanged:  (bool? selected) => setState(() => (taskState == InDelNoteState.default0)? selectedIndexDeliveryNote = i : selectedIndexItem = i)
      )); 
    }
    return rows;
  }

  Future get _buttonAddPressed async{ switch(taskState){

    case InDelNoteState.default0:      
      await DataManager(quickCall: QuickCall.addNewDeliveryNote).beginQuickCall;
      setState((){
        buttonAdd = ButtonState.default0;
        taskState = InDelNoteState.addNew;
      });
      break;

    case InDelNoteState.listItems:      
      String? varString = (['mezandmol'].contains(DataManager.customer))? await Global.showBarcodeScanDialog(context) : await Global.plateNuberDialog(context, title: 'Adja meg a Rendszámot.', content: 'Rendszám');
      if(work == Work.incomingDeliveryNote || varString != null){
        varString ??= '';
        setState(() => buttonAdd = ButtonState.loading);
        plateNumberTest = '';
        if(Global.getRouteAt(2) == NextRoute.deliveryBackFromPartner){
          await DataManager(quickCall: QuickCall.addDeliveryNoteItem, input: {'rendszam': varString}).beginQuickCall;
          if(DataManager.dataQuickCall[17] is List && DataManager.dataQuickCall[17].isNotEmpty) {await Global.showAlertDialog(
            context,
            title:    DataManager.dataQuickCall[17][0]['name'] ?? '',
            content:  DataManager.dataQuickCall[17][0]['message'] ?? ''
          );}
          await DataManager(quickCall: QuickCall.askDeliveryNotesScan).beginQuickCall;
          setState(() => buttonAdd = ButtonState.default0);
        }
        else{
          await DataManager(quickCall: QuickCall.plateNumberCheck, input: {'rendszam': varString}).beginQuickCall;
          switch(plateNumberTest){

            case 'NOK':
              await DataManager(quickCall: QuickCall.addDeliveryNoteItem, input: {'rendszam': varString}).beginQuickCall;
              setState((){
                buttonAdd =       ButtonState.default0;
                buttonContinue =  ButtonState.disabled;
                taskState =       InDelNoteState.addItem;
              });
              break;

            case 'OK':
              await DataManager(quickCall: QuickCall.askDeliveryNotesScan).beginQuickCall;
              setState(() => buttonAdd = ButtonState.default0);
              break;

            default:
              if(plateNumberTest.isNotEmpty) await Global.showAlertDialog(context, title: 'Hiba', content: plateNumberTest);
              setState(() => buttonAdd = ButtonState.default0);
              break;
          }          
        }
      }      
      break;

    default: break;
  }}

  Future get _buttonEditPressed async{
    setState(() => buttonEdit = ButtonState.loading);
    await DataManager(quickCall: QuickCall.editSelectedItemDeliveryNote).beginQuickCall;
    setState(() {
      buttonEdit =  ButtonState.default0;
      taskState =   InDelNoteState.editItem;
    });
  }

  Future get _buttonContinuePressed async {switch(taskState){

    case InDelNoteState.default0:
      setState(() => buttonContinue = ButtonState.loading);
      await DataManager(quickCall: QuickCall.askDeliveryNotesScan).beginQuickCall;
      setState((){
        taskState =       InDelNoteState.listItems;
        buttonContinue =  ButtonState.default0;
      });
      break;

    case InDelNoteState.addNew:
      setState(() => buttonContinue = ButtonState.loading);
      await DataManager(quickCall: QuickCall.addNewDeliveryNoteFinished).beginQuickCall;
      await DataManager().beginProcess;
      setState((){
        taskState =       InDelNoteState.default0;
        buttonContinue =  ButtonState.default0;
      });
      break;

    case InDelNoteState.addItem:
      int getIndex(String id) {for(int i = 0; i < rawDataDataForm.length; i++) {if(rawDataDataForm[i]['id'].toString() == id) return i;} return 0;}
      if(rawDataDataForm[getIndex('id_209')]['value'].toString() == 'Nem'){
        setState(() => buttonContinue = ButtonState.loading);
        await DataManager(
          quickCall:  QuickCall.selectAddItemDeliveryNote,
          input:      {'id': rawDataDataForm[getIndex('id_34')]['kod'].toString()}
        ).beginQuickCall;
        /*await DataManager(quickCall: QuickCall.addItemFinished).beginQuickCall;
        await DataManager(quickCall: QuickCall.askDeliveryNotesScan).beginQuickCall;*/
        setState((){
          taskState =       InDelNoteState.listSelectAddItemDeliveryNote;
          buttonContinue =  ButtonState.default0;
        });
      }
      else{
        setState(() => buttonContinue = ButtonState.loading);
        await DataManager(
          quickCall:  QuickCall.selectAddItemDeliveryNote,
          input:      {'id': rawDataDataForm[getIndex('id_34')]['kod'].toString()}
        ).beginQuickCall;
        await DataManager(quickCall: QuickCall.finishSelectAddItemDeliveryNote).beginQuickCall;
        await DataManager(quickCall: QuickCall.askDeliveryNotesScan).beginQuickCall;
        setState((){
          taskState =       InDelNoteState.listItems;
          buttonContinue =  ButtonState.default0;
        });
      }
      break;

    case InDelNoteState.listSelectAddItemDeliveryNote:
      setState(() => buttonContinue = ButtonState.loading);
      await DataManager(quickCall: QuickCall.finishSelectAddItemDeliveryNote).beginQuickCall;
      await DataManager(quickCall: QuickCall.askDeliveryNotesScan).beginQuickCall;
      setState((){
        taskState =       InDelNoteState.listItems;
        buttonContinue =  ButtonState.default0;
      });
      break;

    case InDelNoteState.editItem:
      setState(() => buttonContinue = ButtonState.loading);
      await DataManager(quickCall: QuickCall.askEditItemDeliveryNote).beginQuickCall;
      setState((){
        taskState =       InDelNoteState.listSelectEditItemDeliveryNote;
        buttonContinue =  ButtonState.default0;
      });
      break;

    case InDelNoteState.listSelectEditItemDeliveryNote:
      setState(() => buttonContinue = ButtonState.loading);
        await DataManager(quickCall: QuickCall.finishSelectEditItemDeliveryNote).beginQuickCall;
        await DataManager(quickCall: QuickCall.askDeliveryNotesScan).beginQuickCall;
        setState((){
          taskState =       InDelNoteState.listItems;
          buttonContinue =  ButtonState.default0;
        });
      break;

    default:break;
  }}

  Future get _buttonRemovePressed async {switch(taskState){

    case InDelNoteState.listItems:
      setState(() => buttonRemove = ButtonState.loading);
      if(await Global.yesNoDialog(context,
        title:    'Tétel törlése',
        content:  'Biztosan törölni kívánja az alábbi tételt:\n(${rawDataListItems[selectedIndexItem!]['cikkszam']})'
      )){
        await DataManager(quickCall: QuickCall.removeDeliveryNoteItem, input: {'tetel_id': rawDataListItems[selectedIndexItem!]['tetel_id']}).beginQuickCall;
        await DataManager(quickCall: QuickCall.askDeliveryNotesScan).beginQuickCall;
        selectedIndexItem = null;
      }
      else {buttonRemove = ButtonState.default0;}
      setState((){});
      break;

    default: break;
  }}

  Future get _buttonPrintPressed async{
    setState(() => buttonPrint = ButtonState.loading);
    await DataManager(
      quickCall:  QuickCall.printBarcodeDeliveryNote,
      input:      (taskState == InDelNoteState.default0)
        ? {'bizonylat_id': int.parse(rawDataListDeliveryNotes[getSelectedIndexDeliveryNote!]['id'].toString())}
        : {'bizonylat_id': int.parse(rawDataListDeliveryNotes[getSelectedIndexItem!]['id'].toString())}
      ,
    ).beginQuickCall;
    setState(() => buttonPrint = ButtonState.default0);
    await Global.showAlertDialog(context, content: 'Tételek nyomtatás alatt.', title: 'Nyomtatás');
  }

  Future get _butonSavePressed async{
    setState(() => buttonSave = ButtonState.loading);
    if(await Global.yesNoDialog(context, content: 'Lezárjam a bizonylatot?', title: 'Lezárás')){
      await DataManager(
        quickCall:  QuickCall.saveDeliveryNoteItem,
        input:      (taskState == InDelNoteState.default0)
          ? {'bizonylat_id': int.parse(rawDataListDeliveryNotes[getSelectedIndexDeliveryNote!]['id'].toString())}
          : {'bizonylat_id': int.parse(rawDataListDeliveryNotes[getSelectedIndexItem!]['id'].toString())}
        ,
      ).beginQuickCall;
      await DataManager().beginProcess;
    }
    setState(() {selectedIndexItem = null; selectedIndexDeliveryNote = null;});
  }

  Future<bool>_handlePop() async{ switch(taskState){

    case InDelNoteState.addNew:
      setState(() => taskState = InDelNoteState.default0);
      return false;

    case InDelNoteState.listItems:
      setState(() {taskState = InDelNoteState.default0; selectedIndexItem = null; selectedIndexDeliveryNote = null;});
      return false;

    case InDelNoteState.addItem:
      setState(() => taskState = InDelNoteState.listItems);
      return false;

    case InDelNoteState.editItem:
      setState(() => taskState = InDelNoteState.listItems);
      return false;
    
    case InDelNoteState.listSelectAddItemDeliveryNote:
      setState(() => taskState = InDelNoteState.addItem);
      return false;

    case InDelNoteState.listSelectEditItemDeliveryNote:
      setState(() => taskState = InDelNoteState.editItem);
      return false;



    default: setState((){}); return true;
  }}

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _getWidget(dynamic input, int index){
    bool editable =           (input['editable'].toString() == '1');
    controller[index].text =  (rawDataDataForm[index]['value'] == null)? '' : rawDataDataForm[index]['value'].toString();
    double getWidth(int index) {int sorDB = 0; for(var item in rawDataDataForm) {if(item['sor'] == rawDataDataForm[index]['sor']) sorDB++;} return MediaQuery.of(context).size.width / sorDB - 22;}
    TextInputType? getKeyboard(String? keyboardType) {if(keyboardType == null) return null; switch(keyboardType){
      case 'number':  return TextInputType.number;
      default:        return null;
    }}

    switch(input['input_field']){

      case 'search':
        List<String> items =    List<String>.empty(growable: true);
        for(var item in listOfLookupDatas[input['id']]) {items.add(item['megnevezes'].toString());}
        return (items.isNotEmpty && editable)
        ? Stack(alignment: AlignmentDirectional.centerStart, children: [
            Visibility(visible: (rawDataDataForm[index]['value'] == null), child: Padding(padding: const EdgeInsets.all(10), child: Text(
              rawDataDataForm[index]['name'],
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
            labelText:      rawDataDataForm[index]['name'],
            border:         InputBorder.none,
          ),
          onChanged:  null,
        ));

      case 'select':
        bool isInLookupData(String input, List<dynamic>? list) {if(list != null)for(var item in list) {if(item['id'].toString() == input) return true;} return false;}
        String getItem(dynamic varList, String id) {for(dynamic item in varList) {if(item['id'] == id) return item['megnevezes'];} return '';}

        List<DropdownMenuItem<String>> items =  List<DropdownMenuItem<String>>.empty(growable: true);
        List<dynamic>? lookupData =             listOfLookupDatas[input['id']];
        if(lookupData != null) for(var item in lookupData) {items.add(DropdownMenuItem(value: item['id'].toString(), child: Text(item['megnevezes'] ?? item['id'], textAlign: TextAlign.start)));}
        String? selectedItem =    (isInLookupData(rawDataDataForm[index]['value'].toString(), lookupData))? rawDataDataForm[index]['value'].toString() : null;
        return (lookupData != null && lookupData.isNotEmpty && editable)
        ? Stack(children: [
          SizedBox(height: 55, width: getWidth(index), child: Padding(padding: const EdgeInsets.all(15), child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value:            selectedItem,
            hint:             Text(rawDataDataForm[index]['name'].toString(), textAlign: TextAlign.start),
            icon:             const Icon(Icons.arrow_downward),
            iconSize:         24,
            elevation:        16,
            isExpanded:       false,
            alignment:        AlignmentDirectional.centerStart,
            dropdownColor:    const Color.fromRGBO(230, 230, 230, 1),
            menuMaxHeight:    MediaQuery.of(context).size.height / 3,
            onChanged:        (String? newValue) async => await _handleSelectChange(newValue, index),
            items:            items
          )))),
          (selectedItem != null)
          ? Text(rawDataDataForm[index]['name'].toString(), style: const TextStyle(color: Colors.grey))
          : Container()
        ])
        : SizedBox(height: 55, width: getWidth(index), child: TextFormField(
          enabled:      false,
          initialValue: (selectedItem != null)? getItem(lookupData, selectedItem) : null,
          controller:   (selectedItem != null)? null : controller[index],
          decoration:   InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            labelText:      rawDataDataForm[index]['name'],
            border:         InputBorder.none,
          ),
          onChanged:  null,
        ));

      case 'number':
      case 'integer': switch(input['name']){

        case 'DOT-szám': return SizedBox(height: 55, width: getWidth(index), child: Focus(
          onFocusChange:  (value) => setState(() {rawDataDataForm[index]['value'] = controller[index].text; buttonContinue = getButton;}),
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
          onFocusChange:  (value) => setState(() {rawDataDataForm[index]['value'] = controller[index].text; _replaceCommas(index);}),
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
          onFocusChange:  (value) => setState(() {rawDataDataForm[index]['value'] = controller[index].text; _checkInteger(rawDataDataForm[index]['value'], input, index);}),
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
      /*case 'number':
      case 'integer': return SizedBox(height: 55, width: getWidth(index), child: TextFormField(
        enabled:            editable,          
        controller:         controller[index],
        onChanged:          (value) => _checkInteger(value, input, index),
        decoration:         InputDecoration(
          contentPadding:     const EdgeInsets.all(10),
          labelText:          input['name'],
          border:             InputBorder.none,
        ),
        style:        TextStyle(color: (editable)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
        keyboardType: TextInputType.number,
      ));*/

      default: return Stack(children: [
        SizedBox(height: 55, width: getWidth(index), child: TextFormField(
          enabled:          editable,
          controller:       controller[index],
          keyboardType:     getKeyboard(input['keyboard_type']),
          decoration:       InputDecoration(
            contentPadding:   const EdgeInsets.all(10),
            labelText:        input['name'],
            border:           InputBorder.none,
          ),
          onChanged:    (value) => setState(() {rawDataDataForm[index]['value'] = value; buttonContinue = getButton;}),
          style:        TextStyle(color: (editable)? const Color.fromARGB(255, 51, 51, 51) : const Color.fromARGB(255, 153, 153, 153)),
        ))
      ]);
    }
  }

  List<DataCell> _getCells(Map<String, dynamic> row){
    List<DataCell> cells = List<DataCell>.empty(growable: true);
    for (var item in row.keys) {switch(item){
      case 'cikkszam':
      case 'sorszam':
      case 'megnevezes':
      case 'szallito':
      case 'vevo':    cells.add(DataCell(Text(row[item].toString())));  break;
      case 'kesz':    cells.add(DataCell((row[item].toString() == '1')
        ? Icon(Icons.check_circle, color: Global.getColorOfButton(ButtonState.default0), size: 30)
        : Container()));                                                break;
      default:                                                          break;
    }}
    return cells;
  }

  List<DataCell> _getCells2(Map<String, dynamic> row){
    List<DataCell> cells = List<DataCell>.empty(growable: true);
    for(var item in rawDataSelectList[0]['oszlop']) {switch(item['id'].toString()){

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

  // ---------- < Methods [3] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  bool _isItemAcceptable(int index) => (rawDataDataForm[index]['mandatory'] != null && rawDataDataForm[index]['mandatory'].toString() == '1')? isValueCorrect(index) : true;

  Future _handleSelectChange(String? newValue, int index) async{
    try{
      rawDataDataForm[index]['value'] = newValue;
      if(newValue == null) {rawDataDataForm[index]['kod'] = null;}
      else {for(dynamic item in listOfLookupDatas[rawDataDataForm[index]['id']]) {if(item['megnevezes'] == newValue) rawDataDataForm[index]['kod'] = item['id'];}}
      DataManager dataManager = DataManager(quickCall: QuickCall.chainGiveDatasDeliveryNote, input: {'index': index});
      await dataManager.beginQuickCall;
    }
    catch(e){
      if(kDebugMode) print(e);
    }
    setState((){
      buttonContinue = getButton;
    });
  }

  void _checkInteger(String value, dynamic input, int index){ //Check if integer and is between 0 and limit.
    if(input['limit'] == null) {setState(() {rawDataDataForm[index]['value'] = value; buttonContinue = getButton;}); return;}
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

  void _replaceCommas(int index){
    List<String> listString = rawDataDataForm[index]['value'].toString().split('');
    for(int i = 0; i < listString.length; i++){
      if(listString[i] == ',' || listString[i] == '.'){
        listString[i] = '.';
        listString =    listString.sublist(0, i + 2);
        break;
      }
    }
    rawDataDataForm[index]['value'] = listString.join('');
  }

  // ---------- < Methods [4] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  ButtonState get getButton {switch(taskState){

    case InDelNoteState.addNew:
      return rawDataDataForm.any((item) => item['value'] != null && item['value'].toString().isNotEmpty)
        ? ButtonState.default0
        : ButtonState.disabled
      ;
    
    default:
      for(int i = 0; i < rawDataDataForm.length; i++) {if(!_isItemAcceptable(i)) return ButtonState.disabled;}
      return ButtonState.default0;
  }}

  bool isValueCorrect(int index) {switch(rawDataDataForm[index]['name']){

    case 'DOT-szám':
      try{
        bool isDotNumberWrong() => (
          int.parse(controller[index].text.substring(0,2)) < 1  ||
          int.parse(controller[index].text.substring(0,2)) > 53 ||
          int.parse(controller[index].text.substring(2)) > int.parse(DateTime.now().year.toString().substring(2))
        );
        return !(controller[index].text.length != 4 || isDotNumberWrong());
      }
      catch(e) {return false;}

     case 'Profilmélység':
      try{
        double varDouble = double.parse(rawDataDataForm[index]['value'].toString());
        if(varDouble < 0.0 || varDouble >= 15) throw Exception();
        return true;
      }
      catch(e) {return false;}

    default: return (rawDataDataForm[index]['value'] != null && rawDataDataForm[index]['value'].toString().isNotEmpty);
  }}
}