import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

enum ConnectionStatus { online, offline, unknown }

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  ConnectionStatus _connectionStatus = ConnectionStatus.unknown;
  final StreamController<ConnectionStatus> _connectionController = 
      StreamController<ConnectionStatus>.broadcast();

  // Getters
  ConnectionStatus get connectionStatus => _connectionStatus;
  Stream<ConnectionStatus> get connectionStream => _connectionController.stream;
  bool get isOnline => _connectionStatus == ConnectionStatus.online;
  bool get isOffline => _connectionStatus == ConnectionStatus.offline;

  // Initialize connectivity service
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      await _updateConnectionStatus();
      
      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          debugPrint('Connectivity error: $error');
          _updateConnectionStatus(ConnectionStatus.unknown);
        },
      );
    } catch (e) {
      debugPrint('Failed to initialize connectivity service: $e');
      _updateConnectionStatus(ConnectionStatus.unknown);
    }
  }

  // Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      _updateConnectionStatus(ConnectionStatus.offline);
      return;
    }

    // Check if any connection is available (any result except none)
    final hasConnection = results.any((result) => result != ConnectivityResult.none);

    _updateConnectionStatus(
      hasConnection ? ConnectionStatus.online : ConnectionStatus.offline,
    );
  }

  // Update connection status
  Future<void> _updateConnectionStatus([ConnectionStatus? status]) async {
    if (status != null) {
      _connectionStatus = status;
    } else {
      try {
        final results = await _connectivity.checkConnectivity();
        _onConnectivityChanged(results);
        return;
      } catch (e) {
        debugPrint('Error checking connectivity: $e');
        _connectionStatus = ConnectionStatus.unknown;
      }
    }

    _connectionController.add(_connectionStatus);
    debugPrint('Connection status updated: $_connectionStatus');
  }

  // Check current connectivity
  Future<ConnectionStatus> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _onConnectivityChanged(results);
      return _connectionStatus;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return ConnectionStatus.unknown;
    }
  }

  // Get connection type details
  Future<Map<String, dynamic>> getConnectionDetails() async {
    try {
      final results = await _connectivity.checkConnectivity();
      
      return {
        'status': _connectionStatus.toString(),
        'types': results.map((r) => r.toString()).toList(),
        'isOnline': isOnline,
        'isOffline': isOffline,
        'lastChecked': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
        'lastChecked': DateTime.now().toIso8601String(),
      };
    }
  }

  // Wait for connection
  Future<bool> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (isOnline) return true;

    final completer = Completer<bool>();
    late StreamSubscription subscription;

    // Set up timeout
    final timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.complete(false);
      }
    });

    // Listen for connection
    subscription = connectionStream.listen((status) {
      if (status == ConnectionStatus.online && !completer.isCompleted) {
        timeoutTimer.cancel();
        subscription.cancel();
        completer.complete(true);
      }
    });

    return completer.future;
  }

  // Execute with connectivity check
  Future<T?> executeWithConnectivity<T>(
    Future<T> Function() operation, {
    T? Function()? fallback,
    bool requireConnection = true,
  }) async {
    if (requireConnection && isOffline) {
      if (fallback != null) {
        return fallback();
      }
      throw Exception('No internet connection available');
    }

    try {
      return await operation();
    } catch (e) {
      if (isOffline && fallback != null) {
        return fallback();
      }
      rethrow;
    }
  }

  // Retry operation when connection is restored
  Future<T?> retryWhenOnline<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        if (isOffline) {
          await waitForConnection();
        }
        
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        await Future.delayed(retryDelay);
      }
    }
    
    return null;
  }

  // Get connection type string
  String getConnectionTypeString() {
    switch (_connectionStatus) {
      case ConnectionStatus.online:
        return 'Online';
      case ConnectionStatus.offline:
        return 'Offline';
      case ConnectionStatus.unknown:
        return 'Unknown';
    }
  }

  // Get connection icon
  IconData getConnectionIcon() {
    switch (_connectionStatus) {
      case ConnectionStatus.online:
        return Icons.wifi;
      case ConnectionStatus.offline:
        return Icons.wifi_off;
      case ConnectionStatus.unknown:
        return Icons.help_outline;
    }
  }

  // Get connection color
  Color getConnectionColor() {
    switch (_connectionStatus) {
      case ConnectionStatus.online:
        return Colors.green;
      case ConnectionStatus.offline:
        return Colors.red;
      case ConnectionStatus.unknown:
        return Colors.orange;
    }
  }

  // Dispose
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionController.close();
  }
}