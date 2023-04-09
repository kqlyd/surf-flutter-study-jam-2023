import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/state_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/model/ticket_model.dart';

class TicketController extends GetxController {
  var ticketList = RxList<TicketModel>();
  late final TextEditingController urlController;
  var loadingProgress = 0.0.obs;

  var dio = Dio();

  @override
  void onInit() {
    super.onInit();
    urlController = TextEditingController(
        text: 'https://journal-free.ru/download/za-rulem-12-dekabr-2019-rossiia.pdf');
  }

  bool isAddingUrlCorrect = false;

  void addTicketByUrl() {
    ticketList.add(
      TicketModel(
        title: 'Ticket ${ticketList.length + 1}',
        url: urlController.text,
        downloadStatus: TicketDownloadStatus.initial(),
      ),
    );
    print('object');
  }

  void downloadTicket({required int ticketIndex}) {
    var ticket = ticketList[ticketIndex];
    if (ticket.downloadStatus?.downloadStatus == TicketDownloadStatusEnum.waiting) {
      downloadFile(dio: dio, ticketIndex: ticketIndex);
    } else if (ticket.downloadStatus?.downloadStatus == TicketDownloadStatusEnum.pause) {
      downloadFile(dio: dio, ticketIndex: ticketIndex, isResumed: true);
    } else if (ticket.downloadStatus?.downloadStatus == TicketDownloadStatusEnum.loading) {
      ticket.downloadStatus?.cancelToken?.cancel('Pause');
      ticket = ticket.copyWith(
        downloadStatus: ticket.downloadStatus?.copyWith(
          downloadStatus: TicketDownloadStatusEnum.pause,
          cancelToken: CancelToken(),
        ),
      );
      ticketList[ticketIndex] = ticket;
    }
  }

  void mergeFilesAfterPause(
    String fullPath,
    String tempPath,
  ) async {
    File pdfFile = File(fullPath);
    File tempPdfFile = File(tempPath);
    if (!(await pdfFile.exists())) {
      pdfFile.create();
    }

    var ioSink = pdfFile.openWrite(mode: FileMode.writeOnlyAppend);
    await ioSink.addStream(tempPdfFile.openRead());
    await tempPdfFile.delete();
  }

  Future downloadFile({required Dio dio, required int ticketIndex, bool isResumed = false}) async {
    Directory tempDir;
    String fullPath = '';
    String tempPath = '';
    try {
      var ticket = ticketList[ticketIndex];
      tempDir = await getTemporaryDirectory();
      fullPath = "${tempDir.path}/${ticket.title}.pdf";
      tempPath = "${tempDir.path}/${ticket.title}_temp.pdf";
      // }
      await dio.download(
        ticket.url ?? '',
        tempPath,
        deleteOnError: false,
        cancelToken: ticket.downloadStatus?.cancelToken,
        onReceiveProgress: (count, total) {
          if (isResumed) {
            showResumeProgress(count, total, ticket, ticketIndex);
          } else {
            showDownloadProgress(count, total, ticket, ticketIndex);
          }
        },
        options: Options(
          headers: getHeadersDownloadFile(ticket),
        ),
      );
    } catch (e) {
      print(e);
    }
    mergeFilesAfterPause(fullPath, tempPath);
  }

  Map<String, dynamic>? getHeadersDownloadFile(TicketModel ticket) {
    if (ticket.downloadStatus?.currentReceived != null) {
      return {
        'range':
            'bytes=${ticket.downloadStatus?.currentReceived}-${ticket.downloadStatus?.totalSize}'
      };
    } else {
      return null;
    }
  }

  void showResumeProgress(int received, int total, TicketModel ticket, int ticketIndex) {
    if (total != -1) {
      TicketDownloadStatusEnum newStatus;
      if (received / total == 1) {
        newStatus = TicketDownloadStatusEnum.finished;
      } else {
        newStatus = TicketDownloadStatusEnum.loading;
      }
      ticket = ticket.copyWith(
        downloadStatus: ticket.downloadStatus?.copyWith(
          currentReceived: received,
          totalReceived: (ticket.downloadStatus?.totalReceived ?? 0) + received,
          currentSize: total,
          totalSize: ticket.downloadStatus?.totalSize,
          downloadStatus: newStatus,
        ),
      );
      ticketList[ticketIndex] = ticket;
    }
  }

  void showDownloadProgress(int received, int total, TicketModel ticket, int ticketIndex) {
    if (total != -1) {
      TicketDownloadStatusEnum newStatus;
      if (received / total == 1) {
        newStatus = TicketDownloadStatusEnum.finished;
      } else {
        newStatus = TicketDownloadStatusEnum.loading;
      }
      ticket = ticket.copyWith(
        downloadStatus: ticket.downloadStatus?.copyWith(
          currentReceived: received,
          totalReceived: received,
          currentSize: received,
          totalSize: total,
          downloadStatus: newStatus,
        ),
      );
      ticketList[ticketIndex] = ticket;
    }
  }
}
