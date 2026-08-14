import 'video_picker_contract.dart';

class PrototypeVideoPicker implements VideoPicker {
  const PrototypeVideoPicker();

  @override
  Future<PickedVideo?> pickVideo() async {
    return const PickedVideo(
      uri: 'prototype://sample_4k_trip.mp4',
      fileName: 'sample_4k_trip.mp4',
      sizeBytes: 248000000,
      duration: Duration(seconds: 84),
      mimeType: 'video/mp4',
    );
  }
}
