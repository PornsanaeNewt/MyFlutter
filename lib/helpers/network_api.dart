class NetworkAPI {
  static const String baseURLDudee = const String.fromEnvironment('API_KEY');
  static const String socketUrl = const String.fromEnvironment('SOCKET_URL');
  static const String post = '/posts';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String register = '/auth/register';
  static const String userProfile = '/auth/me';

  static const String postConversations = '/chat/conversation';
  static const String getConversations = '/chat/conversations';
  static const String sendMessage = '/chat/message';
  static const String getMessages = '/chat/messages';
  static const String read = '/chat/read';

  static const String friend = '/users/friends';
  static const String getUserById = '/users';

}
