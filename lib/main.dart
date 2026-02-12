import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthCheckScreen(),
    );
  }
}

// Classe pour gérer le stockage
class MyStorage {
  final _secureStorage = const FlutterSecureStorage();

  AndroidOptions _getAndroidOptions() {
    return const AndroidOptions(
      encryptedSharedPreferences: true,
    );
  }

  // Sauvegarder la connexion
  Future<void> saveLogin(String email, String password) async {
    await _secureStorage.write(
      key: 'user_email',
      value: email,
      aOptions: _getAndroidOptions(),
    );
    await _secureStorage.write(
      key: 'user_password',
      value: password,
      aOptions: _getAndroidOptions(),
    );
    await _secureStorage.write(
      key: 'is_logged_in',
      value: 'true',
      aOptions: _getAndroidOptions(),
    );
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final value = await _secureStorage.read(
      key: 'is_logged_in',
      aOptions: _getAndroidOptions(),
    );
    return value == 'true';
  }

  // Obtenir l'email de l'utilisateur
  Future<String?> getUserEmail() async {
    return await _secureStorage.read(
      key: 'user_email',
      aOptions: _getAndroidOptions(),
    );
  }

  // Déconnexion
  Future<void> logout() async {
    await _secureStorage.delete(
      key: 'is_logged_in',
      aOptions: _getAndroidOptions(),
    );
  }

  // Sauvegarder un achat
  Future<void> saveProduct(String productId, String imageUrl) async {
    await _secureStorage.write(
      key: 'product_$productId',
      value: imageUrl,
      aOptions: _getAndroidOptions(),
    );
  }

  // Lire tous les achats
  Future<Map<String, String>> readAllProducts() async {
    final allData = await _secureStorage.readAll(aOptions: _getAndroidOptions());
    final products = <String, String>{};
    
    allData.forEach((key, value) {
      if (key.startsWith('product_')) {
        products[key] = value;
      }
    });
    
    return products;
  }

  // Supprimer un achat
  Future<void> deleteProduct(String productId) async {
    await _secureStorage.delete(
      key: 'product_$productId',
      aOptions: _getAndroidOptions(),
    );
  }
}

// Écran de vérification d'authentification
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final MyStorage storage = MyStorage();
  bool isChecking = true;

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    final loggedIn = await storage.isLoggedIn();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => loggedIn 
              ? const HomeScreen() 
              : const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Écran de connexion
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final MyStorage storage = MyStorage();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simuler une connexion
      await Future.delayed(const Duration(seconds: 1));

      await storage.saveLogin(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  const Text(
                    'Koneksyon',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Konekte pou kontinye',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Imel',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tanpri antre imel ou';
                      }
                      if (!value.contains('@')) {
                        return 'Imel pa valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Modpas',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tanpri antre modpas ou';
                      }
                      if (value.length < 4) {
                        return 'Modpas twò kout';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Bouton de connexion
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Konekte',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Modèle de produit
class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
  });
}

// Écran principal avec la liste des produits
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MyStorage storage = MyStorage();
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final email = await storage.getUserEmail();
    setState(() {
      userEmail = email ?? '';
    });
  }

  // Liste des produits disponibles
  final List<Product> products = [
    Product(
      id: 'prod_1',
      name: 'Smartphone',
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
      price: 299.99,
    ),
    Product(
      id: 'prod_2',
      name: 'Laptop',
      imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400',
      price: 899.99,
    ),
    Product(
      id: 'prod_3',
      name: 'Headphones',
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
      price: 149.99,
    ),
    Product(
      id: 'prod_4',
      name: 'Smartwatch',
      imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
      price: 199.99,
    ),
    Product(
      id: 'prod_5',
      name: 'Camera',
      imageUrl: 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=400',
      price: 549.99,
    ),
    Product(
      id: 'prod_6',
      name: 'Tablet',
      imageUrl: 'https://images.unsplash.com/photo-1561154464-82e9adf32764?w=400',
      price: 399.99,
    ),
  ];

  // Fonction pour acheter un produit
  Future<void> buyProduct(Product product) async {
    await storage.saveProduct(product.id, product.imageUrl);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ajoute nan acha yo!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Fonction de déconnexion
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dekonekte'),
        content: const Text('Ou vle dekonekte?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Wi'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await storage.logout();
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PurchaseListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Dekonekte',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Colors.blue),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Pwodui yo'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Acha mwen yo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PurchaseListScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Dekonekte', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onBuy: () => buyProduct(product),
          );
        },
      ),
    );
  }
}

// Widget pour afficher une carte de produit
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onBuy;

  const ProductCard({
    super.key,
    required this.product,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image du produit
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
          ),
          // Informations du produit
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Bouton Acheter
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onBuy,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Achte'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Écran de la liste des achats
class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  final MyStorage storage = MyStorage();
  Map<String, String> purchases = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPurchases();
  }

  // Charger tous les achats
  Future<void> loadPurchases() async {
    setState(() {
      isLoading = true;
    });

    final data = await storage.readAllProducts();
    
    setState(() {
      purchases = data;
      isLoading = false;
    });
  }

  // Supprimer un achat
  Future<void> deletePurchase(String productId) async {
    await storage.deleteProduct(productId);
    await loadPurchases();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pwodui retire'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acha mwen yo'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : purchases.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Pa gen acha ankò',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: purchases.length,
                  itemBuilder: (context, index) {
                    final entry = purchases.entries.elementAt(index);
                    return PurchaseCard(
                      productId: entry.key,
                      imageUrl: entry.value,
                      onDelete: () => deletePurchase(entry.key),
                    );
                  },
                ),
    );
  }
}

// Widget pour afficher une carte d'achat
class PurchaseCard extends StatelessWidget {
  final String productId;
  final String imageUrl;
  final VoidCallback onDelete;

  const PurchaseCard({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image du produit acheté
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
          ),
          // Bouton supprimer
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
              label: const Text('Retire'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Écran principal avec la liste des produits
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MyStorage storage = MyStorage();

  // Liste des produits disponibles
  final List<Product> products = [
    Product(
      id: 'prod_1',
      name: 'Smartphone',
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
      price: 299.99,
    ),
    Product(
      id: 'prod_2',
      name: 'Laptop',
      imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400',
      price: 899.99,
    ),
    Product(
      id: 'prod_3',
      name: 'Headphones',
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
      price: 149.99,
    ),
    Product(
      id: 'prod_4',
      name: 'Smartwatch',
      imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
      price: 199.99,
    ),
    Product(
      id: 'prod_5',
      name: 'Camera',
      imageUrl: 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=400',
      price: 549.99,
    ),
    Product(
      id: 'prod_6',
      name: 'Tablet',
      imageUrl: 'https://images.unsplash.com/photo-1561154464-82e9adf32764?w=400',
      price: 399.99,
    ),
  ];

  // Fonction pour acheter un produit
  Future<void> buyProduct(Product product) async {
    await storage.saveProduct(product.id, product.imageUrl);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ajouté aux achats !'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutique en ligne'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PurchaseListScreen()),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onBuy: () => buyProduct(product),
          );
        },
      ),
    );
  }
}

// Widget pour afficher une carte de produit
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onBuy;

  const ProductCard({
    super.key,
    required this.product,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image du produit
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: product.isAsset
                  ? Image.asset(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        return progress == null
                            ? child
                            : const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 50),
                        );
                      },
                    ),
            ),
          ),
          // Informations du produit
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Bouton Acheter
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onBuy,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Acheter'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Écran de la liste des achats
class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  final MyStorage storage = MyStorage();
  Map<String, String> purchases = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPurchases();
  }

  // Charger tous les achats
  Future<void> loadPurchases() async {
    setState(() {
      isLoading = true;
    });

    final data = await storage.readAllProducts();
    
    setState(() {
      purchases = data;
      isLoading = false;
    });
  }

  // Supprimer un achat
  Future<void> deletePurchase(String productId) async {
    await storage.deleteProduct(productId);
    await loadPurchases();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produit supprimé des achats'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes achats'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : purchases.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucun achat pour le moment',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: purchases.length,
                  itemBuilder: (context, index) {
                    final entry = purchases.entries.elementAt(index);
                    return PurchaseCard(
                      productId: entry.key,
                      imageUrl: entry.value,
                      onDelete: () => deletePurchase(entry.key),
                    );
                  },
                ),
    );
  }
}

// Widget pour afficher une carte d'achat
class PurchaseCard extends StatelessWidget {
  final String productId;
  final String imageUrl;
  final VoidCallback onDelete;

  const PurchaseCard({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image du produit acheté
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  return progress == null
                      ? child
                      : const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
          ),
          // Bouton supprimer
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
              label: const Text('Supprimer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}