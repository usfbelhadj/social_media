import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class FeedService extends GetConnect {
  // Function to fetch feeds from the server
  Future<List<dynamic>> fetchFeeds() async {
    final box = GetStorage();
    final token = box.read('accessToken');
    try {
      final response = await get(
        '${env.api}/api/v1/feeds/all/',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
