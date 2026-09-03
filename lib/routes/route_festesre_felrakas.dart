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
  static List<dynamic> rawData = [];

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
    return InkWell(
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
    int? beamID = await Global.integerDialog(
      context,
      title:   'ℹ️ Gerendaszám megadása',
      content: 'Adja meg a gerenda azonosítóját:',
    );
    if(beamID == null) return;
    int selectedIndex = rawData.indexWhere((rawItem) => identical(rawItem, item));
    if(selectedIndex < 0) return;
    if(!mounted) return;
    setState(() => stamp(selectedIndex, amount, beamID));
    await finalCheck();
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
