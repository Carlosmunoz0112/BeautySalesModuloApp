import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beautysales/insertarUsuarios.dart';

class ListarUsuarios extends StatefulWidget {
  const ListarUsuarios({Key? key}) : super(key: key);

  @override
  State<ListarUsuarios> createState() => _ListarUsuariosState();
}

class _ListarUsuariosState extends State<ListarUsuarios> {
  List<dynamic> data = [];
  List<dynamic> filteredData = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getproductos();
  }

  Future<void> getproductos() async {
    try {
      final response = await http
          .get(Uri.parse('https://backend-1f71.onrender.com/api/productos'));

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);

        setState(() {
          if (decodedData is List) {
            data = decodedData;
            filteredData = data;
          } else if (decodedData is Map<String, dynamic> &&
              decodedData.containsKey('productos')) {
            data = decodedData['productos'] ?? [];
            filteredData = data;
          } else {
            print('La estructura de la respuesta no es la esperada:');
            print(decodedData);
            data = [];
            filteredData = [];
          }
        });
      } else {
        print(
            'Error al cargar datos. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> eliminarProducto(String id) async {
    try {
      final response = await http.delete(
          Uri.parse('https://backend-1f71.onrender.com/api/productos/$id'));

      if (response.statusCode == 200) {
        print('Producto eliminado con ID: $id');
        getproductos();
        mostrarSnackBar('Producto eliminado correctamente');
      } else {
        print(
            'Error al eliminar el producto. Código de estado: ${response.statusCode}');
        print('Respuesta del servidor: ${response.body}');
        mostrarSnackBar('Error al eliminar el producto');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      mostrarSnackBar('Error en la solicitud HTTP');
    }
  }

  Future<void> actualizarProducto(
      String id, Map<String, dynamic> nuevosValores) async {
    try {
      final response = await http.put(
        Uri.parse('https://backend-1f71.onrender.com/api/productos/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(nuevosValores),
      );

      if (response.statusCode == 200) {
        print('Producto actualizado con ID: $id');
        getproductos();
        mostrarSnackBar('Producto actualizado correctamente');
      } else {
        print(
            'Error al actualizar el producto. Código de estado: ${response.statusCode}');
        print('Respuesta del servidor: ${response.body}');
        mostrarSnackBar('Error al actualizar el producto');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      mostrarSnackBar('Error en la solicitud HTTP');
    }
  }

  Future<void> mostrarDialogoEditar(Map<String, dynamic> producto) async {
    Map<String, dynamic> nuevosValores = {
      'nombre': producto['nombre'],
      'precio': producto['precio'].toString(),
      'cantidad': producto['cantidad'].toString(),
      'categoria': producto['categoria'],
      'descripcion': producto['descripcion'],
    };

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Editar Producto',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'Nombre',
                  initialValue: producto['nombre'],
                  onChanged: (value) {
                    nuevosValores['nombre'] = value;
                  },
                  icon: Icons.person,
                ),
                _buildTextField(
                  label: 'Precio',
                  initialValue: producto['precio'].toString(),
                  onChanged: (value) {
                    nuevosValores['precio'] = double.parse(value);
                  },
                  icon: Icons.attach_money,
                ),
                _buildTextField(
                  label: 'Cantidad',
                  initialValue: producto['cantidad'].toString(),
                  onChanged: (value) {
                    nuevosValores['cantidad'] = int.parse(value);
                  },
                  icon: Icons.shopping_cart,
                ),
                _buildTextField(
                  label: 'Categoría',
                  initialValue: producto['categoria'],
                  onChanged: (value) {
                    nuevosValores['categoria'] = value;
                  },
                  icon: Icons.category,
                ),
                _buildTextField(
                  label: 'Descripción',
                  initialValue: producto['descripcion'],
                  onChanged: (value) {
                    nuevosValores['descripcion'] = value;
                  },
                  icon: Icons.description,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await actualizarProducto(producto['_id'], nuevosValores);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Guardar cambios',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(primary: Colors.purple),
            ),
          ],
          contentPadding: EdgeInsets.symmetric(
            horizontal: 40.0,
            vertical: 24.0,
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: TextEditingController(text: initialValue),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple), // Color del texto
          prefixIcon: Icon(icon, color: Colors.purple), // Color del icono
        ),
      ),
    );
  }

  Future<void> mostrarSnackBar(String mensaje) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.purple,
        elevation: 4,
      ),
    );
  }

  _mostrarDialogoEliminar(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '¿Eliminar producto?',
            style: TextStyle(color: Colors.purple),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar este producto?',
            style: TextStyle(color: Colors.purple),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.purple,
              ),
              onPressed: () {
                eliminarProducto(productId);
                Navigator.of(context).pop();
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listar nombre producto'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const InsertarUsuarios()),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  filteredData = data
                      .where((element) => element['nombre']
                          .toString()
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                });
              },
              decoration: InputDecoration(
                labelText: 'Buscar producto',
                prefixIcon: Icon(Icons.search, color: Colors.purple),
                filled: true,
                fillColor: Colors.purple.withOpacity(0.1),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.purple),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.purple),
                        SizedBox(width: 8),
                        Text(
                            'Nombre: ${filteredData[index]['nombre'] ?? 'ID no disponible'}'),
                      ],
                    ),
                    children: [
                      ListTile(
                        title: Row(
                          children: [
                            Icon(Icons.person, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                                'id: ${filteredData[index]['id'] ?? 'No disponible'}'),
                          ],
                        ),
                      ),
                      ListTile(
                        title: Row(
                          children: [
                            Icon(Icons.attach_money, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                                'Precio: \$${filteredData[index]['precio'] ?? 'No disponible'}'),
                          ],
                        ),
                      ),
                      ListTile(
                        title: Row(
                          children: [
                            Icon(Icons.shopping_cart, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                                'Cantidad: ${filteredData[index]['cantidad'] ?? 'No disponible'}'),
                          ],
                        ),
                      ),
                      ListTile(
                        title: Row(
                          children: [
                            Icon(Icons.category, color: Colors.pink),
                            SizedBox(width: 8),
                            Text(
                                'Categoría: ${filteredData[index]['categoria'] ?? 'No disponible'}'),
                          ],
                        ),
                      ),
                      ListTile(
                        title: Row(
                          children: [
                            Icon(Icons.description, color: Colors.purple),
                            SizedBox(width: 8),
                            Text(
                                'Descripción: ${filteredData[index]['descripcion'] ?? 'No disponible'}'),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: 8,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                mostrarDialogoEditar(filteredData[index]);
                              },
                              child: const Text('Actualizar producto'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue,
                                minimumSize: const Size(150, 40),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: 8,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                _mostrarDialogoEliminar(
                                    context, filteredData[index]['_id']);
                              },
                              child: const Text('Eliminar producto'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                                minimumSize: const Size(150, 40),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
