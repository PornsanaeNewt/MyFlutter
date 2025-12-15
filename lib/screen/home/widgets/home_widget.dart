import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_test1/config/logarte.dart';
import 'package:flutter_app_test1/config/routes/app_route.dart';
import 'package:flutter_app_test1/controller/conversation_controller.dart';
import 'package:flutter_app_test1/controller/friend_controller.dart';
import 'package:flutter_app_test1/controller/socket_controller.dart';
import 'package:flutter_app_test1/controller/user_controller.dart';
import 'package:flutter_app_test1/helpers/app_setting.dart';
import 'package:flutter_app_test1/helpers/local_storage_service.dart';
import 'package:flutter_app_test1/screen/home/widgets/list_chat_widget.dart';
import 'package:flutter_app_test1/screen/home/widgets/list_friend_widget.dart';
import 'package:flutter_app_test1/screen/widgets/profile_circle.dart';
import 'package:flutter_app_test1/service/toastification_service.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ConversationController conversationController = Get.put(
    ConversationController(),
  );
  final FriendController friendController = Get.put(FriendController());
  SocketController skController = Get.put(SocketController());
  AppSettingController appSettingController = Get.put(AppSettingController());

  final UserController userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  void init() async {
    await userController.fetchUserProfile();
    await conversationController.fetchConversations();
    await friendController.fetchFriends();
  }

  Future<void> _handleRefresh() async {
    await userController.fetchUserProfile();
    await conversationController.fetchConversations();
    await friendController.fetchFriends();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() {
                    final profileUrl =
                        userController.userProfile.value?.data?.profileUrl;
                    return InkWell(
                      onTap: () {
                        GoRouter.of(context).pushNamed(AppRoute.profile);
                      },
                      child: ProfileCircle(imageUrl: profileUrl),
                    );
                  }),
                  const SizedBox(width: 10),
                  const Text(
                    'Chats Messenger',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),

                  Spacer(),
                  Obx(() {
                    return Text(skController.socketStatus.value.name);
                  }),
                  Builder(
                    builder: (BuildContext innerContext) {
                      return IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          Scaffold.of(innerContext).openEndDrawer();
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      logarte.attach(context: context, visible: true);
                    },
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.edit, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder(
              future: LocalStorageService.getToken(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final token = snapshot.data ?? '';
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Token: $token',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy token',
                      onPressed:
                          token.isEmpty
                              ? null
                              : () {
                                Clipboard.setData(ClipboardData(text: token));
                                ToastService().error(
                                  'Copied to clipboard',
                                  description: 'Token has been copied.',
                                );
                              },
                    ),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  filled: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() {
              final isFriendLoading = friendController.isLoading.value;
              final isConversationLoading =
                  conversationController.isLoading.value;

              if (isFriendLoading || isConversationLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // Friend List
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: friendController.friends.length,
                      itemBuilder: (context, index) {
                        final friend = friendController.friends[index];
                        return ListFriendWidget(
                          friend: friend,
                          currentUserId:
                              userController.userProfile.value?.data?.userId,
                        );
                      },
                    ),
                  ),
                  // Conversation List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: conversationController.conversations.length,
                    itemBuilder: (context, index) {
                      final conversation =
                          conversationController.conversations[index];
                      return ListChatWidget(
                        conversation: conversation,
                        currentUserId:
                            userController.userProfile.value?.data?.userId,
                      );
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
