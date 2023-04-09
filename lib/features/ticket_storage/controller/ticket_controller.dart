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
    urlController = TextEditingController();
  }

  bool isAddingUrlCorrect = false;

  void addTicketByUrl() {
    ticketList.add(
      TicketModel(
        title: 'Ticket',
        url: urlController.text,
        downloadStatus: TicketDownloadStatus(),
      ),
    );
  }

  void downloadTicket(TicketModel ticket, int ticketIndex) {
    downloadFile(dio, ticket, ticketIndex);
  }

  Future downloadFile(Dio dio, TicketModel ticket, int ticketIndex) async {
    try {
      Response response = await dio.get(
        ticket.url ?? '',
        onReceiveProgress: (count, total) {
          showDownloadProgress(count, total, ticket, ticketIndex);
        },
        //Received data with List<int>
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      var tempDir = await getTemporaryDirectory();
      String fullPath = "${tempDir.path}/boo2.pdf'";
      File file = File(fullPath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
    }
  }

  void showDownloadProgress(int received, int total, TicketModel ticket, int ticketIndex) {
    if (total != -1) {
      if (received / total == 1) {
        ticket = ticket.copyWith(
          downloadStatus: TicketDownloadStatus(
            received: received,
            total: total,
            downloadStatus: TicketDownloadStatusEnum.finished,
          ),
        );
      } else {
        ticket = ticket.copyWith(
          downloadStatus: TicketDownloadStatus(
            received: received,
            total: total,
            downloadStatus: TicketDownloadStatusEnum.loading,
          ),
        );
      }
      ticketList[ticketIndex] = ticket;
    }
  }
}
