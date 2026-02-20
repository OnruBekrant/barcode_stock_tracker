class Product {
  final int? id;
  final String? barcode;
  final String name;
  final double price;
  final int quantity;
  final String? description;
  final String? imagePath;

  Product({
    this.id,
    this.barcode,
    required this.name,
    required this.price,
    this.quantity = 0,
    this.description,
    this.imagePath,
  });

  Product copyWith({
    int? id,
    String? barcode,
    String? name,
    double? price,
    int? quantity,
    String? description,
    String? imagePath,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'price': price,
      'quantity': quantity,
      'description': description,
      'imagePath': imagePath,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      barcode: map['barcode'] as String?,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int? ?? 0,
      description: map['description'] as String?,
      imagePath: map['imagePath'] as String?,
    );
  }
}
