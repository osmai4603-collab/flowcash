import 'package:flutter/material.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/widgets/combo_box_form.dart';

class OpeningQuantityFormDialog extends StatefulWidget {
  final List<InventoryEntity> inventoryItems;
  final List<WarehouseEntity> warehouses;

  const OpeningQuantityFormDialog({
    super.key,
    required this.inventoryItems,
    required this.warehouses,
  });

  @override
  State<OpeningQuantityFormDialog> createState() => _OpeningQuantityFormDialogState();
}

class _OpeningQuantityFormDialogState extends State<OpeningQuantityFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _inventoryItemController = TextEditingController();
  int? _selectedInventoryId;
  int? _selectedWarehouseId;
  final _quantityController = TextEditingController();
  final _costTotalController = TextEditingController();

  List<CategoryEntity> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _quantityController.text = "1.0";
    _costTotalController.text = "0.0";
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final res = await sl<GetAllCategoriesUseCase>().call();
    if (mounted) {
      setState(() {
        res.fold((_) => null, (list) => _categories = list);
        _isLoading = false;
      });
    }
  }

  String _getInventoryLabel(InventoryEntity item) {
    try {
      return _categories.firstWhere((c) => c.id == item.categoryId).categoryName;
    } catch (_) {
      return 'صنف مخزون (#${item.id})';
    }
  }

  @override
  void dispose() {
    _inventoryItemController.dispose();
    _quantityController.dispose();
    _costTotalController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInventoryId == null || _selectedWarehouseId == null) return;

    final quantity = double.tryParse(_quantityController.text) ?? 1.0;
    final totalCost = double.tryParse(_costTotalController.text) ?? 0.0;

    final entity = OpeningQuantityEntity(
      id: 0,
      categoryId: _selectedInventoryId!,
      warehouseId: _selectedWarehouseId!,
      countUnits: quantity,
      costTotal: totalCost,
      createdAt: DateTime.now(),
      periodId: 1, // Standard accounting period
    );

    Navigator.of(context).pop(entity);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDark
                ? [theme.colorScheme.surface, theme.colorScheme.surface.withAlpha(240)]
                : [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: _isLoading
            ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.playlist_add_check_outlined, color: theme.colorScheme.primary, size: 28),
                        const SizedBox(width: 8),
                        const Text('إضافة رصيد افتتاحي 📊', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),

                    // Inventory Item
                    ComboBoxForm<InventoryEntity>(
                      controller: _inventoryItemController,
                      decoration: const InputDecoration(
                        labelText: 'اختر صنف المخزون',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                      ),
                      labelMenu: (item) => _getInventoryLabel(item),
                      labelString: (item) => _getInventoryLabel(item),
                      itemsBuilder: (value) {
                        final search = value.trim().toLowerCase();
                        return widget.inventoryItems.where((item) {
                          return _getInventoryLabel(item).toLowerCase().contains(search);
                        }).toList();
                      },
                      onSelectedItem: (item) {
                        setState(() {
                          _selectedInventoryId = item.id;
                        });
                      },
                      onChanged: (value) {
                        if (_selectedInventoryId != null &&
                            _inventoryItemController.text !=
                                _getInventoryLabel(widget.inventoryItems.firstWhere((item) => item.id == _selectedInventoryId!))) {
                          setState(() {
                            _selectedInventoryId = null;
                          });
                        }
                      },
                      validator: (_) => _selectedInventoryId == null ? 'الصنف مطلوب' : null,
                    ),
                    const SizedBox(height: 16),

                    // Warehouse
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'اختر المستودع',
                        prefixIcon: Icon(Icons.store),
                      ),
                      initialValue: _selectedWarehouseId,
                      items: widget.warehouses.map((w) {
                        return DropdownMenuItem<int>(
                          value: w.id,
                          child: Text(w.warehouseName),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedWarehouseId = val),
                      validator: (val) => val == null ? 'المستودع مطلوب' : null,
                    ),
                    const SizedBox(height: 16),

                    // Quantity & Total Cost
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            textDirection: TextDirection.ltr,
                            decoration: const InputDecoration(
                              labelText: 'الكمية الافتتاحية',
                              prefixIcon: Icon(Icons.format_list_numbered),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (val) => val == null || val.isEmpty ? 'الكمية مطلوبة' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _costTotalController,
                            textDirection: TextDirection.ltr,
                            decoration: const InputDecoration(
                              labelText: 'إجمالي التكلفة الدفترية',
                              prefixIcon: Icon(Icons.attach_money_outlined),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (val) => val == null || val.isEmpty ? 'التكلفة مطلوبة' : null,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('إلغاء'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _submit,
                          child: const Text('حفظ الرصيد الافتتاحي'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
