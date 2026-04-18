import '../../data/data_sources/remote_data_source.dart';
import '../../data/repositories/finance_repository.dart';
import '../../presentation/providers/finance_provider.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final RemoteDataSource remoteDataSource;
  late final FinanceRepository financeRepository;
  late final FinanceProvider financeProvider;

  void setup() {
    remoteDataSource = RemoteDataSourceImpl();
    financeRepository = FinanceRepository(remoteDataSource: remoteDataSource);
    financeProvider = FinanceProvider(financeRepository);
  }
}

final sl = ServiceLocator();
