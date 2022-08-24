import 'dart:convert';

import 'package:flutter/material.dart';

@immutable
class PopularTimes {
  final String name;
  final List<int> data;

  const PopularTimes({required this.name, required this.data});

  factory PopularTimes.fromJson(dynamic json) {
    return PopularTimes(
        name: json["name"] as String,
        data: (json['data'] as List<dynamic>).cast<int>());
  }
}
