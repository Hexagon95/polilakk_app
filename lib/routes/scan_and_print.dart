// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// These are from your project. Keep them as-is.
import 'package:logistic_app/global.dart';
import 'package:logistic_app/data_manager.dart';
import 'package:logistic_app/src/scanner_datawedge.dart';

class ScanAndPrint extends StatefulWidget {
  const ScanAndPrint({super.key});

  @override
  State<ScanAndPrint> createState() => _ScanAndPrintState();
}

class _ScanAndPrintState extends State<ScanAndPrint> {
  // --- Scanner plumbing ---
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  ScannerDatawedge? scannerDatawedge;
  ValueNotifier<ScannerDatas>? scannerDatas;
  bool scanOngoing = false;

  // --- UI state ---
  final List<Map<String, dynamic>> _rows = []; // table rows
  List<String> _columns = [];                  // table columns (inferred)
  bool _busy = false;                          // spinner overlay
  double? qrScanCutOutSize;
  double? _width;

  // --- Buttons state ---
  ButtonState _btnPrint = ButtonState.default0;
  ButtonState _btnKeyboard = ButtonState.default0;

  // --- Manual input ---
  String _manualInput = '';

  // ======== Lifecycle ========

  @override
  void initState() {
    super.initState();
    if (Global.isScannerDevice) {
      scannerDatas = ValueNotifier(ScannerDatas(scanData: ''));
      scannerDatawedge = ScannerDatawedge(
        scannerDatas: scannerDatas!,
        profileName: 'ScanAndPrint',
      );
      scannerDatas!.addListener(_onScannerHardware);
    }
  }

  @override
  void dispose() {
    scannerDatas?.removeListener(_onScannerHardware);
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (!Global.isScannerDevice) {
      if (Platform.isAndroid) controller?.pauseCamera();
      controller?.resumeCamera();
    }
  }

  // ======== Build ========

  @override
  Widget build(BuildContext context) {
    _width ??= _recalcCutout();
    if (_isScanScreen) {
      // keep cutout adaptive while on scan screen
      final w = MediaQuery.of(context).size.width;
      if (_width != w) _width = _recalcCutout();
    }

    return WillPopScope(
      onWillPop: () async {
        if (_busy) return false;
        if (!Global.isScannerDevice) await controller?.pauseCamera();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Szkennelés és nyomtatás'),
          backgroundColor: Global.getColorOfButton(ButtonState.default0),
          foregroundColor: Global.getColorOfIcon(ButtonState.default0),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 20),
                Expanded(
                  child: (_rows.isEmpty)
                      ? _buildScanArea()
                      : _buildTableArea(),
                ),
                _bottomBar,
              ],
            ),
            _floatingCount,
            _floatingHint,
            if (_busy)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  // ======== Sections ========

  Widget _buildScanArea() {
    return Stack(
      children: [
        if (!Global.isScannerDevice)
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Global.getColorOfIcon(ButtonState.default0),
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: qrScanCutOutSize ?? 240,
            ),
            onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
          )
        else
          Center(
            child: Icon(
              Icons.qr_code_scanner,
              size: 180,
              color: Global.getColorOfButton(ButtonState.default0),
            ),
          ),
      ],
    );
  }

  Widget _buildTableArea() {
    // infer columns from first row
    if (_rows.isNotEmpty && _columns.isEmpty) {
      _columns = _rows.first.keys.map((e) => e.toString()).toList(growable: false);
    }

    if (_columns.isEmpty) {
      return const Center(child: Text('Nincs adat.'));
    }

    return SingleChildScrollView(
      scrollDirection:  Axis.vertical,
      padding:          const EdgeInsets.only(bottom: 100),
      child:            SingleChildScrollView(
        scrollDirection:  Axis.horizontal,
        child:            DataTable(
          columnSpacing:    20,
          columns:          _columns.map((c) => DataColumn(label: Text(c))).toList(),
          rows:             _rows.map((row) {
            return DataRow(
              cells: _columns.map((c) {
                final v = row[c];
                return DataCell(Text(v?.toString() ?? ''));
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget get _bottomBar => Container(
        height: 56,
        color: Global.getColorOfButton(ButtonState.default0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Manual input for quick tests / fallback
            TextButton(
              onPressed: () => (_btnKeyboard == ButtonState.default0) ? _openManualInput() : null,
              child: Row(
                children: [
                  if (_btnKeyboard == ButtonState.loading)
                    _tinySpinner(Global.getColorOfIcon(_btnKeyboard)),
                  Icon(Icons.keyboard, color: Global.getColorOfIcon(_btnKeyboard)),
                ],
              ),
            ),
            TextButton(
              onPressed: () => (_btnPrint == ButtonState.default0 && _rows.isNotEmpty) ? _printAll() : null,
              child: Row(
                children: [
                  if (_btnPrint == ButtonState.loading)
                    _tinySpinner(Global.getColorOfIcon(_btnPrint)),
                  Icon(Icons.print, color: Global.getColorOfIcon(
                    _rows.isNotEmpty ? _btnPrint : ButtonState.disabled,
                  )),
                ],
              ),
            ),
          ],
        ),
      );

  Widget get _floatingHint => Positioned(
    left: 16,
    right: 16,
    bottom: 60,
    child: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Vonalkód leolvasása a hozzáadáshoz',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    ),
  );

  Widget get _floatingCount => Positioned(
    top: 2,
    left: 2,
    child: SafeArea(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Text(
            'Összesen: ${_rows.length}',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ),
  );

  // ======== Actions ========

  Future<void> _openManualInput() async {
    setState(() => _btnKeyboard = ButtonState.loading);
    final code = await _showManualDialog();
    setState(() => _btnKeyboard = ButtonState.default0);
    if (code != null && code.trim().isNotEmpty) {
      await _handleScannedCode(code.trim());
    }
  }

  Future<void> _printAll() async {
    if(_btnPrint == ButtonState.loading) return;
    setState(() => _btnPrint = ButtonState.loading);
    try {
      await DataManager(quickCall: QuickCall.printAll, input: {'list': _rows}).beginQuickCall;
      if(DataManager.isServerAvailable){
        _rows.clear();
        _columns = [];
      }
    }
    catch(_) {}
    finally {
      setState(() => _btnPrint = ButtonState.default0);
    }
  }

  // ======== Scanner handlers ========

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    ctrl.scannedDataStream.listen((scanData) {
      final code = scanData.code;
      if (code != null) _handleScannedCode(code);
    });
    controller?.resumeCamera();
  }

  Future<void> _handleScannedCode(String code) async {
    if (scanOngoing) return;
    scanOngoing = true;
    setState(() => _busy = true);

    try {
      await DataManager(
        quickCall: QuickCall.scanBarcodeForSticker,
        input: {'code': code},
      ).beginQuickCall;

      final dynamic payload = DataManager.dataQuickCall[36][0];

      // Normalize to List<Map<String, dynamic>>
      List<Map<String, dynamic>> rows = [];
      if (payload is List) {
        rows = payload.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
      } else if (payload is Map) {
        rows = [Map<String, dynamic>.from(payload)];
      } else if (payload is String) {
        final decoded = jsonDecode(payload);
        if (decoded is List) {
          rows = decoded.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
        } else if (decoded is Map) {
          rows = [Map<String, dynamic>.from(decoded)];
        }
      }

      // Infer columns once (from first row)
      if (_columns.isEmpty && rows.isNotEmpty) {
        _columns = rows.first.keys.map((e) => e.toString()).toList(growable: false);
      }

      // Filter out duplicates by "id" (change to "barcode" if that's your unique key)
      for (var row in rows) {
        final newId = row['id']?.toString();
        final alreadyExists = _rows.any((existing) => existing['id']?.toString() == newId);
        if (!alreadyExists) {
          _rows.add(row);
        }
      }

      setState(() {});
    } catch (e) {
      if (kDebugMode) print('scan error: $e');
    } finally {
      setState(() => _busy = false);
      scanOngoing = false;
    }
  }

  void _onScannerHardware() {
    final code = scannerDatas?.value.scanData.trim();
    if ((code ?? '').isEmpty) return;
    _handleScannedCode(code!);
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nincs kamera jogosultság!')),
      );
    }
  }

  // ======== Helpers ========

  bool get _isScanScreen => _rows.isEmpty;

  double _recalcCutout() {
    qrScanCutOutSize = (MediaQuery.of(context).size.width <= MediaQuery.of(context).size.height)
        ? MediaQuery.of(context).size.width * 0.6
        : MediaQuery.of(context).size.height * 0.6;
    return MediaQuery.of(context).size.width;
  }

  Widget _tinySpinner(Color color) => Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        ),
      );

  Future<String?> _showManualDialog() async {
    _manualInput = '';
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Vonalkód manuálisan'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Írja be a kódot…'),
            onChanged: (v) => _manualInput = v,
            onSubmitted: (v) {
              Navigator.pop(ctx, v);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Mégse'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, _manualInput),
              child: const Text('OK'),
            ),
          ],
        );
      },
      barrierDismissible: true,
    );
  }
}
