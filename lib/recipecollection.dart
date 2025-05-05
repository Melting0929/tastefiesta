// Chan Mei Ting_SUKD2101220
// App: Recipe App: TasteFiesta
// Programming of Mobile Device
// Recipe Detail Page (Author Version)
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'database.dart';
import 'edit.dart';

class MyRecipeTab extends StatefulWidget {
  final int userId;
  final int recipeId;
  final DatabaseService _databaseService = DatabaseService.instance;

  MyRecipeTab({super.key, required this.userId, required this.recipeId});

  @override
  // ignore: library_private_types_in_public_api
  _RecipeDetailTabState createState() => _RecipeDetailTabState();
}

class _RecipeDetailTabState extends State<MyRecipeTab> {
  Map<String, dynamic> recipe = {};
  List<Map<String, dynamic>> reviews = [];

  @override
  void initState() {
    super.initState();
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

  // Load recipe reviews from the database
  Future<void> _loadReviews() async {
    final reviewsData = await widget._databaseService.getReviewsForRecipe(widget.recipeId);
    setState(() {
      reviews = reviewsData;
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
              // Navigate to edit page
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditTab(userId: widget.userId, recipeId: widget.recipeId)),
              );
              // Check if the recipe was updated and refresh the page if needed
              if (result != null && result as bool) {
                _loadRecipe();
                _loadReviews();
              }
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              // Show delete confirmation dialog
              _showDeleteConfirmationDialog();
            },
            icon: const Icon(Icons.delete),
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

  // Method to show delete confirmation dialog
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this recipe?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop();
                // Delete the recipe
                _deleteRecipe();
                // Navigate back to the previous screen (recipe detail screen)
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Method to delete the recipe
  void _deleteRecipe() async {
    await widget._databaseService.deleteRecipe(widget.recipeId);
  }
}
