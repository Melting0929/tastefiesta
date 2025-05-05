// Chan Mei Ting_SUKD2101220
// App: Recipe App: TasteFiesta
// Programming of Mobile Device
// Recipe Edit Page
import 'package:flutter/material.dart';
import 'database.dart';
import 'recipecollection.dart';

class EditTab extends StatefulWidget {
  final int userId;
  final int recipeId;

  const EditTab({super.key, required this.userId, required this.recipeId});

  @override
  // ignore: library_private_types_in_public_api
  _EditTabState createState() => _EditTabState();
}

class _EditTabState extends State<EditTab> {
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _cookingTimeController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  String _selectedCategory = '';
  final List<String> _categories = ['Rice', 'Noodle', 'Porridge', 'Malaysian', 'Korean', 'Others'];

  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    _loadRecipeDetails();
  }

  // Load recipe details from the database
  Future<void> _loadRecipeDetails() async {
    final recipeDetails = await _databaseService.getRecipeById(widget.recipeId);
    _recipeNameController.text = recipeDetails['recipeName'] ?? '';
    _ingredientsController.text = recipeDetails['ingredients'] ?? '';
    _instructionsController.text = recipeDetails['instructions'] ?? '';
    _cookingTimeController.text = recipeDetails['cookingTime']?.toString() ?? '';
    _imageUrlController.text = recipeDetails['image'] ?? '';
    setState(() {
      _selectedCategory = recipeDetails['category'] ?? '';
    });
  }

  // Validate cooking time input
  String? _validateCookingTime(String value) {
    final RegExp cookingTimeRegExp = RegExp(r'^[0-9]+$');
    if (value.isNotEmpty && !cookingTimeRegExp.hasMatch(value)) {
      return 'Cooking time must be a positive integer';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'User ID: ${widget.userId}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _recipeNameController,
              decoration: const InputDecoration(
                labelText: 'Recipe Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: 'Ingredients',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _cookingTimeController,
              decoration: const InputDecoration(
                labelText: 'Cooking Time (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              // Apply validation function
              onChanged: (value) {
                setState(() {});
              },
            ),
            // Show validation error message
            if (_validateCookingTime(_cookingTimeController.text) != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _validateCookingTime(_cookingTimeController.text)!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 12.0),
            TextField( 
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Category:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            // Radio buttons for selecting the category
            Column(
              children: _categories.map((category) {
                return Row(
                  children: [
                    Radio(
                      value: category,
                      groupValue: _selectedCategory,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue as String;
                        });
                      },
                    ),
                    Text(category),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _editRecipe,
              child: const Text('Edit Recipe'),
            ),
          ],
        ),
      ),
    );
  }

  // Edit recipe function
  Future<void> _editRecipe() async {
      String recipeName = _recipeNameController.text.trim();
      String ingredients = _ingredientsController.text.trim();
      String instructions = _instructionsController.text.trim();
      int cookingTime = int.tryParse(_cookingTimeController.text.trim()) ?? 0;
      String category = _selectedCategory;
      String imageUrl = _imageUrlController.text.trim();

      if (recipeName.isNotEmpty &&
          ingredients.isNotEmpty &&
          instructions.isNotEmpty &&
          cookingTime > 0 &&
          category.isNotEmpty &&
          imageUrl.isNotEmpty) {
        await _databaseService.updateRecipe(
          recipeId: widget.recipeId,
          recipeName: recipeName,
          ingredients: ingredients,
          instructions: instructions,
          cookingTime: cookingTime,
          category: category,
          imageURL: imageUrl,
        );

        // ignore: use_build_context_synchronously
        Navigator.pop(context);

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyRecipeTab(userId: widget.userId, recipeId: widget.recipeId),
          ),
        );

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe edited successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all fields'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }