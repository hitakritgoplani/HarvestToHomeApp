import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/product.dart';
import '/providers/products_provider.dart';

import '/screens/manage_products_screen.dart';

class EditAddScreen extends StatefulWidget {
  static const routeName = '/EditAddScreen';

  const EditAddScreen({Key? key}) : super(key: key);

  @override
  State<EditAddScreen> createState() => _EditAddScreenState();
}

class _EditAddScreenState extends State<EditAddScreen> {
  bool isInit = true;

  final _imageController = TextEditingController();
  final _imageFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey();
  String? _pageType;
  bool _isLoading = false;

  Product _newProduct = Product(
    id: '',
    title: '',
    description: '',
    price: 0.0,
    imageUrl: '',
  );

  @override
  void initState() {
    _imageFocus.addListener(_updateImage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final routeArgs =
          ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      _pageType = routeArgs['type'];
      final productID = routeArgs['id'].toString();

      if (_pageType == 'Edit Product') {
        Product product = Provider.of<ProductProvider>(context, listen: false)
            .findByID(productID);
        _newProduct = Product(
          id: product.id,
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          isFavorite: product.isFavorite,
        );
        _imageController.text = product.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageFocus.dispose();
    _imageFocus.removeListener(_updateImage);
    _imageController.dispose();
    super.dispose();
  }

  void _updateImage() {
    if (!_imageFocus.hasFocus) {
      setState(() {});
    }
  }

  OutlineInputBorder drawBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: color),
    );
  }

  InputDecoration inputDecoration(String text) {
    return InputDecoration(
      labelText: text,
      floatingLabelStyle: const TextStyle(color: Colors.teal),
      contentPadding: const EdgeInsets.all(20),
      enabledBorder: drawBorder(Colors.black),
      focusedBorder: drawBorder(Colors.teal),
      errorBorder: drawBorder(Colors.red),
      focusedErrorBorder: drawBorder(Colors.red),
    );
  }

  Future<void> _saveForm(String type) async {
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (type == 'Edit Product') {
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .updateProduct(_newProduct);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Something went wrong!'),
            content: const Text('Update failed :('),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Ok')),
            ],
          ),
        );
      }
    } else {
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .addProduct(_newProduct);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Something went wrong.'),
            content: const Text('Please try again'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    if (!mounted) return;
    Navigator.of(context)
        .popUntil(ModalRoute.withName(ManageProducts.routeName));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    String imageUrl = 'https://semantic-ui.com/images/wireframe/image.png';

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageType.toString()),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              !_formKey.currentState!.validate()
                  ? ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Enter valid data')))
                  : showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: _pageType == 'Edit Product'
                              ? const Text('Edit Product')
                              : const Text('Add Product'),
                          content: const Text('Are you sure ?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _saveForm(_pageType.toString());
                              },
                              child: const Text('Yes'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).popUntil(
                                    ModalRoute.withName(
                                        ManageProducts.routeName));
                              },
                              child: const Text('Discard'),
                            ),
                          ],
                        );
                      },
                    );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 10, bottom: 10),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: width / 4,
                      backgroundColor: Colors.transparent,
                      backgroundImage:
                          !Uri.parse(_imageController.text).isAbsolute
                              ? NetworkImage(imageUrl)
                              : NetworkImage(_imageController.text),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: _newProduct.title,
                      maxLength: 20,
                      cursorColor: Colors.teal,
                      decoration: inputDecoration('Title'),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid title.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _newProduct = Product(
                          id: _newProduct.id,
                          title: value.toString(),
                          description: _newProduct.description,
                          price: _newProduct.price,
                          imageUrl: _newProduct.imageUrl,
                          isFavorite: _newProduct.isFavorite,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: _newProduct.price.toString(),
                      cursorColor: Colors.teal,
                      decoration: inputDecoration('Price'),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null ||
                            double.tryParse(value)! <= 0) {
                          return 'Please enter a valid number.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _newProduct = Product(
                          id: _newProduct.id,
                          title: _newProduct.title,
                          description: _newProduct.description,
                          price: double.parse(value.toString()),
                          imageUrl: _newProduct.imageUrl,
                          isFavorite: _newProduct.isFavorite,
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      initialValue: _newProduct.description,
                      maxLength: 150,
                      cursorColor: Colors.teal,
                      decoration: inputDecoration('Description'),
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _newProduct = Product(
                          id: _newProduct.id,
                          title: _newProduct.title,
                          description: value.toString(),
                          price: _newProduct.price,
                          imageUrl: _newProduct.imageUrl,
                          isFavorite: _newProduct.isFavorite,
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _imageController,
                      focusNode: _imageFocus,
                      cursorColor: Colors.teal,
                      decoration: inputDecoration('Image URL'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !Uri.parse(value).isAbsolute) {
                          return 'Please enter a valid url.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _newProduct = Product(
                          id: _newProduct.id,
                          title: _newProduct.title,
                          description: _newProduct.description,
                          price: _newProduct.price,
                          imageUrl: value.toString(),
                          isFavorite: _newProduct.isFavorite,
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
