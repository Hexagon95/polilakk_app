import 'package:polilakk_app/data_manager.dart';
import 'package:polilakk_app/global.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RouteFestesreFelrakas extends StatefulWidget {//---------- ---------- ---------- ---------- ---------- ---------- ---------- <RouteFestesreFelrakas>
  const RouteFestesreFelrakas({super.key});

  @override
  State<RouteFestesreFelrakas> createState() => RouteFestesreFelrakasState();
}

class RouteFestesreFelrakasState extends State<RouteFestesreFelrakas> {//---------- ---------- ---------- ---------- ---------- ---------- ---------- <RouteFestesreFelrakasState>
  // ---------- [⚡️ static variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  static List<dynamic> dataGerenda =  [];
  static List<dynamic> rawData =      [];

  // ---------- [🌸 simple variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  late double _contentWidth;

  // ---------- [💎 complex variables] -- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Map<String, Map<String, List<dynamic>>> get groupedData{
    Map<String, Map<String, List<dynamic>>> result = {};
    for(dynamic item in rawData){
      String orderID = item['rendeles']?.toString() ?? '';
      String basketID = item['kosar']?.toString() ?? '';
      result.putIfAbsent(orderID, () => {});
      result[orderID]!.putIfAbsent(basketID, () => []);
      result[orderID]![basketID]!.add(item);
    }
    return result;  
  }

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
          title:            const Text('Festésre felrakás', style: TextStyle(fontSize: 18)),
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
        'Nincs megjeleníthető tétel.',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ))
    : ListView(
        padding: const EdgeInsets.fromLTRB(6, 85, 6, 15),
        children: [
          for(final order in groupedData.entries) ...[
            _drawOrderCard(order.key, order.value),
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
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFFFFFFFF),
            size:  24,
          ),
          SizedBox(width: 10),
          Flexible(child: Text(
            'Válasszon egy festésre felrakandó tételt!',
            textAlign: TextAlign.center,
            style: TextStyle(
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
      color: Color(0xFFFFFFFF),
      boxShadow: [BoxShadow(
        color:      Color(0x33000000),
        blurRadius: 12,
        offset:     Offset(0, -3),
      )],
    ),
    child: _drawBottomButton(
      text:      'Gerendák lezárása',
      icon:      Icons.view_stream_outlined,
      onPressed: _buttonFinishGerendaPressed,
    ),
  ));

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

  // ---------- < WidgetBuild [2] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget _drawOrderCard(
    String orderID,
    Map<String, List<dynamic>> baskets,
  ){
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:        const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: const Color(0x22000000)),
        boxShadow: const [BoxShadow(
          color:      Color(0x33000000),
          blurRadius: 8,
          offset:     Offset(0, 3),
        )],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFF4444CC),
              size:  24,
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(
              _displayValue(orderID),
              style: const TextStyle(
                fontSize:   17,
                fontWeight: FontWeight.bold,
                color:      Color(0xFF4444CC),
              ),
            )),
          ]),
          const SizedBox(height: 12),
          for(final basket in baskets.entries) ...[
            _drawBasketCard(basket.key, basket.value),
            if(basket.key != baskets.keys.last)
              const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  // ---------- < WidgetBuild [3] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget _drawBasketCard(
    String basketID,
    List<dynamic> items,
  ){
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:        const Color(0xFFF8F8FC),
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: const Color(0x22000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(
              Icons.shopping_basket_outlined,
              size:  19,
              color: Color(0xFF666666),
            ),
            const SizedBox(width: 6),
            const Text(
              'KOSÁR',
              style: TextStyle(
                fontSize:   10,
                fontWeight: FontWeight.bold,
                color:      Color(0xFF888888),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(
              _displayValue(basketID),
              style: const TextStyle(
                fontSize:   14,
                fontWeight: FontWeight.bold,
                color:      Color(0xFF333333),
              ),
            )),
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
    bool isCompleted = _isCompleted(item);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: isCompleted ? null : () => selectItem(item),
          borderRadius: BorderRadius.circular(9),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:  const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:        isCompleted ? const Color(0xFFDCF5E4) : const Color(0x00000000),
              borderRadius: BorderRadius.circular(9),
              border: isCompleted
                ? Border.all(color: const Color(0x6633AA55), width: 1)
                : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width:   72,
                  height:  58,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:        const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: isCompleted ? const Color(0x5533AA55) : const Color(0x22000000),
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
                    Text(
                      _displayValue(item['cikkszam']),
                      style: TextStyle(
                        fontSize:   17,
                        fontWeight: FontWeight.bold,
                        color:      isCompleted ? const Color(0xFF228844) : const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 5),
                    _drawItemValue(Icons.layers_outlined, 'Réteg', item['reteg'], isCompleted: isCompleted),
                    const SizedBox(height: 3),
                    _drawItemValue(Icons.palette_outlined, 'Szín', item['szin'], isCompleted: isCompleted),
                    if(isCompleted) ...[
                      const SizedBox(height: 3),
                      _drawItemValue(Icons.view_stream_outlined, 'Gerenda', item['gerenda_id'], isCompleted: true),
                    ],
                  ],
                )),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color:        isCompleted ? const Color(0xFF33AA55) : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item['mennyiseg'] ?? '-'} db',
                        style: TextStyle(
                          fontSize:   15,
                          fontWeight: FontWeight.bold,
                          color:      isCompleted ? const Color(0xFFFFFFFF) : const Color(0xFF333333),
                        ),
                      ),
                    ),
                    if(isCompleted) ...[
                      const SizedBox(height: 6),
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF229944),
                        size:  24,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        if(isCompleted)
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

  Widget _drawItemValue(
    IconData icon,
    String title,
    dynamic value, {
    bool isCompleted = false,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        size:  16,
        color: isCompleted ? const Color(0xFF229944) : const Color(0xFF777777),
      ),
      const SizedBox(width: 5),
      Expanded(child: Text(
        '$title: ${_displayValue(value)}',
        style: TextStyle(
          fontSize: 13,
          color:    isCompleted ? const Color(0xFF228844) : const Color(0xFF555555),
        ),
      )),
    ],
  );

  // ---------- < Methods [1] > --------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  String _displayValue(dynamic value){
    if(value == null || value.toString().trim().isEmpty) return '-';
    return value.toString();
  }

  bool _isCompleted(dynamic item) => item['ok']?.toString() == '1';

  Future<void> selectItem(dynamic item) async{
    if(_isCompleted(item)) return;
    int maxAmount = int.tryParse(item['mennyiseg']?.toString() ?? '') ?? 0;
    if(maxAmount <= 0) return;
    int? amount = await Global.integerDialog(
      context,
      title:   'ℹ️ Darabszám megadása',
      content: '(Maximum: $maxAmount db)',
      max:     maxAmount,
    );
    if(amount == null) return;
    if(!mounted) return;
    int? beamID = await _gerendaDialog(item);
    if(beamID == null) return;
    int selectedIndex = rawData.indexWhere((rawItem) => identical(rawItem, item));
    if(selectedIndex < 0) return;
    if(!mounted) return;
    setState(() => stamp(selectedIndex, amount, beamID));
    await finalCheck();
  }

  Future<int?> _gerendaDialog(dynamic item) async{
    TextEditingController controller = TextEditingController();
    String? errorText;
    int? result = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState){
          void submit(){
            int? beamID = int.tryParse(controller.text.trim());
            if(beamID == null){
              setDialogState(() => errorText = 'Adjon meg egy érvényes gerendaszámot!');
              return;
            }
            int gerendaIndex = dataGerenda.indexWhere((gerenda) => gerenda['id']?.toString() == beamID.toString());
            if(gerendaIndex < 0){
              setDialogState(() => errorText = 'Nem létező gerendaszámot adott meg!');
              return;
            }
            dynamic gerenda = dataGerenda[gerendaIndex];
            if(gerenda['lezarva']?.toString() == '1'){
              setDialogState(() => errorText = 'A gerenda már lezárásra került!');
              return;
            }
            String gerendaCikkszam = gerenda['cikkszam']?.toString() ?? '0';
            String itemCikkszam = item['szin_cikkszam']?.toString() ?? '';
            if(gerendaCikkszam != '0' && gerendaCikkszam != itemCikkszam){
              setDialogState(() => errorText = 'Csak azonos színeket lehet egy gerendára rakni!');
              return;
            }
            Navigator.pop(dialogContext, beamID);
          }
          return AlertDialog(
            title: const Text(
              'ℹ️ Gerendaszám megadása',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                if(errorText != null) setDialogState(() => errorText = null);
              },
              onSubmitted: (_) => submit(),
              decoration: InputDecoration(
                labelText: 'Gerenda azonosító',
                errorText: errorText,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Mégse'),
              ),
              TextButton(
                onPressed: submit,
                child: const Text('Ok'),
              ),
            ],
          );
        },
      ),
    );
    return result;
  }

  void stamp(int index, int amount, int beamID){
    dynamic item = rawData[index];
    int originalAmount = int.tryParse(item['mennyiseg']?.toString() ?? '') ?? 0;
    if(originalAmount <= 0) return;
    if(amount <= 0 || amount > originalAmount) return;
    Map<String, dynamic> completedItem = {
      ...Map<String, dynamic>.from(item),
      'mennyiseg':  amount,
      'gerenda_id': beamID,
      'ok':         1,
      'time_stamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'user_id':    DataManager.userID,
    };
    if(amount < originalAmount){
      Map<String, dynamic> remainingItem = {
        ...Map<String, dynamic>.from(item),
        'mennyiseg': originalAmount - amount,
      };
      remainingItem.remove('gerenda_id');
      remainingItem.remove('ok');
      remainingItem.remove('time_stamp');
      remainingItem.remove('user_id');
      rawData[index] = completedItem;
      rawData.insert(index + 1, remainingItem);
    }
    else{
      rawData[index] = completedItem;
    }
  }

  Future<void> undoRecord(dynamic item) async{
    if(!_isCompleted(item)) return;
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
      !_isCompleted(rawItem) &&
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
        restoredItem.remove('gerenda_id');
        restoredItem.remove('ok');
        restoredItem.remove('time_stamp');
        restoredItem.remove('user_id');
        rawData[itemIndex] = restoredItem;
      }
    });
  }

  Future<void> _buttonFinishGerendaPressed() async{
    await DataManager(
      appAction: AppAction.callFinishFestesreFelrakas,
      input:     {'data': rawData},
    ).beginCall;
    dataGerenda = await DataManager(appAction: AppAction.callGerenda).beginCall;
    List<Map<String, dynamic>> openGerenda = [];
    for(dynamic gerenda in dataGerenda){
      String cikkszam = gerenda['cikkszam']?.toString() ?? '';
      if(gerenda['lezarva']?.toString() == '1' || cikkszam.isEmpty || cikkszam == '0') continue;
      int articleIndex = rawData.indexWhere((item) => item['cikkszam']?.toString() == cikkszam);
      dynamic article = articleIndex < 0 ? null : rawData[articleIndex];
      openGerenda.add({
        'id':       gerenda['id'],
        'cikkszam': gerenda['cikkszam'],
        'picture':  article?['picture'],
      });
    }
    Map<String, dynamic>? selectedGerenda = await _selectGerendaToCloseDialog(openGerenda);
    if(selectedGerenda == null) return;
    dynamic message = await DataManager(appAction: AppAction.callFinishGerenda, input: {
      'id':       selectedGerenda['id'],
      'user_id':  DataManager.userID
    }).beginCall;
    String cleanMessage = message.toString().replaceAll(RegExp(r'[\[\]]'), '').trim();
    await Global.showAlertDialog(context,
      title:    cleanMessage.isEmpty ? 'ℹ️ Gerenda Lezárva!' : '⚠️ Hiba!',
      content:  cleanMessage.isEmpty ? '✅' : cleanMessage
    );
    dataGerenda = await DataManager(appAction: AppAction.callGerenda).beginCall;
    if(cleanMessage.isEmpty){
      rawData = await DataManager(appAction: AppAction.callFestesreFelrakas).beginCall;
      if(mounted) setState((){});
    }
  }

  Future<Map<String, dynamic>?> _selectGerendaToCloseDialog(List<Map<String, dynamic>> items) async{
    int? selectedIndex;
    return await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'ℹ️ Válassza ki a lezárandó gerendát!',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Center(child: Text(
                    'Nincs lezárható gerenda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Color(0xFF777777)),
                  )),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index){
                    Map<String, dynamic> item = items[index];
                    bool selected = selectedIndex == index;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedIndex = index),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0x182F2587) : Colors.white,
                          border: Border.all(
                            color: selected ? const Color(0xFF2F2587) : const Color.fromARGB(130, 184, 184, 184),
                            width: 1,
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Row(children: [
                          Radio<int>(
                            value: index,
                            groupValue: selectedIndex,
                            onChanged: (value) => setDialogState(() => selectedIndex = value),
                          ),
                          Container(
                            width: 72,
                            height: 58,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(color: const Color(0x22000000)),
                            ),
                            child: Image.network(
                              item['picture']?.toString() ?? '',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.image_not_supported_outlined,
                                size: 30,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gerenda: ${item['id']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F2587),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Cikkszám: ${item['cikkszam']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF555555),
                                ),
                              ),
                            ],
                          )),
                        ]),
                      ),
                    );
                  },
                ),
          ),
          actions: [
            if(items.isNotEmpty)
              TextButton(
                onPressed: selectedIndex == null
                  ? null
                  : () async{
                      bool confirm = await Global.yesNoDialog(
                        context,
                        title:   '⚠️ Megerősítés',
                        content: 'ℹ️ Megerősíti a kiválasztott gerenda lezárását?',
                      );
                      if(!confirm) return;
                      if(dialogContext.mounted) Navigator.pop(dialogContext, items[selectedIndex!]);
                    },
                child: const Text('Ok'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(items.isEmpty ? 'Bezárás' : 'Mégsem'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handlePop() async{
    if(await Global.yesNoDialog(
      context,
      title:    '⚠️ Kilépés',
      content:  'Félbe kívánja szakítani a Festésre felrakást?',
      options:  const ['Igen', 'Mégsem'],
    )){
      await DataManager(
        appAction: AppAction.callFinishFestesreFelrakas,
        input:     {'data': rawData},
      ).beginCall;
      Global.routeBack;
      if(mounted) Navigator.pop(context);
    }
  }

  // ---------- < Methods [2] > --------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  bool _sameRecord(dynamic a, dynamic b){
    const ignoredKeys = {'mennyiseg', 'gerenda_id', 'ok', 'time_stamp', 'user_id'};
    for(dynamic key in {...a.keys, ...b.keys}){
      if(ignoredKeys.contains(key)) continue;
      if(a[key]?.toString() != b[key]?.toString()) return false;
    }
    return true;
  }
  
  Future<bool> finalCheck() async{
    if(rawData.any((item) => !_isCompleted(item))) return false;
    await DataManager(
      appAction: AppAction.callFinishFestesreFelrakas,
      input:     {'data': rawData},
    ).beginCall;
    await Global.showAlertDialog(
      context,
      title:   'ℹ️ Festésre felrakás befejezve!',
      content: 'Nincs több teendő!',
    );
    Global.routeBack;
    if(mounted) Navigator.pop(context);
    return true;
  }
}
