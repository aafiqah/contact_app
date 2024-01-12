import 'dart:io';
import 'package:contact_app/api/api_service.dart';
import 'package:contact_app/api/user_model.dart';
import 'package:contact_app/pages/add_edit_contact.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileContact extends StatefulWidget {
  const ProfileContact({super.key, this.user});

  final UserModel? user;

  @override
  State<ProfileContact> createState() => _ProfileContactState();
}

class _ProfileContactState extends State<ProfileContact> {
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _fullnameController;
  late TextEditingController _emailController;
  late TextEditingController _avatarController;
  late TextEditingController _isFavoriteController;

  File? _image;

  @override
  void initState() {
    super.initState();
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _fullnameController = TextEditingController();
    _emailController = TextEditingController();
    _avatarController = TextEditingController();
    _isFavoriteController = TextEditingController();

    if (widget.user != null) {
      _firstnameController.text = widget.user!.firstName;
      _lastnameController.text = widget.user!.lastName;
      _fullnameController.text =
          "${widget.user!.firstName} ${widget.user!.lastName}";
      _emailController.text = widget.user!.email;
      _avatarController.text = widget.user!.avatar;
      _isFavoriteController.text =
          '0'; // Assuming you don't have favorite info in UserModel

      if (_avatarController.text.isNotEmpty) {
        // Load the image from the network using a package like CachedNetworkImage
        // Set _image accordingly
      }
    }
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _fullnameController.dispose();
    _emailController.dispose();
    _avatarController.dispose();
    _isFavoriteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(context),
    );
  }

  SingleChildScrollView buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          buildEditContact(),
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

  Widget buildEditContact() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AddEditContacts(user: widget.user),
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

  void _refreshData() async {
    try {
      // Fetch the updated user data from the API using the user ID
      if (widget.user != null) {
        UserModel updatedUser = await APIService.getUserById(widget.user!.id);

        setState(() {
          // Update the state with the new data
          _firstnameController.text = updatedUser.firstName;
          _lastnameController.text = updatedUser.lastName;
          _fullnameController.text =
              "${updatedUser.firstName} ${updatedUser.lastName}";
          _emailController.text = updatedUser.email;
          _avatarController.text = updatedUser.avatar;

          if (_avatarController.text.isNotEmpty) {
            // Load the image from the network using a package like CachedNetworkImage
            // Set _image accordingly
          }
        });
      }
    } catch (e) {
      print('Error refreshing data: $e');
      // Handle the error as needed
    }
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

                // TODO: Implement the logic to update favorite status through API
                // await APIService.updateUser(widget.user!.id, UserModel(
                //   id: widget.user!.id,
                //   firstName: widget.user!.firstName,
                //   lastName: widget.user!.lastName,
                //   email: widget.user!.email,
                //   avatar: widget.user!.avatar,
                // ));

                // For now, you can print the new status
                print('Favorite Status Updated: ${_isFavoriteController.text}');
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
