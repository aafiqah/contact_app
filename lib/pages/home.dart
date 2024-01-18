import 'package:contact_app/api/api_service.dart';
import 'package:contact_app/api/user_model.dart';
import 'package:contact_app/local_storage/helper.dart';
import 'package:contact_app/local_storage/mycontact.dart';

import 'package:contact_app/pages/add_edit_contact.dart';
import 'package:contact_app/pages/profile_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentContent = 'image'; // Initial content
  String selectedCategory = 'all'; // Initial selected category

  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
      floatingActionButton: buildFloatingActionButton(),
    );
  }

  Widget buildBody() {
    searchQuery = searchController.text.toLowerCase();
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
        // Check local storage first
        future: DBHelper.readContacts(),
        builder: (BuildContext context,
            AsyncSnapshot<List<Mycontact>> localSnapshot) {
          if (localSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (localSnapshot.hasData && localSnapshot.data!.isNotEmpty) {
            // Filter contacts based on searchQuery
            List<Mycontact> filteredContacts = localSnapshot.data!
                .where((contact) =>
                    contact.firstName.toLowerCase().contains(searchQuery) ||
                    contact.lastName.toLowerCase().contains(searchQuery) ||
                    contact.email.toLowerCase().contains(searchQuery))
                .toList();
            // Display filtered data from local storage
            return displayContactList(filteredContacts);
          } else {
            // Fetch data from the remote API
            return FutureBuilder<List<UserModel>>(
              future: APIService.getUsers(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<UserModel>> remoteSnapshot) {
                if (remoteSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (remoteSnapshot.hasData &&
                    remoteSnapshot.data!.isNotEmpty) {
                  // Filter contacts that are not already in local storage
                  List<UserModel> newContacts =
                      remoteSnapshot.data!.where((user) {
                    return localSnapshot.data!.every((contact) =>
                        contact.firstName != user.firstName &&
                        contact.lastName != user.lastName &&
                        contact.email != user.email &&
                        contact.avatar != user.avatar);
                  }).toList();

                  // Save new contacts from remote to local storage
                  DBHelper.createContactsFromRemote(newContacts);

                  // Display filtered data from local storage
                  return FutureBuilder<List<Mycontact>>(
                    future: DBHelper.readContacts(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Mycontact>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        // Filter contacts based on searchQuery
                        List<Mycontact> filteredContacts = snapshot.data!
                            .where((contact) =>
                                contact.firstName
                                    .toLowerCase()
                                    .contains(searchQuery) ||
                                contact.lastName
                                    .toLowerCase()
                                    .contains(searchQuery) ||
                                contact.email
                                    .toLowerCase()
                                    .contains(searchQuery))
                            .toList();

                        // Display filtered data from local storage
                        return displayContactList(filteredContacts);
                      } else {
                        // No data in local storage after fetching from remote
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
                } else {
                  // No data from remote API
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
          }
        },
      );
    } else if (currentContent == 'favouritelist') {
      return FutureBuilder<List<Mycontact>>(
        future: DBHelper.readContacts(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Mycontact>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Mycontact> contactsToShow = snapshot.data!
                .where((contact) => contact.isFavorite == '1')
                .toList();

            if (contactsToShow.isNotEmpty) {
              // Display favorite contacts
              return ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 10),
                itemCount: contactsToShow.length,
                itemBuilder: (BuildContext context, int index) {
                  Mycontact mycontact = contactsToShow[index];
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
                          padding: const EdgeInsets.all(0.0),
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
                    child: buildContactListTile(mycontact),
                  );
                },
              );
            } else {
              // No favorite contacts
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
                    'No favorite contacts yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            }
          } else {
            // No data available
            return const SizedBox.shrink();
          }
        },
      );
    } else if (currentContent == 'nodata') {
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
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget displayContactList(List<Mycontact> contacts) {
    return ListView.separated(
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 12),
      itemCount: contacts.length,
      itemBuilder: (BuildContext context, int index) {
        Mycontact mycontact = contacts[index];
        return Slidable(
          key: ValueKey(mycontact.id),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            dismissible: DismissiblePane(onDismissed: () {}),
            children: [
              SlidableAction(
                onPressed: (context) => editContact(mycontact),
                backgroundColor: const Color.fromARGB(255, 235, 248, 246),
                foregroundColor: const Color.fromRGBO(242, 201, 76, 100),
                icon: Icons.edit,
                padding: const EdgeInsets.all(0.0),
              ),
              SlidableAction(
                onPressed: (context) => deleteContact(mycontact),
                backgroundColor: const Color.fromARGB(255, 235, 248, 246),
                foregroundColor: Colors.red,
                icon: Icons.delete,
              ),
            ],
          ),
          child: buildContactListTile(mycontact),
        );
      },
    );
  }

  void deleteContact(Mycontact mycontact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete\n${mycontact.firstName} ${mycontact.lastName} contact?',
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
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
                    _showSnackBar(context, 'Succesfully deleted', Colors.red);
                    refreshHomePage();
                  },
                  style: TextButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFDBDBDB),
                      width: 2.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
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
                      color: Color(0xFFFC1212),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: TextButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFDBDBDB),
                      width: 2.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
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
                      color: Color(0xFF32BAA5),
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
    _showSnackBar(context,
        '${mycontact.firstName} ${mycontact.lastName} updated', Colors.green);
    refreshHomePage();
  }

  void _showSnackBar(
      BuildContext context, String message, MaterialColor color) {
    final snackBar = SnackBar(content: Text(message), backgroundColor: color);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  ListTile buildContactListTile(Mycontact mycontact) {
    return ListTile(
      leading: CircleAvatar(
        radius: 27,
        backgroundImage: mycontact.avatar != null
            ? (mycontact.avatar!.startsWith('http') ||
                    mycontact.avatar!.startsWith('https'))
                ? NetworkImage(mycontact.avatar!)
                    as ImageProvider<Object> // If avatar is a network file path
                : FileImage(File(mycontact.avatar!))
                    as ImageProvider<Object> // If avatar is a local file path
            : const AssetImage('assets/icons/Profile.svg')
                as ImageProvider<Object>, // Default avatar
      ),
      title: Row(
        children: [
          Text(
            '${mycontact.firstName} ${mycontact.lastName}',
            style: const TextStyle(
              color: Color(0xFF1B1A57),
              fontSize: 14,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w600,
              height: 0,
            ),
          ),
          const SizedBox(width: 8),
          if (mycontact.isFavorite == '1')
            const Icon(
              Icons.star,
              color: Colors.yellow,
            ),
        ],
      ),
      subtitle: Text(
        mycontact.email,
        style: const TextStyle(
          color: Color(0xFF4E5D7B),
          fontSize: 12,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w400,
          height: 0.12,
        ),
      ),
      onTap: () {},
      trailing: IconButton(
        icon: Image.asset(
          'assets/images/Send.png',
          height: 27,
          width: 23,
        ),
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ProfileContact(mycontact: mycontact),
          ));
          refreshHomePage();
        },
      ),
    );
  }

  Widget _favouriteContacts(String searchText) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedCategory == 'favourite'
            ? const Color(0xFF32BAA5)
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
          fontSize: 14,
          fontFamily: 'Raleway',
          fontWeight: FontWeight.w600,
          height: 0.12,
          color: selectedCategory == 'favourite'
              ? Colors.white
              : const Color(0xFF32BAA5),
        ),
      ),
    );
  }

  Widget _allContacts(String searchText) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedCategory == 'all' ? const Color(0xFF32BAA5) : Colors.white,
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
          fontSize: 14,
          fontFamily: 'Raleway',
          fontWeight: FontWeight.w600,
          height: 0.12,
          color: selectedCategory == 'all'
              ? Colors.white
              : const Color(0xFF32BAA5),
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
        controller: searchController,
        onChanged: (value) {
          // Debounce the search by delaying it for 300 milliseconds
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() {});
          });
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(15),
          hintText: 'Search',
          hintStyle: const TextStyle(
              color: Color(0xFF999999),
              fontSize: 16,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w300,
              height: 0.09),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    // Clear the search text
                    searchController.clear();
                    setState(() {});
                  },
                )
              : SizedBox(
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
            fontSize: 20,
            fontFamily: 'Raleway',
            fontWeight: FontWeight.w700,
            height: 0),
      ),
      backgroundColor: const Color(0xFF32BAA5),
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
        onPressed: () {
          setState(() {
            // Reset the necessary state variables here
            currentContent = 'nodata';
          });
        },
        // if what to add new contact in local storage
        /*onPressed: () async {
          final refresh = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const AddEditContacts()));
          if (refresh == true) {
            setState(() {
              currentContent = 'alllist';
            });
          }
        },*/
        backgroundColor: const Color(0xFF32BAA5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void refreshHomePage() async {
    setState(() {
      // Reset the necessary state variables here
      currentContent = 'alllist';
      selectedCategory = 'all';
    });
    if (selectedCategory == 'favourite') {
      setState(() {});
    }
  }

  void navigateToDetail() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const AddEditContacts();
    }));
  }
}
