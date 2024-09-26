import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulparambil/Models/liverate_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

import '../../../Core/Utils/firebase_constants.dart';
import '../../../Models/get_commodity_model.dart';
import '../../../Models/get_server_details.dart';
import '../../../Models/liverate_model.dart';
//
// class LiveRateNotifier extends StateNotifier<LiveRateModel?> {
//   IO.Socket? _socket;
//   Map<String, dynamic> marketData = {};
//   LiveRateNotifier() : super(null) {
//     _initializeSocketConnection();
//   }
//   final link = 'https://capital-server-9ebj.onrender.com';
//   void _initializeSocketConnection() {
//     _socket = IO.io(link, <String, dynamic>{
//       'transports': ['websocket'],
//       'query': {
//         'secret': 'aurify@123', // Secret key for authentication
//       },
//     });
//     final commodityArray = ['GOLD', 'SILVER'];
//     _socket?.on('connect', (_) {
//       print('Connected to WebSocket server');
//       _requestMarketData(commodityArray);
//     });
//
//     _socket?.on('market-data', (data) {
//       // print("********************************************");
//       // print(data.toString());
//       if (data != null && data['symbol'] != null) {
//         marketData[data['symbol']] = data;
//         state = LiveRateModel.fromJson(marketData);
//         // print("###############################################");
//         // print(marketData);
//       }
//     });
//
//     _socket?.on('connect_error', (data) {
//       print('Connection Error: $data');
//     });
//
//     _socket?.on('disconnect', (_) {
//       print('Disconnected from WebSocket server');
//     });
//   }
//
//   void _requestMarketData(List<String> symbols) {
//     _socket?.emit('request-data', symbols);
//   }
//
//   @override
//   void dispose() {
//     _socket?.disconnect();
//     super.dispose();
//   }
// }
//
// final liveRateProvider =
//     StateNotifierProvider<LiveRateNotifier, LiveRateModel?>((ref) {
//   return LiveRateNotifier();
// });
///

// class LiveRateNotifier extends StateNotifier<LiveRateModel?> {
//   IO.Socket? _socket;
//   Map<String, dynamic> marketData = {};
//
//   LiveRateNotifier() : super(null) {
//     initializeSocketConnection();
//   }
//
//   final link = 'https://capital-server-9ebj.onrender.com';
//
//   Future<void> initializeSocketConnection() async {
//     _socket = IO.io(link, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//       'query': {
//         'secret': 'aurify@123',
//       },
//     });
//
//     final commodityArray = ['GOLD', 'SILVER'];
//
//     _socket?.onConnect((_) {
//       print('Connected to WebSocket server');
//       _requestMarketData(commodityArray);
//     });
//
//     _socket?.on('market-data', (data) {
//       if (data != null && data['symbol'] != null) {
//         marketData[data['symbol']] = data;
//         state = LiveRateModel.fromJson(marketData);
//       }
//     });
//
//     _socket?.onConnectError((data) => print('Connection Error: $data'));
//     _socket?.onDisconnect((_) => print('Disconnected from WebSocket server'));
//
//     await _socket?.connect();
//   }
//
//   void _requestMarketData(List<String> symbols) {
//     _socket?.emit('request-data', symbols);
//   }
//
//   @override
//   void dispose() {
//     _socket?.disconnect();
//     super.dispose();
//   }
// }
//
// final liveRateProvider =
//     StateNotifierProvider<LiveRateNotifier, LiveRateModel?>((ref) {
//   return LiveRateNotifier();
// });
class LiveRateNotifier extends StateNotifier<LiveRateModel?> {
  IO.Socket? _socket;
  Map<String, dynamic> marketData = {};
  bool _isConnected = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectInterval = const Duration(seconds: 1);

  LiveRateNotifier() : super(null) {
    fetchServerLink().then(
      (value) {
        initializeSocketConnection(link: value);
      },
    );
  }

  // final link = 'https://capital-server-9ebj.onrender.com';
  // final commodityArray = ['GOLD', 'SILVER'];

  Future<List<String>> fetchCommodityArray() async {
    const id = "IfiuH/ko+rh/gekRvY4Va0s+aGYuGJEAOkbJbChhcqo=";
    final response = await http.get(
      Uri.parse(
          '${FirebaseConstants.baseUrl}get-commodities/${FirebaseConstants.adminId}'),
      headers: {
        'X-Secret-Key': id,
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      // List<dynamic> data = json.decode(response.body);
      final commudity = GetCommodityModel.fromMap(json.decode(response.body));
      // return data.map((item) => item.toString()).toList();

      return commudity.commodities;
    } else {
      throw Exception('Failed to load commodity data');
    }
  }

  Future<String> fetchServerLink() async {
    final response = await http.get(
      Uri.parse('${FirebaseConstants.baseUrl}get-server'),
      headers: {
        'X-Secret-Key': FirebaseConstants.secretKey,
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      // List<dynamic> data = json.decode(response.body);
      final commudity = GetServerModel.fromMap(json.decode(response.body));
      // return data.map((item) => item.toString()).toList();
      return commudity.info.serverUrl;
    } else {
      throw Exception('Failed to load commodity data');
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

    _socket?.onConnect((_) async {
      print('Connected to WebSocket server');
      _isConnected = true;
      _reconnectAttempts = 0;
      List<String> commodityArray = await fetchCommodityArray();
      _requestMarketData(commodityArray);
    });

    _socket?.on('market-data', (data) {
      print("Working");
      if (data != null && data['symbol'] != null) {
        marketData[data['symbol']] = data;
        state = LiveRateModel.fromJson(marketData);
        print("Market data updated: ${data['symbol']}");
      } else {
        print("Market data is Null");
      }
    });

    _socket?.onConnectError((data) {
      print('Connection Error: $data');
      _handleDisconnection();
    });

    _socket?.onDisconnect((_) {
      print('Disconnected from WebSocket server');
      _handleDisconnection();
    });

    _socket?.connect();
  }

  void _handleDisconnection() {
    _isConnected = false;
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    } else {
      print('Max reconnection attempts reached');
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectInterval, () {
      if (!_isConnected) {
        _reconnectAttempts++;
        print(
            'Attempting to reconnect... (Attempt $_reconnectAttempts/$_maxReconnectAttempts)');
        _socket?.connect();
      }
    });
  }

  void _requestMarketData(List<String> symbols) {
    if (_isConnected) {
      print("Socket Connected");
      print(symbols);
      _socket?.emit('request-data', [symbols]);
    }
  }

  Future<void> refreshData() async {
    if (_isConnected) {
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

final liveRateProvider =
    StateNotifierProvider<LiveRateNotifier, LiveRateModel?>((ref) {
  return LiveRateNotifier();
});
