import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/utils/format_bytes.dart';

enum TicketDownloadStatusEnum {
  waiting,
  loading,
  pause,
  finished;

  IconData getIconStatus() {
    switch (this) {
      case TicketDownloadStatusEnum.waiting:
        return Icons.cloud_download_outlined;
      case TicketDownloadStatusEnum.loading:
        return Icons.pause_circle_outline;
      case TicketDownloadStatusEnum.pause:
        return Icons.pause_circle_filled;
      case TicketDownloadStatusEnum.finished:
        return Icons.cloud_done_rounded;
      default:
        return Icons.error_outline;
    }
  }
}

class TicketDownloadStatus {
  TicketDownloadStatus({
    this.downloadStatus = TicketDownloadStatusEnum.waiting,
    this.currentSize,
    this.totalSize,
    this.currentReceived,
    this.totalReceived,
    this.cancelToken,
  });

  final TicketDownloadStatusEnum? downloadStatus;
  final int? currentSize;
  final int? totalSize;
  final int? currentReceived;
  final int? totalReceived;
  // final int? total;
  final CancelToken? cancelToken;

  double get getDownloadProgress =>
      totalSize == null ? 0 : ((totalReceived ?? 0) / (totalSize ?? 1));

  factory TicketDownloadStatus.initial() => TicketDownloadStatus(
        cancelToken: CancelToken(),
        downloadStatus: TicketDownloadStatusEnum.waiting,
      );

  String getStatusTitle() {
    switch (downloadStatus) {
      case TicketDownloadStatusEnum.waiting:
        return 'Ожидает начала загрузки';
      case TicketDownloadStatusEnum.loading:
        return 'Загружается ${formatBytes((totalReceived ?? 0), 2)} из ${formatBytes((totalSize ?? 0), 2)}';
      case TicketDownloadStatusEnum.pause:
        return 'Пауза';
      case TicketDownloadStatusEnum.finished:
        return 'Загрузка завершена';
      default:
        return 'Неизвестно';
    }
  }

  TicketDownloadStatus copyWith({
    TicketDownloadStatusEnum? downloadStatus,
    int? currentSize,
    int? totalSize,
    int? currentReceived,
    int? totalReceived,
    CancelToken? cancelToken,
  }) {
    return TicketDownloadStatus(
      downloadStatus: downloadStatus ?? this.downloadStatus,
      currentSize: currentSize ?? this.currentSize,
      totalSize: totalSize ?? this.totalSize,
      currentReceived: currentReceived ?? this.currentReceived,
      totalReceived: totalReceived ?? this.totalReceived,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }
}
