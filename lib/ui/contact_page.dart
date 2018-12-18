import 'dart:io';

import 'package:agenda_contato/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();

  final _nameFocus = FocusNode();

  Contact _editContact;
  bool _userEdited = false;

  @override
  void initState() {
    super.initState();

    if(widget.contact == null) {
      _editContact = Contact();
    } else {
      _editContact = Contact.fromMap(widget.contact.toMap());

      _nomeController.text = _editContact.name;
      _emailController.text = _editContact.email;
      _telefoneController.text = _editContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPost,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if(_editContact.name != null && _editContact.name.isNotEmpty) {
              Navigator.pop(context, _editContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      child: Container(
                        width: 140.0,
                        height: 140.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: _editContact.img != null
                                    ? FileImage(File(_editContact.img))
                                    : AssetImage("images/person.png")
                            )
                        ),
                      ),
                      onTap: () {
                        ImagePicker.pickImage(source: ImageSource.camera).then((file) {
                          if(file != null) {
                            setState(() {
                              _editContact.img = file.path;
                            });
                          }
                        });
                      },
                    ),
                    TextField(
                      focusNode: _nameFocus,
                      controller: _nomeController,
                      decoration: InputDecoration(labelText: "Nome"),
                      onChanged: (text) {
                        _userEdited = true;
                        setState(() {
                          _editContact.name = text;
                        });
                      },
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: "E-mail"),
                      onChanged: (text) {
                        _userEdited = true;
                        _editContact.email = text;
                      },
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: _telefoneController,
                      decoration: InputDecoration(labelText: "Telefone"),
                      onChanged: (text) {
                        _userEdited = true;
                        _editContact.phone = text;
                      },
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPost() {
    if(_userEdited) {
      showDialog(context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Descartar alterações?"),
            content: Text("Se sair as alterações serão perdidas."),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

}
