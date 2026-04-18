import 'package:flutter/material.dart';

class PromoBanner extends StatelessWidget {
  final String title;
  final String description;
  final Color backgroundColor;
  final String imagePath; // For now, we'll use Icons or Colors if no images are available.

  const PromoBanner({
    super.key,
    required this.title,
    required this.description,
    required this.backgroundColor,
    this.imagePath = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        image: imagePath.isNotEmpty 
          ? DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
              opacity: 0.1,
            )
          : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
