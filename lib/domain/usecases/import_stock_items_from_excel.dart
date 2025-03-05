import 'dart:async';

import 'package:excel/excel.dart';
import 'package:pedidos/domain/entities/stock_item.dart';
import 'package:pedidos/domain/repositories/stock_repository.dart';

class ImportStockItemsFromExcel {
  final StockRepository repository;

  ImportStockItemsFromExcel(this.repository);

  Future<void> call(
      {required String fileExtension, required List<int> fileBytes}) async {
    List<StockItem> items = [];
    final ext = fileExtension.toLowerCase();
    if (ext == 'xlsx' || ext == 'xls') {
      items = _parseExcel(fileBytes);
    } else {
      throw Exception('Formato de archivo no soportado');
    }
    //Bulk insert the items into the database
    await repository.bulkInsert(items);
  }

  List<StockItem> _parseExcel(List<int> fileBytes) {
    final Excel excel = Excel.decodeBytes(fileBytes);
    List<StockItem> items = [];
    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) {
      throw Exception('No data encontrada en el archivo excel');
    }

    for (int i = 2; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      items.add(StockItem(
        name: row[0]?.value?.toString() ?? '',
        quantity: double.tryParse(row[1]?.value?.toString() ?? '') ?? 0.0,
        category: row[2]?.value?.toString() ?? 'Uncategorized',
        unit: row[3]?.value?.toString() ?? 'unit',
        lot: int.tryParse(row[4]?.value?.toString() ?? '') ?? 0,
        min: double.tryParse(row[5]?.value?.toString() ?? '') ?? 0.0,
        max: double.tryParse(row[6]?.value?.toString() ?? '') ?? 0.0,
        transfer: row[7]?.value?.toString(),
        barcode: row[8]?.value?.toString(),
        error: double.tryParse(row[9]?.value?.toString() ?? '') ?? 0.0,
      ));
    }

    return items;
  }
}
