import 'package:polilakk_app/routes/route_festesre_felrakas.dart';
import 'package:polilakk_app/routes/route_elokezeles.dart';
import 'package:polilakk_app/data_manager.dart';
import 'package:polilakk_app/global.dart';
import 'package:flutter/material.dart';

class MenuFrame extends StatefulWidget {//---------- ---------- ---------- ---------- ---------- ---------- ---------- <MenuFrame>
  const MenuFrame({super.key});


  @override
  State<MenuFrame> createState() => MenuState();
}


class MenuState extends State<MenuFrame> {//---------- ---------- ---------- ---------- ---------- ---------- ---------- <MenuState>
  // ---------- [🌸 simple variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  late double _contentWidth;


  // ---------- < WidgetBuild [0] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  @override
  Widget build(BuildContext context){
    final double screenWidth = MediaQuery.sizeOf(context).width;
    _contentWidth = (screenWidth - 50).clamp(0.0, 500.0).toDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width:      double.infinity,
        height:     double.infinity,
        decoration: const BoxDecoration(image: DecorationImage(
          image:  AssetImage('images/background.png'),
          fit:    BoxFit.cover,
        )),
        child: SafeArea(child: _drawMenu),
      ),
    );
  }


  // ---------- < WidgetBuild [1] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawMenu => Center(child: SingleChildScrollView(
    padding:  const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
    child:    SizedBox(width: _contentWidth, child: Column(
      mainAxisAlignment:  MainAxisAlignment.center,
      children:           _menuWidgets,
    )),
  ));


  // ---------- < WidgetBuild [2] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  List<Widget> get _menuWidgets => [
    _drawMenuButton('Előkezelés'),
    const SizedBox(height: 12),

    _drawMenuButton('Festésre felrakás'),
    const SizedBox(height: 12),

    _drawMenuButton('Porfestés'),
    const SizedBox(height: 12),

    _drawMenuButton('Minőségellenőrzés'),
    const SizedBox(height: 12),

    _drawMenuButton('Festésről leszedés'),
    const SizedBox(height: 12),

    _drawMenuButton('Védőfóliázás'),
    const SizedBox(height: 12),

    _drawMenuButton('Görgőzés'),
  ];


  // ---------- < WidgetBuild [3] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget _drawMenuButton(String text) => SizedBox(
    width:   double.infinity,
    height:  55,
    child:   ElevatedButton(
      onPressed: switch(text) {
        'Előkezelés' =>         buttonElokezelesPressed,
        'Festésre felrakás' =>  buttonFestesreFelrakasPressed,
        _            =>         null,
      },
      style:      ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2F2587),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation:        3,
        shape:            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text, style: const TextStyle(
        fontSize:    18,
        fontWeight:  FontWeight.w600,
      )),
    ),
  );

  // ---------- < Methods [1] > --------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Future<void> buttonElokezelesPressed() async{
    RouteElokezelesState.rawData = await DataManager(appAction: AppAction.callElokezeles).beginCall;
    Global.routeNext =  AppAction.routeElokezeles;
    await Navigator.pushNamed(context, '/menu/elokezeles');
  }

  Future<void> buttonFestesreFelrakasPressed() async{
    RouteFestesreFelrakasState.rawData = await DataManager(appAction: AppAction.callFestesreFelrakas).beginCall;
    Global.routeNext =  AppAction.routeFestesreFelrakas;
    await Navigator.pushNamed(context, '/menu/festesre_felrakas');
  }
}