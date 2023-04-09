import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';

import 'package:surf_flutter_study_jam_2023/features/ticket_storage/controller/ticket_controller.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/model/ticket_model.dart';

class TicketTileWidget extends StatelessWidget {
  const TicketTileWidget({
    Key? key,
    required this.ticket,
    required this.ticketIndex,
  }) : super(key: key);

  final TicketModel ticket;
  final int ticketIndex;

  @override
  Widget build(BuildContext context) {
    return GetX<TicketController>(builder: (controller) {
      return Row(
        children: [
          const Icon(
            Icons.airplane_ticket_outlined,
            color: Colors.grey,
            size: 28,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.title ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.deepPurple),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value:
                        controller.ticketList[ticketIndex].downloadStatus?.getDownloadProgress ?? 0,
                    // value: controller.loadingProgress.value.toDouble(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.ticketList[ticketIndex].downloadStatus?.getStatusTitle() ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              controller.downloadTicket(ticketIndex: ticketIndex);
            },
            icon: Icon(
              ticket.downloadStatus?.downloadStatus?.getIconStatus(),
              color: Colors.deepPurple,
              size: 28,
            ),
          ),
        ],
      );
    });
  }
}
