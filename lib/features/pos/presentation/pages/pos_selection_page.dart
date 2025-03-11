import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedidos/features/pos/presentation/bloc/pos_cubit.dart';
import 'package:pedidos/features/pos/presentation/bloc/pos_state.dart';
import 'package:go_router/go_router.dart';

class PosSelectionPage extends StatefulWidget {
  @override
  _PosSelectionPageState createState() => _PosSelectionPageState();
}

class _PosSelectionPageState extends State<PosSelectionPage> {
  @override
  void initState() {
    super.initState();

    // ✅ Load POS List Only Once
    context.read<PosCubit>().loadPosList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select POS")),
      body: BlocBuilder<PosCubit, PosState>(
        builder: (context, state) {
          if (state is PosLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PosLoaded) {
            return ListView.builder(
              itemCount: state.posList.length,
              itemBuilder: (context, index) {
                final posId = state.posList[index];
                return ListTile(
                  title: Text(posId),
                  onTap: () {
                    context.read<PosCubit>().selectPos(posId);
                    context
                        .go('/stock'); // Navigate to stock page after selection
                  },
                );
              },
            );
          } else if (state is PosError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text("No POS data available."));
          }
        },
      ),
    );
  }
}
