import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:socket_io_common/src/util/event_emitter.dart';

import '../../../Core/Utils/firebase_constants.dart';
import '../../../Models/get_commodity_model.dart';
import '../../../Models/get_server_details.dart';
import 'live_repository.dart';

class LiveRateState {
  final Map<String, dynamic> marketData;
  final bool isConnected;

  LiveRateState({required this.marketData, required this.isConnected});

  LiveRateState copyWith({
    Map<String, dynamic>? marketData,
    bool? isConnected,
  }) {
    return LiveRateState(
      marketData: marketData ?? this.marketData,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

// Create the provider
final liveRateProviderssssss =
    StateNotifierProvider<LiveRateNotifier2, LiveRateState>((ref) {
  return LiveRateNotifier2();
});

class LiveRateNotifier2 extends StateNotifier<LiveRateState> {
  IO.Socket? _socket;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectInterval = const Duration(seconds: 5);

  LiveRateNotifier2()
      : super(LiveRateState(marketData: {}, isConnected: false)) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final serverLink = await fetchServerLink();
      await initializeSocketConnection(link: serverLink);
    } catch (e) {
      print('Error initializing LiveRateNotifier: $e');
    }
  }

  Future<List<String>> fetchCommodityArray() async {
    const id = "IfiuH/ko+rh/gekRvY4Va0s+aGYuGJEAOkbJbChhcqo=";
    try {
      final response = await http.get(
        Uri.parse(
            '${FirebaseConstants.baseUrl}get-commodities/${FirebaseConstants.adminId}'),
        headers: {
          'X-Secret-Key': id,
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final commodity = GetCommodityModel.fromMap(json.decode(response.body));
        return commodity.commodities;
      } else {
        throw Exception(
            'Failed to load commodity data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching commodity array: $e');
      return [];
    }
  }

  Future<String> fetchServerLink() async {
    try {
      final response = await http.get(
        Uri.parse('${FirebaseConstants.baseUrl}get-server'),
        headers: {
          'X-Secret-Key': FirebaseConstants.secretKey,
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final serverInfo = GetServerModel.fromMap(json.decode(response.body));
        return serverInfo.info.serverUrl;
      } else {
        throw Exception('Failed to load server link: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching server link: $e');
      rethrow;
    }
  }

  Future<void> initializeSocketConnection({required String link}) async {
    _socket = IO.io(link, <String, dynamic>{
      'transports': ['websocket'],
      'query': {
        'secret': 'aurify@123', // Secret key for authentication
      },
      'reconnection': false, // We'll handle reconnection manually
    });

    _socket!.onConnect(() async {
      print('Connected to WebSocket server');
      state = state.copyWith(isConnected: true);
      _reconnectAttempts = 0;
      List<String> commodityArray = await fetchCommodityArray();
      _requestMarketData(commodityArray);
    } as EventHandler);

    _socket?.on('market-data', (data) {
      print("Received market data: $data");
      if (data != null &&
          data is Map<String, dynamic> &&
          data['symbol'] != null) {
        final updatedMarketData = Map<String, dynamic>.from(state.marketData);
        updatedMarketData[data['symbol']] = data;
        state = state.copyWith(marketData: updatedMarketData);
        print("Market2 data2 updated for symbol2: ${data['symbol']}");
      } else {
        print("Received invalid market data format: $data");
      }
    });

    _socket?.on('heartbeat', (data) {
      print("Received heartbeat: $data");
      _socket?.emit('heartbeat', 'pong');
    });

    _socket?.onConnectError((data) {
      print('Connection Error: $data');
      _handleDisconnection();
    });

    _socket?.onDisconnect(() {
      print('Disconnected from WebSocket server');
      _handleDisconnection();
    } as EventHandler);

    _socket?.connect();
  }

  void _handleDisconnection() {
    state = state.copyWith(isConnected: false);
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    } else {
      print(
          'Max reconnection attempts reached. Please check your internet connection and try again later.');
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectInterval, () {
      if (!state.isConnected) {
        _reconnectAttempts++;
        print(
            'Attempting to reconnect... (Attempt $_reconnectAttempts/$_maxReconnectAttempts)');
        _socket?.connect();
      }
    });
  }

  void _requestMarketData(List<String> symbols) {
    if (state.isConnected) {
      print("Requesting market data for symbols: $symbols");
      _socket?.emit('request-data', symbols);
    } else {
      print('Not connected. Unable to request market data.');
    }
  }

  Future<void> refreshData() async {
    if (state.isConnected) {
      List<String> commodityArray = await fetchCommodityArray();
      _requestMarketData(commodityArray);
    } else {
      print('Not connected. Attempting to reconnect...');
      _socket?.connect();
    }
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    super.dispose();
  }
}
