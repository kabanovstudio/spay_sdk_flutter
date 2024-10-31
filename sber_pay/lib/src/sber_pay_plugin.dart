import 'package:sber_pay_platform_interface/sber_pay_platform_interface.dart';

/// Плагин для отображения нативной кнопки SberPay SDK
///
/// Все исключения (Exceptions) приходящие из методов этого класса должны
/// обрабатываться уровнем выше.
class SberPayPlugin {
  static SberPayPlatform get _platform => SberPayPlatform.instance;

  /// Инициализация SberPay SDK.
  ///
  /// Необходимо выполнить для начала работы с библиотекой.
  ///
  /// * [initConfig] - конфиг инициализации SberPay.
  static Future<bool> initSberPay({
    required SberPayInitConfig initConfig,
  }) async {
    return _platform.initSberPay(initConfig: initConfig);
  }

  /// Метод для проверки готовности к оплате.
  ///
  /// Зависит от переданного аргумента *env* при инициализации через метод
  /// [initSberPay] (см. комментарий к методу).
  ///
  /// Если у пользователя нет установленного сбера в режимах
  /// [SberPayEnv.sandboxRealBankApp], [SberPayEnv.prod] - вернет false.
  static Future<bool> isReadyForSPaySdk() async {
    return _platform.isReadyForSPaySdk();
  }

  /// Метод оплаты через SberPay SDK.
  ///
  /// * [paymentConfig] - конфиг оплаты SberPay.
  ///
  /// Возвращает статус оплаты [SberPayPaymentStatus].
  static Future<SberPayPaymentStatus> payWithBankInvoiceId({
    required SberPayPaymentConfig paymentConfig,
  }) async {
    return _platform.payWithBankInvoiceId(paymentConfig: paymentConfig);
  }
}
