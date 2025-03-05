import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedidos/domain/entities/stock_item.dart';
import 'package:pedidos/features/stock/presentation/cubits/stock_cubit.dart';
import 'package:file_picker/file_picker.dart';

class StockPage extends StatelessWidget {
  final String userRole;
  const StockPage({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Management $userRole')),
      body: BlocBuilder<StockCubit, StockState>(
        builder: (context, state) {
          if (state is StockLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StockLoaded) {
            final items = state.items;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                StockItem item = items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('Quantity: ${item.quantity}'),
                );
              },
            );
          } else if (state is StockError) {
            return Center(child: Text(state.message));
          }
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => pickExcelFile(context),
        child: const Icon(Icons.import_contacts),
      ),
    );
  }

  Future<void> pickExcelFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['xlsx', 'xls'],
      type: FileType.custom,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final extension = file.extension?.toLowerCase();
      List<int> fileBytes;
      if (file.bytes != null) {
        fileBytes = file.bytes!;
      } else if (file.path != null) {
        final fileFromDisk = File(file.path!);
        fileBytes = await fileFromDisk.readAsBytes();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error leyendo el archivo'),
            ),
          );
        }

        return;
      }
      if (context.mounted) {
        await context
            .read<StockCubit>()
            .importStockFromExcel(extension!, fileBytes);
      }
    }
  }
}
