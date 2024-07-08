import 'dart:async';

import 'package:get/get.dart';

import 'voucher_api.dart';

class VoucherController extends GetxController {
  var voucherList = [].obs;
  final isLoading = true.obs;
  RxString selectedVoucherIndex = RxString('');
  void updateSelectedIndex(String newIndex) {
    selectedVoucherIndex.value = newIndex;
  }

  @override
  void onInit() {
    super.onInit();
    fetchVoucher();
    Timer.periodic(const Duration(seconds: 10), (Timer t) {
      fetchVoucher();
    });
  }

  void fetchVoucher() async {
    isLoading(true);
    try {
      var response = await ownedVoucher();
      print(response);
      voucherList.assignAll(response);
    } catch (e) {
      print('no data found');
    } finally {
      isLoading(false);
    }
  }

// Add this method to refresh the voucher list after a status change
  void refreshVoucherList() async {
    try {
      var response = await ownedVoucher();
      voucherList.assignAll(response);
    } catch (e) {
      print('Error refreshing voucher list: $e');
    }
  }
}
