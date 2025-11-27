import 'package:flutter_app_test1/model/friend_model.dart';
import 'package:flutter_app_test1/service/dudee_service.dart';
import 'package:get/get.dart';

class FriendController extends GetxController {
  RxList<Datum> friends = <Datum>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFriends();
  }

  /// ดึงข้อมูล friends จาก API
  /// แก้ไข: เพิ่ม error handling และ null safety ที่ดีขึ้น
  Future<void> fetchFriends() async {
    try {
      isLoading.value = true;
      update();

      final friendResponse = await DudeeService().listFriend();

      // เช็ค null safety อย่างละเอียด
      if (friendResponse.data != null && friendResponse.data!.data != null) {
        friends.assignAll(friendResponse.data!.data!);
        print('✅ Fetched ${friends.length} friends');
      } else {
        print('⚠️ No friends data received');
        friends.clear();
      }
    } catch (e) {
      print("❌ Error fetching friends: $e");
      // ไม่ clear friends ถ้า error เพื่อให้แสดงข้อมูลเก่า
      // หรือถ้าต้องการ clear: friends.clear();
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
