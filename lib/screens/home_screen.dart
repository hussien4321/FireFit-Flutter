import 'package:flutter/material.dart';
import 'package:mira_mira/screens.dart';

@Deprecated("this is now being replaced by MainAppBar")
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: SafeArea(
        child: MirrorsScreen(),
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar()
    );
  }


  Widget _buildFAB() => FloatingActionButton(
    child: Icon(Icons.add),
    onPressed: _uploadNewOutfit,
    elevation: 5.0,
  );

  _uploadNewOutfit() {
    print('Upload new outfit!');
  }

  Widget _buildBottomNavBar() => BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    fixedColor: Colors.black,
    onTap: _navigateToPage,
    currentIndex: currentIndex,
    items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.search),
        title: Text('Explore')
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.format_list_bulleted),
        title: Text('Wardrobe')
      ),
      BottomNavigationBarItem(
        icon: Opacity(
          opacity: 0.0,
          child: Icon(Icons.search)
        ),
        title: Opacity(
          opacity: 0.0,
          child: Container()
        ),
        
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.new_releases),
        title: Text('New styles')
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        title: Text('Profile')
      ),
    ],
  );

  _navigateToPage(int newIndex){
    if(newIndex == 2){
      _uploadNewOutfit();
    }else{
      setState(() {
       currentIndex=newIndex; 
      });
    }
  }
}
