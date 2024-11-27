import 'package:flutter_riverpod/flutter_riverpod.dart';
import './responseNotifier.dart';

final responsesProvider = StateNotifierProvider<ResponsesNotifier, List<String>>(
      (ref) => ResponsesNotifier(),
);
