import 'package:flutter/material.dart';
import 'pruebadrawer.dart';
import 'home.dart';
import 'dart:math';
import 'package:vagos/servicios/servicio.dart';

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class NavSide extends StatefulWidget {
  NavSide({this.auth, this.onCerrarSesion, this.drawerPosition});

  final int drawerPosition;

  final BaseAuth auth;

  final VoidCallback onCerrarSesion;

  final drawerItems = [
    new DrawerItem("Actividades", Icons.explore),
    new DrawerItem("Prueba", Icons.local_pizza),
  ];

  @override
  _NavSideState createState() => _NavSideState();
}

class _NavSideState extends State<NavSide> {
  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      drawerPosition: _selectedDrawerIndex,
                      onCerrarSesion: this.widget.onCerrarSesion,
                      auth: this.widget.auth,
                    )),
            (Route<dynamic> route) => false);
        print("la posicion de este drawer es: $_selectedDrawerIndex");
        break;
      case 1:
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => PruebaDrawer(
                      drawerPosition: _selectedDrawerIndex,
                      auth: this.widget.auth,
                      onCerrarSesion: this.widget.onCerrarSesion,
                    )),
            (Route<dynamic> route) => false);
        print("la posicion de este drawer es: $_selectedDrawerIndex");
        break;
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop(); // close the drawer
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedDrawerIndex = this.widget.drawerPosition;
    print("Se ha navegado a la posicion: $_selectedDrawerIndex");
  }

  @override
  Widget build(BuildContext context) {
    Random random;
    int min = 1;
    int max = 9;
    random = new Random();
    int r = min + random.nextInt(max - min);
    var drawerOptions = <Widget>[];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      /**drawerOptions.add(new ListTile(
        leading: new Icon(d.icon),
        title: new Text(d.title),
        selected: i == _selectedDrawerIndex,
        onTap: () {
          _onSelectItem(i);
          _getDrawerItemWidget(_selectedDrawerIndex);
        },
      ));*/
      drawerOptions.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            decoration: i == _selectedDrawerIndex
                ? BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(50),
                        bottomRight: Radius.circular(50)))
                : null,
            child: new ListTile(
              selected: i == _selectedDrawerIndex,
              onTap: () {
                _onSelectItem(i);
                _getDrawerItemWidget(_selectedDrawerIndex);
              },
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Icon(
                    d.icon,
                    color: Colors.orange,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 2, 0, 0),
                    child: new Text(
                      d.title,
                      style: TextStyle(color: Colors.orange, fontSize: 15.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Drawer(
      child: new Column(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: new Text(
              'Edycar Reyes',
              style: TextStyle(color: Colors.white),
            ),
            accountEmail: new Text(
              'edycarreyes@gmail.com',
              style: TextStyle(color: Colors.white),
            ),
            currentAccountPicture: new GestureDetector(
              /*onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(
                        auth: this.widget.auth,
                        onCerrarSesion: this.widget.onCerrarSesion))),*/
              child: new CircleAvatar(
                backgroundImage: new NetworkImage(
                    'https://lh4.googleusercontent.com/-2mUp9AT6uyQ/AAAAAAAAAAI/AAAAAAAAOR4/RKxeuCEf37I/photo.jpg'),
              ),
            ),
            decoration: new BoxDecoration(
                color: Colors.orange,
                image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(
                        'assets/backgroundProfiles/background ($r).jpg'))),
          ),
          new Column(
            children: drawerOptions,
          )
        ],
      ),
    );
  }
}
