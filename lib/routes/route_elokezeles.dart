import 'package:polilakk_app/src/scanner_datawedge.dart';
import 'package:polilakk_app/data_manager.dart';
import 'package:polilakk_app/global.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RouteElokezeles extends StatefulWidget{
  const RouteElokezeles({super.key});

  @override
  State<RouteElokezeles> createState() => RouteElokezelesState();
}

class RouteElokezelesState extends State<RouteElokezeles>{
  // ---------- [⚡️ static variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  static List<dynamic> rawData = [];

  // ---------- [🌸 simple variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  bool scanOngoing = false;
  bool loading = false;
  ValueNotifier<ScannerDatas>? scannerDatas;
  ScannerDatawedge? scannerDatawedge;
  late double _contentWidth;

  // ---------- < WidgetBuild [0] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  @override
  Widget build(BuildContext context){
    final double screenWidth = MediaQuery.sizeOf(context).width;
    _contentWidth = (screenWidth - 10).clamp(0.0, 600.0).toDouble();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Előkezelés',
            style: TextStyle(fontSize: 18),
          ),
        ),
        backgroundColor: const Color(0xFF2F2587),
        foregroundColor: const Color(0xFFFFFFFF),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _drawContent,
              _drawInstruction,
              if(loading) _drawLoading,
            ],
          ),
        ),
      ),
    );
  }

  // ---------- < WidgetBuild [1] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawInstruction => Align(
    alignment: Alignment.topCenter,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xCC2F2587),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, color: Color(0xFFFFFFFF), size: 24),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Olvassa be a kosáron található QR kódot!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget get _drawContent => Center(
    child: SizedBox(
      width: _contentWidth,
      child: rawData.isEmpty
        ? const Padding(
            padding: EdgeInsets.only(top: 100),
            child: Center(
              child: Text(
                'Nincs megjeleníthető kosár.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.fromLTRB(10, 100, 10, 20),
            itemCount: rawData.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _drawBasketCard(rawData[index]),
          ),
    ),
  );

  Widget _drawBasketCard(dynamic item){
    bool inProgress = _isInProgress(item);

    final Color borderColor = inProgress
      ? const Color(0xFF2F2587)
      : const Color(0xFFD4D7DD);

    final Color iconBoxColor = inProgress
      ? const Color(0xFFEDEBFF)
      : const Color(0xFFF1F3F5);

    final Color iconColor = inProgress
      ? const Color(0xFF2F2587)
      : const Color(0xFF707782);

    final Color badgeBackground = inProgress
      ? const Color(0xFFE8ECFF)
      : const Color(0xFFF0F2F4);

    final Color badgeForeground = inProgress
      ? const Color(0xFF2F2587)
      : const Color(0xFF5E6670);

    final IconData statusIcon = inProgress
      ? Icons.autorenew_rounded
      : Icons.hourglass_bottom_rounded;

    final String basket = item['kosar']?.toString() ?? '-';
    final String statusText = _getProcessText(item);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: inProgress ? 1.6 : 1.1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: iconBoxColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.shopping_basket_outlined,
                  color: iconColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KOSÁR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B8B8B),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      basket,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: badgeBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 16,
                      color: badgeForeground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      inProgress ? 'Folyamatban' : 'Várakozik',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: badgeForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: inProgress
                ? const Color(0xFFF6F7FF)
                : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  statusIcon,
                  size: 18,
                  color: badgeForeground,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: badgeForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget get _drawLoading => Container(
    color: const Color(0x33000000),
    child: const Center(
      child: CircularProgressIndicator(),
    ),
  );

  // ---------- < Methods [1] > --------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  @override
  void initState(){
    super.initState();
    scannerDatas = ValueNotifier(ScannerDatas(scanData: ''));
    scannerDatawedge = ScannerDatawedge(
      scannerDatas: scannerDatas!,
      profileName: 'PolilakkItemFrame',
    );
    scannerDatas!.addListener(_triggerScan);
  }

  @override
  void dispose(){
    scannerDatas?.removeListener(_triggerScan);
    scannerDatawedge?.dispose();
    scannerDatas?.dispose();
    super.dispose();
  }

  bool _isInProgress(dynamic item){
    String process = item['folyamat']?.toString().trim() ?? '';
    return process.toLowerCase() == 'előkezelés folyamatban'.toLowerCase();
  }

  String _getProcessText(dynamic item){
    String process = item['folyamat']?.toString().trim() ?? '';
    if(process.isEmpty) return 'Előkezelésre vár';
    return process;
  }

  Future<void> _triggerScan() async{
    if(scanOngoing || loading) return;
    String scanData = scannerDatas!.value.scanData.trim();
    if(scanData.isEmpty) return;
    scanOngoing = true;
    try{
      dynamic basket = _findBasket(scanData);
      if(basket == null){
        AudioPlayer().play(AssetSource('sounds/error.mp3'));
        await Global.showAlertDialog(
          context,
          title: '⚠️ Helytelen kosár!',
          content: 'Kosár $scanData még nincs lezárva!',
        );
        return;
      }

      String basketID = basket['kosar']?.toString() ?? scanData;
      bool inProgress = _isInProgress(basket);

      bool confirmed = await Global.yesNoDialog(
        context,
        title: 'ℹ️ Előkezelés',
        content: inProgress
          ? 'Kosár $basketID előkezelése befejeződött?'
          : 'Kosár $basketID előkezelésbe helyezhető?',
        options: const ['Igen', 'Nem'],
      );

      if(!confirmed) return;
      if(!mounted) return;

      setState(() => loading = true);

      await DataManager(
        appAction: AppAction.callFinishElokezeles,
        input: {'kosar': basket['kosar']},
      ).beginCall;

      await _refreshData();
      AudioPlayer().play(AssetSource('sounds/okay.mp3'));
    }
    catch(e){
      if(kDebugMode) debugPrint('Előkezelés scanner error: $e');
      if(mounted){
        await Global.showAlertDialog(
          context,
          title: '⚠️ Hiba!',
          content: 'Az előkezelési művelet végrehajtása sikertelen.',
        );
      }
    }
    finally{
      if(mounted) setState(() => loading = false);
      scanOngoing = false;
    }
  }

  dynamic _findBasket(String scanData){
    for(dynamic item in rawData){
      if(item['kosar']?.toString().trim() == scanData) return item;
    }
    return null;
  }

  Future<void> _refreshData() async{
    dynamic result = await DataManager(appAction: AppAction.callElokezeles).beginCall;
    if(!mounted) return;
    setState(() => rawData = result is List ? result : []);
  }
}