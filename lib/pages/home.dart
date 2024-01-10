import 'dart:io';
import 'package:contact_app/pages/add_edit_contact.dart';
import 'package:contact_app/helper.dart';
import 'package:contact_app/mycontact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentContent = 'image'; // Initial content
  String selectedCategory = 'all'; // Initial selected category

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
      floatingActionButton: buildFloatingActionButton(),
    );
  }

  Widget buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildSearchField(),
        const SizedBox(height: 20),
        Container(
          height: 50,
          color: Colors.white.withOpacity(0.7),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const SizedBox(width: 10),
                _allContacts("All"),
                const SizedBox(width: 10),
                _favouriteContacts("Favourite"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: getContentWidget(),
        ),
      ],
    );
  }

  Widget getContentWidget() {
    if (currentContent == 'image') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/home_img.png',
            height: 260,
            width: 260,
          ),
        ],
      );
    } else if (currentContent == 'alllist') {
      return FutureBuilder<List<Mycontact>>(
        future: DBHelper.readContacts(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Mycontact>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView.separated(
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 10),
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                Mycontact mycontact = snapshot.data![index];
                return Slidable(
                  key: ValueKey(mycontact.id),
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    dismissible: DismissiblePane(onDismissed: () {}),
                    children: [
                      SlidableAction(
                        onPressed: (context) => editContact(mycontact),
                        backgroundColor:
                            const Color.fromARGB(255, 235, 248, 246),
                        foregroundColor:
                            const Color.fromRGBO(242, 201, 76, 100),
                        icon: Icons.edit,
                      ),
                      SlidableAction(
                        onPressed: (context) => deleteContact(mycontact),
                        backgroundColor:
                            const Color.fromARGB(255, 235, 248, 246),
                        foregroundColor: Colors.red,
                        icon: Icons.delete,
                      ),
                    ],
                  ),
                  child: builContactListTile(mycontact),
                );
              },
            );
          } else {
            // No data available
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/home_img.png',
                  height: 260,
                  width: 260,
                ),
                const SizedBox(height: 20),
                const Text(
                  'No list of Contacts here\nAdd Contact Now',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          }
        },
      );
    } else if (currentContent == 'favouritelist') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/home_img.png',
            height: 260,
            width: 260,
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void deleteContact(Mycontact mycontact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete\n${mycontact.fullname} contact?',
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                5.0), // Adjust the border radius as needed
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // Delete the contact and close the dialog
                    DBHelper.deleteContacts(mycontact.id!);
                    Navigator.of(context).pop();
                    _showSnackBar(context, '${mycontact.fullname} is deleted',
                        Colors.red);
                    refreshHomePage();
                  },
                  style: TextButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFDBDBDB), // Border color for "No" button
                      width: 2.0, // Border width
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(0.0), // Adjust border radius
                    ),
                    minimumSize: const Size(100.0, 50.0),
                  ),
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w500,
                      height: 0.09,
                      color: Color(0xFFFC1212), // Text color for "Yes" button
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: TextButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFDBDBDB), // Border color for "No" button
                      width: 2.0, // Border width
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(0.0), // Adjust border radius
                    ),
                    minimumSize: const Size(100.0, 50.0),
                  ),
                  child: const Text(
                    'No',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w500,
                      height: 0.09,
                      color: Color(0xFF32BAA5), // Text color for "No" button
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void editContact(Mycontact mycontact) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddEditContacts(mycontact: mycontact),
    ));
    _showSnackBar(context, '${mycontact.fullname} is updated', Colors.green);
    refreshHomePage();
  }

  void _showSnackBar(
      BuildContext context, String message, MaterialColor color) {
    final snackBar = SnackBar(content: Text(message), backgroundColor: color);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  ListTile builContactListTile(Mycontact mycontact) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: mycontact.profileImage != null
            ? FileImage(File(mycontact.profileImage!)) as ImageProvider<Object>
            : AssetImage('assets/icons/Profile.svg') as ImageProvider<Object>,
      ),
      title: Text(mycontact.fullname),
      subtitle: Text(mycontact.email),
      onTap: () {},
      trailing: IconButton(
        icon: Image.asset('assets/images/Send.png'),
        onPressed: () {},
      ),
    );
  }

  Widget _favouriteContacts(String searchText) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedCategory == 'favourite'
            ? const Color.fromARGB(255, 50, 186, 165)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      onPressed: () {
        setState(() {
          selectedCategory = 'favourite';
          currentContent = 'favouritelist';
        });
      },
      child: Text(
        searchText,
        style: TextStyle(
          color: selectedCategory == 'favourite'
              ? Colors.white
              : const Color.fromARGB(255, 50, 186, 165),
        ),
      ),
    );
  }

  Widget _allContacts(String searchText) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedCategory == 'all'
            ? const Color.fromARGB(255, 50, 186, 165)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      onPressed: () {
        setState(() {
          selectedCategory = 'all';
          currentContent = 'alllist';
        });
      },
      child: Text(
        searchText,
        style: TextStyle(
          color: selectedCategory == 'all'
              ? Colors.white
              : const Color.fromARGB(255, 50, 186, 165),
        ),
      ),
    );
  }

  Widget buildSearchField() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1D1617).withOpacity(0.11),
            blurRadius: 40,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(15),
          hintText: 'Search',
          hintStyle: const TextStyle(color: Color(0xffDDDADA), fontSize: 14),
          suffixIcon: SizedBox(
            width: 100,
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const VerticalDivider(
                    color: Colors.black,
                    indent: 10,
                    endIndent: 10,
                    thickness: 0.1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset('assets/icons/Search.svg'),
                  ),
                ],
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text(
        'My Contacts',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 50, 186, 165),
      elevation: 0.0,
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: () {
            // Call the refresh function here
            refreshHomePage();
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            width: 37,
            child: SvgPicture.asset(
              'assets/icons/Refresh.svg',
              height: 20,
              width: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildFloatingActionButton() {
    return Builder(
      builder: (context) => FloatingActionButton(
        onPressed: () async {
          final refresh = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => AddEditContacts()));
          if (refresh == true) {
            setState(() {
              currentContent = 'alllist';
            });
          }
        },
        backgroundColor: const Color.fromARGB(255, 50, 186, 165),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(50.0), // Adjust the radius as needed
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void refreshHomePage() {
    setState(() {
      // Reset the necessary state variables here
      currentContent = 'alllist';
      selectedCategory = 'all';
    });
  }

  void navigateToDetail() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddEditContacts();
    }));
  }
}
