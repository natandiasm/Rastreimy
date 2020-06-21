import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:rastreimy/models/order_model.dart';
import 'package:rastreimy/models/user_model.dart';
import 'package:rastreimy/screens/add_order_screen.dart';
import 'package:rastreimy/screens/login_screen.dart';
import 'package:rastreimy/screens/order_detail.dart';
import 'package:rastreimy/util/correios.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shimmer/shimmer.dart';

class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Correios correio = Correios();
    Widget _buildListTile(BuildContext context, DocumentSnapshot document) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                  blurRadius: 5,
                  offset: Offset(0, 1),
                  color: Color.fromARGB(255, 46, 46, 46).withOpacity(0.1))
            ],
            color: Colors.white,
          ),
          child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            actions: <Widget>[
              IconSlideAction(
                caption: 'Editar',
                color: Colors.transparent,
                foregroundColor: Color.fromARGB(255, 22, 98, 187),
                icon: LineAwesomeIcons.pencil,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => AddOrderScreen(order: document)),
                  );
                },
              ),
              IconSlideAction(
                  caption: 'Excluir',
                  color: Colors.transparent,
                  foregroundColor: Colors.deepOrange,
                  icon: LineAwesomeIcons.trash,
                  onTap: () {
                    buttonExcluirTouch(context: context, order: document);
                  }),
            ],
            child: ListTile(
              title: Text(
                document['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: FutureBuilder(
                  future: correio.rastrear(codigo: document['shippingcode']),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                          child: Text(
                        snapshot.data["eventos"][0]["local"],
                        style: TextStyle(fontSize: 13.0),
                      ));
                    } else {
                      return Shimmer.fromColors(
                          baseColor: Colors.black12,
                          highlightColor: Colors.black26,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5)),
                          ));
                    }
                  }),
              leading: Icon(
                  OrderModel.iconOrder(category: document['category']),
                  size: 35,
                  color: Theme.of(context).primaryColor),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => OrderDetailScreen(
                            orderData: document,
                          )),
                );
              },
            ),
          ),
        ),
      );
    }

    Widget _buildBodyBack() =>
        ScopedModelDescendant<UserModel>(builder: (context, child, model) {
          if (!model.isLoggedIn()) {
            return Container(
              decoration:
                  BoxDecoration(color: Color.fromARGB(255, 252, 252, 252)),
              child: Center(
                child: Container(
                  height: 365,
                  child: Column(
                    children: <Widget>[
                      Container(
                          height: 200,
                          child: Hero(
                              tag: "icon-login",
                              child: Image.asset('assets/images/login.png'))),
                      Text(
                        "Faça login ou crie uma conta \npara salvar suas encomendas",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: SizedBox(
                          height: 60.0,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                            child: Text(
                              "Entrar",
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                            textColor: Colors.white,
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: StreamBuilder<QuerySnapshot>(
                  stream: OrderModel.listOrder(user: model, onFail: () {}),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Text("Carregando..."),
                      );
                    }
                    return Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 20),
                          child: Container(
                            width: double.maxFinite,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Olá, ${model.userData["name"]}",
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      "Vamos ver como estão suas encomendas hoje."),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, item) {
                              return _buildListTile(
                                  context, snapshot.data.documents[item]);
                            }),
                      ],
                    );
                  }),
            ),
          );
        });

    return SafeArea(
      child: Stack(
        children: <Widget>[
          CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: <Widget>[
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.asset(
                      'assets/images/title.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  centerTitle: true,
                ),
                iconTheme:
                    IconThemeData(color: Color.fromARGB(255, 22, 98, 187)),
              ),
            ],
          ),
          _buildBodyBack(),
        ],
      ),
    );
  }

  VoidCallback buttonExcluirTouch(
      {@required BuildContext context, @required DocumentSnapshot order}) {
    Widget cancelaButton = FlatButton(
      child: Text("Cancelar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continuaButton = FlatButton(
      child: Text(
        "Continuar",
        style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        OrderModel.removeOrder(
            order: order,
            onSucess: () {
              Navigator.of(context).pop();
            },
            onFail: () {});
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(
        "Exclusão da encomenda",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content:
          Text("A sua encomenda será excluida da sua conta, deseja continuar?"),
      actions: [
        cancelaButton,
        continuaButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
