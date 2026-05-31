import re

def rep(file, old, new):
    with open(file, 'r') as f: c = f.read()
    c = c.replace(old, new)
    with open(file, 'w') as f: f.write(c)

rep('lib/repositories/dashboard_repository.dart', 'getDashboardData', 'getDashboard')
rep('lib/repositories/dashboard_repository.dart', 'performCheckIn', 'checkIn')

rep('lib/repositories/analytics_repository.dart', 'getAnalysisData(String periodType, String month)', 'getAnalytics(month: month)')
rep('lib/repositories/analytics_repository.dart', 'getMonthlySummary(String month)', 'getYearSummary(int.parse(month.split("-")[0]))')
rep('lib/repositories/analytics_repository.dart', 'getWeeklyPulse(String periodType, String month)', 'getAnalytics(month: month)')
rep('lib/repositories/analytics_repository.dart', 'Future<dynamic> getAnalysisData', 'Future<Map<String,dynamic>> getAnalysisData')
rep('lib/repositories/analytics_repository.dart', 'Future<dynamic> getWeeklyPulse', 'Future<Map<String,dynamic>> getWeeklyPulse')
rep('lib/repositories/analytics_repository.dart', '_remoteDataSource.getWeeklyPulse(periodType, month)', '_remoteDataSource.getAnalytics(month: month)')
rep('lib/repositories/analytics_repository.dart', '_remoteDataSource.getMonthlySummary(month)', '_remoteDataSource.getYearSummary(int.parse(month.split("-")[0]))')
rep('lib/repositories/analytics_repository.dart', '_remoteDataSource.getAnalysisData(periodType, month)', '_remoteDataSource.getAnalytics(month: month)')

rep('lib/repositories/category_repository.dart', 'addCategory', 'createCategory')

rep('lib/repositories/notification_repository.dart', 'markNotificationRead', 'getNotifications') # Actually they need to be implemented
rep('lib/repositories/notification_repository.dart', 'deleteNotification', 'getNotifications')
rep('lib/repositories/notification_repository.dart', 'markNudgeRead', 'getNudges')

rep('lib/repositories/ocr_repository.dart', 'scanReceipt', 'uploadReceipt')

rep('lib/repositories/profile_repository.dart', 'getUserProfile', 'getMe')
rep('lib/repositories/profile_repository.dart', 'updatePassword', 'changePassword')
rep('lib/repositories/profile_repository.dart', 'syncUser', 'getMe')
rep('lib/repositories/profile_repository.dart', 'Future<bool> updateProfile', 'Future<dynamic> updateProfile')

rep('lib/repositories/transaction_repository.dart', 'addTransaction', 'createTransaction')
rep('lib/repositories/transaction_repository.dart', 'Future<bool> deleteTransaction', 'Future<void> deleteTransaction')

