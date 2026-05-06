import 'package:savaio/core/network/api_client.dart';
import 'package:savaio/repositories/data_sources/remote/auth_remote_data_source.dart';
import 'package:savaio/repositories/data_sources/remote/transaction_remote_data_source.dart';
import 'package:savaio/repositories/data_sources/remote/budget_remote_data_source.dart';
import 'package:savaio/repositories/data_sources/remote/analytics_remote_data_source.dart';
import 'package:savaio/repositories/data_sources/remote/dashboard_remote_data_source.dart';
import 'package:savaio/repositories/data_sources/remote/category_remote_data_source.dart';

// Domain Repositories
import 'package:savaio/repositories/transaction_repository.dart';
import 'package:savaio/repositories/notification_repository.dart';
import 'package:savaio/repositories/dashboard_repository.dart';
import 'package:savaio/repositories/budget_repository.dart';
import 'package:savaio/repositories/profile_repository.dart';
import 'package:savaio/repositories/analytics_repository.dart';
import 'package:savaio/repositories/category_repository.dart';

// Domain Controllers
import 'package:savaio/controllers/transaction_controller.dart';
import 'package:savaio/controllers/notification_controller.dart';
import 'package:savaio/controllers/dashboard_controller.dart';
import 'package:savaio/controllers/budget_controller.dart';
import 'package:savaio/controllers/profile_controller.dart';
import 'package:savaio/controllers/analytics_controller.dart';
import 'package:savaio/services/analytics_service.dart';

import 'package:savaio/controllers/auth_controller.dart';
import 'package:savaio/controllers/ocr_controller.dart';
import 'package:savaio/repositories/data_sources/ocr_data_source.dart';
import 'package:savaio/repositories/ocr_repository.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final ApiClient apiClient;
  
  late final AuthRemoteDataSource authRemoteDataSource;
  late final TransactionRemoteDataSource transactionRemoteDataSource;
  late final BudgetRemoteDataSource budgetRemoteDataSource;
  late final AnalyticsRemoteDataSource analyticsRemoteDataSource;
  late final DashboardRemoteDataSource dashboardRemoteDataSource;
  late final CategoryRemoteDataSource categoryRemoteDataSource;

  // Domain Repositories
  late final TransactionRepository transactionRepository;
  late final NotificationRepository notificationRepository;
  late final DashboardRepository dashboardRepository;
  late final BudgetRepository budgetRepository;
  late final ProfileRepository profileRepository;
  late final AnalyticsRepository analyticsRepository;
  late final CategoryRepository categoryRepository;

  // Domain Controllers
  late final TransactionController transactionController;
  late final NotificationController notificationController;
  late final DashboardController dashboardController;
  late final BudgetController budgetController;
  late final ProfileController profileController;
  late final AnalyticsController analyticsController;
  late final AnalyticsService analyticsService;
  
  late final AuthController authController;
  late final OcrController ocrController;
  late final OcrRepository ocrRepository;
  late final OcrDataSource ocrDataSource;

  void setup() {
    authController = AuthController();
    
    apiClient = ApiClient(authController: authController);

    authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
    transactionRemoteDataSource = TransactionRemoteDataSourceImpl(apiClient: apiClient);
    budgetRemoteDataSource = BudgetRemoteDataSourceImpl(apiClient: apiClient);
    analyticsRemoteDataSource = AnalyticsRemoteDataSourceImpl(apiClient: apiClient);
    dashboardRemoteDataSource = DashboardRemoteDataSourceImpl(apiClient: apiClient);
    categoryRemoteDataSource = CategoryRemoteDataSourceImpl(apiClient: apiClient);

    // Initialize Domain Repositories
    transactionRepository = TransactionRepository(transactionRemoteDataSource);
    notificationRepository = NotificationRepository(dashboardRemoteDataSource);
    dashboardRepository = DashboardRepository(dashboardRemoteDataSource);
    budgetRepository = BudgetRepository(budgetRemoteDataSource);
    profileRepository = ProfileRepository(authRemoteDataSource);
    analyticsRepository = AnalyticsRepository(analyticsRemoteDataSource);
    categoryRepository = CategoryRepository(categoryRemoteDataSource);

    // Initialize Domain Controllers
    transactionController = TransactionController(transactionRepository);
    notificationController = NotificationController(notificationRepository);
    dashboardController = DashboardController(dashboardRepository);
    budgetController = BudgetController(budgetRepository, categoryRepository);
    profileController = ProfileController(profileRepository);
    analyticsService = AnalyticsService();
    analyticsController = AnalyticsController(analyticsRepository, analyticsService);

    // Inject repository into AuthController for sync
    authController.setProfileRepository(profileRepository);

    // OCR
    ocrDataSource = OcrDataSource();
    ocrRepository = OcrRepository(ocrDataSource);
    ocrController = OcrController(ocrRepository);
  }
}

final sl = ServiceLocator();
