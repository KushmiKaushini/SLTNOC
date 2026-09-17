import 'package:flutter/material.dart';
import 'package:sltnoc/app_config.dart';

// UI Palette
const Color kChatSurface = Colors.white;
const Color kChatGlass = Color(0xFFE2E8F0);
const Color kChatBorder = Color(0xFFCBD5E1);
const Color kChatAccent1 = Color(0xFF0056A2);
const Color kChatAccent2 = Color(0xFF0284C7);
const Color kChatUserGrad1 = Color(0xFF0056A2);
const Color kChatUserGrad2 = Color(0xFF0284C7);
const Color kChatError = Color(0xFFEF4444);
const Color kChatGreen = Color(0xFF22C55E);

const Color kChatText = Color(0xFF0F172A);
const Color kChatTextSec = Color(0xFF475569);
const Color kChatTextTer = Color(0xFF94A3B8);

// Networking Defaults
String get kChatFallbackUrl => AppConfig.apiBaseUrl;
const Duration kConnectionAttemptTimeout = Duration(seconds: 5);
const Duration kCriticalAlertCacheTTL = Duration(seconds: 45);

// Suggestions for welcome screen
const List<String> kSuggestedPrompts = [
  'What alarms are currently active?',
  'Show me network node locations',
  'Check service order status',
  'Recent escalations overview',
];
