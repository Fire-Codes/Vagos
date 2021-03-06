import 'package:flutter/material.dart';
import 'servicios/servicio.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/newUser.dart';
import 'package:vagos/pages/signup.dart';
import 'pages/welcome.dart';
import 'package:mysql1/mysql1.dart';

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
  int cantidadParticipacionesUsuario;
  String correoUsuario;
  String displayName;
  MySqlConnection conectorSql;

  String respuesta;
  List<DocumentSnapshot> actividades = new List<DocumentSnapshot>();

  Future<void> _realizarInitState() async {
    await widget.auth.currentUser().then((userId) async {
      this.respuesta = null;
      this
          .widget
          .auth
          .extraerUsuariosControl()
          .then((List<dynamic> idUsuarios) async {
        if (!(userId == null)) {
          await this
              .widget
              .auth
              .extraerDatosUsuarioSQL(userId.email)
              .then((onValue) {
            print('Usuarios extraidos y almacenados de sql');
          }).catchError((e) {
            print(e.toString());
          });
          await this
              ._fs
              .document('Vagos/Control/Usuarios/${userId.email}')
              .get()
              .then((DocumentSnapshot usuario) async {
            await this
                .widget
                .auth
                .agregarActualizarBaseDeDatos(
                    usuario.data['Email'].toString(),
                    usuario.data['displayName'].toString(),
                    usuario.data['photoProfile'].toString())
                .then((onValue) {
              print('Usuario agregado a la base de datos sql');
            }).catchError((e) {
              print(e.toString());
            });
            setState(() {
              this.cantidadParticipacionesUsuario =
                  usuario.data['CantidadParticipaciones'];
              this.correoUsuario = userId.email.toString();
              this.displayName = usuario.data['displayName'].toString();
            });
          }).catchError((e) {
            print(e.toString());
          });
        }
        print(idUsuarios.toString());
      }).catchError((e) {
        print(e);
      });
      setState(() {
        authState = userId == null ? AuthState.noIniciado : AuthState.iniciado;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      conectarSql();
      _realizarInitState();
    });
  }

  Future<void> conectarSql() async {
    await this.widget.auth.conectarSQL().then((MySqlConnection conector) {
      setState(() {
        this.conectorSql = conector;
        print(this.conectorSql.toString());
      });
    }).catchError((e) {
      print(e.toString());
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
          print('correo guardado: ' + this.correoUsuario.toString());
          return new HomePage(
            auth: widget.auth,
            onCerrarSesion: noIniciado,
            drawerPosition: 0,
            cantidadParticipacionesUsuario: this.cantidadParticipacionesUsuario,
            correoUsuario: this.correoUsuario.toString(),
            displayName: this.displayName.toString(),
          );
        }
    }
    return LoginPage(
      auth: widget.auth,
    );
  }
}
