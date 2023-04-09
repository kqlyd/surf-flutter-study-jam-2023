import 'dart:math';
import 'dart:typed_data';

enum TicketDownloadStatusEnum {
  waiting,
  loading,
  pause,
  finished;
}

class TicketDownloadStatus {
  TicketDownloadStatus({
    this.downloadStatus = TicketDownloadStatusEnum.waiting,
    this.received = 0,
    this.total = 1,
  });

  final TicketDownloadStatusEnum? downloadStatus;
  final int received;
  final int total;

  double get getDownloadProgress => received / total;

  String getStatusTitle() {
    switch (downloadStatus) {
      case TicketDownloadStatusEnum.waiting:
        return 'Ожидает начала загрузки';
      case TicketDownloadStatusEnum.loading:
        return 'Загружается ${formatBytes(received, 2)} из ${formatBytes(total, 2)}';
      case TicketDownloadStatusEnum.pause:
        return 'Пауза';
      case TicketDownloadStatusEnum.finished:
        return 'Загрузка завершена';
      default:
        return 'Неизвестно';
    }
  }

  String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  TicketDownloadStatus copyWith({
    TicketDownloadStatusEnum? downloadStatus,
    int? received,
    int? total,
  }) {
    return TicketDownloadStatus(
      downloadStatus: downloadStatus ?? this.downloadStatus,
      received: received ?? this.received,
      total: total ?? this.total,
    );
  }
}

class TicketModel {
  TicketModel({
    this.title,
    this.data,
    this.url,
    this.downloadStatus,
  });
  final String? title;
  final String? url;
  final Uint8List? data;
  final TicketDownloadStatus? downloadStatus;
  // final double? downloadStatus;

  TicketModel copyWith({
    String? title,
    String? url,
    Uint8List? data,
    TicketDownloadStatus? downloadStatus,
  }) {
    return TicketModel(
      title: title ?? this.title,
      url: url ?? this.url,
      data: data ?? this.data,
      downloadStatus: downloadStatus ?? this.downloadStatus,
    );
  }
}
