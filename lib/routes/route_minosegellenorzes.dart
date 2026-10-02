import 'package:polilakk_app/data_manager.dart';
import 'package:polilakk_app/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RouteMinosegellenorzes extends StatefulWidget{
  const RouteMinosegellenorzes({super.key});

  @override
  State<RouteMinosegellenorzes> createState() => RouteMinosegellenorzesState();
}

class RouteMinosegellenorzesState extends State<RouteMinosegellenorzes>{
  static List<dynamic> rawData = [];
  late double _contentWidth;

  @override
  Widget build(BuildContext context){
    _contentWidth = (MediaQuery.sizeOf(context).width - 10).clamp(0.0, 700.0).toDouble();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async{
        if(didPop) return;
        await _finishAllAndPop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Minőségellenőrzés', style: TextStyle(fontSize: 18)),
          backgroundColor: const Color(0xFF2F2587),
          foregroundColor: Colors.white,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('images/background.png'), fit: BoxFit.cover)),
          child: SafeArea(child: _drawContent),
        ),
      ),
    );
  }

  Widget get _drawContent => Center(child: SizedBox(
    width: _contentWidth,
    child: rawData.isEmpty
      ? const Center(child: Text('Nincs minőségellenőrzésre váró tétel.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))
      : ListView(
          padding: const EdgeInsets.all(10),
          children: [
            for(int i = 0; i < rawData.length; i++) ...[
              _drawGerendaCard(rawData[i]),
              if(i < rawData.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
  ));

  Widget _drawGerendaCard(dynamic gerenda){
    List<dynamic> items = gerenda['tetelek'] is List ? gerenda['tetelek'] : [];
    bool readyToClose = items.isNotEmpty && items.every((item) => item['kiertekeles'] != null);
    bool resolved = gerenda['lezarva']?.toString() == '1';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: resolved ? const Color(0xFFF3F7F4) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: resolved ? const Color(0x5533AA55) : const Color(0x22000000), width: resolved ? 1.5 : 1),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(resolved ? Icons.verified_outlined : Icons.view_stream_outlined, color: resolved ? const Color(0xFF229944) : const Color(0xFF4444CC), size: 25),
            const SizedBox(width: 7),
            const Text('GERENDA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF888888))),
            const SizedBox(width: 8),
            Expanded(child: Text(_displayValue(gerenda['gerenda_id']), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: resolved ? const Color(0xFF228844) : const Color(0xFF4444CC)))),
          ]),
          const SizedBox(height: 9),
          _drawGerendaValue(Icons.grain_outlined, 'Por kód', gerenda['porkod'], resolved),
          const SizedBox(height: 5),
          _drawGerendaValue(Icons.palette_outlined, 'Szín', gerenda['szin'], resolved),
          const Divider(height: 22),
          for(int i = 0; i < items.length; i++) ...[
            _drawArticleRow(items[i]),
            if(i < items.length - 1) const Divider(height: 14),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: readyToClose && !resolved ? () => _closeGerenda(gerenda) : null,
              icon: const Icon(Icons.save_outlined),
              label: Text(resolved ? 'Mentve' : 'Mentés'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F2587),
                foregroundColor: Colors.white,
                disabledBackgroundColor: resolved ? const Color(0xFFDDE8E0) : const Color(0xFFE0E0E0),
                disabledForegroundColor: resolved ? const Color(0xFF669977) : const Color(0xFF999999),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawGerendaValue(IconData icon, String title, dynamic value, bool closed) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 18, color: closed ? const Color(0xFF669977) : const Color(0xFF777777)),
      const SizedBox(width: 6),
      Expanded(child: Text('$title: ${_displayValue(value)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: closed ? const Color(0xFF557766) : const Color(0xFF333333)))),
    ],
  );

  Widget _drawArticleRow(dynamic item){
    bool closed = item['kiertekeles'] != null;
    bool accepted = item['kiertekeles']?.toString() == '1';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: closed ? accepted ? const Color(0xFFEAF6ED) : const Color(0xFFFFEEEE) : const Color(0xFFF8F8FC),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: closed ? accepted ? const Color(0x5533AA55) : const Color(0x55CC3333) : const Color(0x22000000)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 64,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(7), border: Border.all(color: const Color(0x22000000))),
            child: Image.network(item['picture']?.toString() ?? '', fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported_outlined, size: 30, color: Color(0xFF999999))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _drawItemValue(Icons.receipt_long_outlined, 'Rendelés', item['rendeles'], closed, accepted),
              const SizedBox(height: 4),
              _drawItemValue(Icons.inventory_2_outlined, 'Cikkszám', item['cikkszam'], closed, accepted, bold: true),
              const SizedBox(height: 4),
              _drawItemValue(Icons.straighten, 'Hossz', '${_displayValue(item['hossz'])} mm', closed, accepted),
              const SizedBox(height: 4),
              _drawItemValue(Icons.numbers, 'Mennyiség', '${_displayValue(item['mennyiseg'])} db', closed, accepted),
              if(closed && !accepted) ...[
                const SizedBox(height: 4),
                _drawItemValue(Icons.delete_outline, 'Selejt', '${_displayValue(item['selejt_mennyiseg'])} db', true, false),
                if(item['megjegyzes'] != null && item['megjegyzes'].toString().trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _drawItemValue(Icons.notes_outlined, 'Megjegyzés', item['megjegyzes'], true, false),
                ],
              ],
            ],
          )),
          const SizedBox(width: 10),
          closed
            ? Icon(accepted ? Icons.check_circle : Icons.cancel, color: accepted ? const Color(0xFF229944) : const Color(0xFFCC3333), size: 34)
            : Column(children: [
                _drawDecisionButton(Icons.check, const Color(0xFF229944), () => _acceptItem(item)),
                const SizedBox(height: 8),
                _drawDecisionButton(Icons.close, const Color(0xFFCC3333), () => _rejectItem(item)),
              ]),
        ],
      ),
    );
  }

  Widget _drawItemValue(IconData icon, String title, dynamic value, bool closed, bool accepted, {bool bold = false}) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 15, color: !closed ? const Color(0xFF777777) : accepted ? const Color(0xFF669977) : const Color(0xFFAA6666)),
      const SizedBox(width: 5),
      Expanded(child: Text('$title: ${_displayValue(value)}', style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.bold : FontWeight.w500, color: !closed ? const Color(0xFF444444) : accepted ? const Color(0xFF557766) : const Color(0xFF995555)))),
    ],
  );

  Widget _drawDecisionButton(IconData icon, Color color, VoidCallback onPressed) => Material(
    color: color,
    elevation: 2,
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: SizedBox(width: 42, height: 42, child: Icon(icon, color: Colors.white, size: 27)),
    ),
  );

  String _displayValue(dynamic value){
    if(value == null || value.toString().trim().isEmpty) return '-';
    return value.toString();
  }

  Future<void> _acceptItem(dynamic item) async{
    bool confirm = await Global.yesNoDialog(context, title: '⚠️ Megerősítés', content: '${_displayValue(item['cikkszam'])} cikkszámú terméket megfelelőnek ítéli?');
    if(!confirm) return;
    if(!mounted) return;
    setState((){
      item['selejt_mennyiseg'] = 0;
      item['kiertekeles'] = 1;
      item['time_stamp'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      item['user_id'] = DataManager.userID;
    });
  }

  Future<void> _rejectItem(dynamic item) async{
    Map<String, dynamic>? result = await _rejectDialog(item);
    if(result == null) return;
    int rejectedAmount = result['selejt_mennyiseg'];
    int originalAmount = int.tryParse(item['mennyiseg']?.toString() ?? '') ?? 0;
    if(!mounted) return;
    setState((){
      if(rejectedAmount < originalAmount){
        Map<String, dynamic> remainingItem = Map<String, dynamic>.from(item);
        remainingItem['mennyiseg'] = originalAmount - rejectedAmount;
        remainingItem['folyamat_id'] = 0;
        remainingItem.remove('selejt_mennyiseg');
        remainingItem.remove('kiertekeles');
        remainingItem.remove('megjegyzes');
        remainingItem.remove('time_stamp');
        remainingItem['user_id'] = DataManager.userID;
        for(dynamic gerenda in rawData){
          List<dynamic> items = gerenda['tetelek'] is List ? gerenda['tetelek'] : [];
          int itemIndex = items.indexWhere((record) => identical(record, item));
          if(itemIndex < 0) continue;
          items.insert(itemIndex + 1, remainingItem);
          break;
        }
      }
      item['mennyiseg'] = rejectedAmount;
      item['selejt_mennyiseg'] = rejectedAmount;
      item['kiertekeles'] = 0;
      item['megjegyzes'] = result['megjegyzes'];
      item['time_stamp'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      item['user_id'] = DataManager.userID;
    });
  }

  Future<void> _closeGerenda(dynamic gerenda) async{
    List<dynamic> dataToSend = [Map<String, dynamic>.from(gerenda)];
    await DataManager(appAction: AppAction.callFinishMinosegellenorzes, input: {'data': dataToSend}).beginCall;
    dynamic refreshedData = await DataManager(appAction: AppAction.callMinosegellenorzes).beginCall;
    if(!mounted) return;
    setState(() => rawData = refreshedData);
  }

  Future<void> _finishAllAndPop() async{
    await DataManager(appAction: AppAction.callFinishMinosegellenorzes, input: {'data': rawData}).beginCall;
    if(!mounted) return;
    Global.routeBack;
    Navigator.pop(context);
  }

  Future<Map<String, dynamic>?> _rejectDialog(dynamic item) async{
    TextEditingController amountController = TextEditingController();
    TextEditingController noteController = TextEditingController();
    int maxAmount = int.tryParse(item['mennyiseg']?.toString() ?? '') ?? 1;
    String? amountError;
    return await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState){
          void submit(){
            int? amount = int.tryParse(amountController.text);
            if(amount == null || amount < 1 || amount > maxAmount){
              setDialogState(() => amountError = 'Adjon meg 1 és $maxAmount közötti értéket!');
              return;
            }
            Navigator.pop(dialogContext, {'selejt_mennyiseg': amount, 'megjegyzes': noteController.text.trim()});
          }
          return AlertDialog(
            title: const Row(children: [
              Icon(Icons.report_problem_outlined, color: Color(0xFFCC3333), size: 22),
              SizedBox(width: 7),
              Text('Selejt rögzítése', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ]),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TextInputFormatter.withFunction((oldValue, newValue){
                        if(newValue.text.isEmpty) return newValue;
                        int? value = int.tryParse(newValue.text);
                        if(value == null || value < 1 || value > maxAmount) return oldValue;
                        return newValue;
                      }),
                    ],
                    onChanged: (_){
                      if(amountError != null) setDialogState(() => amountError = null);
                    },
                    decoration: InputDecoration(labelText: 'Selejtek száma', helperText: 'Maximum: $maxAmount db', errorText: amountError, prefixIcon: const Icon(Icons.delete_outline), border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: noteController,
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Megjegyzés', alignLabelWithHint: true, prefixIcon: Icon(Icons.notes_outlined), border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Mégse')),
              TextButton(onPressed: submit, child: const Text('Ok')),
            ],
          );
        },
      ),
    );
  }
}
