import 'dart:convert';
import 'listarUsuarios.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InsertarUsuarios extends StatefulWidget {
  const InsertarUsuarios({Key? key}) : super(key: key);

  @override
  State<InsertarUsuarios> createState() => _InsertarUsuariosState();
}

class _InsertarUsuariosState extends State<InsertarUsuarios> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController categoriaController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  Future<void> insertarProducto() async {
    final nuevoProducto = {
      'id': idController.text,
      'nombre': nombreController.text,
      'precio': double.parse(precioController.text),
      'cantidad': int.parse(cantidadController.text),
      'categoria': categoriaController.text,
      'descripcion': descripcionController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('https://backend-1f71.onrender.com/api/productos'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(nuevoProducto),
      );

      if (response.statusCode == 200) {
        print('Nuevo producto insertado: $nuevoProducto');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto insertado correctamente.'),
            backgroundColor: Colors.purple,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ListarUsuarios(),
          ),
        );
      } else {
        print(
            'Error al insertar el producto. Código de estado: ${response.statusCode}');
        print('Respuesta del servidor: ${response.body}');
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
    }

    idController.clear();
    nombreController.clear();
    precioController.clear();
    cantidadController.clear();
    categoriaController.clear();
    descripcionController.clear();
  }

  bool camposObligatoriosLlenos() {
    return idController.text.isNotEmpty &&
        nombreController.text.isNotEmpty &&
        precioController.text.isNotEmpty &&
        cantidadController.text.isNotEmpty &&
        categoriaController.text.isNotEmpty &&
        descripcionController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insertar nuevo producto'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'ID',
                prefixIcon: Icon(Icons.info_outline),
              ),
            ),
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            TextField(
              controller: precioController,
              decoration: const InputDecoration(
                labelText: 'Precio',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                prefixIcon: Icon(Icons.shopping_cart),
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: categoriaController,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category),
              ),
            ),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.description),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (camposObligatoriosLlenos()) {
                  insertarProducto();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Por favor, complete todos los campos obligatorios.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Insertar producto'),
              style: ElevatedButton.styleFrom(
                primary: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
