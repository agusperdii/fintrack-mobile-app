import '../../models/data_sources/remote_data_source.dart';
import '../../models/repositories/finance_repository.dart';
import '../../controllers/finance_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/ocr_controller.dart';
import '../../models/data_sources/ocr_data_source.dart';
import '../../models/repositories/ocr_repository.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  late final RemoteDataSource remoteDataSource;
  late final FinanceRepository financeRepository;
  late final FinanceController financeController;
  late final AuthController authController;
  late final OcrController ocrController;
  late final OcrRepository ocrRepository;
  late final OcrDataSource ocrDataSource;

  void setup() {
    authController = AuthController();
    remoteDataSource = RemoteDataSourceImpl(authController: authController);
    financeRepository = FinanceRepository(remoteDataSource: remoteDataSource);
    financeController = FinanceController(financeRepository);
    
    // OCR
    ocrDataSource = OcrDataSource();
    ocrRepository = OcrRepository(ocrDataSource);
    ocrController = OcrController(ocrRepository);
  }
}

final sl = ServiceLocator();
