class Budget {
  double limit;
  DateTime setAt;

  Budget({
    required this.limit,
    DateTime? setAt,
  }) : setAt = setAt ?? DateTime.now();
}