import 'package:flutter/material.dart';
import 'package:polilakk_app/routes/log_in.dart';
import 'package:polilakk_app/data_manager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();  
  runApp(
    MaterialApp(      
      initialRoute:   '/',
      routes: {
        '/':  (context) => const LogInMenuFrame(),
      },
    )
  );
  await DataManager.identitySQLite;
}