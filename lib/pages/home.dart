import 'package:contact_app/pages/add_edit_contact.dart';
import 'package:flutter/material.dart';
import 'package:contact_app/api/api_service.dart';
import 'package:contact_app/api/user_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController searchController;
  late String currentContent;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    currentContent = 'alllist'; // Set the initial content type
  }

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
    } else if (currentContent == 'alllist' ||
        currentContent == 'favouritelist') {
      return FutureBuilder<List<UserModel>>(
        future: currentContent == 'alllist'
            ? APIService.getUsers()
            : APIService.getFavoriteUsers(),
        builder:
            (BuildContext context, AsyncSnapshot<List<UserModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<UserModel> filteredUsers = snapshot.data!
                .where((user) => user.firstName
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()))
                .toList();

            return ListView.separated(
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 10),
              itemCount: filteredUsers.length,
              itemBuilder: (BuildContext context, int index) {
                UserModel user = filteredUsers[index];
                return Slidable(
                  key: ValueKey(user.id),
                  endActionPane: ActionPane(
                    motion: const BehindMotion(),
                    dismissible: DismissiblePane(onDismissed: () {}),
                    children: [
                      SlidableAction(
                        onPressed: (context) => editUser(context, user),
                        backgroundColor:
                            const Color.fromARGB(255, 235, 248, 246),
                        foregroundColor:
                            const Color.fromRGBO(242, 201, 76, 100),
                        icon: Icons.edit,
                        padding: const EdgeInsets.all(0.0),
                      ),
                      SlidableAction(
                        onPressed: (context) => deleteUser(context, user),
                        backgroundColor:
                            const Color.fromARGB(255, 235, 248, 246),
                        foregroundColor: Colors.red,
                        icon: Icons.delete,
                      ),
                    ],
                  ),
                  child: buildUserListTile(user),
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
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildUserListTile(UserModel user) {
    return ListTile(
      title: Text(user.firstName),
      subtitle: Text(user.email),
      // Add more details as needed
    );
  }

  void editUser(BuildContext context, UserModel user) {
    // Implement edit user functionality
    print('Edit user: ${user.firstName}');

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditContacts(user: user)),
    );
  }

  void deleteUser(BuildContext context, UserModel user) {
    // Implement delete user functionality
    print('Delete user: ${user.firstName}');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete ${user.firstName}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Call the delete API or perform deletion logic
                APIService.deleteUser(user.id).then((_) {
                  // Refresh the UI or update the user list
                  // Example: fetch and display updated user list
                  setState(() {
                    currentContent = 'alllist';
                  });
                });

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _favouriteContacts(String searchText) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: currentContent == 'favouritelist'
            ? const Color.fromARGB(255, 50, 186, 165)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      onPressed: () {
        setState(() {
          currentContent = 'favouritelist';
        });
      },
      child: Text(
        searchText,
        style: TextStyle(
          color: currentContent == 'favouritelist'
              ? Colors.white
              : const Color.fromARGB(255, 50, 186, 165),
        ),
      ),
    );
  }

  Widget _allContacts(String searchText) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: currentContent == 'alllist'
            ? const Color.fromARGB(255, 50, 186, 165)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      onPressed: () {
        setState(() {
          currentContent = 'alllist';
        });
      },
      child: Text(
        searchText,
        style: TextStyle(
          color: currentContent == 'alllist'
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
        onPressed: () async {
          final refresh = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const AddEditContacts()));
          if (refresh == true) {
            setState(() {
              currentContent = 'alllist';
            });
          }
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

  void refreshHomePage() {
    setState(() {
      // Reset the necessary state variables here
      currentContent = 'alllist';
    });
    if (currentContent == 'favouritelist') {
      // If you are on the favorite tab, fetch and display updated favorite list
      // You might want to implement a method to fetch the favorite list
      // e.g., fetchFavoriteContacts() and set it to the state variable
      setState(() {
        // favoriteContacts = await fetchFavoriteContacts();
      });
    }
  }
}
