import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_add_products.dart';

import '../widgets/app_drawer.dart';
import '../widgets/manage_design.dart';

import '../providers/products_provider.dart';

class ManageProducts extends StatefulWidget {
  static const routeName = '/ManageProducts';

  const ManageProducts({Key? key}) : super(key: key);

  @override
  State<ManageProducts> createState() => _ManageProductsState();
}

class _ManageProductsState extends State<ManageProducts> {
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if(_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductProvider>(context, listen: false).fetchProducts().then((value) {
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
    final products = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(
              EditAddScreen.routeName,
              arguments: {
                'type': 'Add a product',
                'id': '',
              },
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading ? const Center(child: CircularProgressIndicator(),) : ListView.builder(
        padding: const EdgeInsets.all(5),
        itemCount: products.getItems.length,
        itemBuilder: (_, index) => EditableProduct(
          productID: products.getItems[index].id,
          imageUrl: products.getItems[index].imageUrl,
          title: products.getItems[index].title,
          price: products.getItems[index].price,
          desc: products.getItems[index].description,
        ),
      ),
    );
  }
}
