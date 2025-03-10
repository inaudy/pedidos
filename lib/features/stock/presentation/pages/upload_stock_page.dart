import 'package:flutter/material.dart';
import 'package:pedidos/features/stock/presentation/pages/upload_stock.dart';

class UploadStockPage extends StatelessWidget {
  final String posId;

  const UploadStockPage({super.key, required this.posId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Stock Data")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await uploadExcelToFirestore(posId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Stock data uploaded!")),
            );
          },
          child: Text("Upload Excel to Firestore"),
        ),
      ),
    );
  }
}
