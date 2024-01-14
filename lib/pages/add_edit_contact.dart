import 'package:contact_app/local_storage/helper.dart';
import 'package:contact_app/local_storage/mycontact.dart';

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
  final _avatarImageController = TextEditingController();
  final _isFavoriteController = TextEditingController();

  File? _image;

  @override
  void initState() {
    super.initState();
    if (widget.mycontact != null) {
      _firstnameController.text = widget.mycontact!.firstName;
      _lastnameController.text = widget.mycontact!.lastName;
      _emailController.text = widget.mycontact!.email;
      _avatarImageController.text = widget.mycontact!.avatar ?? '';
      _isFavoriteController.text = widget.mycontact!.isFavorite ?? '';
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _avatarImageController.dispose();
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
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF32BAA5), 
                width: 5.0, 
              ),
            ),
            child: CircleAvatar(
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
                  : (_avatarImageController.text.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            _avatarImageController.text,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.camera_alt)),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 2,
            child: Container(
              width: 30.0, 
              height: 30.0, 
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF32BAA5), 
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 15.0,
                ),
                onPressed: () async {
                  // Update the favorite status
                  setState(() {
                    _isFavoriteController.text =
                        (_isFavoriteController.text == '1') ? '0' : '1';
                  });

                  // Save the updated isFavorite status to the database
                  await DBHelper.updateContactFavoriteStatus(
                    widget.mycontact!.id!,
                    _isFavoriteController.text,
                  );
                },
              ),
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
            color: Color(0xFF32BAA5),
          ),
        ),
      ),
      style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
            ),
    );
  }

  Widget _buildElevatedButton(BuildContext context) {
    return SizedBox(
      width: 360,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          // to update mycontact to local storage
          if (widget.mycontact != null) {
            await DBHelper.updateContacts(Mycontact(
              id: widget.mycontact!.id,
              firstName: _firstnameController.text,
              lastName: _lastnameController.text,
              email: _emailController.text,
              avatar: _avatarImageController.text,
              isFavorite: widget.mycontact!.isFavorite,
            ));
            Navigator.of(context).pop(true);
          } 
          // to create new mycontact to local storage
          else {
            await DBHelper.createContacts(Mycontact(
              firstName: _firstnameController.text,
              lastName: _lastnameController.text,
              email: _emailController.text,
              avatar: _avatarImageController.text,
              isFavorite: _isFavoriteController.text,
            ));
            Navigator.of(context).pop(true);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF32BAA5),
          padding: const EdgeInsets.all(15),
        ),
        child: const Text(
          'Done',
           style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w500,
              height: 0.09,
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
            fontSize: 20,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w700,
            height: 0),
      ),      
      backgroundColor: const Color(0xFF32BAA5),
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
        _avatarImageController.text = image.path;
        print('Profile Image Controller: ${_avatarImageController.text}');
      });
    }
  }
}
