import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> with TickerProviderStateMixin {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;
  bool _isBuying = false;
  List<ProductDetails> _products = [];

  late AnimationController _introController;
  late AnimationController _bounceController;
  late TabController _tabController;

  final List<String> _productIds = [
    'gems_100',
    'gems_1000',
    'coins_10000',
    'coins_50000',
    'bundle_starter',
    'bundle_premium',
  ];

  @override
  void initState() {
    super.initState();

    _introController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);

    _tabController = TabController(length: 3, vsync: this);

    _initStore();
    WidgetsBinding.instance.addPostFrameCallback((_) => _introController.forward());
  }

  Future<void> _initStore() async {
    _available = await _iap.isAvailable();
    if (_available) {
      final ProductDetailsResponse response =
      await _iap.queryProductDetails(_productIds.toSet());
      setState(() => _products = response.productDetails);
    }

    // Mock for testing
    if (_products.isEmpty) _loadMockProducts();
  }

  void _loadMockProducts() {
    setState(() {
      _products = [
        ProductDetails(
          id: 'gems_100',
          title: '100 Gems',
          description: 'A small pack of glowing gems.',
          price: '\$0.99',
          currencyCode: 'USD',
          rawPrice: 0.99,
        ),
        ProductDetails(
          id: 'gems_1000',
          title: '1,000 Gems',
          description: 'A large gem pack for elite players.',
          price: '\$4.99',
          currencyCode: 'USD',
          rawPrice: 4.99,
        ),
        ProductDetails(
          id: 'coins_10000',
          title: '10,000 Coins',
          description: 'A bag full of shiny gold coins.',
          price: '\$2.99',
          currencyCode: 'USD',
          rawPrice: 2.99,
        ),
        ProductDetails(
          id: 'coins_50000',
          title: '50,000 Coins',
          description: 'For serious spenders only.',
          price: '\$7.99',
          currencyCode: 'USD',
          rawPrice: 7.99,
        ),
        ProductDetails(
          id: 'bundle_starter',
          title: 'Starter Bundle',
          description: 'A mix of gems and coins to start your journey.',
          price: '\$3.99',
          currencyCode: 'USD',
          rawPrice: 3.99,
        ),
        ProductDetails(
          id: 'bundle_premium',
          title: 'Premium Bundle',
          description: 'Includes gems, coins, and exclusive rewards.',
          price: '\$9.99',
          currencyCode: 'USD',
          rawPrice: 9.99,
        ),
      ];
    });
  }

  IconData _getProductIcon(String id) {
    if (id.contains('gems')) return Icons.diamond_rounded;
    if (id.contains('coins')) return Icons.monetization_on_rounded;
    if (id.contains('bundle')) return Icons.card_giftcard_rounded;
    return Icons.shopping_bag_rounded;
  }

  Color _getProductColor(String id) {
    if (id.contains('gems')) return Colors.cyanAccent;
    if (id.contains('coins')) return Colors.amber;
    if (id.contains('bundle')) return Colors.pinkAccent;
    return Colors.white;
  }

  List<ProductDetails> _filterProducts(String category) {
    return _products.where((p) => p.id.contains(category)).toList();
  }

  Future<void> _confirmAndBuy(ProductDetails product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Confirm Purchase', style: TextStyle(color: Colors.amber)),
        content: Text(
          'Buy ${product.title} for ${product.price}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Buy'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isBuying = true);
      // skip real purchase for mock
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _isBuying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchased: ${product.title}')),
      );
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    _bounceController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['gems', 'coins', 'bundle'];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Frosted animated background
          AnimatedBuilder(
            animation: _introController,
            builder: (_, __) {
              final offset = 10 * (1 - _introController.value);
              return Transform.translate(
                offset: Offset(offset, offset),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(color: Colors.deepPurple.withOpacity(0.4)),
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FadeTransition(
                    opacity: _introController,
                    child: Column(
                      children: [
                        const Text(
                          '✨ Ultimate Shop ✨',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Grab gems, coins, and premium bundles!',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                // CATEGORY TABS
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.amber.withOpacity(0.6)),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.amber,
                    unselectedLabelColor: Colors.white70,
                    indicator: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    tabs: const [
                      Tab(icon: Icon(Icons.diamond_rounded), text: 'Gems'),
                      Tab(icon: Icon(Icons.monetization_on_rounded), text: 'Coins'),
                      Tab(icon: Icon(Icons.card_giftcard_rounded), text: 'Bundles'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // PRODUCT GRID
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: tabs.map((category) {
                      final filtered = _filterProducts(category);
                      return GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          return ScaleTransition(
                            scale: _bounceController,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple.shade800,
                                    Colors.deepPurple.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _getProductColor(product.id).withOpacity(0.5),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      _getProductIcon(product.id),
                                      size: 48,
                                      color: _getProductColor(product.id),
                                    ),
                                    Text(
                                      product.title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      product.price,
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    const SizedBox(height: 6),
                                    _isBuying
                                        ? const CircularProgressIndicator(color: Colors.amber)
                                        : ElevatedButton(
                                      onPressed: () => _confirmAndBuy(product),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amber,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: const Text(
                                        'Buy Now',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
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
