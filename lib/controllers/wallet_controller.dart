import 'package:adkach/common_widgets/snack_message/snack_message.dart';
import 'package:adkach/controllers/wallet_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WalletController extends GetxController {
  RxInt points = 0.obs;
  RxInt ac_cash = 0.obs;
  final box = GetStorage();

  String withdrawAmount = '';
  RxList<WithdrawalRequest> withdrawalRequests = <WithdrawalRequest>[].obs;

  Future<void> fetchWithdrawRequests() async {
    final token = box.read('accessToken');
    try {
      final response = await http.get(
        Uri.parse('${env.api}/api/v1/me/wallet/widhraws/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);

        // Map each item in the list to WithdrawalRequest object
        final List<WithdrawalRequest> requests = dataList.map((item) {
          return WithdrawalRequest.fromJson(item);
        }).toList();

        withdrawalRequests.assignAll(requests);
      } else {
        print('Error fetching withdrawal requests: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching withdrawal requests: $error');
    }
  }

  Future<void> withdraw(String amount, BuildContext context) async {
    final token = box.read('accessToken');
    try {
      final response = await http.post(
        Uri.parse('${env.api}/api/v1/me/wallet/widhraw/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'amount': amount}),
      );

      if (response.statusCode == 200) {
        print('Withdrawal request successful');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 1),
            content: CustomSnackBarContent(
              title: 'Success',
              message: 'Withdraw request successful.',
              bgcolor: Colors.green,
              bubcolor: Color.fromARGB(255, 0, 114, 4),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
        // refrsh page
        fetchPoints();
        fetchWithdrawRequests();
      } else {
        print('Error making withdrawal request: ${response.statusCode}');
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 1),
            content: CustomSnackBarContent(
              title: 'Error',
              message: 'Error making withdraw request.',
              bgcolor: Colors.red,
              bubcolor: Color.fromARGB(255, 131, 35, 28),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        );
      }
    } catch (error) {
      print('Error making withdrawal request: $error');
    }
  }

  Future<void> sendPoint(email, amounts) async {
    final box = GetStorage();
    final token = box.read('accessToken');
    try {
      print('$email, $amounts');
      final response = await http.post(
        Uri.parse('${env.api}/api/v1/me/wallet/send/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
          <String, String>{'amount': amounts, 'email': email},
        ),
      );
      print(response.body);
      if (response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Points sent successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        );
        points.value -= int.parse(amounts);
      } else {
        Get.snackbar(
          'Error',
          'Points not sent',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      print('Error sending points: $e');
    }
  }

  Future<dynamic> watchWithSub() async {
    String token = box.read('accessToken');
    try {
      String subAccountName = box.read('selectedSubProfileName');
      String apiUrl =
          '${env.api}/api/my-sub-accounts/$subAccountName/watch_ads/';
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await http.post(Uri.parse(apiUrl), headers: headers);

      print('ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Handle successful response, if needed
        print('Watch Ads request successful');
        print(response.body);
        return response;
      } else {
        // Handle any other response, if needed
        print('Watch Ads request failed');
        print(response.body);
        return response;
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> fetchPoints() async {
    final token = box.read('accessToken');
    try {
      final response = await http.get(
        Uri.parse('${env.api}/api/v1/me/wallet/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        points.value = data['points'];

        // Ensure ac_cash is converted from string to double
        final String acCashString = data['ac_cash'] ?? '0';
        final double acCashValue = double.tryParse(acCashString) ?? 0;
        ac_cash.value =
            acCashValue.toInt(); // Convert to integer and assign to RxInt
      } else {
        print('Error fetching points: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching points and ac_cash: $error');
    }
  }
}

Future<void> fetchSubAccountBalance() async {
  final box = GetStorage();
  try {
    String subAccountName = box.read('selectedSubProfileName');

    String apiUrl = '${env.api}/api/my-sub-accounts/$subAccountName/balance';

    String token = box.read('accessToken');

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    http.Response response =
        await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);

      double balance = responseData['balance']; // This is a double
      box.write('selectedSubProfileBalance',
          balance.toString()); // Converting to string here

      // Fetch main balance and save 'points'
      await fetchMainBalance();
    } else {
      print('main profile balance ');
    }
  } catch (error) {
    print('Error: $error');
  }
}

Future<void> fetchMainBalance() async {
  final box = GetStorage();
  String token = box.read('accessToken');
  print(token);
  try {
    String mainApiUrl = '${env.api}/api/v1/me/wallet/';

    Map<String, String> mainHeaders = {
      'Authorization': 'Bearer $token',
    };

    http.Response mainResponse =
        await http.get(Uri.parse(mainApiUrl), headers: mainHeaders);

    if (mainResponse.statusCode == 200) {
      Map<String, dynamic> mainData = json.decode(mainResponse.body);

      int points = mainData['points'];
      String acCash = mainData['ac_cash'];
      print('Points: $points');

      box.write('AC', acCash.toString());
      print('AC Cash: $acCash');
      print(box.read('AC'));

      box.write('mainBalancePoints', points.toString());
      print('Main balance points: $points');
    } else {
      print('Erroraa: ${mainResponse.statusCode} - ${mainResponse.body}');
    }
  } catch (error) {
    print('Error fetching main balance: $error');
  }
}
