import 'package:polilakk_app/data_manager.dart';
import 'package:polilakk_app/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LogInMenuFrame extends StatefulWidget {//------ ---------- ---------- ---------- ---------- ---------- ---------- <LogInMenuFrame>
  const LogInMenuFrame({super.key});

  @override
  State<LogInMenuFrame> createState() => LogInMenuState();
}

class LogInMenuState extends State<LogInMenuFrame> {//---------- ---------- ---------- ---------- ---------- ---------- <LogInMenuState>
  // ---------- [🌸 simple variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  late double _contentWidth;

  // ---------- < WidgetBuild [0] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    _contentWidth = (screenWidth - 50).clamp(0.0, 400.0).toDouble();
    return PopScope(canPop: false, child: Scaffold(backgroundColor: Colors.white, body: Container(
      width:      double.infinity,
      height:     double.infinity,
      decoration: const BoxDecoration(image:  DecorationImage(
        image:  AssetImage('images/background.png'),
        fit:    BoxFit.cover,
      )),
      child: SafeArea(child: _drawLogInMenu),
    )));
  }

  // ---------- < WidgetBuild [1] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawLogInMenu => Center(child: SingleChildScrollView(
    padding:  const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
    child:    SizedBox(width: _contentWidth, child: Column(
      mainAxisAlignment:  MainAxisAlignment.center,
      children:           _logInWidgets,
    )),
  ));

  // ---------- < WidgetBuild [2] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  List<Widget> get _logInWidgets => [
    _drawLogo,
    const SizedBox(height: 30),
    _drawVerzio,
    const SizedBox(height: 40),
    _drawLogInButton,
  ];

  // ---------- < WidgetBuild [3] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawLogo => Container(
    decoration:   const BoxDecoration(boxShadow: [BoxShadow(
      color:        Color.fromARGB(100, 0, 0, 0),
      blurRadius:   15,
      spreadRadius: 2,
      offset:       Offset(0, 10),
    )]),
    child: Image.asset('images/image.png', 
      width:        _contentWidth,
      fit:          BoxFit.contain,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => const Text('Polilakk',
        textAlign:  TextAlign.center,
        style:      TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 47, 37, 135)),
      )
    ),
  );  

  Widget get _drawVerzio => Column(children: [
    Text('v${DataManager.thisVersion}${(DataManager.verzioTest == 0)? '' : '   [Teszt: ${DataManager.verzioTest.toString()}]'}', style: TextStyle(color: Global.getColorOfButton(ButtonState.default0), fontSize: 26, fontWeight: FontWeight.bold)),
  ]);

  Widget get _drawLogInButton => SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
    onPressed:  _logInPressed,
    style:      ElevatedButton.styleFrom(
      backgroundColor: const Color.fromRGBO(47, 37, 135, 1),
      foregroundColor: Colors.white,
      elevation:        2,
      shape:            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6),),
    ),
    child:      const Text('Bejelentkezés', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
  ));

  // ---------- < Methods [1] > --------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Future _logInPressed() async{
    dynamic result = await Global.logInDialog(context);
    if(kDebugMode) print(result.toString());
    Global.routeNext = AppAction.routeMenu;
    await Navigator.pushNamed(context, '/menu');
  }
}