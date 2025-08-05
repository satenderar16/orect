
import 'package:amtnew/myapp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


class OrderPageDemo extends ConsumerStatefulWidget {
  final String? orderId;

  const OrderPageDemo({super.key, this.orderId});

  @override
  ConsumerState<OrderPageDemo> createState() => _OrderPageDemoState();
}

class _OrderPageDemoState extends ConsumerState<OrderPageDemo> {
  late bool showDetails;
  late String? selectedOrder;

  @override
  void initState() {
    super.initState();
    showDetails = widget.orderId != null;
    selectedOrder = widget.orderId;
  }

  void _openDetails(String orderId) {

    setState(() {
      selectedOrder = orderId;
      showDetails = true;
    });
    context.go('/dashboard/orders?id=$orderId');

  }

  void _closeDetails() {


    context.go('/dashboard/orders');


  }

  @override
  Widget build(BuildContext context) {
    print("Rendering OrderPageDemo with orderId: ${widget.orderId}");

    return PopScope(
      canPop: false, // prevent automatic pop
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Orders')),
        body: Row(
          children: [
            Expanded(
              child: OrdersList(
                onTap: _openDetails,
              ),
            ),
            if (showDetails && selectedOrder != null)
              Expanded(
                child: OrderDetailsPanel(
                  orderId: selectedOrder!,
                  onClose: _closeDetails,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
// 🔹 Order List Widget
class OrdersList extends StatelessWidget {
  final void Function(String orderId) onTap;

  const OrdersList({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final orders = List.generate(5, (index) => 'Order #${index + 1}');
    final location = GoRouter.of(context).state.fullPath;
    debugPrint(location);
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index]; // ✅ this gives "Order #1", "Order #2", etc.
        return ListTile(
          title: Text(order),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => onTap(index.toString()), // ✅ send full string to parent
        );
      },
    );
  }
}
class OrderDetailsPanel extends StatelessWidget {
  final String orderId;
  final VoidCallback onClose;

  const OrderDetailsPanel({super.key, required this.orderId, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.indigo.shade50,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                orderId,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text("Order details go here...", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Container(height: 100, color: Colors.deepPurple.shade100),
        ],
      ),
    );
  }
}



class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});
  @override
  Widget build(BuildContext context,ref) {

    final location = GoRouter.of(context).state.fullPath;
    debugPrint(location);
    return  PopScope(
      canPop: false, // prevent automatic pop
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

       debugPrint("this is orderPage 1");

        // Show exit dialog on branch 0 with empty stack

      },
      child: Scaffold(
        appBar: AppBar(title: Text("orderPage"),),
        body: Center(child: TextButton(onPressed:(){
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => OrderHistory()),
          );
        },child: Text('Orders Page')),),
      ),
    );
  }
}

class OrderHistory extends StatelessWidget {
  const OrderHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).state.fullPath;
    debugPrint(location);
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: TextButton(onPressed:(){
        ordersNavKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (context) => OrderValue(),
          ),
        );
      },child: Text('Orders history')),),
    );
  }
}
class OrderItems extends StatelessWidget {
  const OrderItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: TextButton(onPressed:(){

      },child: Text('Orders Items')),),
    );
  }
}

class OrderValue extends StatelessWidget {
  const OrderValue({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: TextButton(onPressed:(){

      },child: Text('Orders Values')),),
    );
  }
}
