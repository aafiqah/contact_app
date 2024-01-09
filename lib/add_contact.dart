import 'package:contact_app/helper.dart';
import 'package:contact_app/mycontact.dart';
import 'package:flutter/material.dart';

class AddContacts extends StatefulWidget {
  AddContacts({Key? key, this.mycontact}) : super(key: key);
  //here i add a variable
  //it is not a required, but use this when update
  final Mycontact? mycontact;

  @override
  State<AddContacts> createState() => _AddContactsState();
}

class _AddContactsState extends State<AddContacts> {
  //for TextField
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    //when mycontact has data, mean is to update
    //instead of create new mycontact
    if (widget.mycontact != null) {
      _firstnameController.text = widget.mycontact!.firstname;
      _lastnameController.text = widget.mycontact!.lastname;
      _fullnameController.text = widget.mycontact!.fullname;
      _emailController.text = widget.mycontact!.email;
    }
    super.initState();
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _fullnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contacts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(false),
          //to prevent back button pressed without add/update
        ),
      ),
      body: Center(
        //create two text field to key in name and mycontact
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildTextField(_firstnameController, 'First Name'),
              const SizedBox(
                height: 30,
              ),
              _buildTextField(_lastnameController, 'Last Name'),
              const SizedBox(
                height: 30,
              ),
              _buildTextField(_fullnameController, 'Full Name'),
              const SizedBox(
                height: 30,
              ),
              _buildTextField(_emailController, 'Email Address'),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                //this button is pressed to add mycontact
                onPressed: () async {
                  //if mycontact has data, then update existing list
                  //according to id
                  //else create a new mycontact
                  if (widget.mycontact != null) {
                    await DBHelper.updateContacts(Mycontact(
                      id: widget.mycontact!.id, //have to add id here
                      firstname: _firstnameController.text,
                      lastname: _lastnameController.text,
                      fullname: _fullnameController.text,
                      email: _emailController.text,
                    ));

                    Navigator.of(context).pop(true);
                  } else {
                    await DBHelper.createContacts(Mycontact(
                      firstname: _firstnameController.text,
                      lastname: _lastnameController.text,
                      fullname: _fullnameController.text,
                      email: _emailController.text,
                    ));

                    Navigator.of(context).pop(true);
                  }
                },
                child: const Text('Add Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //build a text field method
  TextField _buildTextField(TextEditingController _controller, String hint) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: hint,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
