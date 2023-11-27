import 'package:flutter/material.dart';

class EditarProducto extends StatefulWidget {
  final Map<String, dynamic> producto;

  const EditarProducto({Key? key, required this.producto}) : super(key: key);

  @override
  _EditarProductoState createState() => _EditarProductoState();
}

class _EditarProductoState extends State<EditarProducto> {
  late TextEditingController nombreController;
  late TextEditingController precioController;
  late TextEditingController cantidadController;
  late TextEditingController categoriaController;
  late TextEditingController descripcionController;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.producto['nombre']);
    precioController =
        TextEditingController(text: widget.producto['precio'].toString());
    cantidadController =
        TextEditingController(text: widget.producto['cantidad'].toString());
    categoriaController =
        TextEditingController(text: widget.producto['categoria']);
    descripcionController =
        TextEditingController(text: widget.producto['descripcion']);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Producto'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: precioController,
              decoration: const InputDecoration(labelText: 'Precio'),
            ),
            TextField(
              controller: cantidadController,
              decoration: const InputDecoration(labelText: 'Cantidad'),
            ),
            TextField(
              controller: categoriaController,
              decoration: const InputDecoration(labelText: 'Categoría'),
            ),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final nuevosValores = {
              'nombre': nombreController.text,
              'precio': double.parse(precioController.text),
              'cantidad': int.parse(cantidadController.text),
              'categoria': categoriaController.text,
              'descripcion': descripcionController.text,
            };
            Navigator.of(context).pop(nuevosValores);
          },
          child: const Text('Guardar cambios'),
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
          ),
        ),
      ],
    );
  }
}
