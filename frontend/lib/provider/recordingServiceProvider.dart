import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recording_service.dart';


final recordingServiceProvider = Provider<RecordingService>(
      (ref) => RecordingService(ref),
);
