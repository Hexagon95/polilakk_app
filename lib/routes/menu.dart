import 'package:flutter/material.dart';
import 'package:polilakk_app/routes/route_festesrol_leszedes.dart';
import 'package:polilakk_app/routes/route_minosegellenorzes.dart';
import 'package:polilakk_app/routes/route_festesre_felrakas.dart';
import 'package:polilakk_app/routes/route_kosarba_helyezes.dart';
import 'package:polilakk_app/routes/route_vedofoliazas.dart';
import 'package:polilakk_app/routes/route_elokezeles.dart';
import 'package:polilakk_app/routes/route_porfestes.dart';
import 'package:polilakk_app/data_manager.dart';
import 'package:polilakk_app/global.dart';

class MenuFrame extends StatefulWidget {//---------- ---------- ---------- ---------- ---------- ---------- ---------- <MenuFrame>
  const MenuFrame({super.key});

  @override
  State<MenuFrame> createState() => MenuState();
}

class MenuState extends State<MenuFrame> {//---------- ---------- ---------- ---------- ---------- ---------- ---------- <MenuState>
  // ---------- [🌸 simple variables] --- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  late double _contentWidth;
  String? _loadingButton;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollUp = false;
  bool _showScrollDown = false;

  // ---------- < WidgetBuild [0] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  @override
  Widget build(BuildContext context){
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollIndicators());
    final double screenWidth = MediaQuery.sizeOf(context).width;
    _contentWidth = (screenWidth - 80).clamp(0.0, 500.0).toDouble();
    return PopScope(
      canPop: _loadingButton == null,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 52,
          centerTitle: true,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.dashboard_rounded, size: 23),
              SizedBox(width: 8),
              Text(
                'Műveletek',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2F2587),
          foregroundColor: const Color(0xFFFFFFFF),
          automaticallyImplyLeading: false,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          )),
          child: SafeArea(child: Stack(children: [
            _drawMenu,
            if(_showScrollUp)
              Positioned(
                top: 10,
                right: 10,
                child: _drawScrollHint(
                  icon: Icons.keyboard_arrow_up_rounded,
                  onPressed: () => _scrollMenu(-1),
                ),
              ),
            if(_showScrollDown)
              Positioned(
                bottom: 10,
                right: 10,
                child: _drawScrollHint(
                  icon: Icons.keyboard_arrow_down_rounded,
                  onPressed: () => _scrollMenu(1),
                ),
              ),
          ])),
        ),
      ),
    );
  }

  // ---------- < WidgetBuild [1] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget get _drawMenu => Align(
    alignment: Alignment.topLeft,
    child: SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(25, 20, 40, 20),
      child: SizedBox(width: _contentWidth, child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _menuWidgets,
      )),
    ),
  );

  Widget _drawScrollHint({
    required IconData icon,
    required VoidCallback onPressed,
  }) => Material(
    color: const Color(0xDD2F2587),
    elevation: 6,
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(
          icon,
          color: const Color(0xFFFFFFFF),
          size: 25,
        ),
      ),
    ),
  );

  // ---------- < WidgetBuild [2] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  List<Widget> get _menuWidgets => [
    _drawMenuButton('Kosárba helyezés', Icons.shopping_basket_outlined),
    const SizedBox(height: 12),
    _drawMenuButton('Előkezelés', Icons.cleaning_services_outlined),
    const SizedBox(height: 12),
    _drawMenuButton('Festésre felrakás', Icons.construction_outlined),
    const SizedBox(height: 12),
    _drawMenuButton('Porfestés', Icons.format_paint_outlined),
    const SizedBox(height: 12),
    _drawMenuButton('Minőségellenőrzés', Icons.fact_check_outlined),
    const SizedBox(height: 12),
    _drawMenuButton('Festésről leszedés', Icons.download_outlined),
    const SizedBox(height: 12),
    _drawMenuButton('Védőfóliázás', Icons.shield_outlined),
    const SizedBox(height: 12),
    _drawMenuButton('Görgőzés', Icons.settings_outlined),
  ];

  // ---------- < WidgetBuild [3] > ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  Widget _drawMenuButton(String text, IconData icon){
    final bool isLoading = _loadingButton == text;
    final bool isLocked = _loadingButton != null;
    final VoidCallback? buttonAction = switch(text) {
      'Kosárba helyezés' => buttonKosarbaHelyezesPressed,
      'Előkezelés' => buttonElokezelesPressed,
      'Festésre felrakás' => buttonFestesreFelrakasPressed,
      'Porfestés' => buttonPorfestesPressed,
      'Minőségellenőrzés' => buttonMinosegellenorzesPressed,
      'Festésről leszedés' => buttonFestesrolLeszedesPressed,
      'Védőfóliázás' => buttonVedofoliazasPressed,
      _ => null,
    };
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: (isLocked || buttonAction == null)? null : buttonAction,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading? const Color(0xFF766DC4) : const Color(0xFF2F2587),
          foregroundColor: Colors.white,
          disabledBackgroundColor: isLoading? const Color(0xFF766DC4) : const Color(0x442F2587),
          disabledForegroundColor: Colors.white,
          elevation: isLoading? 0 : 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isLoading
            ? const Row(
                key: ValueKey('loading'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 14),
                  Text(
                    'Betöltés...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Padding(
                key: ValueKey(text),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(icon, size: 23),
                    const SizedBox(width: 12),
                    Flexible(child: Text(
                      text,
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    )),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  // ---------- < Methods [1] > --------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- //
  @override
  void initState(){
    super.initState();
    _scrollController.addListener(_updateScrollIndicators);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollIndicators());
  }

  @override
  void dispose(){
    _scrollController.removeListener(_updateScrollIndicators);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollIndicators(){
    if(!_scrollController.hasClients) return;
    bool showUp = _scrollController.position.pixels > _scrollController.position.minScrollExtent + 1;
    bool showDown = _scrollController.position.pixels < _scrollController.position.maxScrollExtent - 1;
    if(showUp == _showScrollUp && showDown == _showScrollDown) return;
    if(mounted) {setState(() {_showScrollUp = showUp; _showScrollDown = showDown;});}
  }

  Future<void> _scrollMenu(int direction) async{
    if(!_scrollController.hasClients) return;
    double distance = _scrollController.position.viewportDimension * 0.75 * direction;
    double target = (_scrollController.offset + distance).clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    ).toDouble();
    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _runMenuAction(String buttonName, Future<void> Function() action) async{
    if(_loadingButton != null) return;
    setState(() => _loadingButton = buttonName);
    try{
      await action();
    }
    finally{
      if(mounted) setState(() => _loadingButton = null);
    }
  }

  Future<void> buttonKosarbaHelyezesPressed() async{
    await _runMenuAction('Kosárba helyezés', () async{
      await DataManager(appAction: AppAction.callverzio, input: context).beginCall;
      if(!mounted) return;
      RouteKosarbaHelyezesState.rawData = await DataManager(appAction: AppAction.callKosarbaHelyezes).beginCall;
      if(!mounted) return;
      Global.routeNext = AppAction.routeKosarbaHelyezes;
      await Navigator.pushNamed(context, '/menu/kosarba_helyezes');
    });
  }

  Future<void> buttonElokezelesPressed() async{
    await _runMenuAction('Előkezelés', () async{
      await DataManager(appAction: AppAction.callverzio, input: context).beginCall;
      if(!mounted) return;
      RouteElokezelesState.rawData = await DataManager(appAction: AppAction.callElokezeles).beginCall;
      if(!mounted) return;
      Global.routeNext = AppAction.routeElokezeles;
      await Navigator.pushNamed(context, '/menu/elokezeles');
    });
  }

  Future<void> buttonFestesreFelrakasPressed() async{
    await _runMenuAction('Festésre felrakás', () async{
      await DataManager(appAction: AppAction.callverzio, input: context).beginCall;
      if(!mounted) return;
      RouteFestesreFelrakasState.rawData = await DataManager(appAction: AppAction.callFestesreFelrakas).beginCall;
      if(!mounted) return;
      RouteFestesreFelrakasState.dataGerenda = await DataManager(appAction: AppAction.callGerenda).beginCall;
      if(!mounted) return;
      Global.routeNext = AppAction.routeFestesreFelrakas;
      await Navigator.pushNamed(context, '/menu/festesre_felrakas');
    });
  }

  Future<void> buttonPorfestesPressed() async{
    await _runMenuAction('Porfestés', () async{
      await DataManager(appAction: AppAction.callverzio, input: context).beginCall;
      if(!mounted) return;
      RoutePorfestesState.rawData = await DataManager(appAction: AppAction.callPorfestes).beginCall;
      if(!mounted) return;
      Global.routeNext = AppAction.routePorfestes;
      await Navigator.pushNamed(context, '/menu/porfestes');
    });
  }

  Future<void> buttonMinosegellenorzesPressed() async{
    await _runMenuAction('Minőségellenőrzés', () async{
      await DataManager(appAction: AppAction.callverzio, input: context).beginCall;
      if(!mounted) return;
      RouteMinosegellenorzesState.rawData = await DataManager(appAction: AppAction.callMinosegellenorzes).beginCall;
      if(!mounted) return;
      Global.routeNext = AppAction.routeMinosegellenorzes;
      await Navigator.pushNamed(context, '/menu/minosegellenorzes');
    });
  }

  Future<void> buttonFestesrolLeszedesPressed() async{
    await _runMenuAction('Festésről leszedés', () async{
      await DataManager(appAction: AppAction.callverzio, input: context).beginCall;
      if(!mounted) return;
      RouteFestesrolLeszedesState.rawData = await DataManager(appAction: AppAction.callFestesrolLeszedes).beginCall;
      if(!mounted) return;
      Global.routeNext = AppAction.routeFestesrolLeszedes;
      await Navigator.pushNamed(context, '/menu/festesrol_leszedes');
    });
  }

  Future<void> buttonVedofoliazasPressed() async{
    await _runMenuAction('Védőfóliázás', () async{
      await DataManager(appAction: AppAction.callverzio, input: context).beginCall;
      if(!mounted) return;
      RouteVedofoliazasState.rawData = await DataManager(appAction: AppAction.callVedofoliazas).beginCall;
      if(!mounted) return;
      Global.routeNext = AppAction.routeVedofoliazas;
      await Navigator.pushNamed(context, '/menu/vedofoliazas');
    });
  }
}