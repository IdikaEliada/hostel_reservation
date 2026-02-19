import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double _rating = 3.0; // default star rating
  final _commentController = TextEditingController();

  // Dummy past reviews
  final List<Map<String, dynamic>> _pastReviews = [
    {'name': 'John', 'rating': 4.5, 'comment': 'Room is clean and nice!'},
    {'name': 'Mary', 'rating': 5, 'comment': 'Very comfortable stay.'},
    {'name': 'Alex', 'rating': 2, 'comment': 'Okay, but needs better lighting.'},
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rate & Review Room')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Star Rating
            Text('Rate the Room:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              maxRating: 5,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 20),

            // Comment box
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write your review here...',
              ),
            ),
            SizedBox(height: 20),

            // Submit button
            ElevatedButton(
              child: Text('Submit Review'),
              onPressed: () {
                // Show thank you popup
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Thank You!'),
                    content: Text('Thank you for your review!'),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.pop(context);
                          // Reset form
                          setState(() {
                            _rating = 3.0;
                            _commentController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 20),

            // Past reviews
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Past Reviews:', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _pastReviews.length,
                      itemBuilder: (context, index) {
                        final review = _pastReviews[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text('${review['name']} - ${review['rating']} ⭐'),
                            subtitle: Text('${review['comment']}'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
