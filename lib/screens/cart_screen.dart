import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/cart_design.dart';

import '../providers/orders.dart';
import '../providers/cart.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/CartScreen';

  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.bottom -
        kToolbarHeight;

    final double width = MediaQuery.of(context).size.width;

    final cartData = Provider.of<Cart>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Cart'),
        ),
        body: cartData.cartItems.isEmpty
            ? const Center(child: Text('No Items in Cart'))
            : Column(
                children: [
                  SizedBox(
                    height: height * 0.87,
                    child: _isLoading
                        ? Center(
                            child: SizedBox(
                              height: height * 0.05,
                              child: const CircularProgressIndicator(),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(5),
                            itemExtent: height * 0.25,
                            itemCount: cartData.cartItems.length,
                            itemBuilder: (ctx, index) {
                              return CartDesign(
                                productKey:
                                    cartData.cartItems.keys.elementAt(index),
                                title: cartData.cartItems.values
                                    .toList()[index]
                                    .title,
                                imageUrl: cartData.cartItems.values
                                    .toList()[index]
                                    .imageUrl,
                                price: cartData.cartItems.values
                                    .toList()[index]
                                    .price,
                                quantity: cartData.cartItems.values
                                    .toList()[index]
                                    .quantity,
                              );
                            },
                          ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      width: width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                          colors: [
                            Colors.teal.shade300,
                            Colors.white,
                          ],
                          //stops: [0, 0.7],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Total :  ',
                            style:
                                Theme.of(context).textTheme.headline1?.copyWith(
                                      color: Colors.black,
                                      fontSize: 35,
                                    ),
                          ),
                          Text(
                            '\u20b9 ${cartData.totalPrice.toInt()}',
                            style:
                                Theme.of(context).textTheme.headline1?.copyWith(
                                      color: Colors.black,
                                      fontSize: 35,
                                    ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              await Provider.of<Orders>(context, listen: false)
                                  .addOrder(
                                    cartData.cartItems.values.toList(),
                                    cartData.totalPrice.toInt(),
                                  )
                                  .then((_) => cartData.clearCart());
                              setState(() {
                                _isLoading = false;
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.teal),
                            ),
                            child: const Text('Checkout'),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ));
  }
}
