import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ResumeState extends Equatable {
  final String currentWordId;
  final Map<int, String> userFilled; // { index : "A" }
  final int hintCountUsed;
  final DateTime? updatedAt;

  const ResumeState({
    required this.currentWordId,
    required this.userFilled,
    required this.hintCountUsed,
    required this.updatedAt,
  });

  factory ResumeState.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final d = snap.data() ?? const {};
    final rawUf =
        (d['userFilled'] as Map?)?.cast<String, dynamic>() ?? const {};
    final uf = <int, String>{};
    rawUf.forEach((k, v) {
      final i = int.tryParse(k);
      if (i != null && v is String) uf[i] = v;
    });

    return ResumeState(
      currentWordId: (d['currentWordId'] as String?) ?? '',
      userFilled: uf,
      hintCountUsed: (d['hintCountUsed'] as num?)?.toInt() ?? 0,
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool withServerUpdateTs = true}) {
    final ufStr = <String, String>{
      for (final e in userFilled.entries) e.key.toString(): e.value,
    };
    return {
      'currentWordId': currentWordId,
      'userFilled': ufStr,
      'hintCountUsed': hintCountUsed,
      if (withServerUpdateTs) 'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ResumeState copyWith({
    String? currentWordId,
    Map<int, String>? userFilled,
    int? hintCountUsed,
    DateTime? updatedAt,
  }) {
    return ResumeState(
      currentWordId: currentWordId ?? this.currentWordId,
      userFilled: userFilled ?? this.userFilled,
      hintCountUsed: hintCountUsed ?? this.hintCountUsed,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    currentWordId,
    userFilled,
    hintCountUsed,
    updatedAt,
  ];
}
