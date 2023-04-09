import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/controller/ticket_controller.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/presentation/widgets/ticket_tile.dart';

/// Экран “Хранения билетов”.
class TicketStoragePage extends StatelessWidget {
  const TicketStoragePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Хранения билетов'),
      ),
      floatingActionButton: TextButton(
        onPressed: () {
          showModalBottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: Get.find<TicketController>().urlController,
                      decoration: InputDecoration(
                        labelText: 'Введите url',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      style: ButtonStyle(
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        backgroundColor: const MaterialStatePropertyAll(
                          Color.fromRGBO(99, 81, 159, 1),
                        ),
                        foregroundColor: const MaterialStatePropertyAll(Colors.white),
                        textStyle: const MaterialStatePropertyAll(
                          TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Get.find<TicketController>().addTicketByUrl();
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
                        child: Text('Добавить'),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          );
        },
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Добавить'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GetX<TicketController>(
          init: TicketController(),
          builder: (controller) {
            if (controller.ticketList.isEmpty) {
              return const TicketsEmptyListWidget();
            } else {
              return ListView.separated(
                shrinkWrap: true,
                itemCount: controller.ticketList.length,
                itemBuilder: (context, index) {
                  var ticket = controller.ticketList[index];
                  return TicketTileWidget(
                    ticket: ticket,
                    ticketIndex: index,
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 24);
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class TicketsEmptyListWidget extends StatelessWidget {
  const TicketsEmptyListWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Здесь пока ничего нет'),
    );
  }
}
