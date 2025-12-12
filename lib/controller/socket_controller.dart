import 'package:flutter_app_test1/helpers/local_storage_service.dart';
import 'package:flutter_app_test1/helpers/network_api.dart';
import 'package:get/get.dart';
import 'package:flutter_app_test1/controller/friend_controller.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

enum SocketSatus { connecting, connected, error, disconnect, authError }

class SocketController extends GetxController {
  Rx<SocketSatus> socketStatus = SocketSatus.disconnect.obs;
  socket_io.Socket? socket;
  String? _currentToken;
  bool _hasAuthError = false;
  late final FriendController _friendController;

  /// เชื่อมต่อ Socket และตั้งค่า listeners
  Future<socket_io.Socket> connectSocket() async {
    // ดึง token ปัจจุบัน
    final accessToken = await LocalStorageService.getToken();
    if (accessToken == null || accessToken.isEmpty) {
      print('❌ [Socket] Access token missing, skip connection');
      socketStatus.value = SocketSatus.authError;
      return Future.error('Access token is required for socket connection.');
    }

    if (_hasAuthError) {
      print(
        '⚠️ [Socket] Auth error detected, waiting for new token before reconnect.',
      );
      return Future.error('Socket auth error, reconnect after token refresh.');
    }

    // เช็คว่า socket มีอยู่แล้ว, connected, และ token ไม่เปลี่ยน
    if (socket != null && socket!.connected && _currentToken == accessToken) {
      print('✅ [Socket] Reusing existing socket connection');
      return socket!;
    }

    // ถ้า token เปลี่ยน หรือ socket ยังไม่ connected
    if (socket != null) {
      print('🔄 [Socket] Token changed or socket disconnected, recreating...');
      socket!.disconnect();
      socket!.dispose();
      socket = null;
    }

    // สร้าง socket ใหม่
    socket = await _createSocket(accessToken);
    _currentToken = accessToken;

    // ตั้งค่า listeners
    _setupSocketListeners();

    // Connect socket (เพราะใช้ autoConnect: false)
    socket!.connect();

    // Get friend controller instance
    _friendController = Get.find<FriendController>();

    return socket!;
  }

  /// สร้าง Socket instance ใหม่
  Future<socket_io.Socket> _createSocket(String? accessToken) async {
    final optionBuilder = socket_io.OptionBuilder()
        .setTransports([
          'websocket',
          'polling',
        ]) // Try websocket first, fallback to polling
        .disableAutoConnect() // ไม่ connect อัตโนมัติ (เหมือน autoConnect: false)
        .enableReconnection() // เปิด reconnection
        .setReconnectionDelay(1000) // Delay 1 วินาทีก่อน reconnect
        .setReconnectionAttempts(5); // ลอง reconnect 5 ครั้ง

    // เพิ่ม auth token และ headers ถ้ามี
    if (accessToken != null && accessToken.isNotEmpty) {
      optionBuilder
        ..setAuth({'token': 'Bearer $accessToken'})
        ..setExtraHeaders({'Authorization': 'Bearer $accessToken'});
      // Note: socket_io_client Flutter อาจไม่รองรับ auth object โดยตรง
      // แต่สามารถส่งผ่าน extraHeaders ได้
    }

    print('🔌 [Socket] Creating socket connection to: ${NetworkAPI.socketUrl}');

    return socket_io.io(NetworkAPI.socketUrl, optionBuilder.build());
  }

  /// ตั้งค่า event listeners สำหรับ socket
  void _setupSocketListeners() {
    // Connection successful
    socket!.onConnect((_) {
      socketStatus.value = SocketSatus.connected;
      _hasAuthError = false;
      print('✅ [Socket] Connected, ID: ${socket?.id}');
    });

    // Connection error (ตั้งก่อน connect)
    socket!.on('connect_error', (data) async {
      if (_isUnauthorizedError(data)) {
        _handleUnauthorizedError(data);
        return;
      }
      socketStatus.value = SocketSatus.error;
      final memberId = (await LocalStorageService().getUserInfo())['userId'];
      if (memberId != null) {
        print('❌ [Socket] Connection error - memberId: $memberId');
        print('❌ [Socket] Error data: $data');
      } else {
        print('❌ [Socket] Connection error: $data');
      }
    });

    socket!.on('message:new', (data) {
      print('📩 [Socket] New message received: $data');
    });

    socket!.on('connection:success', (data) {
      print('✅ [Socket] Connection success');
      print('✅ [Socket] connection data: $data');
    });

    // Disconnected
    socket!.onDisconnect((_) {
      socketStatus.value = SocketSatus.disconnect;
      print('🔌 [Socket] Disconnected');
    });

    // General error
    socket!.onError((error) {
      if (_isUnauthorizedError(error)) {
        _handleUnauthorizedError(error);
        return;
      }
      socketStatus.value = SocketSatus.error;
      print('❌ [Socket] Error: $error');
    });

    // Reconnection events
    socket!.onReconnect((attempt) {
      print('🔄 [Socket] Reconnecting... Attempt: $attempt');
      socketStatus.value = SocketSatus.connecting;
    });

    socket!.onReconnectAttempt((attempt) {
      print('🔄 [Socket] Reconnection attempt: $attempt');
    });

    socket!.onReconnectError((error) {
      print('❌ [Socket] Reconnection error: $error');
    });

    socket!.onReconnectFailed((_) {
      print('❌ [Socket] Reconnection failed');
      socketStatus.value = SocketSatus.error;
    });

    // Listener สำหรับสถานะออนไลน์ของเพื่อน
    socket!.on('user:status', (data) {
      if (data is Map<String, dynamic>) {
        final int? userId = data['userId'];
        final bool? isOnline = data['isOnline'];
        if (userId != null && isOnline != null) {
          _friendController.updateUserStatus(userId, isOnline);
        }
      }
    });
  }

  @override
  void onClose() {
    socket?.dispose();
    super.onClose();
  }

  /// ตรวจสอบว่า error จาก server เป็น 401 หรือ unauthorized หรือไม่
  bool _isUnauthorizedError(dynamic data) {
    if (data == null) return false;
    if (data is Map) {
      final status = data['status'] ?? data['code'] ?? data['statusCode'];
      final message = '${data['message'] ?? data['error']}'.toLowerCase();
      if ('$status' == '401' || message.contains('unauthorized')) {
        return true;
      }
    }
    final str = data.toString().toLowerCase();
    return str.contains('401') || str.contains('unauthorized');
  }

  /// จัดการเมื่อ token ไม่ถูกต้อง -> หยุด reconnect จนกว่าจะได้รับ token ใหม่
  void _handleUnauthorizedError(dynamic error) {
    print('❌ [Socket] Unauthorized error, stop reconnect: $error');
    _hasAuthError = true;
    socketStatus.value = SocketSatus.authError;
    socket?.disconnect();
    socket?.dispose();
    socket = null;
    _currentToken = null;
  }

  /// รีเซ็ต auth error เมื่อได้รับ token ใหม่ แล้วสามารถเรียก connectSocket ได้อีกครั้ง
  void resetAuthError() {
    _hasAuthError = false;
    socketStatus.value = SocketSatus.disconnect;
  }
}
