import 'package:delivery_flutter/helpers/relative_time_util.dart';
import 'package:delivery_flutter/pages/order_detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delivery_flutter/models/pedido.dart';
import 'package:delivery_flutter/services/pedido_service.dart';
import 'package:delivery_flutter/services/usuario_service.dart';
import 'package:delivery_flutter/theme/colors.dart';
import 'package:delivery_flutter/widgets/drawer.dart';

import '../widgets/noData.dart';

class OrdersListPage extends StatefulWidget {
  const OrdersListPage({super.key});

  @override
  State<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage> {

  final estados = ['PAGADO', 'DESPACHADO', 'EN CAMINO', 'ENTREGADO'];

  late PedidoService _pedidoService;
  late UsuarioService _usuarioService;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _usuarioService = Provider.of<UsuarioService>(context);
    _pedidoService = PedidoService(_usuarioService);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: estados.length,
      child: Scaffold(
          key: key,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              leading: AppDrawer.menuDrawer(key),
              bottom: _tabs()
            ),
            
          ),
        
          drawer: const AppDrawer(),
          body: TabBarView(
            children: estados.map((String estado) {
              return FutureBuilder(
                future: _getOrders(context, estado),
                builder: (_, snapshot) {
                  if(snapshot.hasData) {
                    if(snapshot.data!.isEmpty) return const NoData(text: 'No se encontraron ordenes');
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        return snapshot.data != null ? _cardOrder(snapshot.data![index], context) : const SizedBox();
                      },
                    );
                  } else {
                    return const NoData(text: 'No se encontraron ordenes');
                  }

                },
              );
            }).toList(),
          )
        ),
    );
  }

    _tabs() {
      return TabBar(
                indicatorColor: MyColors.primaryColor,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey[400],
                isScrollable: true,
                tabs:  List<Widget>.generate(estados.length, (index) {
                  return Tab(
                    child: Text(estados[index]),
                  );
                })
      );
  }

  Future<List<Pedido>?> _getOrders(BuildContext context, String estado) async {
    return await _pedidoService.findByEstado(estado);
  } 

  Widget _cardOrder(Pedido pedido, BuildContext context) {
    return GestureDetector(
      onTap: () => _openBottomSheet(pedido, context),
      child: Container(
        height: 160,
        margin:const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          child: Material(
            elevation: 3,
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            child: Stack(
              children: [
                Positioned(
                  child: Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      color: MyColors.primaryColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)
                      )
                    ),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        'Orden #${pedido.id}', 
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15
                      )),
                    ),
                  )
                ),
                Container(
                  margin: const EdgeInsets.only(top: 40,left: 20, right: 20),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        width: double.infinity,
                        child: Text(
                          'Pedido: ${RelativeTimeUtil.getRelativeTime(pedido.timestamp ?? 0)}',
                          style: const TextStyle(
                            fontSize: 13
                          ),
                          maxLines: 1,
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        width: double.infinity,
                        child: Text(
                            'Cliente: ${pedido.cliente?.nombre} ${pedido.cliente?.apellido}',
                            style: const TextStyle(
                              fontSize: 13
                            ),
                            maxLines: 1,
                          ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        width: double.infinity,
                        child: Text(
                            'Entregar en: ${pedido.direccion?.direccion} ${pedido.direccion?.direccion2}',
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                            maxLines: 2,
                          ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _openBottomSheet(Pedido pedido, BuildContext context) async {
    var isUpdate;
    isUpdate = await showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      builder: (_) => OrderDetail(pedido: pedido,)
    );

    if(isUpdate == true) {
      setState(() {
        
      });
    }
  }
}