import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class WalletData {
  Future<String> fetchWalletData(String token) async {
    print(token);
    var wallet;
    const url = '${env.api}/api/v1/me/wallet/';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      wallet = json.decode(response.body);
      print(token);
      print('This is the response body: ${response.body}');
      print("points : ${wallet['points']}");
      print("response code for wallet data: ${response.statusCode}");

      if (response.statusCode == 200) {
        print('Wallet data fetched');
        final walletData = response.body;
        // final WalletMap = json.decode(walletData) as Map<String, dynamic>;
        final WalletMap = json.decode(walletData);
        return WalletMap['points'];
      } else {
        print('Failed to fetch Wallet data');
        print("response for wallet data: ${response.statusCode}");
        print("response for wallet data: ${response.body}");
        return 'null';
      }
    } catch (e) {
      print('Exception: $e');
      return 'null';
    }
  }

  Future<dynamic> fetchWalletWatchAd() async {
    final box = GetStorage();
    final token = box.read('accessToken');
    const url = '${env.api}/api/v1/me/ads/watch/';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("response body for watch ad: ${response.body}");
      if (response.statusCode == 202) {
        print('Wallet data fetched');

        return response;
      } else {
        print('Failed to fetch Wallet data');
        print("response for wallet data: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }
}
