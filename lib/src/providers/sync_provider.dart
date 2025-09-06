import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/database_service.dart';

class SyncProvider with ChangeNotifier {
  bool _online = false;
  bool _syncing = false;
  int _pending = 0;

  bool get isOnline => _online;
  bool get isSyncing => _syncing;
  int get pendingSyncCount => _pending;

  SyncProvider() {
    _monitor();
    checkSyncStatus();
  }

  void _monitor() {
    Connectivity().onConnectivityChanged.listen((res) async {
      _online = res != ConnectivityResult.none;
      notifyListeners();
      if (_online && _pending > 0) await syncData();
    });
  }

  Future<void> checkSyncStatus() async {
    _online = (await Connectivity().checkConnectivity()) != ConnectivityResult.none;
    _pending = await DatabaseService.instance.getPendingSyncCount();
    notifyListeners();
  }

  Future<void> syncData() async {
    if (_syncing || !_online) return;
    _syncing = true; notifyListeners();
    try {
      final items = await DatabaseService.instance.getPendingDatasets();
      for (final it in items) {
        // TODO: upload pending dataset file if cached; then:
        await DatabaseService.instance.markAsSynced(it.id);
      }
      _pending = await DatabaseService.instance.getPendingSyncCount();
    } finally {
      _syncing = false; notifyListeners();
    }
  }
}