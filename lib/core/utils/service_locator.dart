import '../../models/data_sources/remote_data_source.dart';
import '../../models/repositories/finance_repository.dart';
import '../../controllers/finance_controller.dart';
import '../../controllers/auth_controller.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final RemoteDataSource remoteDataSource;
  late final FinanceRepository financeRepository;
  late final FinanceController financeController;
  late final AuthController authController;

  void setup() {
    authController = AuthController();
    remoteDataSource = RemoteDataSourceImpl(authController: authController);
    financeRepository = FinanceRepository(remoteDataSource: remoteDataSource);
    financeController = FinanceController(financeRepository);
  }
}

final sl = ServiceLocator();
