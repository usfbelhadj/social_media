// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adkach/controllers/auth_controller.dart';
import 'package:adkach/controllers/wallet_controller.dart';

import '../voucher/common_widget/round_buttom.dart';

class CreditCardsPage extends StatefulWidget {
  const CreditCardsPage({super.key});

  @override
  _CreditCardsPageState createState() => _CreditCardsPageState();
}

class _CreditCardsPageState extends State<CreditCardsPage> {
  final AuthController authController = Get.find();
  TextEditingController amountController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final walletController = Get.put(WalletController());

  @override
  void initState() {
    super.initState();
    fetchData();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });
  }

  void fetchData() {
    walletController.fetchPoints();
    walletController.fetchWithdrawRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20.0),
            _buildBalanceCard(
              'Balance: ',
              double.parse(walletController.ac_cash.toString()),
            ),
            const SizedBox(height: 40.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Withdraw Requests:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Expanded(
                    child: Obx(
                      () {
                        final requests = walletController.withdrawalRequests;
                        if (requests.isEmpty) {
                          return const Center(
                            child: Text('No requests found!'),
                          );
                        } else {
                          final reversedRequests = List.from(requests.reversed);

                          return ListView.builder(
                            itemCount: reversedRequests.length,
                            itemBuilder: (context, index) {
                              final request = reversedRequests[index];
                              final formattedAmount =
                                  request.amount.toStringAsFixed(2);

                              return Card(
                                elevation: 2.0,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  leading: const Icon(Icons.money),
                                  title: Text('Amount: $formattedAmount AC'),
                                  trailing: Text(
                                    '${request.status}',
                                    style: TextStyle(
                                      color: request.status == 'pending'
                                          ? Colors.orange
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            RoundButton(
              colors: const Color.fromARGB(255, 218, 59, 48),
              title: "Withdraw",
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Withdraw'),
                    content: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Enter amount to withdraw',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        walletController.withdrawAmount = value;
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (walletController.withdrawAmount.isNotEmpty) {
                            walletController.withdraw(
                              walletController.withdrawAmount,
                              context,
                            );
                            Get.back();
                          } else {
                            print('Please enter a valid amount');
                          }
                        },
                        child: const Text('Withdraw'),
                      ),
                    ],
                  ),
                );
              },
            ),
            RoundButton(
              colors: Color.fromARGB(255, 32, 149, 228),
              title: "Send Points",
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Send Points'),
                    content: Container(
                      height: 170,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Enter Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Enter amount to send',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.money),
                              ),
                              keyboardType: TextInputType.number,
                              controller: amountController,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          emailController.clear();
                          amountController.clear();
                          Get.back();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (emailController.text.isNotEmpty &&
                              amountController.text.isNotEmpty) {
                            walletController.sendPoint(
                              emailController.text,
                              amountController.text,
                            );
                            emailController.clear();
                            amountController.clear();
                            Get.back();
                          } else {
                            print('Please enter a valid amount');
                          }
                        },
                        child: const Text('Send Points'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, double amount) {
    final acCash = walletController.ac_cash.value;
    final points = walletController.points.value;

    return Card(
      elevation: 4.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Points: $points', // Display the points balance
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '$acCash AC', // Display the ac_cash balance
              style: const TextStyle(
                fontSize: 24.0,
                color: Color.fromARGB(218, 172, 126, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
