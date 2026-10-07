import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cart_store.dart';

class Order {
  final String id;
  final DateTime date;
  final List<CartItem> items;
  final int total;
  final String payment;
  final String address;
  final String status;

  const Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.payment,
    required this.address,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    id: j['id'] as String,
    date: DateTime.parse(j['date'] as String),
    items: (j['items'] as List)
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: j['total'] as int,
    payment: j['payment'] as String,
    address: j['address'] as String,
    status: j['status'] as String? ?? 'Diproses',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'items': items.map((e) => e.toJson()).toList(),
    'total': total,
    'payment': payment,
    'address': address,
    'status': status,
  };
}

class OrderStore extends ChangeNotifier {
  OrderStore._();
  static final OrderStore instance = OrderStore._();

  static const _key = 'orders_v1';
  final List<Order> orders = [];

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      orders
        ..clear()
        ..addAll(
          (jsonDecode(raw) as List).map(
            (e) => Order.fromJson(e as Map<String, dynamic>),
          ),
        );
    } catch (_) {
      orders.clear();
    }
  }

  Future<Order> place({
    required List<CartItem> items,
    required int total,
    required String payment,
    required String address,
  }) async {
    final now = DateTime.now();
    final order = Order(
      id: 'TKP-${now.millisecondsSinceEpoch.toString().substring(4)}',
      date: now,

      items: items.map((e) => CartItem.fromJson(e.toJson())).toList(),
      total: total,
      payment: payment,
      address: address,
      status: 'Diproses',
    );
    orders.insert(0, order);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(orders.map((e) => e.toJson()).toList()),
    );
    return order;
  }
}
