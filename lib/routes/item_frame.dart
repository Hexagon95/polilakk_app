import 'package:polilakk_app/src/scanner_datawedge.dart';
import 'package:polilakk_app/data_manager.dart';
import 'package:polilakk_app/global.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ItemFrame extends StatefulWidget {//---------- ---------- ---------- ---------- ---------- ---------- ---------- <ItemFrame>
  const ItemFrame({super.key});


  @override
  State<ItemFrame> createState() => ItemState();
}


enum Work{packageIdScan, basketIdScan, basketItemPlacement, default0}
class ItemState extends State<ItemFrame> {//---------- ---------- ---------- ---------- ---------- ---------- ---------- <ItemState>
  // ---------- [⚡️ static variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  static List<dynamic> rawData = [];

  // ---------- [🌸 simple variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  bool scanOngoing =  false;
  ValueNotifier<ScannerDatas>? scannerDatas;
  ScannerDatawedge? scannerDatawedge;
  late double _contentWidth;
  String? basketID;

  // ---------- [💎 complex variables] -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  int _index = 0; int get index => _index; set index(int value){
    if(value < 0 || value >= rawData.length) return;
    _index = value;
  }
  Work _work = Work.default0; Work get work => _work; void setWork() {_work = switch(work){
    Work.packageIdScan =>       Work.basketIdScan,
    Work.basketIdScan =>        Work.basketItemPlacement,
    Work.basketItemPlacement => Work.packageIdScan,
    _ =>                        Work.default0
  };}
  String get _workMessage => switch(work){
    Work.packageIdScan =>       'Olvassa be a csomag QR kódját!',
    Work.basketIdScan =>        'Olvassa be a kosáron lévő QR kódot!',
    Work.basketItemPlacement => 'Helyezze a kosárba az anyagokat!',
    _ =>                        '⚠️ A Munkalap üres!',
  };

  // ---------- < WidgetBuild [0] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  @override
  Widget build(BuildContext context){
    final double screenWidth = MediaQuery.sizeOf(context).width;
    _contentWidth = (screenWidth - 30).clamp(0.0, 600.0).toDouble();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async{if(didPop) return; await handlePop();},
      child: Scaffold(
        backgroundColor:  const Color(0xFFF5F5F5),
        appBar: AppBar(
          title:            const Text('Előkezeléshez kosár összeállítás', style: TextStyle(fontSize: 18)),
          backgroundColor: const Color(0xFF2F2587),
          foregroundColor: const Color(0xFFFFFFFF),
        ),
        body: Container(
          width:      double.infinity,
          height:     double.infinity,
          decoration: const BoxDecoration(image: DecorationImage(
            image:  AssetImage('images/background.png'),
            fit:    BoxFit.cover,
          )),
          child: SafeArea(child: Stack(children: [_drawContent, _drawWorkMessage])),
        ),
        bottomNavigationBar: _drawBottomBar,
      )
    );
  }


  // ---------- < WidgetBuild [1] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawContent => Center(child: Padding(
    padding:  const EdgeInsets.all(10),
    child:    SizedBox(width: _contentWidth, child: Column(
      children: _widgets,
    )),
  ));

  Widget get _drawWorkMessage => Align(
    alignment: Alignment.topCenter,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding:     const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color:        const Color(0x33000000),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.info_outline, color: Color(0xFFFFFFFF), size: 24),
          const SizedBox(width: 10),
          Flexible(child: Text(
            _workMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color:       Color(0xFFFFFFFF),
              fontSize:    16,
              fontWeight:  FontWeight.w600,
            ),
          )),
        ]),
      ),
    ),
  );

  Widget get _drawBottomBar => SafeArea(child: Container(
    padding:     const EdgeInsets.fromLTRB(12, 10, 12, 10),
    decoration:  const BoxDecoration(
      color:      Color(0xFFFFFFFF),
      boxShadow:  [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, -3))],
    ),
    child: Row(children: [
      for(final button in switch(work){
        Work.packageIdScan       => [_drawButtonSkip, _drawButtonNotFound],
        Work.basketIdScan        => [_drawButtonEnterBasketID],
        Work.basketItemPlacement => [_drawButtonPlacementComplete],
        _                        => <Widget>[],
      }) Expanded(child: Padding(
        padding:  const EdgeInsets.symmetric(horizontal: 5),
        child:    button,
      )),
    ]),
  ));

  // ---------- < WidgetBuild [1][Buttons] > ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawButtonSkip => _drawBottomButton(
    text:     'QR kód nem olvasható',
    icon:     Icons.qr_code_scanner,
    onPressed: buttonQrNotReadablePressed,
  );

  Widget get _drawButtonNotFound => _drawBottomButton(
    text:     'Nem találom az anyagot',
    icon:     Icons.search_off,
    onPressed: buttonMaterialNotFoundPressed,
  );

  Widget get _drawButtonEnterBasketID => _drawBottomButton(
    text:     'Megadás billentyűzettel',
    icon:     Icons.keyboard,
    onPressed: buttonEnterBasketIDPressed,
  );

  Widget get _drawButtonPlacementComplete => _drawBottomButton(
    text:     'Kosárba helyeztem',
    icon:     Icons.done,
    onPressed: buttonPlacementCompletePressed,
  );

  // ---------- < WidgetBuild [2] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  List<Widget> get _widgets => [
    Expanded(child: _drawPicture),
    const SizedBox(height: 10),
    _drawInformation,
  ];

  Widget _drawBottomButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) => SizedBox(
    height: 58,
    child: OutlinedButton.icon(
      onPressed:  onPressed,
      icon:       Icon(icon, size: 23),
      label:      Text(text,
        textAlign: TextAlign.center,
        style:     const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2F2587),
        backgroundColor: const Color(0xFFF8F7FF),
        side:            const BorderSide(color: Color(0xFF2F2587), width: 1.5),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding:         const EdgeInsets.symmetric(horizontal: 10),
      ),
    ),
  );

  // ---------- < WidgetBuild [3] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawPicture => Container(
    width:      double.infinity,
    padding:    const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color:        const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(10),
      boxShadow:    const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3))],
    ),
    child: Image.network(
      rawData[index]['picture'] ?? '',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_not_supported_outlined, size: 40, color: Color(0xFF999999)),
          SizedBox(height: 5),
          Text('A kép nem elérhető', style: TextStyle(color: Color(0xFF777777))),
        ],
      )),
    ),
  );

  Widget get _drawInformation => Container(
    width:   double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color:        const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(10),
      boxShadow:    const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3))],
    ),
    child: Column(children: [
      _drawMainInformation,
      const Divider(height: 18),
      Row(children: [
        Expanded(child: _drawMainValue('MENNYISÉG', '${rawData[index]['mennyiseg'] ?? '-'} db')),
        const SizedBox(width: 15),
        Expanded(child: _drawMainValue('CSOMAG AZONOSÍTÓ', _value('package_id'))),
      ]),
    ]),
  );

  // ---------- < WidgetBuild [4] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawMainInformation => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('RENDELÉS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF888888))),
    const SizedBox(height: 4),
    Text(_value('rendeles'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4444CC))),
    const SizedBox(height: 10),
    Row(children: [
      Expanded(child: _drawMainValue('CIKKSZÁM', _value('cikkszam'))),
      const SizedBox(width: 15),
      Expanded(child: _drawMainValue('SZÍN',     _value('szin'))),
    ]),
  ]);    

  // ---------- < WidgetBuild [5] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget _drawMainValue(String title, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF888888))),
      const SizedBox(height: 3),
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
    ],
  );  

  // ---------- < Methods [1] > --------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Future<void> buttonQrNotReadablePressed() async => setState(() => setWork());  

  @override
  void initState(){
    super.initState();
    if(rawData.isNotEmpty) {_work = Work.packageIdScan;}
    scannerDatas =      ValueNotifier(ScannerDatas(scanData: ''));
    scannerDatawedge =  ScannerDatawedge(
      scannerDatas: scannerDatas!,
      profileName:  'PolilakkItemFrame',
    );
    scannerDatas!.addListener(_triggerScan);
  }  

  String _value(String key){
    dynamic value = rawData[index][key];
    if(value == null || value.toString().trim().isEmpty) return '-';
    return value.toString();
  }  

  Future<void> buttonMaterialNotFoundPressed() async{
    if(await Global.yesNoDialog(context,
      title:    '⚠️ Anyag Kihagyása!',
      content:  'Kívánja kihagyni a jelenlegi anyagot:\n${rawData[index]['rendeles'].toString()}',
      options:  const ['Igen', 'Mégsem']
    )) {setState(() => index++);}
  }

  Future<void> buttonEnterBasketIDPressed() async{
    basketID = await Global.textInputDialog(context, title:   'ℹ️ Kosár azonosító', content: 'Adja meg a kosár azonosítóját:');
    if(basketID != null) setState(() => setWork());
  }

  Future<void> buttonPlacementCompletePressed() async{
    stamp();
    if(await finalCheck()) return;
    setState(() {index++; setWork();});
  }

  @override
  void dispose(){
    scannerDatas?.removeListener(_triggerScan);
    scannerDatawedge?.dispose();
    scannerDatas?.dispose();

    super.dispose();
  }

  Future<void> handlePop() async{
    if(await Global.yesNoDialog(
      context,
      title:    '⚠️ Kilépés',
      content:  'Félbe kívánja szakítani az Előkezelést?',
      options:  const ['Igen', 'Mégsem'],
    )){
      await DataManager(
        appAction:  AppAction.callFinishElokezeles,
        input:      {'data': rawData.where((item) => item['ok'] == 1).toList()}
      ).beginCall;
      Global.routeBack;
      if(mounted) Navigator.pop(context);
    }
  }

  // ---------- < Methods [2] > --------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Future<void> _triggerScan() async{if(scanOngoing) return; scanOngoing = true;
    try {switch(work){

      case Work.packageIdScan:
        String scanData = scannerDatas!.value.scanData.trim();
        if(rawData[index]['package_id'].toString() == scanData){
          AudioPlayer().play(AssetSource('sounds/okay.mp3'));
          setState(() => setWork());
        }
        else{
          AudioPlayer().play(AssetSource('sounds/error.mp3'));
          await Global.showAlertDialog(context, title: '⚠️ Helytelen kód!', content: 'Helytelen kódot olvasott le!');
        }
        break;

      case Work.basketIdScan:
        basketID = scannerDatas!.value.scanData.trim();
        AudioPlayer().play(AssetSource('sounds/okay.mp3'));
        setState(() => setWork());
        break;

      default: break;
    }}
    catch(e){
      if(kDebugMode) debugPrint('Scanner error: $e');
    }
    finally{
      scanOngoing = false;
    }
  }

  void stamp() {rawData[index] = {
    ...rawData[index],
    'ok':         1,
    'kosar_id':   basketID,
    'time_stamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    'user_id':    DataManager.userID
  }; basketID = null;}

  Future<bool> finalCheck() async{
    if(index != rawData.length - 1) return false;
    await DataManager(
      appAction:  AppAction.callFinishElokezeles,
      input:      {'data': rawData.where((item) => item['ok'] == 1).toList()}
    ).beginCall;
    await Global.showAlertDialog(context,
      title:    'ℹ️ Előkezelés befejezve!',
      content:  'Nincs több teendő!'
    );
    Global.routeBack;
    if(mounted) Navigator.pop(context);
    return true;
  }

  // ---------- < Methods [3] > --------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
}