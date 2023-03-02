import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../providers/cart.dart';

class ProductDesc extends StatelessWidget {
  static const routeName = '/ProductDesc';

  const ProductDesc({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productID = ModalRoute.of(context)?.settings.arguments as String;

    //We give listen false as we don't need to rebuild this widget once it is
    // created as product description wont change even if we add other products.
    final productData = Provider.of<ProductProvider>(context, listen: false);
    final cartData = Provider.of<Cart>(context, listen: false);

    final title = productData.findByID(productID).title;
    final imageUrl = productData.findByID(productID).imageUrl;
    final price = productData.findByID(productID).price;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(title),
      //   actions: [
      //     IconButton(
      //       onPressed: () =>
      //           cartData.addToCart(productID, title, imageUrl, price),
      //       icon: const Icon(Icons.add_shopping_cart),
      //     ),
      //   ],
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.teal,
            actions: [
              IconButton(
                onPressed: () =>
                    cartData.addToCart(productID, title, imageUrl, price),
                icon: const Icon(Icons.add_shopping_cart),
              ),
            ],
            expandedHeight: 500,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headline1
                    ?.copyWith(color: Colors.white),
              ),
              background: Hero(
                tag: productID,
                child: Image.network(imageUrl),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Text(
                price.toString(),
                textAlign: TextAlign.center,
              ),
              Text(
                productData.findByID(productID).description,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 800,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
