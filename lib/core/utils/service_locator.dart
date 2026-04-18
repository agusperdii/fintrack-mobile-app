import '../../data/data_sources/remote_data_source.dart';
import '../../data/repositories/finance_repository.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final RemoteDataSource remoteDataSource;
  late final FinanceRepository financeRepository;

  void setup() {
    remoteDataSource = RemoteDataSourceImpl();
    financeRepository = FinanceRepository(remoteDataSource: remoteDataSource);
  }
}

final sl = ServiceLocator();
