import '../../models/data_sources/remote_data_source.dart';
import '../../models/repositories/finance_repository.dart';
import '../../controllers/finance_controller.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final RemoteDataSource remoteDataSource;
  late final FinanceRepository financeRepository;
  late final FinanceController financeController;

  void setup() {
    remoteDataSource = RemoteDataSourceImpl();
    financeRepository = FinanceRepository(remoteDataSource: remoteDataSource);
    financeController = FinanceController(financeRepository);
  }
}

final sl = ServiceLocator();
