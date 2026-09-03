import 'package:polilakk_app/src/scanner_datawedge.dart';
import 'package:polilakk_app/data_manager.dart';
import 'package:polilakk_app/global.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Work{itemSelection, packageIdScan, basketIdScan, basketItemPlacement, default0}
enum RStatus{done, notFound, default0}

class RouteElokezeles extends StatefulWidget {//---------- ---------- ---------- ---------- ---------- ---------- ---------- <ItemFrame>
  const RouteElokezeles({super.key});


  @override
  State<RouteElokezeles> createState() => RouteElokezelesState();
}

class RouteElokezelesState extends State<RouteElokezeles> {//---------- ---------- ---------- ---------- ---------- ---------- ---------- <ItemState>
  // ---------- [⚡️ static variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  static List<dynamic> rawData = [];

  // ---------- [🌸 simple variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  bool scanOngoing = false;
  ValueNotifier<ScannerDatas>? scannerDatas;
  ScannerDatawedge? scannerDatawedge;
  late double _contentWidth;
  int? _index;
  int? selectedAmount;
  String? basketID;
  String? selectedPackageID;

  // ---------- [💎 complex variables] -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  int? get index => _index;
  Work _work = Work.default0;
  Work get work => _work;
  void setWork(){
    _work = switch(work){
      Work.basketIdScan => Work.basketItemPlacement,
      _                 => Work.default0,
    };
  }
  String get _workMessage => switch(work){
    Work.itemSelection         => 'Válasszon tételt az aktuális csomagból!',
    Work.packageIdScan         => 'Olvassa le a csomag QR kódját!',
    Work.basketIdScan          => 'Olvassa be a kosáron lévő QR kódot!',
    Work.basketItemPlacement   => 'Helyezze a kosárba az anyagokat!',
    _                          => '⚠️ A Munkalap üres!',
  };
  Map<String, Map<String, List<dynamic>>> get groupedData {
    Map<String, Map<String, List<dynamic>>> result = {};
    for(dynamic item in rawData){
      String orderID   = '${item['rendeles']}|${item['szin']}';
      String packageID = item['package_id']?.toString() ?? '';

      result.putIfAbsent(orderID, () => {});
      result[orderID]!.putIfAbsent(packageID, () => []);
      result[orderID]![packageID]!.add(item);
    }
    return result;
  }
  String? get activeOrder {
    for(final order in groupedData.entries){
      if(order.value.values
          .expand((items) => items)
          .any((item) => _setRecordStatus(item) == RStatus.default0)){
        return order.key;
      }
    }
    return null;
  }
  String? get activePackage => selectedPackageID;
  List<dynamic> get completedData => rawData.where((item) => _setRecordStatus(item) != RStatus.default0).toList();

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
          title:            const Text('Kosárba helyezés - Előkezelés', style: TextStyle(fontSize: 18)),
          backgroundColor: const Color(0xFF2F2587),
          foregroundColor: const Color(0xFFFFFFFF),
        ),
        body: Container(
          width:      double.infinity,
          height:     double.infinity,
          decoration: const BoxDecoration(image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit:   BoxFit.cover,
          )),
          child: SafeArea(child: Stack(children: [
            _drawContent,
            _drawWorkMessage,
          ])),
        ),
        bottomNavigationBar: _drawBottomBar,
      ),
    );
  }

  // ---------- < WidgetBuild [1] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawContent => Center(child: SizedBox(
    width: _contentWidth,
    child: rawData.isEmpty
    ? const Center(child: Text(
        'Nincs előkészítésre váró anyag.',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ))
    : ListView(
        padding: const EdgeInsets.fromLTRB(6, 85, 6, 15),
        children: [
          for(final order in groupedData.entries) ...[
            _drawOrderCard(
              order.key,
              order.value,
            ),
            const SizedBox(height: 12),
          ],
        ],
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
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFFFFFFF),
            size:  24,
          ),
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
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
    decoration: const BoxDecoration(
      color:     Color(0xFFFFFFFF),
      boxShadow: [BoxShadow(
        color:      Color(0x33000000),
        blurRadius: 12,
        offset:     Offset(0, -3),
      )],
    ),
    child: Row(children: [
      for(final button in switch(work){
        Work.itemSelection       => [_drawFinishBasket],
        Work.packageIdScan       => [_drawButtonSkip, _drawFinishBasket],
        Work.basketIdScan        => [_drawButtonEnterBasketID],
        Work.basketItemPlacement => [_drawButtonPlacementComplete],
        _                        => <Widget>[],
      })
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child:   button,
        )),
    ]),
  ));

  // ---------- < WidgetBuild [1][Buttons] > ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawButtonSkip => _drawBottomButton(
    text:      'QR kód nem olvasható',
    icon:      Icons.qr_code_scanner,
    onPressed: null, //buttonQrNotReadablePressed,
  );

  Widget get _drawFinishBasket => _drawBottomButton(
    text:      'Kosarak Lezárása',
    icon:      Icons.shopping_basket,
    onPressed: _buttonFinishBasketPressed, //buttonMaterialNotFoundPressed,
  );

  Widget get _drawButtonEnterBasketID => _drawBottomButton(
    text:      'Megadás billentyűzettel',
    icon:      Icons.keyboard,
    onPressed: buttonEnterBasketIDPressed,
  );

  Widget get _drawButtonPlacementComplete => _drawBottomButton(
    text:      'Kosárba helyeztem',
    icon:      Icons.done,
    onPressed: buttonPlacementCompletePressed,
  );

  // ---------- < WidgetBuild [2] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget _drawOrderCard(
    String orderID,
    Map<String, List<dynamic>> packages,
  ){
    dynamic first =     packages.values.first.first;
    bool isCompleted =  packages.values.expand((items) => items).every((item) => _setRecordStatus(item) != RStatus.default0);
    bool isActive =     orderID == activeOrder;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width:   double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isCompleted
          ? const Color(0xFFEAF8EE)
          : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
            ? const Color(0xFF33AA55)
            : isActive
              ? const Color(0xFF4444CC)
              : const Color(0x22000000),
          width: (isCompleted || isActive) ? 2 : 1,
        ),
        boxShadow: const [BoxShadow(
          color:      Color(0x33000000),
          blurRadius: 8,
          offset:     Offset(0, 3),
        )],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _drawOrderHeader(
            first,
            isActive,
            isCompleted,
          ),
          const SizedBox(height: 12),
          for(final package in packages.entries) ...[
            _drawPackageCard(
              orderID,
              package.key,
              package.value,
            ),
            if(package.key != packages.keys.last)
              const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _drawOrderHeader(
    dynamic item,
    bool isActive,
    bool isCompleted,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        if(isCompleted) ...[
          const Icon(
            Icons.check_circle,
            color: Color(0xFF229944),
            size:  25,
          ),
          const SizedBox(width: 6),
        ]
        else if(isActive) ...[
          const Icon(
            Icons.play_arrow_rounded,
            color: Color(0xFF4444CC),
            size:  25,
          ),
          const SizedBox(width: 4),
        ],
        Expanded(child: Text(
          _displayValue(item['rendeles']),
          style: TextStyle(
            fontSize:   17,
            fontWeight: FontWeight.bold,
            color: isCompleted
              ? const Color(0xFF228844)
              : const Color(0xFF4444CC),
          ),
        )),
      ]),
      const SizedBox(height: 8),
      _drawHeaderValue(
        Icons.palette_outlined,
        'Szín',
        _displayValue(item['szin']),
        isCompleted: isCompleted,
      ),
    ],
  );

  Widget _drawHeaderValue(
    IconData icon,
    String title,
    String value, {
    bool isCompleted = false,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        size:  18,
        color: isCompleted
          ? const Color(0xFF229944)
          : const Color(0xFF777777),
      ),
      const SizedBox(width: 6),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize:    10,
              fontWeight:  FontWeight.bold,
              color:       Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,

            style: TextStyle(
              fontSize:   13,
              fontWeight: FontWeight.w600,

              color: isCompleted
                ? const Color(0xFF228844)
                : const Color(0xFF333333),
            ),
          ),
        ],
      )),
    ],
  );


  // ---------- < WidgetBuild [3] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget _drawPackageCard(
    String orderID,
    String packageID,
    List<dynamic> items,
  ){
    dynamic first =     items.first;
    bool isCompleted =  items.every((item) => _setRecordStatus(item) != RStatus.default0);
    bool isActive =     !isCompleted && orderID == activeOrder && packageID == activePackage;
    return AnimatedContainer(
      duration:   const Duration(milliseconds: 250),
      width:      double.infinity,
      padding:    const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:        isCompleted? const Color(0xFFDDF4E4) : const Color(0xFFF8F8FC),
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(
          color: isCompleted
            ? const Color(0xFF33AA55)
            : isActive
              ? const Color(0xFF7777DD)
              : const Color(0x22000000),
          width: (isCompleted || isActive) ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(
              isCompleted
                ? Icons.check_circle
                : Icons.inventory_2_outlined,

              size: 18,

              color: isCompleted
                ? const Color(0xFF229944)
                : isActive
                  ? const Color(0xFF4444CC)
                  : const Color(0xFF666666),
            ),

            const SizedBox(width: 6),

            const Text(
              'CSOMAG',

              style: TextStyle(
                fontSize:   10,
                fontWeight: FontWeight.bold,
                color:      Color(0xFF888888),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(child: Text(
              _displayValue(first['package_id']),

              style: TextStyle(
                fontSize:   14,
                fontWeight: FontWeight.bold,

                color: isCompleted
                  ? const Color(0xFF228844)
                  : const Color(0xFF333333),
              ),
            )),

            if(isActive)
              const Icon(
                Icons.play_arrow_rounded,
                size:  22,
                color: Color(0xFF4444CC),
              ),
          ]),

          const Divider(height: 18),

          for(int i = 0; i < items.length; i++) ...[
            _drawArticleRow(items[i]),

            if(i < items.length - 1)
              const Divider(height: 12),
          ],
        ],
      ),
    );
  }  

  Widget _drawArticleRow(dynamic item){
    RStatus rStatus   = _setRecordStatus(item);
    bool isCompleted  = rStatus == RStatus.done;
    bool isNotFound   = rStatus == RStatus.notFound;
    bool isSelected   = _isSelectedItem(item);
    bool isSelectable = _isSelectableItem(item);
    bool canUndo      = isCompleted || isNotFound;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: isSelectable
            ? () => selectItem(item)
            : null,
          borderRadius: BorderRadius.circular(9),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted
                ? const Color(0xFFDCF5E4)
                : isNotFound
                  ? const Color(0xFFFFE4E4)
                  : isSelected
                    ? const Color(0x224444CC)
                    : isSelectable
                      ? const Color(0x08000000)
                      : const Color(0x00000000),
              borderRadius: BorderRadius.circular(9),
              border: isCompleted
                ? Border.all(
                    color: const Color(0x6633AA55),
                    width: 1,
                  )
                : isNotFound
                  ? Border.all(
                      color: const Color(0x66CC3333),
                      width: 1,
                    )
                  : isSelected
                    ? Border.all(
                        color: const Color(0xFF4444CC),
                        width: 1.5,
                      )
                    : null,
            ),
            child: Row(children: [
              Container(
                width:   72,
                height:  58,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:        const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: isCompleted
                      ? const Color(0x5533AA55)
                      : isNotFound
                        ? const Color(0x55CC3333)
                        : const Color(0x22000000),
                  ),
                ),
                child: Image.network(
                  item['picture']?.toString() ?? '',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported_outlined,
                    size:  30,
                    color: Color(0xFF999999),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CIKKSZÁM',
                    style: TextStyle(
                      fontSize:   10,
                      fontWeight: FontWeight.bold,
                      color:      Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _displayValue(item['cikkszam']),
                    style: TextStyle(
                      fontSize:   17,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                        ? const Color(0xFF228844)
                        : isNotFound
                          ? const Color(0xFFCC3333)
                          : isSelected
                            ? const Color(0xFF4444CC)
                            : isSelectable
                              ? const Color(0xFF333333)
                              : const Color(0xFF888888),
                    ),
                  ),
                ],
              )),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical:   7,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                        ? const Color(0xFF33AA55)
                        : isNotFound
                          ? const Color(0xFFCC4444)
                          : isSelected
                            ? const Color(0xFF4444CC)
                            : const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item['mennyiseg'] ?? '-'} db',
                      style: TextStyle(
                        fontSize:   15,
                        fontWeight: FontWeight.bold,
                        color: (isCompleted || isNotFound || isSelected)
                          ? const Color(0xFFFFFFFF)
                          : isSelectable
                            ? const Color(0xFF333333)
                            : const Color(0xFF888888),
                      ),
                    ),
                  ),
                  if(isCompleted) ...[
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_basket_outlined,
                          size:  16,
                          color: Color(0xFF228844),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['kosar_id']?.toString() ?? '-',
                          style: const TextStyle(
                            fontSize:   13,
                            fontWeight: FontWeight.bold,
                            color:      Color(0xFF228844),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              if(isCompleted) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF229944),
                  size:  24,
                ),
              ]
              else if(isNotFound) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.cancel,
                  color: Color(0xFFCC3333),
                  size:  24,
                ),
              ]
              else if(isSelectable) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.touch_app_outlined,
                  color: Color(0xFF4444CC),
                  size:  22,
                ),
              ],
            ]),
          ),
        ),
        if(canUndo)
          Positioned(
            top:  -14,
            left: -14,
            child: Material(
              color:     const Color(0xFFD32F2F),
              elevation: 7,
              shape:     const CircleBorder(),
              child: InkWell(
                onTap: () => undoRecord(item),
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width:  34,
                  height: 34,
                  child: Icon(
                    Icons.close,
                    color: Color(0xFFFFFFFF),
                    size:  22,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _drawBottomButton({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
  }) => SizedBox(
    height: 58,

    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon:      Icon(icon, size: 23),

      label: Text(
        text,
        textAlign: TextAlign.center,
        maxLines:  2,
        softWrap:  true,

        style: const TextStyle(
          fontSize:   14,
          fontWeight: FontWeight.w600,
        ),
      ),

      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2F2587),
        backgroundColor: const Color(0xFFF8F7FF),

        side: const BorderSide(
          color: Color(0xFF2F2587),
          width: 1.5,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),

        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    ),
  );


  // ---------- < Methods [1] > --------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  @override
  void initState(){
    super.initState();

    if(rawData.isNotEmpty){
      _work = Work.packageIdScan;
    }

    scannerDatas = ValueNotifier(
      ScannerDatas(scanData: ''),
    );

    scannerDatawedge = ScannerDatawedge(
      scannerDatas: scannerDatas!,
      profileName:  'PolilakkItemFrame',
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


  String _displayValue(dynamic value){
    if(value == null || value.toString().trim().isEmpty){
      return '-';
    }

    return value.toString();
  }


  String _orderID(dynamic item) =>
      '${item['rendeles']}|${item['szin']}';


  RStatus _setRecordStatus(dynamic item) => switch(item['ok']?.toString()){
    '1' =>  RStatus.done,
    '0' =>  RStatus.notFound,
    _ =>    RStatus.default0,
  };  

  bool _isSelectedItem(dynamic item){
    if(index == null) return false;
    return identical(
      item,
      rawData[index!],
    );
  }

  bool _isSelectableItem(dynamic item){
    if(work != Work.itemSelection) return false;
    if(_setRecordStatus(item) != RStatus.default0) return false;
    return _orderID(item) == activeOrder && item['package_id']?.toString() == activePackage;
  }

  Future<void> selectItem(dynamic item) async{
    if(!_isSelectableItem(item)) return;
    int maxAmount = int.tryParse(item['mennyiseg']?.toString() ?? '') ?? 0;
    if(maxAmount <= 0) return;
    scanOngoing = true;
    try{
      int? amount = await Global.integerDialog(
        context,
        title:   'ℹ️ Darabszám megadása',
        content: '(Maximum: $maxAmount db)',
        max:     maxAmount,
        extraButtons: [{
          'text':      'Nem találom az anyagot',
          'icon':      Icons.search_off,
          'isConfirm': true,
        }],
      );
      if(amount == null) return;
      int selectedIndex = rawData.indexWhere(
        (rawItem) => identical(rawItem, item),
      );
      if(selectedIndex < 0) return;
      if(!mounted) return;
      if(amount == -1){
        rawData[selectedIndex] = {
          ...Map<String, dynamic>.from(item),
          'ok':         0,
          'time_stamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          'user_id':    DataManager.userID,
        };
        String? orderBefore   = activeOrder;
        String? packageBefore = selectedPackageID;
        if(await finalCheck()) return;
        if(!mounted) return;
        bool packageCompleted =
            orderBefore != null &&
            packageBefore != null &&
            !rawData.any((item) =>
              _orderID(item) == orderBefore &&
              item['package_id']?.toString() == packageBefore &&
              _setRecordStatus(item) == RStatus.default0
            );
        setState((){
          _index         = null;
          selectedAmount = null;
          basketID       = null;
          if(packageCompleted){
            selectedPackageID = null;
            _work             = Work.packageIdScan;
          }
          else{
            _work = Work.itemSelection;
          }
        });
        return;
      }
      setState((){
        _index          = selectedIndex;
        selectedAmount = amount;
        _work           = Work.basketIdScan;
      });
    }
    finally{
      scanOngoing = false;
    }
  }

  Future<void> buttonQrNotReadablePressed() async{
    if(index == null) return;
    setState(() => setWork());
  }

  Future<void> _buttonFinishBasketPressed() async{
    try{
      await DataManager(
        appAction: AppAction.callFinishElokezeles,
        input:     {'data': completedData},
      ).beginCall;
      List<Map<String, dynamic>>? result = await Global.selectItemsFromListDialog(context,
        items:          List<Map<String, dynamic>>.from(await DataManager(appAction: AppAction.callTermelesKosar).beginCall),
        title:          'ℹ️ Válassza ki a lezárandó kosarakat!',
        confirmString:  'ℹ️ Megerősíti a kiválasztott kosarak lezárását?',
        design: {
          'kosar': (value) => Row(
            children: [
              const Icon(Icons.shopping_basket, color: Color(0xFF2F2587)),
              const SizedBox(width: 6),
              Text(
                'Kosár: $value',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F2587),
                ),
              ),
            ],
          ),
          'mennyiseg': (value) => Text(
            'Mennyiség: $value db',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
            ),
          ),
        },
      );
      if(result != null && result.isNotEmpty){
        List<dynamic> message = [];
        for(dynamic item in result){
          message.add(await DataManager(appAction: AppAction.callFinishTermelsKosar, input: {
            'id':       item['kosar'],
            'user_id':  DataManager.userID
          }).beginCall);
        }
        String cleanMessage = message.join('\n').replaceAll(RegExp(r'[\[\]]'), '').trim();
        await Global.showAlertDialog(context,
          title:    cleanMessage.isEmpty ? 'ℹ️ Kosarak Lezárva!' : '⚠️ Hiba!',
          content:  cleanMessage.isEmpty ? '✅' : cleanMessage
        );
      }
      rawData = await DataManager(appAction: AppAction.callElokezeles).beginCall;
      setState((){});
    }
    catch(e){
      if(kDebugMode) print(e.toString());
    }
  }

  Future<void> buttonMaterialNotFoundPressed() async{
    if(index == null) return;
    if(await Global.yesNoDialog(
      context,
      title:    '⚠️ Anyag nem található!',
      content:  'Nem találja a kiválasztott anyagot?\n${rawData[index!]['cikkszam']}',
      options:  const ['Igen', 'Mégsem'],
    )){
      if(!mounted) return;
      setState((){
        _index         = null;
        selectedAmount = null;
        basketID       = null;
        _work          = Work.itemSelection;
      });
    }
  }

  Future<void> buttonEnterBasketIDPressed() async{
    scanOngoing = true;
    try{
      basketID = (await Global.integerDialog(
        context,
        title:   'ℹ️ Kosár azonosító',
        content: 'Adja meg a kosár azonosítóját:',
      ))?.toString();      
      if(basketID != null && mounted){
        setState(() => setWork());
      }
    }
    finally{
      scanOngoing = false;
    }
  }

  Future<void> buttonPlacementCompletePressed() async{
    if(index == null || selectedAmount == null) return;
    String? orderBefore   = activeOrder;
    String? packageBefore = selectedPackageID;
    stamp();
    if(await finalCheck()) return;
    if(!mounted) return;
    bool packageCompleted = orderBefore != null && packageBefore != null &&
      !rawData.any((item) => _orderID(item) == orderBefore && item['package_id']?.toString() == packageBefore && _setRecordStatus(item) == RStatus.default0)
    ;
    setState((){
      _index         = null;
      selectedAmount = null;
      basketID       = null;
      if(packageCompleted){
        selectedPackageID = null;
        _work             = Work.packageIdScan;
      }
      else{
        _work = Work.itemSelection;
      }
    });
  }

  Future<void> handlePop() async{
    if(await Global.yesNoDialog(
      context,
      title:    '⚠️ Kilépés',
      content:  'Félbe kívánja szakítani az Előkezelést?',
      options:  const ['Igen', 'Mégsem'],
    )){
      await DataManager(
        appAction: AppAction.callFinishElokezeles,
        input:     {'data': completedData},
      ).beginCall;
      Global.routeBack;
      if(mounted){
        Navigator.pop(context);
      }
    }
  }

  // ---------- < Methods [2] > --------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Future<void> _triggerScan() async{
    if(scanOngoing) return;
    scanOngoing = true;
    try{
      switch(work){

        case Work.packageIdScan:
          String scanData =                       scannerDatas!.value.scanData.trim();
          Map<String, List<dynamic>>? packages =  activeOrder == null ? null : groupedData[activeOrder];
          bool validPackage =
            packages != null &&
            packages.containsKey(scanData) &&
            packages[scanData]!.any((item) => _setRecordStatus(item) == RStatus.default0)
          ;
          if(validPackage){
            AudioPlayer().play(AssetSource('sounds/okay.mp3'));
            if(mounted) {setState((){
              selectedPackageID = scanData;
              _index            = null;
              selectedAmount    = null;
              basketID          = null;
              _work             = Work.itemSelection;
            });}
          }
          else{
            AudioPlayer().play(AssetSource('sounds/error.mp3'));
            await Global.showAlertDialog(context,
              title:   '⚠️ Helytelen kód!',
              content: 'Ez a csomag nem választható az aktuális Szín alatt!',
            );
          }
          break;

        case Work.basketIdScan:
          if(index == null) break;
          basketID = scannerDatas!.value.scanData.trim();
          AudioPlayer().play(AssetSource('sounds/okay.mp3'));
          if(mounted){setState(() => setWork());}
          break;

        default: break;
      }
    }
    catch(e){
      if(kDebugMode){
        debugPrint('Scanner error: $e');
      }
    }
    finally{
      scanOngoing = false;
    }
  }

  Future<void> undoRecord(dynamic item) async{
    if(_setRecordStatus(item) == RStatus.default0) return;
    scanOngoing = true;
    try{
      if(!await Global.yesNoDialog(
        context,
        title:    '⚠️ Visszavonás',
        content:  'Visszavonja a tétel rögzítését?\n${item['cikkszam']}',
        options:  const ['Igen', 'Mégsem'],
      )) return;
      int itemIndex = rawData.indexWhere((rawItem) => identical(rawItem, item));
      if(itemIndex < 0) return;
      int cancelledAmount = int.tryParse(item['mennyiseg']?.toString() ?? '') ?? 0;
      int remainingIndex = rawData.indexWhere((rawItem) =>
        !identical(rawItem, item) &&
        _setRecordStatus(rawItem) == RStatus.default0 &&
        _sameRecord(rawItem, item)
      );
      setState((){
        if(remainingIndex >= 0){
          int remainingAmount = int.tryParse(rawData[remainingIndex]['mennyiseg']?.toString() ?? '') ?? 0;
          rawData[remainingIndex]['mennyiseg'] = remainingAmount + cancelledAmount;
          rawData.removeAt(itemIndex);
        }
        else{
          Map<String, dynamic> restoredItem = Map<String, dynamic>.from(item);
          restoredItem.remove('ok');
          restoredItem.remove('kosar_id');
          restoredItem.remove('time_stamp');
          restoredItem.remove('user_id');
          rawData[itemIndex] = restoredItem;
        }
        _index = null;
        selectedAmount = null;
        basketID = null;
        selectedPackageID = null;
        _work = Work.packageIdScan;
      });
    }
    finally{
      scanOngoing = false;
    }
  }

  // ---------- < Methods [3] > --------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  void stamp(){
    if(index == null || selectedAmount == null) return;
    dynamic item = rawData[index!];
    int originalAmount =
        int.tryParse(item['mennyiseg']?.toString() ?? '') ?? 0;
    int amount = selectedAmount!;
    if(originalAmount <= 0) return;
    if(amount <= 0 || amount > originalAmount) return;
    Map<String, dynamic> completedItem = {
      ...Map<String, dynamic>.from(item),
      'mennyiseg':  amount,
      'ok':         1,
      'kosar_id':   basketID,
      'time_stamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'user_id':    DataManager.userID,
    };
    if(amount < originalAmount){
      Map<String, dynamic> remainingItem = {
        ...Map<String, dynamic>.from(item),
        'mennyiseg': originalAmount - amount,
      };
      remainingItem.remove('ok');
      remainingItem.remove('kosar_id');
      remainingItem.remove('time_stamp');
      remainingItem.remove('user_id');
      rawData[index!] = completedItem;
      rawData.insert(
        index! + 1,
        remainingItem,
      );
    }
    else{
      rawData[index!] = completedItem;
    }
    basketID = null;
  }

  bool _sameRecord(dynamic a, dynamic b){
    const ignoredKeys = {'mennyiseg', 'ok', 'kosar_id', 'time_stamp', 'user_id'};
    for(dynamic key in {...a.keys, ...b.keys}){
      if(ignoredKeys.contains(key)) continue;
      if(a[key]?.toString() != b[key]?.toString()) return false;
    }
    return true;
  }

  Future<bool> finalCheck() async{
    if(rawData.any((item) => _setRecordStatus(item) == RStatus.default0)) return false;
    await DataManager(
      appAction: AppAction.callFinishElokezeles,
      input:     {'data': completedData},
    ).beginCall;
    await Global.showAlertDialog(
      context,
      title:   'ℹ️ Előkezelés befejezve!',
      content: 'Nincs több teendő!',
    );
    Global.routeBack;
    if(mounted) {Navigator.pop(context);}
    return true;
  }
}