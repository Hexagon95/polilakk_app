import 'package:polilakk_app/global.dart';
import 'package:polilakk_app/routes/log_in.dart';
import 'package:polilakk_app/routes/menu.dart';
import 'package:polilakk_app/routes/route_elokezeles.dart';
import 'package:polilakk_app/routes/route_festesre_felrakas.dart';
import 'package:flutter/material.dart';

void main() async{
  Global.routeNext = AppAction.routeLogIn;
  runApp(MaterialApp(
    initialRoute: '/',
    routes:       {
      '/':                        (context) =>  const LogInMenuFrame(),
      '/menu':                    (context) =>  const MenuFrame(),
      '/menu/elokezeles':         (context) =>  const RouteElokezeles(),
      '/menu/festesre_felrakas':  (context) =>  const RouteFestesreFelrakas()
    }
  ));
}