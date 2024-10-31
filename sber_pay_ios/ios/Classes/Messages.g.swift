// Autogenerated from Pigeon (v18.0.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

private func wrapResult(_ result: Any?) -> [Any?] {
  return [result]
}

private func wrapError(_ error: Any) -> [Any?] {
  if let flutterError = error as? FlutterError {
    return [
      flutterError.code,
      flutterError.message,
      flutterError.details,
    ]
  }
  return [
    "\(error)",
    "\(type(of: error))",
    "Stacktrace: \(Thread.callStackSymbols)",
  ]
}

private func isNullish(_ value: Any?) -> Bool {
  return value is NSNull || value == nil
}

private func nilOrValue<T>(_ value: Any?) -> T? {
  if value is NSNull { return nil }
  return value as! T?
}

/// Тип инициализации сервисов Сбербанка
enum SberPayApiEnv: Int {
  /// Продуктовый режим.
  ///
  /// Для авторизации пользователя происходит редирект в приложение Сбербанка.
  case prod = 0
  /// Режим песочницы.
  ///
  /// Позволяет протестировать оплату как в [prod], но с тестовыми данными.
  case sandboxRealBankApp = 1
  /// Режим песочницы без перехода в банк.
  ///
  /// При авторизации пользователя не осуществляется переход в приложение
  /// Сбербанка.
  case sandboxWithoutBankApp = 2
}

/// Статусы оплаты
enum SberPayApiPaymentStatus: Int {
  /// Успешный результат
  case success = 0
  /// Необходимо проверить статус оплаты
  case processing = 1
  /// Пользователь отменил оплату
  case cancel = 2
  /// Неизвестный тип
  case unknown = 3
}

/// Конфигурация инициализации
///
/// Generated class from Pigeon that represents data sent in messages.
struct InitConfig {
  /// Среда запуска
  var env: SberPayApiEnv
  /// Использование функционала оплаты частями
  var enableBnpl: Bool? = nil

  // swift-format-ignore: AlwaysUseLowerCamelCase
  static func fromList(_ __pigeon_list: [Any?]) -> InitConfig? {
    let env = SberPayApiEnv(rawValue: __pigeon_list[0] as! Int)!
    let enableBnpl: Bool? = nilOrValue(__pigeon_list[1])

    return InitConfig(
      env: env,
      enableBnpl: enableBnpl
    )
  }
  func toList() -> [Any?] {
    return [
      env.rawValue,
      enableBnpl,
    ]
  }
}

/// Конфигурация оплаты
///
/// Generated class from Pigeon that represents data sent in messages.
struct PayConfig {
  /// Ключ, выдаваемый по договору, либо создаваемый в личном кабинете
  var apiKey: String
  /// Логин, выдаваемый по договору, либо создаваемый в личном кабинете
  var merchantLogin: String
  /// Уникальный идентификатор заказа, сгенерированный Банком
  var bankInvoiceId: String
  /// Диплинк для перехода обратно в приложение после открытия Сбербанка
  var redirectUri: String
  /// Номер заказа
  var orderNumber: String

  // swift-format-ignore: AlwaysUseLowerCamelCase
  static func fromList(_ __pigeon_list: [Any?]) -> PayConfig? {
    let apiKey = __pigeon_list[0] as! String
    let merchantLogin = __pigeon_list[1] as! String
    let bankInvoiceId = __pigeon_list[2] as! String
    let redirectUri = __pigeon_list[3] as! String
    let orderNumber = __pigeon_list[4] as! String

    return PayConfig(
      apiKey: apiKey,
      merchantLogin: merchantLogin,
      bankInvoiceId: bankInvoiceId,
      redirectUri: redirectUri,
      orderNumber: orderNumber
    )
  }
  func toList() -> [Any?] {
    return [
      apiKey,
      merchantLogin,
      bankInvoiceId,
      redirectUri,
      orderNumber,
    ]
  }
}

private class SberPayApiCodecReader: FlutterStandardReader {
  override func readValue(ofType type: UInt8) -> Any? {
    switch type {
    case 128:
      return InitConfig.fromList(self.readValue() as! [Any?])
    case 129:
      return PayConfig.fromList(self.readValue() as! [Any?])
    default:
      return super.readValue(ofType: type)
    }
  }
}

private class SberPayApiCodecWriter: FlutterStandardWriter {
  override func writeValue(_ value: Any) {
    if let value = value as? InitConfig {
      super.writeByte(128)
      super.writeValue(value.toList())
    } else if let value = value as? PayConfig {
      super.writeByte(129)
      super.writeValue(value.toList())
    } else {
      super.writeValue(value)
    }
  }
}

private class SberPayApiCodecReaderWriter: FlutterStandardReaderWriter {
  override func reader(with data: Data) -> FlutterStandardReader {
    return SberPayApiCodecReader(data: data)
  }

  override func writer(with data: NSMutableData) -> FlutterStandardWriter {
    return SberPayApiCodecWriter(data: data)
  }
}

class SberPayApiCodec: FlutterStandardMessageCodec {
  static let shared = SberPayApiCodec(readerWriter: SberPayApiCodecReaderWriter())
}

/// Generated protocol from Pigeon that represents a handler of messages from Flutter.
protocol SberPayApi {
  func initSberPay(config: InitConfig, completion: @escaping (Result<Bool, Error>) -> Void)
  func isReadyForSPaySdk() throws -> Bool
  func payWithBankInvoiceId(config: PayConfig, completion: @escaping (Result<SberPayApiPaymentStatus, Error>) -> Void)
}

/// Generated setup class from Pigeon to handle messages through the `binaryMessenger`.
class SberPayApiSetup {
  /// The codec used by SberPayApi.
  static var codec: FlutterStandardMessageCodec { SberPayApiCodec.shared }
  /// Sets up an instance of `SberPayApi` to handle messages through the `binaryMessenger`.
  static func setUp(binaryMessenger: FlutterBinaryMessenger, api: SberPayApi?, messageChannelSuffix: String = "") {
    let channelSuffix = messageChannelSuffix.count > 0 ? ".\(messageChannelSuffix)" : ""
    let initSberPayChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.sber_pay_ios.SberPayApi.initSberPay\(channelSuffix)", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      initSberPayChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let configArg = args[0] as! InitConfig
        api.initSberPay(config: configArg) { result in
          switch result {
          case .success(let res):
            reply(wrapResult(res))
          case .failure(let error):
            reply(wrapError(error))
          }
        }
      }
    } else {
      initSberPayChannel.setMessageHandler(nil)
    }
    let isReadyForSPaySdkChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.sber_pay_ios.SberPayApi.isReadyForSPaySdk\(channelSuffix)", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      isReadyForSPaySdkChannel.setMessageHandler { _, reply in
        do {
          let result = try api.isReadyForSPaySdk()
          reply(wrapResult(result))
        } catch {
          reply(wrapError(error))
        }
      }
    } else {
      isReadyForSPaySdkChannel.setMessageHandler(nil)
    }
    let payWithBankInvoiceIdChannel = FlutterBasicMessageChannel(name: "dev.flutter.pigeon.sber_pay_ios.SberPayApi.payWithBankInvoiceId\(channelSuffix)", binaryMessenger: binaryMessenger, codec: codec)
    if let api = api {
      payWithBankInvoiceIdChannel.setMessageHandler { message, reply in
        let args = message as! [Any?]
        let configArg = args[0] as! PayConfig
        api.payWithBankInvoiceId(config: configArg) { result in
          switch result {
          case .success(let res):
            reply(wrapResult(res.rawValue))
          case .failure(let error):
            reply(wrapError(error))
          }
        }
      }
    } else {
      payWithBankInvoiceIdChannel.setMessageHandler(nil)
    }
  }
}
