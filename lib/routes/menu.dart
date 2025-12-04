// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:logistic_app/global.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:logistic_app/routes/incoming_deliverynote.dart';
import 'package:logistic_app/routes/log_in.dart';
import 'package:logistic_app/routes/scan_check_stock.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

class Menu extends StatefulWidget{ //----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <Menu>
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  const Menu({super.key});

  @override
  State<Menu> createState() => MenuState();
}

class MenuState extends State<Menu>{ //--------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <LogInMenuState>
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  static List<dynamic> menuList =         List<dynamic>.empty();
  static String email =                   '';
  static String errorMessageBottomLine =  '';
  
  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  MainMenuState mainMenuState =               MainMenuState.default0;
  ButtonState buttonPickUpList =              ButtonState.default0;
  ButtonState buttonDeliveryOut =             ButtonState.default0;
  ButtonState buttonDeliveryBackFromPartner = ButtonState.default0;
  ButtonState buttonIncomingDeliveryNote =    ButtonState.default0;
  ButtonState buttonLocalMaintenance =        ButtonState.default0;
  ButtonState buttonListOrdersOut =           ButtonState.default0;
  ButtonState buttonListOrders =              ButtonState.default0;
  ButtonState buttonDeliveryNote =            ButtonState.default0;
  ButtonState buttonRevenue =                 ButtonState.disabled;
  ButtonState buttonScanAndPrint =            ButtonState.default0;
  ButtonState buttonCheckStock =              ButtonState.default0;
  ButtonState buttonStockIn =                 ButtonState.default0;
  ButtonState buttonInventory =               ButtonState.default0;
  ButtonState buttonDone =                    ButtonState.disabled;
  late double _width;
  BoxDecoration customBoxDecoration =       BoxDecoration(            
    border:       Border.all(color: const Color.fromARGB(130, 184, 184, 184), width: 1),
    color:        Colors.white,
    borderRadius: const BorderRadius.all(Radius.circular(8))
  );
  String get title {switch(mainMenuState){
    case MainMenuState.editPassword:  return 'Adatok';
    default:                          return DataManager.raktarMegnevezes;
  }}
  Map<String,TextEditingController> controller = {
    'password_1': TextEditingController(),
    'password_2': TextEditingController()
  };

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  MenuState(){
    Global.routeNext =  NextRoute.logIn;
  }

  // ---------- < WidgetBuild [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
   Widget build(BuildContext context){
    _width = MediaQuery.of(context).size.width - 50;
    if(_width > 400) _width = 400;
    return WillPopScope(
      onWillPop:  _handlePop,
      child:      Scaffold(
        appBar:     AppBar(
          title:            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(),
            Text(title),
            PopupMenuButton(
              itemBuilder:  (context) => <PopupMenuEntry<int>>[
                PopupMenuItem(
                  value:      1,
                  child:      Row(children:[
                    Icon(Icons.edit, color: Global.getColorOfButton(ButtonState.default0),),
                    Text('Jelszó módosítása', style: TextStyle(color: Global.getColorOfButton(ButtonState.default0)))
                  ])
                ),
                PopupMenuItem(
                  value:      0,
                  child:      Row(children:[
                    Icon(Icons.logout, color: Global.getColorOfButton(ButtonState.default0),),
                    Text('Kijelentkezés', style: TextStyle(color: Global.getColorOfButton(ButtonState.default0)))
                  ])
                ),
              ],
              enabled:    (mainMenuState == MainMenuState.default0),
              onSelected: handlePopUpMenu,
              child:      Icon(Icons.menu, color: Global.getColorOfIcon((mainMenuState == MainMenuState.default0)? ButtonState.default0 : ButtonState.disabled)),
            )
          ]),
          backgroundColor:  Global.getColorOfButton(ButtonState.default0),
          foregroundColor:  Global.getColorOfIcon(ButtonState.default0),
        ),
        backgroundColor:    Colors.white,
        body:               (){switch(mainMenuState){
          case MainMenuState.editPassword:  return _drawChangePassword;
          default:                          return _drawMenu;
        }}(),
      )
    );
  }

  // ---------- < WidgetBuild [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawMenu {
    Widget filter(int id, Widget menuOption) {for(var item in menuList) {if(item['id'] == id && item['aktiv'] == 1) return menuOption;} return Container();}
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // allows smooth scroll
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight( // 🔥 will compress content if overflow would happen
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    filter(7,   _drawButtonListOrdersOut),
                    filter(1,   _drawButtonPickUpList),
                    filter(2,   _drawButtonListOrders),
                    filter(8,   _drawDeliveryOut),
                    filter(9,   _drawButtonIncomingDeliveryNote(9)),
                    filter(10,  _drawButtonIncomingDeliveryNote(10)),
                    filter(12,  _drawButtonIncomingDeliveryNote(12)),
                    const SizedBox(height: 20),
                    filter(11,  _drawButtonScanAndPrint),
                    filter(3,   _drawButtonDeliveryNote),
                    filter(4,   _drawButtonCheckStock),
                    filter(5,   _drawButtonStockIn),
                    filter(6,   _drawButtonInventory),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget get _drawChangePassword => Stack(children: [
    Container(
      decoration: const BoxDecoration(image: DecorationImage(
          image:  AssetImage('images/background.png'),
          fit:    BoxFit.fitHeight
        )),
    ),
    Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      SingleChildScrollView(child:Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(padding: const EdgeInsets.all(10),child: Container(height: 55, decoration: customBoxDecoration, child: TextFormField(
          controller:   controller['password_1'],
          onChanged:    (value) => setState(() => buttonDone = _setButtonDone),
          obscureText:  true,
          decoration:   const InputDecoration(
            contentPadding: EdgeInsets.all(10),
            labelText:      'Jelszó',
            border:         InputBorder.none,
          ),
          style:        const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
        ))),
        Padding(padding: const EdgeInsets.all(10),child: Container(height: 55, decoration: customBoxDecoration, child: TextFormField(
          controller:   controller['password_2'],
          obscureText:  true,
          onChanged:    (value) => setState(() => buttonDone = _setButtonDone),
          decoration:   const InputDecoration(
            contentPadding: EdgeInsets.all(10),
            labelText:      'Jelszó mégegyszer',
            border:         InputBorder.none,
          ),
          style:        const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
        ))),
        const Padding(padding: EdgeInsets.all(5),child: Divider()),
        Padding(padding: const EdgeInsets.all(10),child: Container(height: 55, decoration: customBoxDecoration, child: TextFormField(
          enabled:      false,
          initialValue: email,
          decoration:   const InputDecoration(
            contentPadding: EdgeInsets.all(10),
            labelText:      'E-mail',
            border:         InputBorder.none,
          ),
          style:        const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
        )))
      ])),
      _drawBottomBar
    ])
  ]);

  // ---------- < WidgetBuild [2]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawBottomBar => Container(height: 50, color: Global.getColorOfButton(ButtonState.default0), child:
    Row(mainAxisAlignment: MainAxisAlignment.end, children:  [_drawButtonDone])
  );

  Widget get _drawButtonPickUpList => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(
        side:            MaterialStateProperty.all(BorderSide(color: Global.getColorOfIcon(buttonPickUpList))),
        backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonPickUpList))
      ),
      onPressed:  (buttonPickUpList == ButtonState.default0)? () => _buttonPickUpListPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonPickUpList == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonPickUpList))))
        ),
        Text((buttonPickUpList == ButtonState.loading)? 'Betöltés...' : menuList[0]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonPickUpList)))
      ])
    ))
  );

  Widget get _drawDeliveryOut => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(
        side:            MaterialStateProperty.all(BorderSide(color: Global.getColorOfIcon(buttonDeliveryOut))),
        backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonDeliveryOut))
      ),
      onPressed:  (buttonDeliveryOut == ButtonState.default0)? () => _buttonDeliveryOutPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonDeliveryOut == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonDeliveryOut))))
        ),
        Text((buttonDeliveryOut == ButtonState.loading)? 'Betöltés...' : menuList[7]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonDeliveryOut)))
      ])
    ))
  );

  /*Widget get _drawDeliveryBackFromPartner => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(
        side:            MaterialStateProperty.all(BorderSide(color: Global.getColorOfIcon(buttonDeliveryBackFromPartner))),
        backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonDeliveryBackFromPartner))
      ),
      onPressed:  (buttonDeliveryBackFromPartner == ButtonState.default0)? () => _buttonDeliveryBackFromPartnerPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonDeliveryBackFromPartner == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonDeliveryBackFromPartner))))
        ),
        Text((buttonDeliveryBackFromPartner == ButtonState.loading)? 'Betöltés...' : menuList[11]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonDeliveryBackFromPartner)))
      ])
    ))
  );*/

  Widget _drawButtonIncomingDeliveryNote(int menuNumber){

    ButtonState getButton(int menuNumber) {switch(menuNumber){
      case 9:   return buttonLocalMaintenance;
      case 10:  return buttonIncomingDeliveryNote;
      case 12:  return buttonDeliveryBackFromPartner;
      default:  throw Exception('Menu item not implemented yet!');
    }}
    return Padding(
      padding:  const EdgeInsets.symmetric(vertical: 10),
      child:    SizedBox(height: 40, width: _width, child: TextButton(          
        style:      ButtonStyle(
          side:            MaterialStateProperty.all(BorderSide(color: Global.getColorOfIcon(getButton(menuNumber)))),
          backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(getButton(menuNumber)))
        ),
        onPressed:  (getButton(menuNumber) == ButtonState.default0)? () => _buttonIncomingDeliveryNotePressed(menuNumber) : null,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Visibility(
            visible:  (getButton(menuNumber) == ButtonState.loading)? true : false,
            child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(getButton(menuNumber)))))
          ),
          Text((getButton(menuNumber) == ButtonState.loading)? 'Betöltés...' : menuList[menuNumber - 1]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(getButton(menuNumber))))
        ])
      ))
    );
  }

  Widget get _drawButtonListOrdersOut => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(
        side:            MaterialStateProperty.all(BorderSide(color: Global.getColorOfIcon(buttonListOrders))),
        backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonListOrdersOut))
      ),
      onPressed:  (buttonListOrdersOut == ButtonState.default0)? () => _buttonListOrdersOutPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonListOrdersOut == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonListOrdersOut))))
        ),
        Text((buttonListOrdersOut == ButtonState.loading)? 'Betöltés...' : menuList[6]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonListOrdersOut)))
      ])
    ))
  );

  Widget get _drawButtonListOrders => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(
        side:            MaterialStateProperty.all(BorderSide(color: Global.getColorOfIcon(buttonListOrders))),
        backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonListOrders))
      ),
      onPressed:  (buttonListOrders == ButtonState.default0)? () => _buttonListOrdersPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonListOrders == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonListOrders))))
        ),
        Text((buttonListOrders == ButtonState.loading)? 'Betöltés...' : menuList[1]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonListOrders)))
      ])
    ))
  );

  Widget get _drawButtonDeliveryNote => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(
        side:            MaterialStateProperty.all(BorderSide(color: Global.getColorOfIcon(buttonDeliveryNote))),
        backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonDeliveryNote))
      ),
      onPressed:  (buttonDeliveryNote == ButtonState.default0)? () => _buttonDeliveryNotePressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonDeliveryNote == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonDeliveryNote))))
        ),
        Text((buttonDeliveryNote == ButtonState.loading)? 'Betöltés...' : menuList[2]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonDeliveryNote)))
      ])
    ))
  );  

  /*Widget get _drawButtonRevenue => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(
      style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonRevenue))),
      onPressed:  (buttonRevenue == ButtonState.default0)? () => _buttonRevenuePressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonRevenue == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonRevenue))))
        ),
        Text((buttonRevenue == ButtonState.loading)? 'Betöltés...' : 'Bevételezés', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonRevenue)))
      ])
    ))
  );*/

  Widget get _drawButtonScanAndPrint => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(
        side:            MaterialStateProperty.all(BorderSide(color: Global.getColorOfIcon(buttonScanAndPrint))),
        backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonScanAndPrint))
      ),
      onPressed:  (buttonScanAndPrint == ButtonState.default0)? () => _buttonScanAndPrintPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonScanAndPrint == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonScanAndPrint))))
        ),
        Text((buttonScanAndPrint == ButtonState.loading)? 'Betöltés...' : menuList[10]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonScanAndPrint)))
      ])
    ))
  );

  Widget get _drawButtonCheckStock => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(
        side:            MaterialStateProperty.all(BorderSide(color: Global.getColorOfIcon(buttonCheckStock))),
        backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonCheckStock))
      ),
      onPressed:  (buttonCheckStock == ButtonState.default0)? () => _buttonCheckStockPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonCheckStock == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonCheckStock))))
        ),
        Text((buttonCheckStock == ButtonState.loading)? 'Betöltés...' : menuList[3]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonCheckStock)))
      ])
    ))
  );

  Widget get _drawButtonStockIn => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(
        side:            MaterialStateProperty.all(BorderSide(color: Global.getColorOfIcon(buttonStockIn))),
        backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonStockIn))
      ),
      onPressed:  (buttonStockIn == ButtonState.default0)? () => _buttonStockInPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonStockIn == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonStockIn))))
        ),
        Text((buttonStockIn == ButtonState.loading)? 'Betöltés...' : menuList[4]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonStockIn)))
      ])
    ))
  );

  Widget get _drawButtonInventory => Padding(
    padding:  const EdgeInsets.symmetric(vertical: 10),
    child:    SizedBox(height: 40, width: _width, child: TextButton(          
      style:      ButtonStyle(
        side:            MaterialStateProperty.all(BorderSide(color: Global.getColorOfIcon(buttonInventory))),
        backgroundColor: MaterialStateProperty.all(Global.getColorOfButton(buttonInventory))
      ),
      onPressed:  (buttonInventory == ButtonState.default0)? () => _buttonInventoryPressed : null,          
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible:  (buttonInventory == ButtonState.loading)? true : false,
          child:    Padding(padding: const EdgeInsets.fromLTRB(0, 0, 10, 0), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Global.getColorOfIcon(buttonInventory))))
        ),
        Text((buttonInventory == ButtonState.loading)? 'Betöltés...' : menuList[5]['megnevezes'], style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonInventory)))
      ])
    ))
  );
    
  // ---------- < WidgetBuild [3]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget get _drawButtonDone => TextButton(
    onPressed:  () async => (buttonDone == ButtonState.default0)? await _buttonDonePressed : null,
    style:      ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
    child:      Padding(padding: const EdgeInsets.all(5), child: Row(children: [
      (buttonDone == ButtonState.loading)? _progressIndicator(Global.getColorOfIcon(buttonDone)) : Container(),
      Text(' Mentés ', style: TextStyle(fontSize: 18, color: Global.getColorOfIcon(buttonDone))),
      Icon(Icons.save, color: Global.getColorOfIcon(buttonDone), size: 30)
    ]))
  );

  // ---------- < WidgetBuild [4]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Widget _progressIndicator(Color colorInput) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: SizedBox(
    width:  20,
    height: 20,
    child:  CircularProgressIndicator(color: colorInput)
  ));

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future get _buttonPickUpListPressed async{
    setState(() => buttonPickUpList = ButtonState.loading);
    await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
    if(LogInMenuState.updateNeeded) Restart.restartApp();
    Global.routeNext =        NextRoute.pickUpList;
    DataManager dataManager = DataManager();
    await dataManager.beginProcess;
    buttonPickUpList =        ButtonState.default0;
    await Navigator.pushNamed(context, '/listOrders');
    setState((){});
  }

  Future get _buttonDeliveryOutPressed async{
    setState(() => buttonPickUpList = ButtonState.loading);
    await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
    if(LogInMenuState.updateNeeded) Restart.restartApp();
    Global.routeNext =        NextRoute.deliveryOut;
    await DataManager().beginProcess;
    buttonPickUpList =        ButtonState.default0;
    await Navigator.pushNamed(context, '/listOrders');
    setState((){});
  }   

  Future _buttonIncomingDeliveryNotePressed(int menuNumber) async{
    if(menuNumber == 12) {await _buttonDeliveryBackFromPartnerPressed; return;}
    switch(menuNumber){
      case 9:   setState(() => buttonLocalMaintenance = ButtonState.loading);     break;
      default:  setState(() => buttonIncomingDeliveryNote = ButtonState.loading); break;
    }
    IncomingDeliveryNoteState.work =      (menuNumber == 9)? Work.localMaintenance : Work.incomingDeliveryNote;
    await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
    if(LogInMenuState.updateNeeded) Restart.restartApp();
    Global.routeNext =                    NextRoute.incomingDeliveryNote;
    await DataManager().beginProcess;
    buttonLocalMaintenance =              ButtonState.default0;
    buttonIncomingDeliveryNote =          ButtonState.default0;
    IncomingDeliveryNoteState.taskState = InDelNoteState.default0;
    await Navigator.pushNamed(context, '/incomingDeliveryNote');
    setState((){});
  }

  Future get _buttonListOrdersOutPressed async{
    setState(() => buttonListOrdersOut = ButtonState.loading);
    await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
    if(LogInMenuState.updateNeeded) Restart.restartApp();
    Global.routeNext =        NextRoute.orderOutList;
    DataManager dataManager = DataManager();
    await dataManager.beginProcess;
    buttonListOrdersOut =     ButtonState.default0;
    await Navigator.pushNamed(context, '/listOrders');
    setState((){});
  }

  Future get _buttonListOrdersPressed async{
    setState(() => buttonListOrders = ButtonState.loading);
    await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
    if(LogInMenuState.updateNeeded) Restart.restartApp();
    Global.routeNext =        NextRoute.orderList;
    DataManager dataManager = DataManager();
    await dataManager.beginProcess;
    buttonListOrders =        ButtonState.default0;
    await Navigator.pushNamed(context, '/listOrders');
    setState((){});
  }

  Future get _buttonDeliveryNotePressed async{
    buttonDeliveryNote =      ButtonState.loading;
    Global.routeNext =        NextRoute.deliveryNoteList;
    setState((){});
    await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
    if(LogInMenuState.updateNeeded) Restart.restartApp();
    DataManager dataManager = DataManager();
    await dataManager.beginProcess;
    buttonDeliveryNote =      ButtonState.default0;
    if(DataManager.isServerAvailable){
      await Navigator.pushNamed(context, '/listDeliveryNote');
      setState((){});
    }
  }

  Future get _buttonCheckStockPressed async{
    setState(() => buttonCheckStock = ButtonState.loading);
    await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
    if(LogInMenuState.updateNeeded) Restart.restartApp();
    Global.routeNext =                NextRoute.checkStock;
    buttonCheckStock =                ButtonState.default0;
    ScanCheckStockState.stockState =  StockState.checkStock;
    await Navigator.pushNamed(context, '/scanCheckStock');
    setState((){});
  }

  Future get _buttonScanAndPrintPressed async{
    setState(() => buttonScanAndPrint = ButtonState.loading);
    await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
    if(LogInMenuState.updateNeeded) Restart.restartApp();
    Global.routeNext =                NextRoute.scanAndPrint;
    buttonScanAndPrint =              ButtonState.default0;
    await Navigator.pushNamed(context, '/scanAndPrint');
    setState((){});
  }

  Future get _buttonStockInPressed async{
    setState(() => buttonStockIn = ButtonState.loading);
    await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
    if(LogInMenuState.updateNeeded) Restart.restartApp();
    Global.routeNext =                NextRoute.checkStock;
    buttonStockIn =                   ButtonState.default0;
    ScanCheckStockState.stockState =  StockState.stockIn;
    await Navigator.pushNamed(context, '/scanCheckStock');
    setState((){});
  }

  Future get _buttonInventoryPressed async{
    setState(() => buttonInventory = ButtonState.loading);
    await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
    if(LogInMenuState.updateNeeded) Restart.restartApp();
    if(await _isInventoryDate){
      Global.routeNext =  NextRoute.inventory;
      buttonInventory =   ButtonState.default0;
      await Navigator.pushNamed(context, '/scanInventory');
      setState((){});
    }
    else{
      setState(() => buttonInventory = ButtonState.default0);
      await Global.showAlertDialog(context,
        title:    "Leltár hiba",
        content:  "A main napra nincs kiírva leltár."
      );
    }
  }

  Future get _buttonDonePressed async{
    setState(() => buttonDone = ButtonState.loading);
    if(controller['password_1']!.text != controller['password_2']!.text){
      await Global.showAlertDialog(context, content: 'A megadott két jelszó nem egyezik!', title: 'Nem egyező jelszavak!');
      setState(() => buttonDone = ButtonState.disabled);
      return;
    }
    await DataManager(quickCall: QuickCall.changePassword, input: {'password': controller['password_1']!.text}).beginQuickCall;
    buttonDone = ButtonState.disabled;
    _handlePop();
  }

  void handlePopUpMenu(int value) {switch(value){
    case 1: setState(() => mainMenuState = MainMenuState.editPassword); return;
    case 0: _handlePop();                                               return;
    default:                                                            return;
  }}

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future get _buttonDeliveryBackFromPartnerPressed async{
    setState(() => buttonDeliveryBackFromPartner = ButtonState.loading);
      await DataManager(quickCall: QuickCall.verzio).beginQuickCall;
      if(LogInMenuState.updateNeeded) Restart.restartApp();
    Global.routeNext = NextRoute.deliveryBackFromPartner;
    await DataManager().beginProcess;
    buttonDeliveryBackFromPartner = ButtonState.default0;
    await Navigator.pushNamed(context, '/incomingDeliveryNote');
    setState((){});
  }

  Future<bool> get _isInventoryDate async{
    DataManager dataManager = DataManager(quickCall: QuickCall.askInventoryDate);
    await dataManager.beginQuickCall;
    return (DataManager.dataQuickCall[3][0]['leltar_van'] != null);
  }

  Future<bool> _handlePop() async{
    if(mainMenuState != MainMenuState.default0) {setState(() => mainMenuState = MainMenuState.default0); resetControllers; return false;}
    if(await Global.yesNoDialog(context, title: 'Kijelentkezés', content: 'Ki kíván jelentkezni a LogisticApp-ból?')) {Restart.restartApp();}
    return false;
  }

  ButtonState get _setButtonDone {for(String key in controller.keys) {if(controller[key]!.text.isEmpty) return ButtonState.disabled;} return ButtonState.default0;}

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
  void get resetControllers {buttonDone = ButtonState.disabled; controller = {
    'password_1': TextEditingController(),
    'password_2': TextEditingController()
  };}
}