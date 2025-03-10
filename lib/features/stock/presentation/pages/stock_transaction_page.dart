/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedidos/domain/entities/stock_transaction.dart';
import '../bloc/stock_transaction_cubit.dart';
import '../bloc/stock_transaction_state.dart';

class StockTransactionPage extends StatelessWidget {
  final String stockId;
  final String posId;

  const StockTransactionPage(
      {super.key, required this.stockId, required this.posId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Stock Transactions")),
      body: BlocBuilder<StockTransactionCubit, StockTransactionState>(
        builder: (context, state) {
          if (state is StockTransactionLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is StockTransactionLoaded) {
            return ListView.builder(
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final txn = state.transactions[index];
                return ListTile(
                  title: Text(txn.type.toUpperCase()),
                  subtitle: Text("User: ${txn.user} • ${txn.timestamp}"),
                  trailing: Text(txn.change.toString(),
                      style: TextStyle(
                          color: txn.change < 0 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold)),
                );
              },
            );
          } else if (state is StockTransactionError) {
            return Center(child: Text(state.message));
          } else {
            return Center(child: Text("No transactions found"));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final txn = StockTransaction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            stockId: stockId,
            posId: posId,
            user: "Admin",
            change: -0.05, // Example: Deduct 0.05L for a sale
            timestamp: DateTime.now(),
            type: "sale",
          );
          context.read<StockTransactionCubit>().createTransaction(txn);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
*/