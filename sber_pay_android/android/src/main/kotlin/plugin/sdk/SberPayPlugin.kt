package plugin.sdk

import FlutterError
import InitConfig
import PayConfig
import SberPayApi
import SberPayApiEnv
import SberPayApiPaymentStatus
import android.app.Activity
import android.content.Context
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import spay.sdk.SPaySdkApp
import spay.sdk.api.InitializationResult
import spay.sdk.api.PaymentResult
import spay.sdk.api.SPaySdkInitConfig
import spay.sdk.api.SPayStage

/**
 * Плагин для оплаты с использованием SberPay. Для работы нужен установленный Сбербанк (либо Сбол).
 */
class SberPayPlugin : FlutterPlugin, ActivityAware, SberPayApi {

    private lateinit var activity: Activity
    private lateinit var context: Context
    private lateinit var sberPayInstance: SPaySdkApp

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        sberPayInstance = SPaySdkApp.getInstance()
        SberPayApi.setUp(flutterPluginBinding.binaryMessenger, this)
    }

    /**
     * Метод инициализации, выполняется перед стартом приложения.
     *
     * @property InitConfig конфигурация инициализации
     */
    override fun initSberPay(config: InitConfig, callback: (Result<Boolean>) -> Unit) {
        onApiVersionCheck(callback = callback) {
            val sPayStage = when (config.env) {
                SberPayApiEnv.SANDBOX_REAL_BANK_APP -> SPayStage.SandboxRealBankApp
                SberPayApiEnv.SANDBOX_WITHOUT_BANK_APP -> SPayStage.SandBoxWithoutBankApp
                else -> SPayStage.Prod
            }
            val enableBnpl = config.enableBnpl ?: false

            try {
                val sPayConfig = SPaySdkInitConfig(
                    application = activity.application,
                    stage = sPayStage,
                    enableBnpl = enableBnpl
                ) { result: InitializationResult ->
                    when (result) {
                        is InitializationResult.ConfigError -> callback(Result.success(false))
                        InitializationResult.Success -> callback(Result.success(true))
                    }
                }
                sberPayInstance.initialize(sPayConfig)
            } catch (e: Exception) {
                callback(Result.failure(FlutterError("-", e.localizedMessage, e.message)))
            }
        }


    }

    /**
     * Метод для проверки готовности к оплате.
     *
     * @return Если у пользователя нет установленного сбера в режимах
     * SPayStage.SandboxRealBankApp, SPayStage.prod - вернет false.
     */
    override fun isReadyForSPaySdk(): Boolean {
        return onApiVersionCheck { return@onApiVersionCheck sberPayInstance.isReadyForSPaySdk(context) }
    }

    /**
     * Метод для оплаты.
     *
     * @property PayConfig конфигурация оплаты
     * @return SberPayApiPaymentStatus статус оплаты
     */
    override fun payWithBankInvoiceId(config: PayConfig, callback: (Result<SberPayApiPaymentStatus>) -> Unit) {
        onApiVersionCheck(callback) {
            var hasEventSent = false // Флаг для отслеживания отправки события

            try {
                val appPackage = context.packageName
                // Пока поддержка только русского языка
                val language = "RU"

                sberPayInstance.payWithBankInvoiceId(
                    activity,
                    config.apiKey,
                    config.merchantLogin,
                    config.bankInvoiceId,
                    config.bankInvoiceId,
                    appPackage,
                    language
                ) { response ->
                    if (!hasEventSent) {
                        when (response) {
                            // Оплата не завершена
                            is PaymentResult.Processing -> callback(Result.success(SberPayApiPaymentStatus.PROCESSING))
                            // Оплата прошла успешно
                            is PaymentResult.Success -> callback(Result.success(SberPayApiPaymentStatus.SUCCESS))
                            // Оплата отменена
                            is PaymentResult.Cancel -> callback(Result.success(SberPayApiPaymentStatus.CANCEL))
                            // Оплата прошла с ошибкой
                            is PaymentResult.Error -> callback(
                                Result.failure(
                                    FlutterError(
                                        "-", "MerchantError", response.merchantError?.description
                                            ?: "Ошибка выполнения оплаты"
                                    )
                                )
                            )
                        }
                    }
                    hasEventSent = true
                }
            } catch (error: Exception) {
                callback(Result.failure(FlutterError("-", error.localizedMessage, error.message)))
            }
        }
    }

    private fun <T> onApiVersionCheck(callback: (Result<T>) -> Unit, successCallback: () -> Unit) {
        // Минимальная версия Android для SberPay SDK - 24
        if (Build.VERSION.SDK_INT < 24) {
            callback(Result.failure(FlutterError("NOT_SUPPORTED", "Android API Error", "Your app SDK < 24")))

            return
        }

        successCallback()
    }

    private fun <T> onApiVersionCheck(successCallback: () -> T): T {
        // Минимальная версия Android для SberPay SDK - 24
        if (Build.VERSION.SDK_INT < 24) {
            throw FlutterError("NOT_SUPPORTED", "Android API Error", "Your app SDK < 24")
        }

        return successCallback()
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        SberPayApi.setUp(binding.binaryMessenger, null)
    }

    override fun onAttachedToActivity(activityBinding: ActivityPluginBinding) {
        activity = activityBinding.activity
    }

    override fun onReattachedToActivityForConfigChanges(activityBinding: ActivityPluginBinding) {
        activity = activityBinding.activity
    }

    override fun onDetachedFromActivity() {}

    override fun onDetachedFromActivityForConfigChanges() {}
}
