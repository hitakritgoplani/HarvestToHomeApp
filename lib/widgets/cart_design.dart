import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartDesign extends StatelessWidget {
  final String productKey;
  final String title;
  final double price;
  final String farmerId;
  final String imageUrl;
  final int quantity;

  const CartDesign({
    Key? key,
    required this.productKey,
    required this.title,
    required this.price,
    required this.quantity,
    required this.farmerId,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final cartData = Provider.of<Cart>(context);

    return Dismissible(
      key: ValueKey(productKey),
      movementDuration: const Duration(milliseconds: 10),
      onDismissed: (direction) {
        cartData.removeEntire(productKey);
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Are you sure ?'),
            content: const Text('Do you want to remove the entire item ?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('No')),
              TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Yes')),
            ],
          ),
        );
      },
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 5),
        decoration: const BoxDecoration(
          color: Colors.red,
        ),
        child: const Align(
          alignment: Alignment.centerRight,
          child: Icon(
            Icons.delete,
            color: Colors.grey,
            size: 35,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10),
              width: width * 0.4,
              child: Image(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .headline1
                        ?.copyWith(fontSize: 35),
                  ),
                  Text(
                    'Price - \u20b9${price.toInt()}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          onPressed: () => cartData.removeFromCart(productKey),
                          icon: const Icon(Icons.remove)),
                      Text(quantity.toString()),
                      IconButton(
                          onPressed: () => cartData.addToCart(
                            productKey,
                            title,
                            price,
                            farmerId,
                            imageUrl,
                          ),
                          icon: const Icon(Icons.add)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
