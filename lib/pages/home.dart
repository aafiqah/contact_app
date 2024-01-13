import 'package:contact_app/api/api_service.dart';
import 'package:contact_app/api/user_model.dart';
import 'package:contact_app/local_storage/helper.dart';
import 'package:contact_app/local_storage/mycontact.dart';

import 'package:contact_app/pages/add_edit_contact.dart';
import 'package:contact_app/pages/profile_contact.dart';
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

  TextEditingController searchController = TextEditingController();

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
        // Check local storage first
        future: DBHelper.readContacts(),
        builder: (BuildContext context,
            AsyncSnapshot<List<Mycontact>> localSnapshot) {
          if (localSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (localSnapshot.hasData && localSnapshot.data!.isNotEmpty) {
            // Display data from local storage
            return displayContactList(localSnapshot.data!);
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

                  // Save new contacts to local storage
                  DBHelper.createContactsFromRemote(newContacts);

                  // Display data from local storage
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
                        return displayContactList(snapshot.data!);
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
              color: Color.fromARGB(255, 15, 15, 15),
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
          const SizedBox(height: 15),
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
                    _showSnackBar(context, 'Succesfully deleted', Colors.red);
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
      radius: 30,
      backgroundImage: mycontact.avatar != null
          ? (mycontact.avatar!.startsWith('http') || mycontact.avatar!.startsWith('https'))
              ? NetworkImage(mycontact.avatar!)
              : AssetImage(mycontact.avatar!) as ImageProvider
          : const AssetImage('assets/icons/Profile.svg'),
    ),
      title: Row(
        children: [
          Text('${mycontact.firstName} ${mycontact.lastName}'),
          const SizedBox(width: 8),
          if (mycontact.isFavorite == '1')
            const Icon(
              Icons.star,
              color: Colors.yellow,
            ),
        ],
      ),
      subtitle: Text(mycontact.email),
      onTap: () {},
      trailing: IconButton(
        icon: Image.asset('assets/images/Send.png'),
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ProfileContact(mycontact: mycontact),
          ));

// This will be executed when ProfileContact is popped
          refreshHomePage();
        },
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
          hintStyle: const TextStyle(color: Color(0xffDDDADA), fontSize: 14),
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
        onPressed: () {
          setState(() {
            // Reset the necessary state variables here
            currentContent = 'nodata';
          });
        },
        backgroundColor: const Color.fromARGB(255, 50, 186, 165),
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
      selectedCategory = 'all';
      currentContent = 'alllist';
    });
  }

  void navigateToDetail() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const AddEditContacts();
    }));
  }
}
