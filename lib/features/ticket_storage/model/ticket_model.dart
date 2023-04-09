import 'dart:typed_data';

import 'package:surf_flutter_study_jam_2023/features/ticket_storage/model/download_status.dart';

class TicketModel {
  TicketModel({
    this.title,
    this.filePath,
    this.url,
    this.downloadStatus,
  });
  final String? title;
  final String? url;
  final String? filePath;
  final TicketDownloadStatus? downloadStatus;

  TicketModel copyWith({
    String? title,
    String? url,
    String? filePath,
    TicketDownloadStatus? downloadStatus,
  }) {
    return TicketModel(
      title: title ?? this.title,
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      downloadStatus: downloadStatus ?? this.downloadStatus,
    );
  }
}
