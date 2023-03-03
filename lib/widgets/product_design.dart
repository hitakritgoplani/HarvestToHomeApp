import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../providers/auth.dart';

import '../screens/product_desc.dart';

class ProductDesign extends StatelessWidget {
  const ProductDesign({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    final product = Provider.of<Product>(context);

    void goToDesc() {
      Navigator.of(context).pushNamed(
        ProductDesc.routeName,
        arguments: product.id,
      );
    }

    return GestureDetector(
      onTap: goToDesc,
      child: Card(
        color: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        elevation: 2,
        margin: const EdgeInsets.only(left: 7, top: 10, right: 7),
        child: Row(
          children: [
            SizedBox(
              width: width * 0.01,
            ),
            CircleAvatar(
              radius: width * 0.25 / 2,
              backgroundColor: Colors.transparent,
              child: Hero(
                tag: product.id,
                child: FadeInImage(
                  placeholder: const AssetImage('images/product-placeholder.png'),
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: width * 0.02,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  width: width * 0.66,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.title,
                        style: Theme.of(context).textTheme.headline1,
                      ),
                      Text(
                        '\u20B9 ${product.price.toInt()}',
                        style: TextStyle(
                          color: Colors.teal.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: width * 0.66,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Consumer<Cart>(
                        builder: (_, cartData, child) => IconButton(
                            onPressed: () {
                              cartData.addToCart(
                                product.id,
                                product.title,
                                product.price,
                                product.farmerId,
                                product.imageUrl,
                              );
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Item Added to Cart'),
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () => cartData.removeFromCart(product.id),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_shopping_cart_rounded)),
                      ),
                      Consumer2<Auth, ProductProvider>(builder: (_, authData,productData, __) {
                        return IconButton(
                          onPressed: () async {
                           productData.notifyFrom();
                           await product.toggleFavorite(authData.token!, authData.userID!);
                          },
                          icon: product.isFavorite
                              ? const Icon(Icons.favorite)
                              : const Icon(
                                  Icons.favorite_border,
                                ),
                          color: const Color.fromRGBO(255, 0, 0, 1),
                          iconSize: 30,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: width * 0.01),
          ],
        ),
      ),
    );
  }
}
