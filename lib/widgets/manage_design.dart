import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

import '../screens/edit_add_products.dart';

class EditableProduct extends StatelessWidget {
  final String productID;
  final String title;
  final double price;
  final String desc;
  final String imageUrl;

  const EditableProduct({
    Key? key,
    required this.productID,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.desc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final navigator = Navigator.of(context);
    final scaffold = ScaffoldMessenger.of(context);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(5),
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(imageUrl),
          radius: 30,
        ),
        title: Text(title),
        trailing: SizedBox(
          width: width * 0.25,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.of(context).pushNamed(
                  EditAddScreen.routeName,
                  arguments: {
                    'type': 'Edit Product',
                    'id': productID,
                  },
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Delete $title'),
                      content: const Text('Are you sure ?'),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            navigator.pop();
                            try {
                              await Provider.of<ProductProvider>(context,
                                      listen: false)
                                  .removeItem(productID);
                            } catch (error) {
                              scaffold.showSnackBar(
                                SnackBar(
                                  content: Text(error.toString()),
                                ),
                              );
                            }
                          },
                          child: const Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('No'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
