import 'package:flutter/material.dart';
import 'servicios/servicio.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/newUser.dart';
import 'package:vagos/pages/signup.dart';
import 'pages/welcome.dart';

class RouterPage extends StatefulWidget {
  RouterPage({this.auth});
  final BaseAuth auth;
  @override
  _RouterPageState createState() => _RouterPageState();
}

enum AuthState { noIniciado, iniciado }

class _RouterPageState extends State<RouterPage> {
  AuthState authState = AuthState.noIniciado;
  final _fs = Firestore.instance;

  FirebaseUser currentUser;

  bool usuarioNuevo = false;

  String respuesta;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.auth.currentUser().then((userId) async {
      this.respuesta = null;
      this
          .widget
          .auth
          .extraerUsuariosControl()
          .then((List<dynamic> idUsuarios) {
        print(idUsuarios.toString());
      }).catchError((e) {
        print(e);
      });
      setState(() {
        authState = userId == null ? AuthState.noIniciado : AuthState.iniciado;
      });
    });
  }

  void iniciado() async {
    await this.widget.auth.verificarSiEsUsuarioNuevo().then((String respuesta) {
      setState(() {
        this.respuesta = respuesta;
        authState = AuthState.iniciado;
      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  void noIniciado() {
    setState(() {
      authState = AuthState.noIniciado;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authState) {
      case AuthState.noIniciado:
            /*SignupPage(auth: widget.auth, onIniciado: iniciado);
            return new LoginPage(
              auth: widget.auth,
              onIniciado: iniciado,
            );*/
            SignupPage(auth: widget.auth, onIniciado: iniciado);
            return new WelcomePage(
              auth: widget.auth,
              onIniciado: iniciado,
            );
        break;
      case AuthState.iniciado:
        print("Ejecutando la orden para usuarios nuevos");
        if (this.respuesta == "si") {
          this.usuarioNuevo = false;
          SignupPage(auth: widget.auth, onIniciado: iniciado);
          return new NewUserPage(
            auth: widget.auth,
          );
        } else {
          this.usuarioNuevo = true;
          SignupPage(auth: widget.auth, onIniciado: iniciado);
          return new HomePage(
            auth: widget.auth,
            onCerrarSesion: noIniciado,
            drawerPosition: 0,
          );
        }
    }
    return LoginPage(
      auth: widget.auth,
    );
  }
}
