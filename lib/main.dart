import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surf_flutter_study_jam_2023/features/ticket_storage/presentation/ticket_storage_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color.fromRGBO(232, 221, 252, 1),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          foregroundColor: Colors.black,
          color: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            backgroundColor: const MaterialStatePropertyAll(Color.fromRGBO(232, 221, 252, 1)),
            foregroundColor: const MaterialStatePropertyAll(Colors.black),
            elevation: const MaterialStatePropertyAll(10),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const TicketStoragePage(),
    );
  }
}
