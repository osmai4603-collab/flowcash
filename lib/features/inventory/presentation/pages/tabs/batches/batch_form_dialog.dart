import 'package:flutter/material.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';
import 'package:flowcash/core/enums/batch_source_enum.dart';
import 'package:flowcash/core/enums/batch_status_enum.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_batch_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/widgets/combo_box_form.dart';

class BatchFormDialog extends StatefulWidget {
  final InventoryBatchEntity? batch;
  final List<InventoryEntity> inventoryItems;

  const BatchFormDialog({super.key, this.batch, required this.inventoryItems});

  @override
  State<BatchFormDialog> createState() => _BatchFormDialogState();
}

class _BatchFormDialogState extends State<BatchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEdit;

  // Form fields
  final _batchNumberController = TextEditingController();
  final _inventoryItemController = TextEditingController();
  int? _selectedInventoryId;
  BatchSource _selectedSource = BatchSource.buys;
  BatchStatus _selectedStatus = BatchStatus.available;
  final _countUnitsController = TextEditingController();
  final _unitCostController = TextEditingController();
  DateTime _inputDate = DateTime.now();
  DateTime? _productionDate;
  DateTime? _expirationDate;

  // Resolved list of categories for drop down
  List<CategoryEntity> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.batch != null;
    _loadCategories();

    if (_isEdit) {
      final b = widget.batch!;
      _batchNumberController.text = b.batchNumber;
      _selectedInventoryId = b.inventoryId;
      _inventoryItemController.text = _getInventoryName(widget.inventoryItems.firstWhere((item) => item.id == b.inventoryId));
      _selectedSource = b.batchSource;
      _selectedStatus = b.batchStatus;
      _countUnitsController.text = b.countUnits.toString();
      _unitCostController.text = b.unitCost.toString();
      _inputDate = b.inputDate;
      _productionDate = b.productionDate;
      _expirationDate = b.expirationDate;
    } else {
      _countUnitsController.text = "0.0";
      _unitCostController.text = "0.0";
    }
  }

  Future<void> _loadCategories() async {
    final res = await sl<GetAllCategoriesUseCase>().call();
    if (mounted) {
      setState(() {
        res.fold((_) => null, (list) => _categories = list);
        _isLoadingCategories = false;
      });
    }
  }

  String _getInventoryName(InventoryEntity item) {
    try {
      return _categories
          .firstWhere((c) => c.id == item.categoryId)
          .categoryName;
    } catch (_) {
      return 'صنف مخزون (#${item.id})';
    }
  }

  @override
  void dispose() {
    _batchNumberController.dispose();
    _inventoryItemController.dispose();
    _countUnitsController.dispose();
    _unitCostController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, String field) async {
    DateTime initial = DateTime.now();
    if (field == 'input') initial = _inputDate;
    if (field == 'production' && _productionDate != null) {
      initial = _productionDate!;
    }
    if (field == 'expiration' && _expirationDate != null) {
      initial = _expirationDate!;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (field == 'input') _inputDate = picked;
        if (field == 'production') _productionDate = picked;
        if (field == 'expiration') _expirationDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedInventoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار صنف المخزون')),
      );
      return;
    }

    final countUnits = double.tryParse(_countUnitsController.text) ?? 0.0;
    final unitCost = double.tryParse(_unitCostController.text) ?? 0.0;

    final resultBatch = InventoryBatchEntity(
      id: _isEdit ? widget.batch!.id : 0,
      batchNumber: _batchNumberController.text.trim(),
      inventoryId: _selectedInventoryId!,
      batchSource: _selectedSource,
      batchStatus: _selectedStatus,
      countUnits: countUnits,
      unitCost: unitCost,
      inputDate: _inputDate,
      productionDate: _productionDate,
      expirationDate: _expirationDate,
    );

    Navigator.of(context).pop(resultBatch);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      constraints: BoxConstraints(
        maxWidth: 600,
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withAlpha(240),
                  ]
                : [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: _isLoadingCategories
            ? const AppShimmer(
                child: SizedBox(
                  height: 380,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ShimmerPlaceholder(height: 52),
                      SizedBox(height: 16),
                      ShimmerPlaceholder(height: 52),
                      SizedBox(height: 16),
                      ShimmerPlaceholder(height: 52),
                      SizedBox(height: 16),
                      ShimmerPlaceholder(height: 52),
                      SizedBox(height: 16),
                      ShimmerPlaceholder(height: 52),
                    ],
                  ),
                ),
              )
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          _isEdit
                              ? Icons.edit_calendar_outlined
                              : Icons.playlist_add_outlined,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isEdit ? 'تعديل بيانات الدفعة' : 'إنشاء دفعة جديدة',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // 1. Batch number & Inventory Item selector
                            Row(
                              children: [
                                // Batch Number
                                Expanded(
                                  child: TextFormField(
                                    controller: _batchNumberController,
                                    decoration: const InputDecoration(
                                      labelText: 'رقم/رمز الدفعة',
                                      prefixIcon: Icon(Icons.tag_outlined),
                                    ),
                                    validator: (val) =>
                                        val == null || val.isEmpty
                                        ? 'رقم الدفعة مطلوب'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Inventory Item Select
                                Expanded(
                                  child: ComboBoxForm<InventoryEntity>(
                                    controller: _inventoryItemController,
                                    decoration: const InputDecoration(
                                      labelText: 'صنف المخزون',
                                      prefixIcon: Icon(Icons.inventory_2_outlined),
                                    ),
                                    labelMenu: (item) => _getInventoryName(item),
                                    labelString: (item) => _getInventoryName(item),
                                    itemsBuilder: (value) {
                                      final search = value.trim().toLowerCase();
                                      return widget.inventoryItems.where((item) {
                                        return _getInventoryName(item).toLowerCase().contains(search);
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
                                              _getInventoryName(widget.inventoryItems.firstWhere((item) => item.id == _selectedInventoryId!))) {
                                        setState(() {
                                          _selectedInventoryId = null;
                                        });
                                      }
                                    },
                                    validator: (_) =>
                                        _selectedInventoryId == null ? 'الصنف مطلوب' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 2. Source & Status selectors
                            Row(
                              children: [
                                // Source
                                Expanded(
                                  child: DropdownButtonFormField<BatchSource>(
                                    decoration: const InputDecoration(
                                      labelText: 'مصدر الدفعة',
                                      prefixIcon: Icon(Icons.login_outlined),
                                    ),
                                    initialValue: _selectedSource,
                                    items: BatchSource.values.map((src) {
                                      return DropdownMenuItem<BatchSource>(
                                        value: src,
                                        child: Text(src.displayName()),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedSource = val);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Status
                                Expanded(
                                  child: DropdownButtonFormField<BatchStatus>(
                                    decoration: const InputDecoration(
                                      labelText: 'حالة الدفعة',
                                      prefixIcon: Icon(Icons.check_circle_outline),
                                    ),
                                    initialValue: _selectedStatus,
                                    items: BatchStatus.values.map((stat) {
                                      return DropdownMenuItem<BatchStatus>(
                                        value: stat,
                                        child: Text(stat.displayName()),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedStatus = val);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 3. Count Units & Unit Cost
                            Row(
                              children: [
                                // Count units
                                Expanded(
                                  child: TextFormField(
                                    controller: _countUnitsController,
                                    decoration: const InputDecoration(
                                      labelText: 'كمية الدفعة',
                                      prefixIcon: Icon(Icons.format_list_numbered),
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'مطلوب';
                                      }
                                      if (double.tryParse(val) == null) {
                                        return 'قيمة غير صالحة';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Unit cost
                                Expanded(
                                  child: TextFormField(
                                    controller: _unitCostController,
                                    decoration: const InputDecoration(
                                      labelText: 'تكلفة الوحدة',
                                      prefixIcon: Icon(Icons.attach_money_outlined),
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'مطلوب';
                                      }
                                      if (double.tryParse(val) == null) {
                                        return 'قيمة غير صالحة';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // 4. Dates section (Input, Production, Expiration)
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '📅 تتبع التواريخ والصلاحية',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                // Input Date
                                Expanded(
                                  child: _buildDatePickerButton(
                                    'تاريخ الإدخال',
                                    _inputDate,
                                    () => _selectDate(context, 'input'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Production Date
                                Expanded(
                                  child: _buildDatePickerButton(
                                    'تاريخ الإنتاج (اختياري)',
                                    _productionDate,
                                    () => _selectDate(context, 'production'),
                                    isOptional: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Expiration Date
                                Expanded(
                                  child: _buildDatePickerButton(
                                    'تاريخ الانتهاء (اختياري)',
                                    _expirationDate,
                                    () => _selectDate(context, 'expiration'),
                                    isOptional: true,
                                    accentColor: Colors.red.shade400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 24),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('إلغاء'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.save_outlined),
                          label: Text(_isEdit ? 'حفظ الدفعة' : 'إنشاء الدفعة'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDatePickerButton(
    String label,
    DateTime? date,
    VoidCallback onTap, {
    bool isOptional = false,
    Color? accentColor,
  }) {
    final theme = Theme.of(context);
    final displayStr = date != null
        ? '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
        : (isOptional ? 'غير محدد ──' : 'اختر التاريخ');

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(
          color: accentColor ?? theme.colorScheme.outline.withAlpha(100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withAlpha(120),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayStr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Icon(
                Icons.calendar_today,
                size: 14,
                color: accentColor ?? theme.colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
