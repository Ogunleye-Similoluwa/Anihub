import 'package:anihub/common/progress_indicator.dart';
import 'package:anihub/config/styles.dart';
import 'package:anihub/providers/wishlistprovider.dart';
import 'package:anihub/widgets/detail_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({Key? key}) : super(key: key);

  @override
  _FavouritesScreenState createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  @override
  void initState() {
    super.initState();
    // Load wishlist when screen initializes
    Future.microtask(() => 
      Provider.of<WishListProvider>(context, listen: false).loadWishlist()
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Row(
              children: [
                const Text("Wishlist", style: TextStyles.primaryTitle),
                const Spacer(),
                Consumer<WishListProvider>(
                  builder: (context, provider, _) {
                    if (provider.wishlistAnimes.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(Icons.delete_sweep),
                        onPressed: () => _showClearConfirmation(context),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<WishListProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const CustomProgressIndicator();
                }

                if (provider.wishlistAnimes.isEmpty) {
                  return const Center(
                    child: Text(
                      "Your wishlist is empty!",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: provider.wishlistAnimes.length,
                  itemBuilder: (context, index) {
                    final anime = provider.wishlistAnimes[index];
                    return GestureDetector(
                      onTap: () => showBottomSheet(
                        context: context,
                        builder: (context) => SavedBottomSheet(
                          id: anime.malId,
                          title: anime.title,
                          image: anime.imageUrl,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(anime.imageUrl),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () => provider.removeFromWishlist(anime.malId),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text('Are you sure you want to clear your entire wishlist?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<WishListProvider>(context, listen: false).clearWishlist();
    }
  }
}
