import 'package:flutter/material.dart';

class CategoryEmptyWidget extends StatelessWidget {
  const CategoryEmptyWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Asset Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset(
                'assets/empty_menu.png',
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),

            // Instructional Text (optional)
            Text(
              'No categories yet!',
              style: TextTheme.of(context).titleLarge,
            ),
            const SizedBox(height: 16),

            // Add Category Button
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

