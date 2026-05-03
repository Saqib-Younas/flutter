import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/src/controller/admin_controller.dart';
import 'package:e_commerce_flutter/src/core/app_color.dart';
import 'package:e_commerce_flutter/src/model/product.dart';
import 'package:e_commerce_flutter/src/view/widget/gradient_button.dart';

/// Bottom-sheet form used for both creating and editing a product. Exposes
/// every field on the `products` table.
class AdminProductForm extends StatefulWidget {
  const AdminProductForm({super.key, this.product});

  final Product? product;

  static Future<void> show(BuildContext context, [Product? product]) {
    return Get.bottomSheet(
      AdminProductForm(product: product),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
  }

  @override
  State<AdminProductForm> createState() => _AdminProductFormState();
}

class _AdminProductFormState extends State<AdminProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _about;
  late final TextEditingController _category;
  late final TextEditingController _imageUrl;
  late final TextEditingController _price;
  late final TextEditingController _discountValue;
  late final TextEditingController _stock;

  late DiscountType _discountType;
  late bool _isActive;
  late bool _isFeatured;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _about = TextEditingController(text: p?.about ?? '');
    _category = TextEditingController(text: p?.category ?? '');
    _imageUrl = TextEditingController(text: p?.imageUrl ?? '');
    _price = TextEditingController(text: p?.price.toString() ?? '');
    _discountValue =
        TextEditingController(text: p?.discountValue.toString() ?? '0');
    _stock = TextEditingController(text: p?.stockQuantity.toString() ?? '0');
    _discountType = p?.discountType ?? DiscountType.none;
    _isActive = p?.isActive ?? true;
    _isFeatured = p?.isFeatured ?? false;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _description,
      _about,
      _category,
      _imageUrl,
      _price,
      _discountValue,
      _stock,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final p = Product(
      id: widget.product?.id ?? '',
      name: _name.text.trim(),
      description:
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      about: _about.text.trim().isEmpty ? '' : _about.text.trim(),
      category: _category.text.trim().isEmpty ? null : _category.text.trim(),
      imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
      price: double.tryParse(_price.text) ?? 0,
      discountType: _discountType,
      discountValue: double.tryParse(_discountValue.text) ?? 0,
      stockQuantity: int.tryParse(_stock.text) ?? 0,
      isActive: _isActive,
      isFeatured: _isFeatured,
    );
    Get.find<AdminController>().saveProduct(p);
  }

  @override
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: mq.size.height * 0.92),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FF), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.brandIndigo,
                            AppColor.brandIndigo.withOpacity(0.4)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// 🔥 Title
                  Text(
                    _isEdit ? 'Edit Product' : 'Add New Product',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _Field(
                    controller: _name,
                    label: 'Product Name',
                    icon: Icons.shopping_bag_outlined,
                    validator: _required,
                  ),

                  _Field(
                    controller: _category,
                    label: 'Category',
                    icon: Icons.category_outlined,
                  ),

                  _Field(
                    controller: _imageUrl,
                    label: 'Image Asset Path',
                    icon: Icons.image,
                  ),

                  _Field(
                    controller: _description,
                    label: 'Short Description',
                    icon: Icons.short_text,
                  ),

                  _Field(
                    controller: _about,
                    label: 'Full Details',
                    icon: Icons.description,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          controller: _price,
                          label: 'Price (Rs)',
                          icon: Icons.currency_rupee,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: _requiredNumber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _stock,
                          label: 'Stock',
                          icon: Icons.inventory,
                          keyboardType: TextInputType.number,
                          validator: _requiredNumber,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// 🔥 Discount Section Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Discount",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        _DiscountSelector(
                          type: _discountType,
                          onChanged: (t) => setState(() => _discountType = t),
                        ),
                        if (_discountType != DiscountType.none) ...[
                          const SizedBox(height: 10),
                          _Field(
                            controller: _discountValue,
                            label: _discountType == DiscountType.percentage
                                ? 'Discount %'
                                : 'Discount Rs',
                            icon: Icons.percent,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 🔥 Switches Card
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Active Product'),
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                          activeColor: AppColor.brandIndigo,
                        ),
                        SwitchListTile(
                          title: const Text('Featured Product'),
                          value: _isFeatured,
                          onChanged: (v) => setState(() => _isFeatured = v),
                          activeColor: AppColor.brandIndigo,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔥 Button
                  Obx(() {
                    final loading = Get.find<AdminController>().isLoading.value;
                    return GradientButton(
                      text: _isEdit ? 'UPDATE PRODUCT' : 'CREATE PRODUCT',
                      onPressed: loading ? null : _submit,
                      isLoading: loading,
                    );
                  }),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _requiredNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (double.tryParse(v) == null) return 'Must be a number';
    return null;
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColor.brandIndigo),
          filled: true,
          fillColor: AppColor.surfaceGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _DiscountSelector extends StatelessWidget {
  const _DiscountSelector({required this.type, required this.onChanged});

  final DiscountType type;
  final ValueChanged<DiscountType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: DiscountType.values.map((t) {
        final selected = t == type;
        return ChoiceChip(
          label: Text(switch (t) {
            DiscountType.none => 'No discount',
            DiscountType.percentage => 'Percentage',
            DiscountType.fixed => 'Fixed amount',
          }),
          selected: selected,
          onSelected: (_) => onChanged(t),
          selectedColor: AppColor.brandIndigo.withValues(alpha: 0.15),
        );
      }).toList(),
    );
  }
}
