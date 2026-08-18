import 'package:polilakk_app/global.dart';
import 'package:polilakk_app/routes/log_in.dart';
import 'package:polilakk_app/routes/menu.dart';
import 'package:polilakk_app/routes/item_frame.dart';
import 'package:flutter/material.dart';

void main() async{
  Global.routeNext = AppAction.routeLogIn;
  runApp(MaterialApp(
    initialRoute: '/',
    routes:       {
      '/':                (context) =>  const LogInMenuFrame(),
      '/menu':            (context) =>  const MenuFrame(),
      '/menu/item_frame': (context) =>  const ItemFrame()
    }
  ));
}