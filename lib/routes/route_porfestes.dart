import 'package:polilakk_app/src/scanner_datawedge.dart';
import 'package:polilakk_app/data_manager.dart';
import 'package:polilakk_app/global.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RoutePorfestes extends StatefulWidget {//---------- ---------- ---------- ---------- ---------- ---------- ---------- <RoutePorfestes>
  const RoutePorfestes({super.key});

  @override
  State<RoutePorfestes> createState() => RoutePorfestesState();
}

class RoutePorfestesState extends State<RoutePorfestes> {//---------- ---------- ---------- ---------- ---------- ---------- ---------- <RoutePorfestesState>
  // ---------- [⚡️ static variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  static List<dynamic> rawData = [];

  // ---------- [🌸 simple variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  late double _contentWidth;

  // ---------- < WidgetBuild [0] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  @override
  Widget build(BuildContext context){
    final double screenWidth = MediaQuery.sizeOf(context).width;
    _contentWidth = (screenWidth - 10).clamp(0.0, 600.0).toDouble();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async{
        if(didPop) return;
        await handlePop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title:            const Text('Porfestés', style: TextStyle(fontSize: 18)),
          backgroundColor: const Color(0xFF2F2587),
          foregroundColor: const Color(0xFFFFFFFF),
        ),
        body: Container(
          width:  double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit:   BoxFit.cover,
          )),
          child: SafeArea(child: Stack(children: [
            _drawContent,
            _drawWorkMessage,
          ])),
        ),
      ),
    );
  }

  // ---------- < WidgetBuild [1] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawContent => Center(child: SizedBox(
    width: _contentWidth,
    child: rawData.isEmpty
    ? const Center(child: Text(
        'Nincs porfestésre váró gerenda.',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ))
    : ListView.separated(
        padding: const EdgeInsets.fromLTRB(10, 85, 10, 20),
        itemCount: rawData.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _drawGerendaCard(rawData[index]),
      ),
  ));

  Widget get _drawWorkMessage => Align(
    alignment: Alignment.topCenter,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding:     const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color:        const Color(0x80000000),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFFFFFFFF),
            size:  24,
          ),
          SizedBox(width: 10),
          Flexible(child: Text(
            'Válasszon ki egy gerendát porfestésre',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:      Color(0xFFFFFFFF),
              fontSize:   16,
              fontWeight: FontWeight.w600,
            ),
          )),
        ]),
      ),
    ),
  );

  // ---------- < WidgetBuild [2] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget _drawGerendaCard(dynamic item){
    bool isPainting = item['festes_alatt']?.toString() == '1';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isPainting ? null : () => selectGerenda(item),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width:    double.infinity,
          padding:  const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:        isPainting ? const Color(0xFFEAF8EE) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPainting ? const Color(0xFF33AA55) : const Color(0x22000000),
              width: isPainting ? 1.5 : 1,
            ),
            boxShadow: const [BoxShadow(
              color:      Color(0x33000000),
              blurRadius: 8,
              offset:     Offset(0, 3),
            )],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width:  50,
                height: 50,
                decoration: BoxDecoration(
                  color:        isPainting ? const Color(0x1A229944) : const Color(0x142F2587),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.view_stream_outlined,
                  size:  28,
                  color: isPainting ? const Color(0xFF229944) : const Color(0xFF2F2587),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(
                      'Gerenda: ${_displayValue(item['gerenda_id'])}',
                      style: TextStyle(
                        fontSize:   17,
                        fontWeight: FontWeight.bold,
                        color:      isPainting ? const Color(0xFF228844) : const Color(0xFF2F2587),
                      ),
                    )),
                    if(isPainting)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color:        const Color(0xFF33AA55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.autorenew, color: Colors.white, size: 15),
                          SizedBox(width: 4),
                          Text(
                            'Festés alatt',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ]),
                      ),
                  ]),
                  const SizedBox(height: 10),
                  _drawCardValue(
                    Icons.palette_outlined,
                    'Szín',
                    item['szin'],
                    isPainting,
                  ),
                  const SizedBox(height: 7),
                  _drawCardValue(
                    Icons.qr_code_2,
                    'Por kód',
                    item['porkod'],
                    isPainting,
                  ),
                ],
              )),
              if(!isPainting) ...[
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: Icon(Icons.chevron_right, color: Color(0xFF777777), size: 26),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawCardValue(IconData icon, String title, dynamic value, bool isPainting) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        size:  17,
        color: isPainting ? const Color(0xFF229944) : const Color(0xFF777777),
      ),
      const SizedBox(width: 6),
      Expanded(child: Text(
        '$title: ${_displayValue(value)}',
        style: TextStyle(
          fontSize:   13,
          fontWeight: FontWeight.w500,
          color:      isPainting ? const Color(0xFF228844) : const Color(0xFF555555),
        ),
      )),
    ],
  );

  // ---------- < Methods [1] > --------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  String _displayValue(dynamic value){
    if(value == null || value.toString().trim().isEmpty) return '-';
    return value.toString();
  }

  Future<void> selectGerenda(dynamic item) async{
    if(item['festes_alatt']?.toString() == '1') return;
    String? scannedCode = await _porfestesScanDialog(item);
    if(scannedCode == null || scannedCode.isEmpty) return;
    if(!mounted) return;
    setState((){
      item['festes_alatt'] = 1;
      item['time_stamp'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      item['user_id'] = DataManager.userID;
    });
    await DataManager(appAction: AppAction.callFinishPorfestes, input: {'data': rawData}).beginCall;
    rawData = await DataManager(appAction: AppAction.callPorfestes).beginCall;
    setState((){});
  }

  Future<String?> _porfestesScanDialog(dynamic item) async{
    final ValueNotifier<ScannerDatas> scannerDatas = ValueNotifier(ScannerDatas(scanData: ''));
    final ScannerDatawedge scannerDatawedge = ScannerDatawedge(
      scannerDatas: scannerDatas,
      profileName:  'Dialog',
    );
    String? result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        titlePadding:   const EdgeInsets.fromLTRB(18, 18, 18, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          const Icon(Icons.qr_code_scanner, color: Color(0xFF2F2587)),
          const SizedBox(width: 10),
          Expanded(child: Text(
            'Porfestés - Gerenda ${_displayValue(item['gerenda_id'])}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          )),
        ]),
        content: ValueListenableBuilder<ScannerDatas>(
          valueListenable: scannerDatas,
          builder: (context, scanData, child){
            String scannedText = scanData.scanData.trim();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.qr_code_2,
                  size:  90,
                  color: Color(0xFF2F2587),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Olvassa be a porfestéshez tartozó QR kódot!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color:        scannedText.isEmpty ? const Color(0xFFF2F2F2) : const Color(0xFFEAF8EE),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: scannedText.isEmpty ? const Color(0x22000000) : const Color(0x5533AA55),
                    ),
                  ),
                  child: scannedText.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 7),
                      child: Text(
                        'Nincs beolvasott kód',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF999999), fontSize: 13),
                      ),
                    )
                  : Row(children: [
                      const Icon(Icons.check_circle, color: Color(0xFF229944), size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(
                        scannedText,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF228844)),
                      )),
                      IconButton(
                        onPressed: () => scannerDatas.value = ScannerDatas(scanData: ''),
                        icon: const Icon(Icons.close, color: Color(0xFFCC3333)),
                        tooltip: 'Beolvasás törlése',
                      ),
                    ]),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width:  double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: scannedText.isEmpty ? null : () => Navigator.pop(dialogContext, scannedText),
                    icon: const Icon(Icons.play_arrow_rounded, size: 25),
                    label: const Text(
                      'Porfestés Megkezdése',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:         const Color(0xFF2F2587),
                      foregroundColor:         Colors.white,
                      disabledBackgroundColor: const Color(0xFFE0E0E0),
                      disabledForegroundColor: const Color(0xFF999999),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Mégse'),
          ),
        ],
      ),
    );
    scannerDatawedge.dispose();
    scannerDatas.dispose();
    return result;
  }

  Future<void> handlePop() async{
    if(await Global.yesNoDialog(
      context,
      title:    '⚠️ Kilépés',
      content:  'Félbe kívánja szakítani a Porfestést?',
      options:  const ['Igen', 'Mégsem'],
    )){
      Global.routeBack;
      if(mounted) Navigator.pop(context);
    }
  }
}