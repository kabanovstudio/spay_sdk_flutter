import Flutter
import UIKit
import SPaySdk

// This extension of Error is required to do use FlutterError in any Swift code.
extension FlutterError: Error {}

/**
 * Плагин для оплаты с использованием SberPay. Для работы нужен установленный Сбербанк (либо Сбол).
 */
public class SberPayPlugin: NSObject, FlutterPlugin, SberPayApi{
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger : FlutterBinaryMessenger = registrar.messenger()
        let instance = SberPayPlugin()
        SberPayApiSetup.setUp(binaryMessenger: messenger, api: instance)
        
        /// Создание [addApplicationDelegate] для перехода по диплинку обратно в приложение
        registrar.addApplicationDelegate(instance)
    }
    
    public func application(_ app: UIApplication,open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        /// Если при открытии приложения с диплинком если он содержит хост "spay", то такой диплинк
        /// попадает в нативный плагин. Таким образом работает возврат в приложение и получение данных нативным
        /// SDK от приложения Сбербанк онлайн/СБОЛ
        if  url.host == "spay" {
            SPay.getAuthURL(url)
        }
        
        return true
    }
    
    /**
     Метод инициализации, выполняется перед стартом приложения.
     - Parameter InitConfig конфигурация инициализации
     */
    internal func initSberPay(config: InitConfig, completion: @escaping (Result<Bool, any Error>) -> Void) {
        onApiVersiobCheck(onError: completion) {
            let env = config.env
            let enableBnpl = config.enableBnpl ?? false
            
            let sPayStage: SEnvironment
            switch env {
            case SberPayApiEnv.sandboxRealBankApp:
                sPayStage = .sandboxRealBankApp
            case SberPayApiEnv.sandboxWithoutBankApp:
                sPayStage = .sandboxWithoutBankApp
            default:
                sPayStage = .prod
            }
            
            SPay.setup(bnplPlan: enableBnpl, environment: sPayStage) { error in
                if let error {
                    completion(.failure(FlutterError(code: "-", message: "Ошибка инициализации", details: error.description)))
                } else {
                    completion(.success(true))
                }
            }
        }
    }
    
    /**
     Метод для проверки готовности к оплате.
     
     - Returns Если у пользователя нет установленного сбера в режимах SEnvironment.sandboxRealBankApp,
     SEnvironment.prod - вернет false.
     */
    internal func isReadyForSPaySdk() throws -> Bool {
        return try onApiVersiobCheck() {
            return SPay.isReadyForSPay
        }
    }
    
    /**
     Метод для оплаты.
     - Parameter PayConfig конфигурация оплаты
     - Returns SberPayApiPaymentStatus статус оплаты
     */
    internal func payWithBankInvoiceId(config: PayConfig, completion: @escaping (Result<SberPayApiPaymentStatus, Error>) -> Void) {
        onApiVersiobCheck(onError: completion) {
            if config.bankInvoiceId.count != 32 {
                completion(.failure(FlutterError(code: "-", message: "MerchantError", details: "Длина bankInvoiceId должна быть 32 символа")))
            }
            
            guard let topController = self.getTopViewController() else {
                completion(.failure(FlutterError(code: "PluginError", message: "SberPay: Failed to implement controller", details: nil)))
                return
            }
            
            let request = SBankInvoicePaymentRequest(
                merchantLogin: config.merchantLogin,
                bankInvoiceId: config.bankInvoiceId,
                orderNumber: config.orderNumber,
                language: "RU",
                redirectUri: config.redirectUri,
                apiKey: config.apiKey)
            
            SPay.payWithBankInvoiceId(with: topController, paymentRequest: request) { state, info, localSessionId  in
                switch state {
                case .success:
                    completion(.success(SberPayApiPaymentStatus.success))
                case .waiting:
                    completion(.success(SberPayApiPaymentStatus.processing))
                case .cancel:
                    completion(.success(SberPayApiPaymentStatus.cancel))
                case .error:
                    completion(.failure(FlutterError(code: "-", message: "Ошибка оплаты", details: info)))
                @unknown default:
                    completion(.failure(FlutterError(code: "-", message: "Неопределенная ошибка", details: info)))
                }
            }
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        var topController = UIWindow.window?.rootViewController
        
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
    }
    
    private func onApiVersiobCheck<T>(onSuccess: @escaping () -> T)  throws -> T {
        if #unavailable(iOS 13.0) {
            throw FlutterError(code: "NOT_SUPPORTED", message: "iOS API Error", details: "Your iOS version < 13")
        }
        
        return onSuccess()
    }
    
    private func onApiVersiobCheck<T>(onError: @escaping (Result<T, Error>) -> Void, onSuccess: @escaping () -> Void) {
        if #unavailable(iOS 13.0) {
            onError(.failure(FlutterError(code: "NOT_SUPPORTED", message: "iOS API Error", details: "Your iOS version < 13")))
            
            return
        }
        
        onSuccess()
    }
}

extension UIWindow {
    static var window: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
