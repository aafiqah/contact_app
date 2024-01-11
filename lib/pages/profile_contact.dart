import 'package:contact_app/helper.dart';
import 'package:contact_app/mycontact.dart';
import 'package:contact_app/pages/add_edit_contact.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ProfileContact extends StatefulWidget {
  const ProfileContact({super.key, this.mycontact});

  final Mycontact? mycontact;

  @override
  State<ProfileContact> createState() => _ProfileContactState();
}

class _ProfileContactState extends State<ProfileContact> {
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _fullnameController = TextEditingController();
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
      _fullnameController.text = widget.mycontact!.fullname;
      _emailController.text = widget.mycontact!.email;
      _profileImageController.text = widget.mycontact!.profileImage ?? '';
      _isFavoriteController.text = widget.mycontact!.isFavorite ?? '';

      if (_profileImageController.text.isNotEmpty) {
        _image = File(_profileImageController.text);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.mycontact != null) {
      _refreshData();
    }
  }

  void _refreshData() async {
    // Call DBHelper.readContacts() to get the updated data
    List<Mycontact> updatedContacts = await DBHelper.readContacts();

    // Find the updated contact from the list based on ID
    Mycontact updatedContact = updatedContacts.firstWhere(
      (contact) => contact.id == widget.mycontact!.id,
    );

    setState(() {
      // Update the state with the new data
      _fullnameController.text = updatedContact.fullname;
      _emailController.text = updatedContact.email;

      // Update the profile image
      if (updatedContact.profileImage != null &&
          updatedContact.profileImage!.isNotEmpty) {
        _image = File(updatedContact.profileImage!);
        _profileImageController.text = updatedContact.profileImage!;
      } else {
        // Handle the case where the profile image is empty or null
        _image = null;
        _profileImageController.text = '';
      }

      // Update the favorite status
      _isFavoriteController.text = updatedContact.isFavorite ?? '';
    });
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _fullnameController.dispose();
    _emailController.dispose();
    _profileImageController.dispose();
    _isFavoriteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildbody(context),
    );
  }

  SingleChildScrollView buildbody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          builEditContact(),
          const SizedBox(height: 10),
          _buildAvatar(),
          _buildTextField(_fullnameController),
          const SizedBox(height: 10),
          buildSendEmailField(_emailController),
          const SizedBox(height: 30),
          _buildElevatedButton(context, _emailController),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          controller.text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget buildSendEmailField(TextEditingController controller) {
    return Container(
      color: Colors.grey[300],
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/Emel.png',
            height: 50,
            width: 50,
          ),
          const SizedBox(height: 3),
          Align(
            alignment: Alignment.center,
            child: Text(
              controller.text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 3),
        ],
      ),
    );
  }

  Widget builEditContact() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AddEditContacts(mycontact: widget.mycontact),
        ));

        print('Result from AddEditContacts: $result');

        if (result == true) {
          _showSnackBar(
            context,
            'Successfully updated',
            Colors.green,
          );
          _refreshData(); // Refresh data after edit
        }
      },
      child: const Padding(
        padding: EdgeInsets.only(top: 30, right: 30),
        child: Align(
          alignment: Alignment.topRight,
          child: Text(
            'Edit',
            style: TextStyle(
              color: Color(0xFF32BAA5),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(
      BuildContext context, String message, MaterialColor color) {
    final snackBar = SnackBar(content: Text(message), backgroundColor: color);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
              icon: Icon(
                _isFavoriteController.text == '1'
                    ? Icons.star
                    : Icons.star_border,
                color: _isFavoriteController.text == '1'
                    ? Colors.yellow
                    : Colors.grey,
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
        ],
      ),
    );
  }

  Widget _buildElevatedButton(
      BuildContext context, TextEditingController emailController) {
    return SizedBox(
      width: 300,
      child: ElevatedButton(
        onPressed: () async {
          String? encodeQueryParameters(Map<String, String> params) {
            return params.entries
                .map((MapEntry<String, String> e) =>
                    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                .join('&');
          }

          final Uri emailLaunchUri = Uri(
            scheme: 'mailto',
            path: emailController.text,
            query: encodeQueryParameters(<String, String>{
              'subject': 'Hi',
              'body': 'good morning',
            }),
          );

          try {
            await launchUrl(emailLaunchUri);
          } catch (e) {
            print(e.toString());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 50, 186, 165),
          padding: const EdgeInsets.all(15),
        ),
        child: const Text(
          'Send Email',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text(
        "Profile",
        style: TextStyle(
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
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
