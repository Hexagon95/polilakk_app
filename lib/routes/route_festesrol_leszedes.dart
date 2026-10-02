import 'package:flutter/foundation.dart';
import 'package:polilakk_app/data_manager.dart';
import 'package:polilakk_app/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class RouteFestesrolLeszedes extends StatefulWidget {//---------- ---------- ---------- ---------- ---------- ---------- ---------- <RouteFestesrolLeszedes>
  const RouteFestesrolLeszedes({super.key});
  @override
  State<RouteFestesrolLeszedes> createState() => RouteFestesrolLeszedesState();
}
class RouteFestesrolLeszedesState extends State<RouteFestesrolLeszedes> {//---------- ---------- ---------- ---------- ---------- ---------- ---------- <RouteFestesrolLeszedesState>
  // ---------- [⚡️ static variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  static List<dynamic> rawData = [];
  // ---------- [🌸 simple variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  late double _contentWidth;
  // ---------- < WidgetBuild [0] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  @override
  Widget build(BuildContext context){
    final double screenWidth = MediaQuery.sizeOf(context).width;
    _contentWidth = (screenWidth - 10).clamp(0.0, 650.0).toDouble();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async{
        if(didPop) return;
        await _exitRoute();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text(
            'Festésről leszedés',
            style: TextStyle(fontSize: 18),
          ),
          backgroundColor: const Color(0xFF2F2587),
          foregroundColor: const Color(0xFFFFFFFF),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          )),
          child: SafeArea(child: _drawContent),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ))
      : ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: rawData.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _drawGerendaCard(rawData[index]),
        ),
  ));
  Widget get _drawBottomBar => SafeArea(child: Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
    decoration: const BoxDecoration(
      color: Color(0xFFFFFFFF),
      boxShadow: [BoxShadow(
        color: Color(0x33000000),
        blurRadius: 12,
        offset: Offset(0, -3),
      )],
    ),
    child: _drawBottomButton(
      text: 'Kalodák lezárása',
      icon: Icons.inventory_2_outlined,
      onPressed: (){},
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
      icon: Icon(icon, size: 23),
      label: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        softWrap: true,
        style: const TextStyle(
          fontSize: 14,
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
  Widget _drawGerendaCard(dynamic gerenda){
    List<dynamic> items = gerenda['tetelek'] is List ? gerenda['tetelek'] : [];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x22000000)),
        boxShadow: const [BoxShadow(
          color: Color(0x33000000),
          blurRadius: 8,
          offset: Offset(0, 3),
        )],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0x182F2587),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.view_stream_outlined,
                color: Color(0xFF2F2587),
                size: 25,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GERENDA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF888888),
                  ),
                ),
                Text(
                  '#${_displayValue(gerenda['gerenda_id'])}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F2587),
                  ),
                ),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EFFA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${items.length} tétel',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F2587),
                ),
              ),
            ),
          ]),
          const Divider(height: 22),
          for(int i = 0; i < items.length; i++) ...[
            _drawArticleRow(items[i]),
            if(i < items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
  // ---------- < WidgetBuild [3] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget _drawArticleRow(dynamic item){
    int kalodaId = int.tryParse(item['kaloda_id']?.toString() ?? '') ?? 0;
    bool hasKaloda = kalodaId > 0;
    return InkWell(
      onTap: () => selectItem(item),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: hasKaloda ? const Color(0xFFE8F5E9) : const Color(0xFFF9F9FC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: hasKaloda ? const Color(0x6633AA55) : const Color(0x18000000)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 70,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: hasKaloda ? const Color(0x5533AA55) : const Color(0x22000000)),
              ),
              child: Image.network(
                item['picture']?.toString() ?? '',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported_outlined, size: 32, color: Color(0xFF999999)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _drawItemValue(Icons.receipt_long_outlined, 'Rendelés', item['rendeles'], important: true),
                const SizedBox(height: 4),
                _drawItemValue(Icons.sell_outlined, 'Cikkszám', item['cikkszam']),
                const SizedBox(height: 4),
                _drawItemValue(Icons.straighten, 'Hossz', '${_displayValue(item['hossz'])} mm'),
                const SizedBox(height: 6),
                _drawStatus(item),
                if(hasKaloda) ...[
                  const SizedBox(height: 6),
                  _drawStatusBadge(Icons.inventory_2_outlined, 'Kaloda #$kalodaId', const Color(0xFFDDF3E3), const Color(0xFF228844)),
                ],
              ],
            )),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: hasKaloda ? const Color(0xFF33AA55) : const Color(0xFFECEAF8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_displayValue(item['mennyiseg'])} db',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: hasKaloda ? const Color(0xFFFFFFFF) : const Color(0xFF2F2587)),
              ),
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
    bool important = false,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        size: 16,
        color: important ? const Color(0xFF2F2587) : const Color(0xFF777777),
      ),
      const SizedBox(width: 5),
      Expanded(child: Text(
        '$title: ${_displayValue(value)}',
        style: TextStyle(
          fontSize: important ? 14 : 13,
          fontWeight: important ? FontWeight.bold : FontWeight.normal,
          color: important ? const Color(0xFF2F2587) : const Color(0xFF555555),
        ),
      )),
    ],
  );
  // ---------- < WidgetBuild [4] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget _drawStatus(dynamic item){
    int vedofoliazas = int.tryParse(item['vedofoliazas']?.toString() ?? '') ?? 0;
    int gorgozes = int.tryParse(item['gorgozes']?.toString() ?? '') ?? 0;
    if(vedofoliazas == 1 && gorgozes == 1){
      return _drawStatusBadge(
        Icons.sync_alt,
        'Védőfóliázásra és görgőzésre vár',
        const Color(0xFFFFF3E0),
        const Color(0xFFB35A00),
      );
    }
    if(vedofoliazas == 1){
      return _drawStatusBadge(
        Icons.shield_outlined,
        'Védőfóliázásra vár',
        const Color(0xFFE8F1FF),
        const Color(0xFF2865A8),
      );
    }
    if(gorgozes == 1){
      return _drawStatusBadge(
        Icons.autorenew,
        'Görgőzésre vár',
        const Color(0xFFF3E8FF),
        const Color(0xFF7441A8),
      );
    }
    return _drawStatusBadge(
      Icons.check_circle_outline,
      'További megmunkálás nélkül',
      const Color(0xFFE7F5EA),
      const Color(0xFF278044),
    );
  }
  Widget _drawStatusBadge(
    IconData icon,
    String text,
    Color backgroundColor,
    Color foregroundColor,
  ) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: foregroundColor,
        ),
        const SizedBox(width: 5),
        Flexible(child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
        )),
      ],
    ),
  );
  // ---------- < Methods [1] > --------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Future<void> _exitRoute() async{
    bool? save = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mentés és kilépés'),
        content: const Text('Szeretnéd menteni a módosításokat és kilépni?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Igen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Mégsem'),
          ),
        ],
      ),
    );
    if(save != true) return;
    await DataManager(
      appAction: AppAction.callFinishFestesrolLeszedes,
      input: {'data': rawData},
    ).beginCall;
    if(!mounted) return;
    Global.routeBack;
    Navigator.pop(context);
  }
  String _displayValue(dynamic value){
    if(value == null || value.toString().trim().isEmpty) return '-';
    return value.toString();
  }
  Future<void> selectItem(dynamic item) async{
    List<dynamic> selectList = await DataManager(appAction: AppAction.callSelectKaloda, input: {
      'vedofoliazas': item['vedofoliazas'],
      'gorgozes':     item['gorgozes']
    }).beginCall;
    if(!mounted) return;
    Map<String, dynamic>? result = await _showRecordDialog(item, selectList);
    if(result == null) return;
    _assignKaloda(item, result['mennyiseg'], result['kaloda_id']);
  }
  Future<Map<String, dynamic>?> _showRecordDialog(dynamic item, List<dynamic> selectList) async{
    TextEditingController amountController = TextEditingController();
    int maxAmount = int.tryParse(item['mennyiseg']?.toString() ?? '') ?? 0;
    int? selectedKalodaId;
    bool validAmount = false;
    bool addingKaloda = false;
    bool kalodaAdded = false;
    Map<String, dynamic>? result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'ℹ️ Tétel kiválasztása',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                enabled: !addingKaloda,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Darabszám',
                  hintText: '1 - $maxAmount',
                  helperText: 'Maximum: $maxAmount db',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value){
                  int? amount = int.tryParse(value);
                  setDialogState(() => validAmount = amount != null && amount >= 1 && amount <= maxAmount);
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: DropdownButtonFormField<int>(
                    value: selectedKalodaId,
                    decoration: const InputDecoration(
                      labelText: 'Kaloda',
                      border: OutlineInputBorder(),
                    ),
                    items: selectList.map<DropdownMenuItem<int>>((kaloda){
                      int id = int.tryParse(kaloda['id']?.toString() ?? '') ?? 0;
                      return DropdownMenuItem<int>(
                        value: id,
                        child: Row(children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 20,
                            color: Color(0xFF2F2587),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Kaloda #$id',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ]),
                      );
                    }).toList(),
                    onChanged: addingKaloda ? null : (value) => setDialogState(() => selectedKalodaId = value),
                  )),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: addingKaloda || kalodaAdded ? null : () async{
                        setDialogState(() => addingKaloda = true);
                        int? newKalodaId = await _addKaloda(item);
                        if(!dialogContext.mounted) return;
                        setDialogState((){
                          addingKaloda = false;
                          if(newKalodaId == null) return;
                          if(!selectList.any((kaloda) => int.tryParse(kaloda['id']?.toString() ?? '') == newKalodaId)){
                            selectList.add({'id': newKalodaId});
                          }
                          selectedKalodaId = newKalodaId;
                          kalodaAdded = true;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: const Color(0xFF2F2587),
                        side: const BorderSide(color: Color(0xFF2F2587)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: addingKaloda
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add, size: 28),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: validAmount && selectedKalodaId != null && !addingKaloda ? () => Navigator.pop(dialogContext, {
                'mennyiseg': int.parse(amountController.text),
                'kaloda_id': selectedKalodaId,
              }) : null,
              child: const Text('Ok'),
            ),
            TextButton(
              onPressed: addingKaloda ? null : () => Navigator.pop(dialogContext),
              child: const Text('Mégse'),
            ),
          ],
        ),
      ),
    );
    amountController.dispose();
    return result;
  }
  Future<int?> _addKaloda(dynamic item) async{
    try{
      return await DataManager(appAction: AppAction.callKalodaFelvitele, input: {
        'vedofoliazas': item['vedofoliazas'],
        'gorgozes':     item['gorgozes']
      }).beginCall;
    }
    catch(e) {if(kDebugMode)print(e.toString());}
    return null;
  }
  void _assignKaloda(dynamic item, int amount, int kalodaId){
    for(dynamic gerenda in rawData){
      List<dynamic> items = gerenda['tetelek'] is List ? gerenda['tetelek'] : [];
      int itemIndex = items.indexWhere((rawItem) => identical(rawItem, item));
      if(itemIndex < 0) continue;
      int originalAmount = int.tryParse(item['mennyiseg']?.toString() ?? '') ?? 0;
      int remainingAmount = originalAmount - amount;
      setState((){
        if(remainingAmount > 0){
          Map<String, dynamic> remainingItem = Map<String, dynamic>.from(item);
          remainingItem['mennyiseg'] = remainingAmount;
          remainingItem['kaloda_id'] = 0;
          item['mennyiseg'] = amount;
          item['kaloda_id'] = kalodaId;
          items.insert(itemIndex + 1, remainingItem);
        }else{
          item['kaloda_id'] = kalodaId;
        }
      });
      return;
    }
  }
}
