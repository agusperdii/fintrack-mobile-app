#!/bin/bash
sed -i '' 's/b.categoryKey/b.categoryId/g' lib/controllers/budget_controller.dart
sed -i '' 's/b.month/b.startMonth/g' lib/controllers/budget_controller.dart
sed -i '' 's/item.month/item.startMonth/g' lib/controllers/budget_controller.dart
sed -i '' 's/item.categoryKey/item.categoryId/g' lib/controllers/budget_controller.dart
sed -i '' 's/b.isBudgetExists/true/g' lib/controllers/budget_controller.dart
sed -i '' 's/month:/startMonth:/g' lib/controllers/budget_controller.dart
sed -i '' 's/periodType: periodType,//g' lib/controllers/budget_controller.dart
sed -i '' 's/category:/categoryId:/g' lib/controllers/budget_controller.dart
sed -i '' 's/item.periodType,//g' lib/controllers/budget_controller.dart
sed -i '' 's/item.isBudgetExists/true/g' lib/controllers/budget_controller.dart
