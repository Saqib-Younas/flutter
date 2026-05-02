import 'package:flutter/material.dart';
import '../../model/category_model.dart';

class CategorySelector extends StatelessWidget {
  final List<CategoryModel> categories;
  final Function(int) onTap;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final item = categories[index];

          return GestureDetector(
            onTap: () => onTap(index),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: item.isSelected
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: NetworkImage(item.image),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: item.isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}