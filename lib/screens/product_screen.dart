import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:harvesttohome/screens/manage_products_screen.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cart_screen.dart';

import '../providers/products_provider.dart';
import '../providers/cart.dart';

import '../widgets/product_design.dart';
import '../widgets/app_drawer.dart';

enum PopupListOptions {
  all,
  favourites,
  cart,
}

class ProductOverview extends StatefulWidget {
  static const routeName = '/ProductOverview';

  const ProductOverview({Key? key}) : super(key: key);

  @override
  State<ProductOverview> createState() => _ProductOverviewState();
}

class _ProductOverviewState extends State<ProductOverview> {
  PopupListOptions filter = PopupListOptions.all;
  bool _isInit = true;
  bool _isLoading = false;
  String? _role = null;

  void showItems(PopupListOptions choice) {
    if (choice == PopupListOptions.favourites) {
      setState(() {
        filter = PopupListOptions.favourites;
      });
    } else if (choice == PopupListOptions.cart) {
      goToCart();
    } else {
      setState(() {
        filter = PopupListOptions.all;
      });
    }
  }

  void goToCart() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    Navigator.of(context).pushNamed(CartScreen.routeName);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductProvider>(context).getRole().then((value) {
        setState(() {
          _role = value;
        });
      });
      Provider.of<ProductProvider>(context).fetchProducts(false).then((value) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return _role == 'Customer'
        ? Scaffold(
            drawer: const AppDrawer(),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(
                color: Color.fromRGBO(48, 55, 51, 1),
              ),
              title: Row(
                children: [
                  GestureDetector(
                    onTap: () => showItems(PopupListOptions.all),
                    child: const Text(
                      'H2H',
                    ),
                  ),
                  const Spacer(),
                  Consumer<Cart>(
                    child: GestureDetector(
                      onTap: goToCart,
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Color.fromRGBO(48, 55, 51, 1),
                        size: 30,
                      ),
                    ),
                    builder: (_, cartData, child) => Badge(
                      badgeContent: FittedBox(
                          child: Text(cartData.totalItems.toString())),
                      badgeAnimation: const BadgeAnimation.scale(),
                      child: child,
                    ),
                  ),
                  SizedBox(
                    width: width * 0.05,
                  ),
                  Consumer<ProductProvider>(
                    child: GestureDetector(
                      onTap: () => showItems(PopupListOptions.favourites),
                      child: const Icon(
                        Icons.favorite_border,
                        color: Color.fromRGBO(48, 55, 51, 1),
                        size: 30,
                      ),
                    ),
                    builder: (_, prod, child) => Badge(
                      badgeAnimation: const BadgeAnimation.scale(),
                      badgeContent: Text(prod.totalFav.toString()),
                      child: child,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                PopupMenuButton(
                  onSelected: (PopupListOptions selectedValue) {
                    showItems(selectedValue);
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: PopupListOptions.all,
                      child: Text('All'),
                    ),
                    const PopupMenuItem(
                      value: PopupListOptions.favourites,
                      child: Text('Favourites'),
                    ),
                    const PopupMenuItem(
                      value: PopupListOptions.cart,
                      child: Text('Your Cart'),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                )
              ],
            ),
            body: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : MainProductList(filter: filter),
          )
        : const ManageProducts();
  }
}

class MainProductList extends StatelessWidget {
  final PopupListOptions filter;

  const MainProductList({Key? key, required this.filter}) : super(key: key);

  Future<void> _fetchProducts(BuildContext context) async {
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchProducts(false);
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductProvider>(context);

    final getProducts = (filter == PopupListOptions.all)
        ? productsData.getItems
        : productsData.favItems;
    final double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.bottom -
        kToolbarHeight;

    return RefreshIndicator(
      onRefresh: () => _fetchProducts(context),
      child: ListView.builder(
        itemExtent: height * 0.16,
        itemCount: getProducts.length,
        itemBuilder: (ctx, index) {
          //Always use the .value method when working with lists, grids, ....
          return ChangeNotifierProvider.value(
            value: getProducts[index],
            child: const ProductDesign(),
          );
        },
      ),
    );
  }
}
