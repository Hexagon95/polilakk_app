// ignore_for_file: prefer_final_fields

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/scanner_datawedge.dart';
// ---------- < Enums > --- ---------- ---------- ---------- ----------
enum AppAction{
  routeLogIn, routeMenu, routeItemFrame,
  callLogInSecondTime, callElokezeles, callFinishElokezeles, callTermelesKosar, callFinishTermelsKosar,
  default0, 
}
enum ButtonState{hidden, loading, disabled, error, default0}

class Global{
  // ---------- < Variables [Static] > - ---------- ---------- ----------
  static List<AppAction> _routes =            List<AppAction>.empty(growable: true);
  static AppAction get currentRoute =>        _routes.last;
  static AppAction? getRouteAt(int input) =>  (_routes.length > input && input >= 0)? _routes[input] : null;
  static AppAction get previousRoute =>       (_routes.length >= 2)? _routes[_routes.length - 2] : _routes.first;
  static void get routeBack                   {_routes.removeLast(); _printRoutes;}
  static set routeNext (AppAction value){
    int check(int i)  {while(_routes.length > i){_routes.removeLast();} while(_routes.length <= i){_routes.add(AppAction.default0);} return i; }
    switch (value) {
      case AppAction.routeLogIn:                       _routes[check(0)] =   value;  break;
      case AppAction.routeMenu:                        _routes[check(1)] =   value;  break;
      case AppAction.routeItemFrame:                   _routes[check(2)] =   value;  break;
      default:  throw Exception('Default rout has been thrown!!!!');
    }
    _printRoutes;
  }
  static bool isScannerDevice = false;

  // ---------- < SQL Commands > ------- ---------- ---------- ----------
  static const String sqlCreateTableIdentity = "CREATE TABLE identityTable(id INTEGER PRIMARY KEY, identity TEXT)";
  
  // ---------- < Global Dialogs > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  static Future showAlertDialog(BuildContext context, {String title = 'Figyelmeztetés', required String content}) async{
    
    Widget okButton = TextButton(
      child: const Text('Ok'),
      onPressed: () => Navigator.pop(context, true)
    );

    AlertDialog infoRegistry = AlertDialog(
      title:    Text(title,   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      content:  Text(content, style: const TextStyle(fontSize: 12)),
      actions:  [okButton]
    ); 

    return await showDialog(
      context: context,
      builder: (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  }

  static Future<bool> yesNoDialog(BuildContext context, {String title = '', String content = '', List<String> options = const ['Igen', 'Nem']}) async{
    Widget leftButton = TextButton(
      child: Text(options[0]),
      onPressed: () => Navigator.pop(context, true)
    );
    Widget rightButton = TextButton(
      child: Text(options[1]),
      onPressed: () => Navigator.pop(context, false)
    );

    AlertDialog infoRegistry = AlertDialog(
      title:    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      content:  Text(content, style: const TextStyle(fontSize: 12)),
      actions:  [leftButton, rightButton]
    );

    return await showDialog(
      context: context,
      builder: (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  }  

  /// Example: `Global.integerDialog(context, title: 'Darabszám', content: 'Adja meg:', max: 100, extraButtons: [{'text': 'Nem találom az anyagot', 'icon': Icons.search_off, 'isConfirm': true}]);`
  static Future<int?> integerDialog(
    BuildContext context, {
    String title = '',
    String content = '',
    int? max,
    List<Map<String, dynamic>>? extraButtons,
  }) async{
    int? varInt;
    BoxDecoration customBoxDecoration = BoxDecoration(
      border: Border.all(color: const Color.fromARGB(130, 184, 184, 184), width: 1),
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    );
    Widget okButton = TextButton(
      child: const Text('Ok'),
      onPressed: (){
        if(varInt != null){
          Navigator.pop(context, varInt);
        }
      },
    );
    Widget cancel = TextButton(
      child: const Text('Mégsem'),
      onPressed: () => Navigator.pop(context, null),
    );
    List<Widget> specialButtons = [
      for(int i = 0; i < (extraButtons?.length ?? 0); i++)
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFFFFFF),
            backgroundColor: const Color(0xFF2F2587),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async{
            Map<String, dynamic> button = extraButtons[i];
            if(button['isConfirm'] == true){
              bool confirm = await yesNoDialog(
                context,
                title: '⚠️ Megerősítés',
                content: button['text'],
              );
              if(!confirm) return;
            }
            if(context.mounted){
              Navigator.pop(context, -(i + 1));
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if(extraButtons![i]['icon'] != null) ...[
                Icon(extraButtons[i]['icon'], size: 20),
                const SizedBox(width: 6),
              ],
              Text(extraButtons[i]['text']),
            ],
          ),
        ),
    ];
    AlertDialog infoRegistry = AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Container(
        height: 55,
        decoration: customBoxDecoration,
        child: TextFormField(
          autofocus: true,
          onChanged: (value) => varInt = int.tryParse(value),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            TextInputFormatter.withFunction((oldValue, newValue){
              if(newValue.text.isEmpty) return newValue;
              int? value = int.tryParse(newValue.text);
              if(value == null || value <= 0) return oldValue;
              if(max != null && value > max) return oldValue;
              return newValue;
            }),
          ],
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            labelText: content,
            border: InputBorder.none,
          ),
          style: const TextStyle(
            color: Color.fromARGB(255, 51, 51, 51),
          ),
          keyboardType: TextInputType.number,
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if(specialButtons.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: specialButtons,
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  okButton,
                  cancel,
                ],
              ),
            ],
          ),
        ),
      ],
    );
    return await showDialog(
      context: context,
      builder: (BuildContext context) => infoRegistry,
      barrierDismissible: false,
    );
  }

  static Future<List<Map<String, dynamic>>?> selectItemsFromListDialog(
    BuildContext context, {
    String title = '',
    required List<Map<String, dynamic>> items,
    Map<String, Widget Function(dynamic value)>? design,
  }) async{
    Set<int> selectedIndexes = {};
    return await showDialog<List<Map<String, dynamic>>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return StatefulBuilder(
          builder: (context, setState){
            return AlertDialog(
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index){
                    Map<String, dynamic> item = items[index];
                    bool selected = selectedIndexes.contains(index);
                    return InkWell(
                      onTap: (){
                        setState((){
                          if(selected){
                            selectedIndexes.remove(index);
                          }
                          else{
                            selectedIndexes.add(index);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0x182F2587) : Colors.white,
                          border: Border.all(
                            color: selected ? const Color(0xFF2F2587) : const Color.fromARGB(130, 184, 184, 184),
                            width: 1,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: selected,
                              onChanged: (_){
                                setState((){
                                  if(selected){
                                    selectedIndexes.remove(index);
                                  }
                                  else{
                                    selectedIndexes.add(index);
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for(MapEntry<String, dynamic> entry in item.entries)
                                    design?[entry.key] != null
                                      ? design![entry.key]!(entry.value)
                                      : Text(
                                          '${entry.key}: ${entry.value}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(255, 51, 51, 51),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: selectedIndexes.isEmpty
                    ? null
                    : (){
                        List<Map<String, dynamic>> selectedItems = [
                          for(int i = 0; i < items.length; i++)
                            if(selectedIndexes.contains(i))
                              items[i],
                        ];
                        Navigator.pop(context, selectedItems);
                      },
                  child: const Text('Ok'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Mégsem'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /*static Future<int?> integerDialog(BuildContext context, {String title = '', String content = ''}) async{
    int? varInt;
    BoxDecoration customBoxDecoration = BoxDecoration(
      border:       Border.all(color: const Color.fromARGB(130, 184, 184, 184), width: 1),
      color:        Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(8))
    );
    Widget okButton = TextButton(child: const Text('Ok'), onPressed: () => Navigator.pop(context, varInt));
    Widget cancel =   TextButton(child: const Text('Mégsem'), onPressed: () => Navigator.pop(context, null));
    AlertDialog infoRegistry = AlertDialog(
      title:    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      content:  Container(height: 55, decoration: customBoxDecoration, child: TextFormField(
        autofocus:       true,
        onChanged:       (value) => varInt = int.tryParse(value),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration:      InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          labelText:      content,
          border:         InputBorder.none,
        ),
        style:        const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
        keyboardType: TextInputType.number,
      )),
      actions: [okButton, cancel]
    );
    return await showDialog(
      context:            context,
      builder:            (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  }*/

  static Future<String?> plateNuberDialog(BuildContext context, {String title = '', String content = ''}) async{
    // --------- < Variables > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    String? varString;
    BoxDecoration customBoxDecoration =       BoxDecoration(            
      border:       Border.all(color: const Color.fromARGB(130, 184, 184, 184), width: 1),
      color:        Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(8))
    );

    // --------- < Widgets [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    Widget okButton = TextButton(child: const Text('Ok'),     onPressed: () => Navigator.pop(context, varString));
    Widget cancel =   TextButton(child: const Text('Mégsem'), onPressed: () => Navigator.pop(context, null));

    // --------- < Methods [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //

    // --------- < Display > - ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    AlertDialog infoRegistry = AlertDialog(
      title:    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      content:  Container(height: 55, decoration: customBoxDecoration, child: TextFormField(
        onChanged:    (value) => varString = value,
        decoration:   InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          labelText:      content,
          border:         InputBorder.none,
        ),
        style:        const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
      )),
      actions:  [okButton, cancel]
    );

    // --------- < Return > ---- -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    return await showDialog(
      context:            context,
      builder:            (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  }

  static Future<void> readOnlyFormDialog(BuildContext context, {required List<dynamic> rawData, required Map<String, dynamic> lookupDatas, String title = 'Információ'}) async {
    // --------- < Variables > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    final ScrollController scrollController = ScrollController();
    final Color primaryColor = Colors.blue.shade700;

    BoxDecoration customBoxDecoration = BoxDecoration(
      border: Border.all(
        color: primaryColor.withOpacity(0.40),
        width: 1,
      ),
      color: primaryColor.withOpacity(0.06),
      borderRadius: const BorderRadius.all(
        Radius.circular(8),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );

    // --------- < Methods [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    bool isVisible(dynamic item) =>
        item['visible'] == null || item['visible'].toString() == '1';

    int getMaxRow() {
      int maxRow = 1;

      for (dynamic item in rawData) {
        final int? row = int.tryParse(
          item['sor']?.toString() ?? '',
        );

        if (row != null && row > maxRow) {
          maxRow = row;
        }
      }

      return maxRow;
    }

    String getDisplayValue(dynamic item) {
      final String value = item['value']?.toString() ?? '';
      if (!['select', 'search'].contains(item['input_field'])) {return value;}
      final List<dynamic>? lookupData = lookupDatas[item['id'].toString()];
      if (lookupData == null) {return value;}
      for (final lookupItem in lookupData) {
        final String id = lookupItem['id']?.toString() ?? '';
        final String name =lookupItem['megnevezes']?.toString() ?? id;
        if (id == value || name == value) {return name;}
      }
      return value;
    }

    // --------- < Widgets [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    Widget drawReadOnlyField(dynamic item) => Container(
          decoration: customBoxDecoration,
          child: TextFormField(
            initialValue: getDisplayValue(item),
            readOnly: true,
            enableInteractiveSelection: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              labelText: item['name']?.toString() ?? '',
              labelStyle: TextStyle(
                color: primaryColor,
                fontSize: 11,
              ),
              floatingLabelStyle: TextStyle(
                color: primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
            ),
            style: const TextStyle(
              color: Color.fromARGB(255, 40, 40, 40),
              fontSize: 14,
            ),
            maxLines: null,
          ),
        );

    List<Widget> drawFields() {
      List<Widget> fields = List<Widget>.empty(
        growable: true,
      );

      if (rawData.isEmpty) {
        return [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Nincs megjeleníthető adat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
              ),
            ),
          ),
        ];
      }

      if (rawData.first['sor'] == null) {
        for (dynamic item in rawData) {
          if (isVisible(item)) {
            fields.add(
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 4,
                ),
                child: drawReadOnlyField(item),
              ),
            );
          }
        }

        return fields;
      }

      for (
        int rowIndex = 1;
        rowIndex <= getMaxRow();
        rowIndex++
      ) {
        List<dynamic> rowItems = rawData
            .where(
              (item) =>
                  item['sor']?.toString() ==
                      rowIndex.toString() &&
                  isVisible(item),
            )
            .toList();

        if (rowItems.isEmpty) continue;

        fields.add(
          Padding(
            padding: const EdgeInsets.only(
              bottom: 4,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (
                  int i = 0;
                  i < rowItems.length;
                  i++
                ) ...[
                  Expanded(
                    child: drawReadOnlyField(
                      rowItems[i],
                    ),
                  ),
                  if (i < rowItems.length - 1)
                    const SizedBox(width: 4),
                ],
              ],
            ),
          ),
        );
      }

      return fields;
    }

    // --------- < Widgets [2] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    Widget okButton = TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text(
        'Ok',
        style: TextStyle(
          fontSize: 13,
        ),
      ),
    );

    // --------- < Display > ------------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    AlertDialog infoRegistry = AlertDialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      titlePadding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        6,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        16,
        6,
        10,
        4,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        8,
        0,
        8,
        4,
      ),
      title: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: primaryColor,
            size: 20,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 700,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height *
                    0.70,
          ),
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 6,
            radius: const Radius.circular(10),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: drawFields(),
              ),
            ),
          ),
        ),
      ),
      actions: [okButton],
    );

    // --------- < Return > ------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    await showDialog(
      context: context,
      builder: (BuildContext context) =>
          infoRegistry,
      barrierDismissible: false,
    );

    scrollController.dispose();
  }

  static Future<dynamic> logInDialog(BuildContext context, {String? userNameInput}) async{
    // --------- < Variables > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    String userName =                     (kDebugMode)? 'mosaic'  : (userNameInput != null)? userNameInput : '';
    String userPassword =                 (kDebugMode)? 'mos.667' : '';
    bool isTextObscure =                  true;
    ButtonState buttonForgottenPassword = ButtonState.default0;
    BoxDecoration customBoxDecoration =       BoxDecoration(            
      border:       Border.all(color: const Color.fromARGB(130, 184, 184, 184), width: 1),
      color:        Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(8))
    );

    // --------- < Widgets [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    Widget okButton = TextButton(child: const Text('Ok'),     onPressed: () => Navigator.pop(context, {'userName': userName, 'userPassword': userPassword, 'buttonState': buttonForgottenPassword}));
    Widget cancel =   TextButton(child: const Text('Mégsem'), onPressed: () => Navigator.pop(context, null));

    // --------- < Methods [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    
    // --------- < Display [2] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    Widget drawContent() => StatefulBuilder(builder: (context, setState) => SingleChildScrollView(child: Column(children: (buttonForgottenPassword != ButtonState.loading)
    ?[
      Container(height: 55, decoration: customBoxDecoration, child: TextFormField(
        initialValue: userName,
        onChanged:    (value) => userName = value,
        decoration:   const InputDecoration(
          contentPadding: EdgeInsets.all(10),
          labelText:      'Felhasználónév',
          border:         InputBorder.none,
        ),
        style:        const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
      )),
      const SizedBox(height: 4),
      Container(height: 65, decoration: customBoxDecoration, child: TextFormField(
        onChanged:    (value) => userPassword = value,
        obscureText:  isTextObscure,
        decoration:   InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          labelText:      'Jelszó',
          border:         InputBorder.none,
          suffix:         TextButton(
            onPressed:  () => setState(() => isTextObscure = !isTextObscure),
            child:      Icon(
              Icons.remove_red_eye,
              size:   26,
              color:  (isTextObscure)? Global.getColorOfButton(ButtonState.default0) : Global.getColorOfButton(ButtonState.disabled),
            )
          )
        ),
        style:        const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
      )),
      Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        TextButton(
          onPressed:  () => setState(() => buttonForgottenPassword = ButtonState.loading),
          child:      const Text('Elfelejtett jelszó', style: TextStyle(decoration: TextDecoration.underline)),
        )
      ])
    ]
    : [
      const Text('Elfelejtette jelszavát?', style: TextStyle(fontWeight: FontWeight.bold)),
      const Text('Kérjük adja meg regisztrált felhasználói nevét'),
      Container(height: 55, decoration: customBoxDecoration, child: TextFormField(
        initialValue: userName,
        onChanged:    (value) => userName = value,
        decoration:   const InputDecoration(
          contentPadding: EdgeInsets.all(10),
          labelText:      'Felhasználónév',
          border:         InputBorder.none,
        ),
        style:        const TextStyle(color: Color.fromARGB(255, 51, 51, 51)),
      )),
      const SizedBox(height: 4),
    ])));

    // --------- < Display [1] > -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    AlertDialog infoRegistry = AlertDialog(
      title:    const Text('Bejelentkezés', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      content:  drawContent(),
      actions:  [okButton, cancel]
    );

    // --------- < Return > ---- -------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
    return await showDialog(
      context:            context,
      builder:            (BuildContext context) => infoRegistry,
      barrierDismissible: false
    );
  }
  
  static Future<String?> showBarcodeScanDialog(BuildContext context) async{
    final AudioPlayer player = AudioPlayer();
    final TextEditingController manualController = TextEditingController();
    bool manualMode = false;
    BuildContext? activeDialogContext;
    final tempScannerDatawedge = ScannerDatawedge(
      scannerDatas: ValueNotifier(ScannerDatas(scanData: '')),
      profileName: 'BarcodeDialog',
    );
    listener(){
      if(manualMode) return;
      final value = tempScannerDatawedge.scannerDatas.value.scanData.trim();
      if(value.isNotEmpty && activeDialogContext != null){
        player.play(AssetSource('sounds/okay.mp3'));
        Navigator.of(activeDialogContext!).pop(value);
      }
    }
    tempScannerDatawedge.scannerDatas.addListener(listener);
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext){
        activeDialogContext = dialogContext;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState){
            return AlertDialog(
              titlePadding:   const EdgeInsets.all(16),
              contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Row(children: [
                Icon(
                  manualMode? Icons.keyboard : Icons.qr_code_scanner,
                  color: Global.getColorOfButton(ButtonState.default0)
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  manualMode? 'Vonalkód kézi megadása' : 'Vonalkód leolvasása',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )),
              ]),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                if(!manualMode) ...[
                  Icon(
                    Icons.barcode_reader,
                    size: 100,
                    color: Global.getColorOfButton(ButtonState.default0),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Kérem olvasson le egy terméket eszközével',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]
                else ...[
                  TextFormField(
                    controller:       manualController,
                    autofocus:        true,
                    keyboardType:     TextInputType.number,
                    inputFormatters:  [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText:  'Vonalkód',
                      border:     OutlineInputBorder(),
                      prefixIcon: Icon(Icons.keyboard),
                    ),
                    onFieldSubmitted: (value){
                      final String manualValue = value.trim();
                      if(manualValue.isNotEmpty) Navigator.of(dialogContext).pop(manualValue);
                    },
                  ),
                ]
              ]),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                IconButton(
                  tooltip: manualMode? 'Szkenner' : 'Kézi megadás',
                  onPressed: (){
                    FocusManager.instance.primaryFocus?.unfocus();
                    setDialogState((){
                      manualMode = !manualMode;
                      manualController.clear();
                    });
                  },
                  icon: Icon(manualMode? Icons.qr_code_scanner : Icons.keyboard),
                ),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  if(manualMode) TextButton(
                    onPressed: (){
                      final String manualValue = manualController.text.trim();
                      if(manualValue.isNotEmpty) Navigator.of(dialogContext).pop(manualValue);
                    },
                    child: const Text('Ok'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(null),
                    child: const Text('Mégse'),
                  ),
                ])
              ],
            );
          }
        );
      },
    );
    tempScannerDatawedge.scannerDatas.removeListener(listener);
    await player.dispose();
    return result;
  }

  static Future<String?> textInputDialog(BuildContext context, {String title = '', String content = ''}) async{
    String? value;
    Widget okButton = TextButton(
      child: const Text('Ok'),
      onPressed: () => Navigator.pop(context, value),
    );
    Widget cancelButton = TextButton(
      child: const Text('Mégsem'),
      onPressed: () => Navigator.pop(context, null),
    );
    AlertDialog dialog = AlertDialog(
      title: Text(title, style: const TextStyle(
        fontSize:    14,
        fontWeight:  FontWeight.bold,
      )),
      content: TextFormField(
        autofocus: true,
        onChanged:  (input) => value = input,
        decoration: InputDecoration(
          labelText: content,
          border:    const OutlineInputBorder(),
        ),
      ),
      actions: [okButton, cancelButton],
    );
    return await showDialog<String>(
      context:            context,
      barrierDismissible: false,
      builder:            (context) => dialog,
    );
  }
  

  // ---------- < Global Methods > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  static Color invertColor(Color input) => Color.fromRGBO((input.red - 255).abs(), (input.green - 255).abs(), (input.blue - 255).abs(), 1.0);

  static Map<ButtonState, Color> customColor = {
    ButtonState.default0: const Color.fromRGBO(0, 180, 125, 1.0),
    ButtonState.disabled: const Color.fromRGBO(75, 255, 200, 1.0),
    ButtonState.loading:  const Color.fromRGBO(0, 225, 0, 1.0),
    ButtonState.hidden:   Colors.transparent,
    ButtonState.error:    Colors.red
  };
  static Color getColorOfButton(ButtonState buttonState) => customColor[buttonState]!;

  static Color getColorOfIcon(ButtonState buttonState){    
    switch(buttonState){
      case ButtonState.default0:  return Colors.white;
      case ButtonState.disabled:  return const Color.fromRGBO(0, 0, 0, 0.3);
      case ButtonState.loading:   return const Color.fromRGBO(255, 255, 0, 1.0);
      case ButtonState.hidden:    return Colors.transparent;
      default:                    return Colors.red;
    }
  }

  static List<String> filterSearchResults({required List<String> input, String query = ''}) {    
    List<String> items = List<String>.empty(growable: true);
    items.addAll([...input]);    
    if(query.isNotEmpty){      
      for (var i = 0; i < items.length; i++) {
        if(!items[i].toString().toUpperCase().contains(query.toUpperCase())){
          items.removeAt(i);
          i--;
        }        
      }
    }
    return items;
  }
  
  static List<DataRow> filterSearchResultsRows({required List<DataRow> input, String query = ''}) {    
    List<DataRow> items = List<DataRow>.empty(growable: true);
    items.addAll([...input]);    
    if(query.isNotEmpty){      
      for (var i = 0; i < items.length; i++) {
        if(!items[i].cells[0].child.toString().toUpperCase().contains(query.toUpperCase())){
          items.removeAt(i);
          i--;
        }        
      }
    }
    return items;
  }

  static dynamic where(List<dynamic> input, String entry, String value) {for(dynamic item in input){
    if(item[entry] == value) return item;
  }}

  static String getErtek(List<dynamic> input, String entry, String value){
    for(dynamic item in input){
      if(item[entry] == value && item['ertek'] != null) return item['ertek'];
    }
    return '';
  }

  static String? getStringOrNullFromString(String value){
    if(['NULL', 'Null', 'null'].contains(value)) return null;
    return value;
  }

  static int getIntBoolFromString(String value) {switch(value){
    case '':
    case ' ':
    case 'FALSE':
    case 'False':
    case 'false':
    case '0':     return 0;
    default:      return 1;
  }}

  // ---------- < Methods [1] > -------- ---------- ---------- ----------
  static void get _printRoutes{
    String varString = 'IIIII: ';
    for (var item in _routes) {varString += '$item, ';}
    if(kDebugMode)print(varString);
  }
}
