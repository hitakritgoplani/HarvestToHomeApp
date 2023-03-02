import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';

import '../widgets/app_drawer.dart';
import '../widgets/order_design.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = '/OrderScreen';

  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {

  @override
  void initState() {
    Provider.of<Orders>(context, listen: false).fetchOrderItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final orderData = Provider.of<Orders>(context);

    final height = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Your orders'),
      ),
      body: SizedBox(
        height: height,
        child: orderData.orders.isEmpty ? const Text('No orders') : ListView.builder(
          itemCount: orderData.orders.length,
          itemBuilder: (ctx, index) => OrderDesign(
            dateTime: orderData.orders[index].dateTime,
            total: orderData.orders[index].total,
            items: orderData.orders[index].products,
          ),
        ),
      ),
    );
  }
}
