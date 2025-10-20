import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

class Integration {
  Future<List<dynamic>?> fetchViolations() async {
    try {
      final url = Uri.parse(
        '${GlobalConfiguration().getValue("server_url")}/violations',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['violations'] is List) {
          final List<dynamic> data = decoded['violations'];
          return data;
        }
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching violations: $e');
    }
    return null;
  }
}
