import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  //we have to dispose the focusNodes when the state gets cleared
  //<=> when the object gets removed (when we leave the screen)
  //to avoid memory leaks
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();

  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: "",
    imageUrl: "",
  );

  var _initValues = {
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": "",
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "price": _editedProduct.price.toString(),
          // "imageUrl": _editedProduct.imageUrl,
          "imageUrl": "",
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    //to avoid renitializing our form
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    //will be fired if we had focus but we lost it
    // <=> we have an updated value of _imageUrlController
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith("http") &&
              !_imageUrlController.text.startsWith("https")) ||
          (!_imageUrlController.text.endsWith(".png") &&
              !_imageUrlController.text.endsWith(".jpg") &&
              !_imageUrlController.text.endsWith(".jpeg"))) {
        return;
      }
      //to rebuild the screen to reflect
      //the value in the _imageUrlController
      setState(() {});
    }
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  //triggers a method on every TextFormField which allows us
  //to take the value entered into the TextFormField
  void _saveForm() {
    //triggers the validators and returns true
    //if all user inputs are valid
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      Provider.of<Products>(context, listen: false).updateProduct(
        _editedProduct.id,
        _editedProduct,
      );
      setState(() {
        _isLoading = false;
      });
    } else {
      Provider.of<Products>(context, listen: false)
          .addProduct(_editedProduct)
          .catchError((error) {
        return showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("An error has occured"),
            content: Text("Something went wrong."),
            actions: [
              FlatButton(
                child: Text("Okay"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      }).then((_) {
        //we only pop once the product was added
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
    // print(_editedProduct.title);
    // print(_editedProduct.description);
    // print(_editedProduct.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues["title"],
                      decoration: InputDecoration(
                        labelText: "Title",
                      ),
                      //changes the type of the button
                      //at the bottom right of the keyboard
                      textInputAction: TextInputAction.next,
                      //fires whenever the button
                      //at the bottom right corner of the keyboard is pressed
                      //value is the value that was entered in the field
                      onFieldSubmitted: (value) {
                        //moves the focus to the element which has the focusNode value _priceFocusNode
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          //this String will be our message error
                          return "Please provide a value.";
                        }
                        // returning null means we have no error
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: value,
                          price: _editedProduct.price,
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues["price"],
                      decoration: InputDecoration(
                        labelText: "Price",
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a price.";
                        }
                        //returns null if the parsing failed
                        if (double.tryParse(value) == null) {
                          return "Please enter a valid number.";
                        }
                        if (double.parse(value) <= 0) {
                          return "Please enter a number greater than 0.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: double.parse(value),
                          description: _editedProduct.description,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    //long input
                    TextFormField(
                      initialValue: _initValues["description"],
                      decoration: InputDecoration(
                        labelText: "Description",
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a description.";
                        }
                        //description should at least have 10 chars
                        if (value.length < 10) {
                          return "Description should be at least 10 characters long.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          description: value,
                          imageUrl: _editedProduct.imageUrl,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        //to show preview of the image
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text("Enter a URL")
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            // doesn't work because image has a controller
                            // so we have to use the controller to set the initialValue
                            // initialValue: _initValues["imageUrl"],
                            decoration: InputDecoration(labelText: "Image URL"),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            focusNode: _imageUrlFocusNode,
                            //we want to access the input before the form is submitted
                            // to show the preview of the image => adding our own textEditingController

                            //updated when we type into the TextFormField
                            controller: _imageUrlController,
                            // onEditingComplete: () {
                            //   setState(() {});
                            // },
                            onFieldSubmitted: (value) {
                              _saveForm();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter an image URL.";
                              }
                              if (!value.startsWith("http") &&
                                  !value.startsWith("https")) {
                                return "Please enter a valid URL";
                              }
                              if (!value.endsWith(".png") &&
                                  !value.endsWith(".jpg") &&
                                  !value.endsWith(".jpeg")) {
                                return "Please enter a valid image URL";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                title: _editedProduct.title,
                                price: _editedProduct.price,
                                description: _editedProduct.description,
                                imageUrl: value,
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
