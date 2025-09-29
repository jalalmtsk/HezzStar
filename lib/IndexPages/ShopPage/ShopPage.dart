import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;
  List<ProductDetails> _products = [];
  final List<String> _productIds = [
    'gems_100',
    'gems_500',
    'coins_1000',
    'coins_5000',
  ];
  bool _isBuying = false;

  @override
  void initState() {
    super.initState();
    _initStore();
  }

  Future<void> _initStore() async {
    _available = await _iap.isAvailable();
    if (_available) {
      final ProductDetailsResponse response =
      await _iap.queryProductDetails(_productIds.toSet());
      setState(() {
        _products = response.productDetails;
      });

      // Listen to purchase updates
      _iap.purchaseStream.listen(_onPurchaseUpdated, onError: (error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Purchase error: $error')));
      });
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _grantPurchase(purchase.productID);
        _iap.completePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: ${purchase.error}')),
        );
      }
      setState(() => _isBuying = false);
    }
  }

  void _grantPurchase(String productId) {
    // TODO: Add gems or coins to the user's account
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Purchase successful: $productId')),
    );
  }

  Future<void> _confirmAndBuy(ProductDetails product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Purchase'),
        content: Text('Do you want to buy ${product.title} for ${product.price}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Buy'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isBuying = true);
      final purchaseParam = PurchaseParam(productDetails: product);
      _iap.buyConsumable(purchaseParam: purchaseParam);
    }
  }

  Future<void> _restorePurchases() async {
    await _iap.restorePurchases();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restore purchases requested')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _restorePurchases,
            tooltip: 'Restore Purchases',
          ),
        ],
      ),
      body: _available
          ? GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            color: Colors.deepPurple[50],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  product.id.contains('gems')
                      ? Icons.diamond
                      : Icons.monetization_on,
                  size: 50,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                Text(
                  product.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(product.price,
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                _isBuying
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () => _confirmAndBuy(product),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text('Buy Now'),
                ),
              ],
            ),
          );
        },
      )
          : const Center(
        child: Text('Store is not available.'),
      ),
    );
  }
}
