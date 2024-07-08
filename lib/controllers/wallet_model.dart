class WithdrawalRequest {
  final double amount; // Change the type to double
  final String status;

  WithdrawalRequest({required this.amount, required this.status});

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      amount: json['amount'],
      status: json['status'],
    );
  }
}
