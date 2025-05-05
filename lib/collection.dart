// Chan Mei Ting_SUKD2101220
// App: Recipe App: TasteFiesta
// Programming of Mobile Device
// My Collection Page
import 'package:flutter/material.dart';
import 'package:taste_fiesta/recipecollection.dart';
import 'database.dart';
import 'recipe.dart';

class CollectionTab extends StatefulWidget {
  final int userId;

  const CollectionTab({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _CollectionTabState createState() => _CollectionTabState();
}

class _CollectionTabState extends State<CollectionTab> {
  late List<Map<String, dynamic>> userRecipes = [];
  late List<Map<String, dynamic>> favoriteRecipes = [];
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    _loadUserRecipes();
    _loadFavoriteRecipes();
  }

  // Load recipes added by the user
  Future<void> _loadUserRecipes() async {
    final List<Map<String, dynamic>> recipes = await _databaseService.getUserRecipes(widget.userId);
    setState(() {
      userRecipes = recipes;
    });
  }

  // Load recipes added to favorites by the user
  Future<void> _loadFavoriteRecipes() async {
    final List<Map<String, dynamic>> favorites =
        await _databaseService.getUserFavorites(widget.userId);
    setState(() {
      favoriteRecipes = favorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('My Recipes'),
            const SizedBox(height: 20),
            _buildMyRecipeList(userRecipes),
            const SizedBox(height: 20),
            _buildSectionTitle('My Collection'),
            const SizedBox(height: 20),
            _buildRecipeList(favoriteRecipes),
          ],
        ),
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Recipe list
  Widget _buildRecipeList(List<Map<String, dynamic>> recipes) {
    return recipes.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return _buildRecipeItem(recipes[index]);
            },
          )
        : const Center(child: Text('No recipes available.'));
  }

  // Recipe
  Widget _buildRecipeItem(Map<String, dynamic> recipe) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailTab(userId: widget.userId, recipeId: recipe['recipe_id']),
            ),
          );
        },
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: _buildRecipeImage(recipe),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['recipeName'] ?? 'Unknown Recipe',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: ${recipe['category']}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cooking Time: ${recipe['cookingTime']} mins',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // User's recipe list
  Widget _buildMyRecipeList(List<Map<String, dynamic>> recipes) {
    return recipes.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return _buildMyRecipeItem(recipes[index]);
            },
          )
        : const Center(child: Text('No recipes available.'));
  }

  // User's recipes
  Widget _buildMyRecipeItem(Map<String, dynamic> recipe) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyRecipeTab(userId: widget.userId, recipeId: recipe['recipe_id']),
            ),
          );
        },
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: _buildRecipeImage(recipe),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['recipeName'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: ${recipe['category']}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cooking Time: ${recipe['cookingTime']} mins',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Recipe Images
  Widget _buildRecipeImage(Map<String, dynamic> recipe) {
    if (recipe['image'] != null && recipe['image'].isNotEmpty) {
      return Image.network(
        recipe['image'],
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Placeholder(); // Placeholder image if network image fails to load
        },
      );
    } else {
      return const Placeholder(); // Placeholder image if image URL is empty
    }
  }
}
