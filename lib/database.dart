// Chan Mei Ting_SUKD2101220
// App: Recipe App: TasteFiesta
// Programming of Mobile Device
// Database of tastefiesta
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._();

  DatabaseService._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  // Method to initialize the database
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'recipes.db');

    return await openDatabase(path, version: 8, onCreate: _createDB);
  }

  // Method to create tables in the database
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS users(
      user_id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT,
      user_email TEXT,
      user_password TEXT
    )
  ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_favorites(
        collection_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        recipe_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id)
      )
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS reviews(
      review_id INTEGER PRIMARY KEY AUTOINCREMENT,
      rating REAL,
      review TEXT,
      user_id INTEGER,
      recipe_id INTEGER,
      FOREIGN KEY (user_id) REFERENCES users(user_id),
      FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id)
    )
  ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS recipes(
        recipe_id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipeName TEXT,
        image TEXT,
        ingredients TEXT,
        instructions TEXT,
        cookingTime INTEGER,
        category TEXT,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(user_id)
      )
    ''');

    await db.rawInsert('''
      INSERT INTO users(username, user_email, user_password)
      VALUES('Admin', 'admin@gmail.com', 'Admin1234')
    ''');

    await db.rawInsert('''
      INSERT INTO recipes(recipeName, image, ingredients, instructions, cookingTime, category, user_id)
      VALUES('Spaghetti Carbonara', 
      'https://images.immediate.co.uk/production/volatile/sites/30/2020/08/recipe-image-legacy-id-1001491_11-2e0fa5c.jpg?quality=90&resize=440,400',
      'Spaghetti, eggs, bacon, Parmesan cheese, black pepper', 
      '1. Cook spaghetti.\n2. Fry bacon until crispy.\n3. Mix eggs and Parmesan cheese.\n4. Combine everything and add black pepper.',
      30, 'Noodle', 1)
    ''');
    await db.rawInsert('''
      INSERT INTO recipes(recipeName, image, ingredients, instructions, cookingTime, category, user_id)
      VALUES('Chicken Curry', 
      'https://www.cubesnjuliennes.com/wp-content/uploads/2020/07/Instant-Pot-Chicken-Curry-Recipe.jpg', 
      'Chicken, curry paste, coconut milk, potatoes, carrots', 
      '1. Cook chicken in curry paste.\n2. Add coconut milk and vegetables.\n3. Simmer until chicken is cooked and vegetables are tender.', 
      45, 'Malaysian', 1)
    ''');
    await db.rawInsert('''
      INSERT INTO recipes(recipeName, image, ingredients, instructions, cookingTime, category, user_id)
      VALUES('Korean Fried Chicken', 
      'https://www.kitchensanctuary.com/wp-content/uploads/2019/08/Korean-Fried-Chicken-square-FS-New-7377.jpg', 
      'Chicken wings, all-purpose flour, cornstarch, salt, black pepper, garlic powder, ginger powder, eggs, oil, soy sauce, gochujang, honey, brown sugar, rice vinegar, garlic, ginger, sesame oil, sesame seeds, green onions', 
      '1. Mix flour, cornstarch, salt, black pepper, garlic powder, and ginger powder in a bowl.\n2. Beat eggs in another bowl.\n3. Dip chicken wings in beaten eggs, then coat with flour mixture.\n4. Fry chicken wings in hot oil until golden brown and crispy.\n5. Make sauce by combining soy sauce, gochujang, honey, brown sugar, rice vinegar, garlic, and ginger in a saucepan.\n6. Toss fried chicken wings in sauce until coated.\n7. Serve hot, garnished with sesame seeds and green onions.',
      30, 'Korean', 1)
    ''');
    await db.rawInsert('''
      INSERT INTO recipes(recipeName, image, ingredients, instructions, cookingTime, category, user_id)
      VALUES('Belacan Fried Chicken', 
      'https://media-cdn.tripadvisor.com/media/photo-s/0e/4f/52/6e/belacan-fried-chicken.jpg', 
      'Chicken, belacan (shrimp paste), turmeric powder, salt, sugar, cornstarch, oil', 
      '1. Marinate chicken pieces with belacan, turmeric powder, salt, and sugar.\n2. Coat marinated chicken with cornstarch.\n3. Heat oil in a pan.\n4. Fry chicken until golden brown and crispy.\n5. Serve hot.',
      35, 'Malaysian', 1)
    ''');

  }

  // Method to upload a new recipe to the database (Recipe Upload Page)
  Future<void> uploadRecipe({
    required String recipeName,
    required String ingredients,
    required String instructions,
    required int cookingTime,
    required String category,
    required String imageURL,
    required int userId,
  }) async {
    final Database? db = await database;
    await db!.insert(
      'recipes',
      {
        'recipeName': recipeName,
        'ingredients': ingredients,
        'instructions': instructions,
        'cookingTime': cookingTime,
        'category': category,
        'image': imageURL,
        'user_id': userId,
      },
    );
  }

  // Method to search for recipes (Home Page)
  Future<List<int>> searchRecipes(String query) async {
    final Database? db = await database;
    List<Map<String, dynamic>> recipes = await db!.query(
      'recipes',
      where: 'recipeName LIKE ? OR ingredients LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return recipes.map<int>((recipe) => recipe['recipe_id']).toList();
  }

  // Method to retrieve all recipes from the database (Home Page)
  Future<List<int>> getRecipes() async {
    final Database? db = await database;
    List<Map<String, dynamic>> recipes = await db!.query('recipes');
    return recipes.map<int>((recipe) => recipe['recipe_id']).toList();
  }

  // Method to retrieve recipes by a specific category (Home Page)
  Future<List<int>> getRecipesByCategory(String category) async {
    final Database? db = await database;
    List<Map<String, dynamic>> recipes = await db!.query('recipes', where: 'category = ?', whereArgs: [category]);
    return recipes.map<int>((recipe) => recipe['recipe_id']).toList();
  }

  // Method to retrieve a recipe by its ID (Home Page)
  Future<Map<String, dynamic>> getRecipeById(int recipeId) async {
    final Database? db = await database;
    List<Map<String, dynamic>> result = await db!.rawQuery('''
      SELECT *
      FROM recipes
      WHERE recipe_id = ?
      LIMIT 1
    ''', [recipeId]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception('Recipe not found');
    }
  }

  // Method to save a recipe as a favorite for a user (Recipe Detail Page)
  Future<void> saveFavoriteRecipe(int userId, int recipeId) async {
    final Database? db = await database;
    await db!.insert('user_favorites', {'user_id': userId, 'recipe_id': recipeId});
  }

  // Method to remove a favorite recipe for a user (Recipe Detail Page)
  Future<void> removeFavoriteRecipe(int userId, int recipeId) async {
    final Database? db = await database;
    await db!.delete(
      'user_favorites',
      where: 'user_id = ? AND recipe_id = ?',
      whereArgs: [userId, recipeId],
    );
  }

  // Method to check if a recipe is marked as favorite by a user (Recipe Detail Page)
  Future<bool> isFavoriteRecipe(int userId, int recipeId) async {
    final Database? db = await database;
    List<Map<String, dynamic>> result = await db!.query(
      'user_favorites',
      where: 'user_id = ? AND recipe_id = ?',
      whereArgs: [userId, recipeId],
    );
    return result.isNotEmpty;
  }

  // Method to retrieve a user's favorite recipes (My Collection Page)
  Future<List<Map<String, dynamic>>> getUserFavorites(int userId) async {
    final Database? db = await database;
    return db!.rawQuery('''
      SELECT r.*
      FROM user_favorites AS f
      INNER JOIN recipes AS r ON f.recipe_id = r.recipe_id
      WHERE f.user_id = ?
    ''', [userId]);
  }

  // Method to retrieve recipes added by a specific user (My Collection Page)
  Future<List<Map<String, dynamic>>> getUserRecipes(int userId) async {
    final Database? db = await database;
    List<Map<String, dynamic>> recipes = await db!.query('recipes', where: 'user_id = ?', whereArgs: [userId]);
    return recipes.isNotEmpty ? recipes : [];
  }

  // Method to update an existing recipe in the database (Recipe Collection Page)
  Future<void> updateRecipe({
    required int recipeId,
    required String recipeName,
    required String ingredients,
    required String instructions,
    required int cookingTime,
    required String category,
    required String imageURL,
  }) async {
    final Database? db = await database;
    await db!.update(
      'recipes',
      {
        'recipeName': recipeName,
        'ingredients': ingredients,
        'instructions': instructions,
        'cookingTime': cookingTime,
        'category': category,
        'image': imageURL,
      },
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
  }

  // Method to delete a recipe from the database (Recipe Collection Page)
  Future<void> deleteRecipe(int recipeId) async {
    final Database? db = await database;
    await db!.delete('recipes', where: 'recipe_id = ?', whereArgs: [recipeId]);
  }

  // Method to insert a new user into the database (Register Page)
  Future<int> insertUser(String username, String email, String password) async {
    final Database? db = await database;
    return await db!.insert('users', {
      'username': username,
      'user_email': email,
      'user_password': password,
    });
  }

  // Method to verify user login credentials (Login Page)
  Future<Map<String, dynamic>> verifyLogin(String username, String password) async {
    final Database? db = await database;
    List<Map<String, dynamic>> result = await db!.query(
      'users',
      columns: ['user_id'],
      where: 'username = ? AND user_password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return {'verified': true, 'user_id': result.first['user_id']};
    } else {
      return {'verified': false, 'error': 'Incorrect username or password'};
    }
  }

  // Method to retrieve a user by their ID
  Future<Map<String, dynamic>> getUserByID(int userID) async {
    final Database? db = await database;
    List<Map<String, dynamic>> result = await db!.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userID],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception('User not found');
    }
  }

  // Method to update user information in the database (Profile Page)
  Future<void> updateUser(int userId, String username,String email, String password) async {
    final Database? db = await database;
    await db!.update(
      'users',
      {'username': username, 'user_email': email, 'user_password': password},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Method to check if a username already exists in the database (Register Page & Profile Page)
  Future<bool> checkUserExists(String username) async {
    final Database? db = await database;
    List<Map<String, dynamic>> result = await db!.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Method to save a review for a recipe (Review Page)
  Future<void> saveReview(int userId, int recipeId, double rating, String review) async {
    final Database? db = await database;
    await db!.insert('reviews', {
      'user_id': userId,
      'recipe_id': recipeId,
      'rating': rating,
      'review': review,
    });
  }

  // Method to retrieve reviews for a specific recipe (Recipe Detail Page & Recipe Collection Page)
  Future<List<Map<String, dynamic>>> getReviewsForRecipe(int recipeId) async {
    final Database? db = await database;
    List<Map<String, dynamic>> reviews = await db!.query(
      'reviews',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
    return reviews;
  }
}