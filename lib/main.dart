import 'package:flutter/material.dart';
import 'package:polilakk_app/routes/route_festesrol_leszedes.dart';
import 'package:polilakk_app/routes/route_minosegellenorzes.dart';
import 'package:polilakk_app/routes/route_festesre_felrakas.dart';
import 'package:polilakk_app/routes/route_elokezeles.dart';
import 'package:polilakk_app/routes/route_porfestes.dart';
import 'package:polilakk_app/routes/log_in.dart';
import 'package:polilakk_app/routes/menu.dart';
import 'package:polilakk_app/global.dart';

void main() async{
  Global.routeNext = AppAction.routeLogIn;
  runApp(MaterialApp(
    initialRoute: '/',
    routes:       {
      '/':                        (context) =>  const LogInMenuFrame(),
      '/menu':                    (context) =>  const MenuFrame(),
      '/menu/elokezeles':         (context) =>  const RouteElokezeles(),
      '/menu/festesre_felrakas':  (context) =>  const RouteFestesreFelrakas(),
      '/menu/porfestes':          (context) =>  const RoutePorfestes(),
      '/menu/minosegellenorzes':  (context) =>  const RouteMinosegellenorzes(),
      '/menu/festesrol_leszedes': (context) =>  const RouteFestesrolLeszedes()
    }
  ));
}