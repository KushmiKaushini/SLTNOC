// ============================================================================
// ChronosAI — Shared State
// Author: K K K Ekanayake
// Shared global state variables across the app
// ============================================================================

import 'package:flutter/foundation.dart';

/// Global flag to control floating chat button visibility.
/// Set to true when AIChatPage is active to hide the floating button.
final ValueNotifier<bool> isChatScreenOpen = ValueNotifier<bool>(false);
