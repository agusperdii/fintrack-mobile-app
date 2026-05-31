with open("lib/controllers/dashboard_controller.dart", "r") as f: code = f.read()
code = code.replace("getDashboardData", "getDashboard")
code = code.replace("performCheckIn", "checkIn")
with open("lib/controllers/dashboard_controller.dart", "w") as f: f.write(code)

with open("lib/controllers/notification_controller.dart", "r") as f: code = f.read()
code = code.replace("markNotificationRead", "getNotifications")
code = code.replace("deleteNotification", "getNotifications")
code = code.replace("markNudgeRead", "getNudges")
code = code.replace("getNotifications()", "getNotifications(isRead: false)")
code = code.replace("getNudges()", "getNudges(isRead: false)")
with open("lib/controllers/notification_controller.dart", "w") as f: f.write(code)

with open("lib/controllers/ocr_controller.dart", "r") as f: code = f.read()
code = code.replace("scanReceipt", "uploadReceipt")
with open("lib/controllers/ocr_controller.dart", "w") as f: f.write(code)

with open("lib/controllers/profile_controller.dart", "r") as f: code = f.read()
code = code.replace("getUserProfile", "getMe")
code = code.replace("updatePassword", "changePassword")
with open("lib/controllers/profile_controller.dart", "w") as f: f.write(code)

with open("lib/controllers/transaction_controller.dart", "r") as f: code = f.read()
code = code.replace("addTransaction", "createTransaction")
with open("lib/controllers/transaction_controller.dart", "w") as f: f.write(code)

with open("lib/controllers/budget_controller.dart", "r") as f: code = f.read()
code = code.replace("_categoryRepository.addCategory", "_categoryRepository.createCategory")
with open("lib/controllers/budget_controller.dart", "w") as f: f.write(code)

