import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/model/download_status.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/model/ticket_model.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/presentation/widgets/pdf_view_page.dart';

class TicketController extends GetxController {
  var ticketList = RxList<TicketModel>();
  late final TextEditingController urlController;
  var loadingProgress = 0.0.obs;
  RegExp urlWithPdf = RegExp(r'(http(s?):)([/|.|\w|\s|-])*\.(?:pdf)');
  final formkey = GlobalKey<FormState>();

  var dio = Dio();

  @override
  void onInit() {
    super.onInit();

    urlController = TextEditingController();
  }

  void viewPdf(int ticketIndex) {
    var ticket = ticketList[ticketIndex];
    if (ticket.downloadStatus?.downloadStatus == TicketDownloadStatusEnum.finished) {
      Get.to(
        () => PdfViewPage(
          filePath: ticket.filePath,
          title: ticket.title,
        ),
      );
    }
  }

  var isAddingUrlCorrect = false.obs;

  void onChangeUrl(String? value) {
    if (urlWithPdf.hasMatch(value ?? '')) {
      isAddingUrlCorrect.value = true;
    } else {
      isAddingUrlCorrect.value = false;
    }
  }

  void clearTextFieldAfterAdd() {
    urlController.clear();
    isAddingUrlCorrect.value = false;
  }

  void addTicketByUrl() {
    ticketList.add(
      TicketModel(
        title: 'Ticket ${ticketList.length + 1}',
        url: urlController.text,
        downloadStatus: TicketDownloadStatus.initial(),
      ),
    );
    clearTextFieldAfterAdd();
    print('object');
  }

  void downloadAllTickets() {
    for (var index = 0; index < ticketList.length; index++) {
      if (ticketList[index].downloadStatus?.downloadStatus == TicketDownloadStatusEnum.waiting) {
        downloadTicket(ticketIndex: index);
      }
    }
  }

  void downloadTicket({required int ticketIndex}) {
    var ticket = ticketList[ticketIndex];
    if (ticket.downloadStatus?.downloadStatus == TicketDownloadStatusEnum.waiting) {
      downloadFile(dio: dio, ticketIndex: ticketIndex);
      ticket = ticket.copyWith(
        downloadStatus: ticket.downloadStatus?.copyWith(
          downloadStatus: TicketDownloadStatusEnum.loading,
          cancelToken: CancelToken(),
        ),
      );
      ticketList[ticketIndex] = ticket;
    } else if (ticket.downloadStatus?.downloadStatus == TicketDownloadStatusEnum.pause) {
      downloadFile(dio: dio, ticketIndex: ticketIndex, isResumed: true);
      ticket = ticket.copyWith(
        downloadStatus: ticket.downloadStatus?.copyWith(
          downloadStatus: TicketDownloadStatusEnum.loading,
          cancelToken: CancelToken(),
        ),
      );
      ticketList[ticketIndex] = ticket;
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
    var ticket = ticketList[ticketIndex];
    ticket = ticket.copyWith(filePath: fullPath);
    ticketList[ticketIndex] = ticket;
    mergeFilesAfterPause(fullPath, tempPath);
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
