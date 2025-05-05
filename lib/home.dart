// Chan Mei Ting_SUKD2101220
// App: Recipe App: TasteFiesta
// Programming of Mobile Device
// Home Page (Search, Upload, Category Bar, and Recipe Display)
import 'package:flutter/material.dart';
import 'upload.dart';
import 'database.dart';
import 'recipe.dart';
import 'recipecollection.dart';

class HomeTab extends StatefulWidget {
  final int userId;

  const HomeTab({super.key, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService.instance;
  List<int> _filteredRecipeIds = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();// dispose search contoller
    super.dispose();
  }

  // Method to handle text change on search tab
  void _onSearchTextChanged() {
    if (_searchController.text.isEmpty) {
      _loadRecipes();
    }
  }

  // Method to load all recipe from database
  Future<void> _loadRecipes() async {
    final recipes = await _databaseService.getRecipes();
    setState(() {
      _filteredRecipeIds = recipes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome To Taste Fiesta!'),
      ),
      body:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search recipes by name or ingredient',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      _searchRecipes(value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear), // to clear text on the search tab
                  onPressed: () {
                    setState(() {
                      _clearSearch();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded), // to upload recipe
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UploadTab(userId: widget.userId)),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Text(
                  'Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row( // Category bar
              children: [
                CategoryButton(text: 'All', onPressed: _loadRecipes),
                CategoryButton(text: 'Rice', onPressed: () => _filterRecipesByCategory('Rice')),
                CategoryButton(text: 'Noodle', onPressed: () => _filterRecipesByCategory('Noodle')),
                CategoryButton(text: 'Porridge', onPressed: () => _filterRecipesByCategory('Porridge')),
                CategoryButton(text: 'Malaysian', onPressed: () => _filterRecipesByCategory('Malaysian')),
                CategoryButton(text: 'Korean', onPressed: () => _filterRecipesByCategory('Korean')),
                CategoryButton(text: 'Others', onPressed: () => _filterRecipesByCategory('Others')),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Text(
                  'Recipes:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded( // display recipes
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _filteredRecipeIds.length,
              itemBuilder: (BuildContext context, int index) {
                return FutureBuilder<Map<String, dynamic>>(
                  future: _databaseService.getRecipeById(_filteredRecipeIds[index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final recipe = snapshot.data;
                    return RecipeCard(recipe: recipe, userId: widget.userId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Method to clear search text and reset filtered recipes
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredRecipeIds = [];
      _loadRecipes();
    });
  }

  // Method to filter recipes by category
  void _filterRecipesByCategory(String category) async {
    final filteredRecipes = await _databaseService.getRecipesByCategory(category);
    setState(() {
      _filteredRecipeIds = filteredRecipes;
    });
  }

  // Method to search recipes based on query
  Future<void> _searchRecipes(String query) async {
    final result = await _databaseService.searchRecipes(query);
    setState(() {
      _filteredRecipeIds = result;
    });
  }
}

class RecipeCard extends StatelessWidget {
  final Map<String, dynamic>? recipe;
  final int userId;

  const RecipeCard({super.key, required this.recipe, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: () {
          if (recipe!['user_id'] == userId) {
            // Navigate to MyRecipeTab if the recipe belongs to the current user
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyRecipeTab(userId: userId, recipeId: recipe!['recipe_id'])),
            );
          } else {
            // Navigate to RecipeDetailTab if the recipe belongs to another user
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecipeDetailTab(userId: userId, recipeId: recipe!['recipe_id'])),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                child: _buildRecipeImage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    recipe!['recipeName'],
                    style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${recipe!['cookingTime']} min',
                    style: const TextStyle(fontSize: 14.0, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // To build the recipe image
  Widget _buildRecipeImage() {
    if (recipe != null && recipe!['image'] != null && recipe!['image'].isNotEmpty) {
      return Image.network(
        recipe!['image'],
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

// Category Bar Buttons
class CategoryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CategoryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
