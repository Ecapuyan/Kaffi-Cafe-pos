import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaffi_cafe_pos/widgets/text_widget.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextWidget(
            text: 'Customer Feedback',
            fontSize: 18,
            fontFamily: 'Bold',
            color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final feedbackDocs = snapshot.data!.docs;
          if (feedbackDocs.isEmpty) {
            return const Center(child: Text('No feedback yet.'));
          }
          return ListView.builder(
            itemCount: feedbackDocs.length,
            itemBuilder: (context, index) {
              final feedback =
                  feedbackDocs[index].data() as Map<String, dynamic>;
              final timestamp = feedback['timestamp'] as Timestamp?;
              final date = timestamp?.toDate();
              final formattedDate = date?.toString() ?? 'N/A';
              final orderItems = feedback['orderItems'] as List<dynamic>? ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStarRating(
                              (feedback['rating'] as num?)?.toInt() ?? 0),
                          TextWidget(
                            text: formattedDate,
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextWidget(
                        text: feedback['comment'] ?? 'No feedback text',
                        fontSize: 16,
                        fontFamily: 'Medium',
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          TextWidget(
                            text: 'Username: ${feedback['username'] ?? 'N/A'}',
                            fontSize: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.store_outlined,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          TextWidget(
                            text: 'Branch: ${feedback['branch'] ?? 'N/A'}',
                            fontSize: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          TextWidget(
                            text: 'Order ID: ${feedback['orderId'] ?? 'N/A'}',
                            fontSize: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextWidget(
                        text: 'Order Items:',
                        fontSize: 14,
                        isBold: true,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: orderItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: TextWidget(
                              text: '• ${item['name']} (x${item['quantity']})',
                              fontSize: 14,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
