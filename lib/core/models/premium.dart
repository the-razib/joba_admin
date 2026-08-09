class PromoCode {
  const PromoCode({
    required this.code,
    required this.percentOff,
    required this.expiresAt,
    this.active = true,
    this.usedCount = 0,
  });

  final String code;
  final int percentOff;
  final DateTime expiresAt;
  final bool active;
  final int usedCount;

  PromoCode copyWith({bool? active}) => PromoCode(
        code: code,
        percentOff: percentOff,
        expiresAt: expiresAt,
        active: active ?? this.active,
        usedCount: usedCount,
      );
}

enum TxStatus { success, refunded, pending }

class Transaction {
  const Transaction({
    required this.id,
    required this.userName,
    required this.amountBdt,
    required this.method,
    required this.date,
    this.status = TxStatus.success,
  });

  final String id;
  final String userName;
  final int amountBdt;
  final String method; // bKash / Nagad / Card
  final DateTime date;
  final TxStatus status;
}
