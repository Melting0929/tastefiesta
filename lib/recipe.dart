// Chan Mei Ting_SUKD2101220
// App: Recipe App: TasteFiesta
// Programming of Mobile Device
// Recipe Detail Page (Users Version)
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'database.dart';
import 'review.dart';

class RecipeDetailTab extends StatefulWidget {
  final int userId;
  final int recipeId;
  final DatabaseService _databaseService = DatabaseService.instance;

  RecipeDetailTab({super.key, required this.userId, required this.recipeId});

  @override
  // ignore: library_private_types_in_public_api
  _RecipeDetailTabState createState() => _RecipeDetailTabState();
}

class _RecipeDetailTabState extends State<RecipeDetailTab> {
  bool isFavorite = false;
  Map<String, dynamic> recipe = {};
  List<Map<String, dynamic>> reviews = [];

  @override
  void initState() {
    super.initState();
    checkFavorite();
    _loadRecipe();
    _loadReviews();
  }

  // Load recipe details from the database
  Future<void> _loadRecipe() async {
    final recipeDetails = await widget._databaseService.getRecipeById(widget.recipeId);
    setState(() {
      recipe = recipeDetails;
    });
  }

  // Load recipe review from the database
  Future<void> _loadReviews() async {
    final reviewsData = await widget._databaseService.getReviewsForRecipe(widget.recipeId);
    setState(() {
      reviews = reviewsData;
    });
  }

  // Check if the recipe is marked as a favorite by the user
  void checkFavorite() async {
    bool favorite = await widget._databaseService.isFavoriteRecipe(widget.userId, widget.recipeId);
    setState(() {
      isFavorite = favorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['recipeName']?? ''),
        actions: [
          IconButton(
            onPressed: () async {
              // Navigate to review page
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReviewPage(userId: widget.userId, recipeId: widget.recipeId)),
              );
              // Check if a review was submitted and refresh the page if needed
              if (result != null && result as bool) {
                _loadRecipe();
                _loadReviews();
              }
            },
            icon: const Icon(Icons.comment),
          ),
          IconButton(
            onPressed: () {
              toggleFavorite();// toggle the favourite status of recipe
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 500,
              height: 300,
              child: _buildRecipeImage(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Author:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<Map<String, dynamic>>(
              future: widget._databaseService.getUserByID(recipe['user_id']?? 1),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final username = snapshot.data!['username'];
                return Text('$username');
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Cooking Time:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('${recipe['cookingTime']} min'),
            const SizedBox(height: 20),
            const Text(
              'Ingredients:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(recipe['ingredients']?? ''),
            const SizedBox(height: 20),
            const Text(
              'Instructions:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(recipe['instructions']?? ''),
            const SizedBox(height: 20),
            const Text(
              'Rate of this recipe:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            RatingBar.builder(
              initialRating: _calculateAverageRating(),
              minRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              ignoreGestures: true,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                // Handle rating update if needed
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Reviews:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Display the reviews as a list of Text widgets
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reviews.isEmpty
              ? [
                  const Text(
                    'No reviews',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ]
              : reviews.map((review) {
                  return FutureBuilder<Map<String, dynamic>>(
                    future: widget._databaseService.getUserByID(review['user_id']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final username = snapshot.data!['username'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('${review['review']} by $username'),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    }

  // Method to calculate the average rating
  double _calculateAverageRating() {
    if (reviews.isEmpty) {
      return 5.0;
    }

    double totalRating = 0.0;
    for (var review in reviews) {
      totalRating += review['rating'];
    }

    return totalRating / reviews.length;
  }

  // Recipe Image
  Widget _buildRecipeImage() {
    if (recipe['image'] != null && recipe['image'].isNotEmpty) {
      return Image.network(
        recipe['image']!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Placeholder(); // Placeholder image if network image fails to load
        },
      );
    } else {
      return const Placeholder(); // Placeholder image if image URL is empty
    }
  }

  // Method to toggle the favorite status of the recipe
  void toggleFavorite() async {
    if (isFavorite) {
      await widget._databaseService.removeFavoriteRecipe(widget.userId, widget.recipeId); // Remove the recipe from favorites
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe removed from favorites!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      await widget._databaseService.saveFavoriteRecipe(widget.userId, widget.recipeId); // Add the recipe to favorites
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe added to favorites!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    // Update the favorite status
    setState(() {
      isFavorite = !isFavorite;
    });
  }
}
