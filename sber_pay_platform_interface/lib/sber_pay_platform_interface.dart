import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sber_pay_platform_interface/types/types.dart';

export 'package:sber_pay_platform_interface/types/types.dart';

abstract class SberPayPlatform extends PlatformInterface {
  SberPayPlatform() : super(token: _token);

  static final Object _token = Object();

  static SberPayPlatform _instance = _PlaceholderImplementation();

  /// Стандартный [instance] текущего класса.
  ///
  /// По умолчанию [_PlaceholderImplementation].
  static SberPayPlatform get instance => _instance;

  /// Имплементация текущего [instance] на определенной платформе.
  ///
  /// В коде платформы должна быть реализована функция, определяющая [instance].
  static set instance(SberPayPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Инициализация SberPay SDK.
  ///
  /// Необходимо выполнить для начала работы с библиотекой.
  ///
  /// * [initConfig] - конфиг инициализации SberPay.
  Future<bool> initSberPay({required SberPayInitConfig initConfig}) {
    throw UnimplementedError('initSberPay() has not been implemented.');
  }

  /// Метод для проверки готовности к оплате.
  ///
  /// Зависит от переданного аргумента *env* при инициализации через метод
  /// [initSberPay] (см. комментарий к методу).
  ///
  /// Если у пользователя нет установленного сбера в режимах
  /// [SberPayEnv.sandboxRealBankApp], [SberPayEnv.prod] - вернет false.
  Future<bool> isReadyForSPaySdk() {
    throw UnimplementedError('isReadyForSPaySdk() has not been implemented.');
  }

  /// Метод оплаты через SberPay SDK.
  ///
  /// * [paymentConfig] - конфиг оплаты SberPay.
  ///
  /// Возвращает статус оплаты [SberPayPaymentStatus].
  Future<SberPayPaymentStatus> payWithBankInvoiceId({
    required SberPayPaymentConfig paymentConfig,
  }) {
    throw UnimplementedError(
      'payWithBankInvoiceId() has not been implemented.',
    );
  }
}

class _PlaceholderImplementation extends SberPayPlatform {}
