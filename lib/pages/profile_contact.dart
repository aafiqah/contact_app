import 'package:contact_app/local_storage/helper.dart';
import 'package:contact_app/local_storage/mycontact.dart';
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
  final _avatarImageController = TextEditingController();
  final _isFavoriteController = TextEditingController();

  File? _image;

  @override
  void initState() {
    super.initState();
    if (widget.mycontact != null) {
      _firstnameController.text = widget.mycontact!.firstName;
      _lastnameController.text = widget.mycontact!.lastName;
      _fullnameController.text =
          '${widget.mycontact!.firstName} ${widget.mycontact!.lastName}';
      _emailController.text = widget.mycontact!.email;
      _avatarImageController.text = widget.mycontact!.avatar ?? '';
      _isFavoriteController.text = widget.mycontact!.isFavorite ?? '';
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
      _fullnameController.text =
          '${updatedContact.firstName} ${updatedContact.lastName}';
      _emailController.text = updatedContact.email;

      // Update the profile image
      _avatarImageController.text = updatedContact.avatar ?? '';

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
    _avatarImageController.dispose();
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
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            height: 0,
          ),
        ),
      ),
    );
  }

  Widget buildSendEmailField(TextEditingController controller) {
    return Container(
      color: const Color(0xFFF1F1F1),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/Emel.png',
            height: 30.93,
            width: 44,
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.center,
            child: Text(
              controller.text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                height: 0,
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
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w500,
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
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(
                    0xFF32BAA5), // Set your desired border color here
                width: 5.0, // Set the width of the border
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
                          child: _isNetworkImage(_avatarImageController.text)
                              ? Image.network(
                                  _avatarImageController.text,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_avatarImageController.text),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        )
                      : const Icon(Icons.camera_alt)),
            ),
          ),
          Positioned(
            bottom: -3,
            right: -6,
            child: IconButton(
              icon: Icon(
                _isFavoriteController.text == '1'
                    ? Icons.star
                    : Icons.star_border,
                color: _isFavoriteController.text == '1'
                    ? Colors.yellow
                    : Colors.grey,
                size: 35.0,
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

  bool _isNetworkImage(String path) {
    return path.startsWith('http') || path.startsWith('https');
  }

  Widget _buildElevatedButton(
      BuildContext context, TextEditingController emailController) {
    return SizedBox(
      width: 300,
      height: 50,
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
          backgroundColor: const Color(0xFF32BAA5),
          padding: const EdgeInsets.all(15),
        ),
        child: const Text(
          'Send Email',
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

  AppBar buildAppBar() {
    return AppBar(
      title: const Text(
        "Profile",
        style: TextStyle(
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
