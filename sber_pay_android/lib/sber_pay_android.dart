import 'package:flutter/foundation.dart';
import 'package:sber_pay_android/src/messages.g.dart';
import 'package:sber_pay_platform_interface/sber_pay_platform_interface.dart';

class SberPayAndroid extends SberPayPlatform {
  SberPayAndroid({
    @visibleForTesting SberPayApi? api,
  }) : _api = api ?? SberPayApi();

  final SberPayApi _api;

  static void registerWith() => SberPayPlatform.instance = SberPayAndroid();

  @override
  Future<bool> initSberPay({required SberPayInitConfig initConfig}) async {
    final envConfig = switch (initConfig.env) {
      SberPayEnv.sandboxRealBankApp => SberPayApiEnv.sandboxRealBankApp,
      SberPayEnv.sandboxWithoutBankApp => SberPayApiEnv.sandboxWithoutBankApp,
      _ => SberPayApiEnv.prod
    };
    final result = await _api.initSberPay(
      InitConfig(env: envConfig, enableBnpl: initConfig.enableBnpl),
    );

    return result;
  }

  @override
  Future<bool> isReadyForSPaySdk() => _api.isReadyForSPaySdk();

  @override
  Future<SberPayPaymentStatus> payWithBankInvoiceId({
    required SberPayPaymentConfig paymentConfig,
  }) async {
    final result = await _api.payWithBankInvoiceId(
      PayConfig(
        apiKey: paymentConfig.apiKey,
        merchantLogin: paymentConfig.merchantLogin,
        bankInvoiceId: paymentConfig.bankInvoiceId,
        orderNumber: paymentConfig.orderNumber,
      ),
    );

    return switch (result) {
      SberPayApiPaymentStatus.success => SberPayPaymentStatus.success,
      SberPayApiPaymentStatus.processing => SberPayPaymentStatus.processing,
      SberPayApiPaymentStatus.cancel => SberPayPaymentStatus.cancel,
      _ => SberPayPaymentStatus.unknown
    };
  }
}
