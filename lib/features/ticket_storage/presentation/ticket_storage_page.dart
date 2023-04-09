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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppTextButton(
            title: 'Добавить',
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
                        TextFormField(
                          controller: Get.find<TicketController>().urlController,
                          onChanged: Get.find<TicketController>().onChangeUrl,
                          decoration: InputDecoration(
                            labelText: 'Введите url',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GetX<TicketController>(builder: (controller) {
                          return TextButton(
                            style: ButtonStyle(
                              shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) =>
                                    states.contains(MaterialState.disabled)
                                        ? Colors.grey
                                        : const Color.fromRGBO(99, 81, 159, 1),
                              ),
                              foregroundColor: const MaterialStatePropertyAll(Colors.white),
                              textStyle: const MaterialStatePropertyAll(
                                TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onPressed: controller.isAddingUrlCorrect.value
                                ? () {
                                    controller.addTicketByUrl();
                                    Navigator.pop(context);
                                  }
                                : null,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 24),
                              child: Text('Добавить'),
                            ),
                          );
                        }),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 16),
          AppTextButton(
            onPressed: () {
              Get.find<TicketController>().downloadAllTickets();
            },
            title: 'Загрузить все',
          ),
        ],
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

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    this.title,
    required this.onPressed,
  });
  final String? title;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(title ?? ''),
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
