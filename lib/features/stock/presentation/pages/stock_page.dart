import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedidos/domain/entities/stock_item.dart';
import 'package:pedidos/features/stock/presentation/bloc/stock_cubit.dart';
import 'package:pedidos/features/stock/presentation/bloc/stock_state.dart';
import 'package:pedidos/features/stock/presentation/bloc/stock_transaction_cubit.dart';
import 'package:pedidos/core/network/connectivity_cubit.dart';

class StockPage extends StatelessWidget {
  final String posId;
  final String userRole;

  const StockPage({super.key, required this.posId, required this.userRole});

  @override
  Widget build(BuildContext context) {
    // ✅ Load stock when page opens
    context.read<StockCubit>().loadStock(posId);

    return Scaffold(
      appBar: AppBar(title: Text("Stock Management - $posId")),
      body: BlocBuilder<StockCubit, StockState>(
        builder: (context, state) {
          if (state is StockLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StockLoaded) {
            return ListView.builder(
              itemCount: state.stockItems.length,
              itemBuilder: (context, index) {
                final stock = state.stockItems[index];
                return StockItemTile(stock: stock, posId: posId);
              },
            );
          } else if (state is StockError) {
            return Center(child: Text("Error: ${state.message}"));
          } else {
            return const Center(child: Text("No stock data found."));
          }
        },
      ),
    );
  }
}

/// ✅ Stock Item Tile
class StockItemTile extends StatelessWidget {
  final StockItem stock;
  final String posId;

  const StockItemTile({super.key, required this.stock, required this.posId});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(stock.name),
      subtitle: Text("Packing: ${stock.packing} - Category: ${stock.category}"),
      trailing: _EditableQuantityField(stock: stock, posId: posId),
    );
  }
}

/// ✅ Inline Editable Quantity Field
class _EditableQuantityField extends StatefulWidget {
  final StockItem stock;
  final String posId;

  const _EditableQuantityField({required this.stock, required this.posId});

  @override
  _EditableQuantityFieldState createState() => _EditableQuantityFieldState();
}

class _EditableQuantityFieldState extends State<_EditableQuantityField> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.stock.quantity.toString());
  }

  @override
  Widget build(BuildContext context) {
    return _isEditing
        ? SizedBox(
            width: 70, // ✅ Compact input field
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              onSubmitted: (value) => _saveQuantity(context, value),
              onTapOutside: (_) => _saveQuantity(context, _controller.text),
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                border: OutlineInputBorder(),
              ),
            ),
          )
        : GestureDetector(
            onTap: () => setState(() => _isEditing = true),
            child: Container(
              width: 70,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey[200],
              ),
              child: Center(
                child: Text(
                  widget.stock.quantity.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
  }

  void _saveQuantity(BuildContext context, String value) {
    final double? newQuantity = double.tryParse(value);
    if (newQuantity != null && newQuantity != widget.stock.quantity) {
      final double difference = newQuantity - widget.stock.quantity;

      // ✅ Call StockTransactionCubit to handle stock updates
      context.read<StockTransactionCubit>().processTransaction(
            stockId: widget.stock.stockId,
            posId: widget.posId,
            change: difference,
            type: "correction",
            user: "Admin",
            connectivityCubit:
                context.read<ConnectivityCubit>(), // Check network status
          );
    }
    setState(() => _isEditing = false);
  }
}
