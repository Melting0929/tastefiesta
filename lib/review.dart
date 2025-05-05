// Chan Mei Ting_SUKD2101220
// App: Recipe App: TasteFiesta
// Programming of Mobile Device
// Write Review Page
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'database.dart';

class ReviewPage extends StatefulWidget {
  final int recipeId;
  final int userId;

  const ReviewPage({super.key, required this.recipeId, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double inputRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate and Review'),
      ),
      body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rate:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              RatingBar.builder(
                initialRating: inputRating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 30,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    inputRating = rating;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Write your review:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reviewController,
                decoration: const InputDecoration(
                  hintText: 'Write your review here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _submitReview(); // To submit review
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to submit review
  void _submitReview() async {
    String reviewText = _reviewController.text;
    if (reviewText.isNotEmpty && inputRating > 0) {
      DatabaseService databaseService = DatabaseService.instance;
      await databaseService.saveReview(widget.userId, widget.recipeId, inputRating, reviewText);
      // ignore: use_build_context_synchronously
      Navigator.pop(context, true);
    } else {
      // Show an error message if the review text or rating is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide both rating and review before submitting.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
