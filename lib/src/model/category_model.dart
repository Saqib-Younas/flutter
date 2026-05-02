class CategoryModel {
  final String name;
  final String image;
  bool isSelected;

  CategoryModel({
    required this.name,
    required this.image,
    this.isSelected = false,
  });
}