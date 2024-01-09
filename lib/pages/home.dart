import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:contact_app/pages/add_contact.dart';
import 'package:contact_app/helper.dart';
import 'package:contact_app/mycontact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
          print('Connection State: ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.hasData) {
            print('No data');
            // Show the default image if there's no data
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
            print('Data available: ${snapshot.data}');
            return ListView(
              children: snapshot.data!.map((mycontact) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: mycontact.profileImage != null
                        ? FileImage(File(mycontact.profileImage!))
                            as ImageProvider<Object>
                        : AssetImage(
                                'assets/icons/Profile.svg')
                            as ImageProvider<Object>,
                  ),
                  title: Text(mycontact.fullname),
                  subtitle: Text(mycontact.email),
                  trailing: IconButton(
                    icon: Image.asset('assets/icons/Send.png'),
                    onPressed: () {},
                  ),
                );
              }).toList(),
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
              .push(MaterialPageRoute(builder: (_) => AddContacts()));
          if (refresh == true) {
            setState(() {
              currentContent = 'alllist';
            });
          }
        },
        backgroundColor: const Color.fromARGB(255, 50, 186, 165),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0), // Adjust the radius as needed
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
      return AddContacts();
    }));
  }
}
