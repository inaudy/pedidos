import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

/// ✅ Function to upload stock data from Excel to Firestore using Auto-ID
Future<void> uploadExcelToFirestore(String posId) async {
  print('starting');
  // ✅ Pick Excel File
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
  );

  if (result == null) {
    print("❌ No file selected.");
    return;
  }

  File file = File(result.files.single.path!);
  var bytes = await file.readAsBytes();
  var excel = Excel.decodeBytes(bytes);

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ✅ Assume the first sheet contains stock data
  var sheet = excel.tables.keys.first;
  var rows = excel.tables[sheet]!.rows;

  for (int i = 1; i < rows.length; i++) {
    var row = rows[i];

    // ✅ Ensure row has enough columns before processing
    //if (row.length < 11) continue; // Now checking for transfer column too
    print('before try');
    try {
      String name = row[0]?.value.toString() ?? '';
      double quantity = double.tryParse(row[1]?.value.toString() ?? '0') ?? 0;
      double bottleSize = double.tryParse(row[2]?.value.toString() ?? '0') ?? 0;
      String category = row[3]?.value.toString() ?? '';
      String unit = row[4]?.value.toString() ?? '';
      String packing = row[5]?.value.toString() ?? '';
      double min = double.tryParse(row[6]?.value.toString() ?? '0') ?? 0;
      double max = double.tryParse(row[7]?.value.toString() ?? '0') ?? 0;
      String transfer =
          row[8]?.value.toString() ?? ''; // ✅ Fix: Added Transfer Column
      String barcode = row[9]?.value.toString() ?? '';

      // ✅ Generate Auto-ID
      DocumentReference docRef =
          firestore.collection('pos').doc(posId).collection('stocks').doc();

      // ✅ Upload data to Firestore
      await docRef.set({
        'stockId': docRef.id, // ✅ Save the Auto-ID
        'name': name,
        'quantity': quantity,
        'bottleSize': bottleSize,
        'category': category,
        'unit': unit,
        'packing': packing,
        'min': min,
        'max': max,
        'transfer': transfer, // ✅ Fix: Added Transfer Field
        'barcode': barcode,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print("✅ Uploaded: $name (ID: ${docRef.id})");
    } catch (e) {
      print("❌ Error uploading row ${i + 1}: $e");
    }
  }
}
