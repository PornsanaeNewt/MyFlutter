import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_test1/config/routes/app_route.dart';
import 'package:flutter_app_test1/controller/conversation_controller.dart';
import 'package:flutter_app_test1/controller/friend_controller.dart';
import 'package:flutter_app_test1/controller/socket_controller.dart';
import 'package:flutter_app_test1/helpers/local_storage_service.dart';
import 'package:flutter_app_test1/screen/widgets/custom_drawerbar.dart';
import 'package:flutter_app_test1/controller/user_controller.dart';
import 'package:flutter_app_test1/screen/home/widgets/list_chat_widget.dart';
import 'package:flutter_app_test1/screen/home/widgets/list_friend_widget.dart';
import 'package:flutter_app_test1/screen/widgets/custom_drawerbar.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic> _currentUserInfo = {};
  final ConversationController conversationController = Get.put(
    ConversationController(),
  );
  final FriendController friendController = Get.put(FriendController());
  SocketController skController = Get.put(SocketController());

  final UserController userController = Get.put(UserController());
  @override
  void initState() {
    super.initState();
    userController.fetchUserProfile();
    _loadCurrentUserInfo();
    //skController.connectSocket();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  Future<void> _loadCurrentUserInfo() async {
    conversationController.fetchConversations();
    friendController.fetchFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomDrawerbar(),
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: <Widget>[
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
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() {
                    final profileUrl =
                        userController.userProfile.value?.data?.profileUrl;

                    // แปลง SVG URL เป็น PNG URL สำหรับ dicebear
                    String? processedUrl = profileUrl;
                    if (profileUrl != null &&
                        profileUrl.contains('dicebear.com')) {
                      // แทนที่ svg ด้วย png เพื่อให้ Flutter รองรับ
                      processedUrl = profileUrl.replaceAll('/svg?', '/png?');
                    }

                    final isValidUrl =
                        processedUrl != null &&
                        processedUrl.isNotEmpty &&
                        (processedUrl.startsWith('http://') ||
                            processedUrl.startsWith('https://'));

                    // ใช้ตัวแปร local เพื่อหลีกเลี่ยง null check warning
                    final String? finalImageUrl =
                        isValidUrl ? processedUrl : null;

                    return InkWell(
                      onTap: () {
                        GoRouter.of(context).pushNamed(AppRoute.profile);
                      },
                      child:
                          finalImageUrl != null
                              ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: finalImageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => const CircleAvatar(
                                        radius: 30.0,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) =>
                                          const CircleAvatar(
                                            radius: 30.0,
                                            child: Icon(
                                              Icons.person,
                                              size: 30,
                                              color: Colors.grey,
                                            ),
                                          ),
                                ),
                              )
                              : const CircleAvatar(
                                radius: 30.0,
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              ),
                    );
                  }),
                  const SizedBox(width: 10),
                  const Text(
                    'Chats',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  const Icon(Icons.camera_alt_outlined, size: 28),
                  const SizedBox(width: 16),
                  const Icon(Icons.edit, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 10),
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
            Column(
              children: [
                GetBuilder<FriendController>(
                  builder: (friendController) {
                    if (friendController.isLoading.value &&
                        friendController.friends.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Container(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: friendController.friends.length,
                        itemBuilder: (context, index) {
                          final friend = friendController.friends[index];
                          return ListFriendWidget(
                            friend: friend,
                            currentUserId: _currentUserInfo['userId'],
                          );
                        },
                      ),
                    );
                  },
                ),
                GetBuilder<ConversationController>(
                  builder: (controller) {
                    if (controller.isLoading.value &&
                        controller.conversations.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: ListView.builder(
                        itemCount: controller.conversations.length,
                        itemBuilder: (context, index) {
                          final conversation = controller.conversations[index];
                          return ListChatWidget(
                            conversation: conversation,
                            currentUserId: _currentUserInfo['userId'],
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
