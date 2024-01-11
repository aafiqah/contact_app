import 'package:contact_app/helper.dart';
import 'package:contact_app/mycontact.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddEditContacts extends StatefulWidget {
  const AddEditContacts({Key? key, this.mycontact}) : super(key: key);

  final Mycontact? mycontact;

  @override
  State<AddEditContacts> createState() => _AddEditState();
}

class _AddEditState extends State<AddEditContacts> {
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _profileImageController = TextEditingController();
  final _isFavoriteController = TextEditingController();

  File? _image;

  @override
  void initState() {
    super.initState();
    if (widget.mycontact != null) {
      _firstnameController.text = widget.mycontact!.firstname;
      _lastnameController.text = widget.mycontact!.lastname;
      _emailController.text = widget.mycontact!.email;
      _profileImageController.text = widget.mycontact!.profileImage ?? '';

       // Load the profile image if it exists
      if (_profileImageController.text.isNotEmpty) {
        _image = File(_profileImageController.text);
      }

     _isFavoriteController.text = widget.mycontact!.isFavorite ?? '';
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _profileImageController.dispose();
    _isFavoriteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: _buildAvatar(),
              ),
              const SizedBox(height: 30),
              _buildTextField(_firstnameController, 'First Name'),
              const SizedBox(height: 30),
              _buildTextField(_lastnameController, 'Last Name'),
              const SizedBox(height: 30),
              _buildTextField(_emailController, 'Email Address'),
              const SizedBox(height: 30),
              _buildElevatedButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            child: _image != null
                ? ClipOval(
                    child: Image.file(
                      _image!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.camera_alt),
          ),
          Positioned(
            bottom: 2,
            right: -12,
            child: IconButton(
              icon: const Icon(
                    Icons.edit,
                    color: Colors.green,
              ),
              onPressed: () {
                setState(() {
                  
                });
              },
            ),
          ),          
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hintText,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 50, 186, 165),
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (widget.mycontact != null) {
            await DBHelper.updateContacts(Mycontact(
              id: widget.mycontact!.id,
              firstname: _firstnameController.text,
              lastname: _lastnameController.text,
              email: _emailController.text,
              profileImage: _profileImageController.text, 
            ));
            Navigator.of(context).pop(true);
          } else {
            await DBHelper.createContacts(Mycontact(
              firstname: _firstnameController.text,
              lastname: _lastnameController.text,
              email: _emailController.text,
              profileImage: _profileImageController.text,
              isFavorite: _isFavoriteController.text,      
            ));
            Navigator.of(context).pop(true);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 50, 186, 165),
          padding: const EdgeInsets.all(15),
        ),
        child: const Text(
          'Done',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    String title = widget.mycontact != null ? 'Edit Contact' : 'Add Contact';

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 50, 186, 165),
      elevation: 0.0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
        onPressed: () => Navigator.of(context).pop(false),
      ),
    );
  }

  Future _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      print('Selected Image Path: ${image.path}');
      setState(() {
        _image = File(image.path);
        _profileImageController.text = image.path;
        print('Profile Image Controller: ${_profileImageController.text}');
      });
    }
  }
}
