import re

def rep(fpath, changes):
    try:
        with open(fpath, "r") as f: code = f.read()
        for old, new in changes:
            code = code.replace(old, new)
        with open(fpath, "w") as f: f.write(code)
    except Exception as e:
        pass

rep('lib/repositories/dashboard_repository.dart', 'Future<bool> checkIn', 'Future<CheckInStatus> checkIn')
rep('lib/repositories/data_sources/ocr_data_source.dart', 'return _client.getStoredToken()', 'return _apiClient.getStoredToken()')
rep('lib/repositories/ocr_repository.dart', 'return _remoteDataSource.uploadReceipt(file);', 'final result = await _remoteDataSource.uploadReceipt(file);\n    return result;')
rep('lib/repositories/ocr_repository.dart', 'Future<Map<String, dynamic>> uploadReceipt', 'Future<OcrResult> uploadReceipt')

rep('lib/services/analytics_service.dart', 'b.isBudgetExists', 'true')

rep('lib/views/components/molecules/app_transaction_item.dart', 'transaction.category', 'transaction.categoryId')
rep('lib/views/components/molecules/app_transaction_item.dart', 'date: transaction.date,', 'date: transaction.date.toIso8601String(),')

rep('lib/views/components/molecules/daily_checkin_card.dart', 'performCheckIn', 'checkIn')
rep('lib/views/pages/add_transaction_page.dart', 'addTransactionOptimistic', 'createTransactionOptimistic')

rep('lib/views/pages/all_transactions_page.dart', 'date.startsWith', 'date.toIso8601String().startsWith')
rep('lib/views/pages/all_transactions_page.dart', 'date.substring', 'date.toIso8601String().substring')
rep('lib/views/pages/all_transactions_page.dart', 'date.length', 'date.toIso8601String().length')
rep('lib/views/pages/all_transactions_page.dart', 'a.date.compareTo(b.date)', '(a.date).compareTo(b.date)')
rep('lib/views/pages/all_transactions_page.dart', 'date: selectedDate', 'date: selectedDate.toIso8601String()')

rep('lib/views/pages/dashboard_page.dart', 'userProfile!.name', 'userProfile!.fullName')

rep('lib/views/pages/ocr_scan_page.dart', 'result.merchantName', "result.parsedData['merchantName']")
rep('lib/views/pages/ocr_scan_page.dart', 'result.transactionDate', "result.parsedData['date']")
rep('lib/views/pages/ocr_scan_page.dart', 'result.totalAmount', "result.parsedData['amount']")
rep('lib/views/pages/ocr_scan_page.dart', 'result.lineItems', '[]')

rep('lib/views/pages/register_page.dart', "authController.register(fullNameController.text, emailController.text);", "authController.register(fullNameController.text, emailController.text, passwordController.text);")

rep('lib/views/pages/spending_target_page.dart', 'target.periodType?.toLowerCase()', "'monthly'")
rep('lib/views/pages/spending_target_page.dart', 'target.month', 'target.startMonth')
rep('lib/views/pages/spending_target_page.dart', "periodType: 'monthly',", "")
rep('lib/views/pages/spending_target_page.dart', "month: DateTime.now().toIso8601String().substring(0, 7),", "startMonth: DateTime.now().toIso8601String().substring(0, 7),")
rep('lib/views/pages/spending_target_page.dart', 'category: null,', 'categoryId: null,')
rep('lib/views/pages/spending_target_page.dart', "budgetController.updateSpendingTargetOptimistic(target.amount);", "budgetController.updateSpendingTargetOptimistic(target.amount, categoryId: null, startMonth: null);")

rep('lib/views/pages/transaction_detail_page.dart', 'category: transaction.category', 'categoryId: transaction.categoryId')
rep('lib/views/pages/transaction_detail_page.dart', 'date: transaction.date', 'date: transaction.date.toIso8601String()')
