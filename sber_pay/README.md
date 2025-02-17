# sber_pay

Плагин для работы с платежным сервисом SberPay.

## Как работать с SDK

Для работы с SberPay SDK необходимо подготовить ваше приложение. Ниже описан процесс интеграции для Android и iOS. В
случае чего, можно посмотреть как все реализовано в `example`. Тестирование на Android проводится на реальном
устройстве.

### Android

Для получения SberPay SDK на стороне Android необходимо создать в папке `android` вашего приложения файл
`sberpay.properties` и в нем указать:

```
sPayUrl=<ссылка на хост из договора>
sPayUsername=<логин из договора>
sPayPassword=<пароль из договора>
```

На этом же уровне в `build.gradle` укажите строки для получения `.aar` бандла:

```
def sberpayProperties = new File('sberpay.properties')
def properties = new Properties()
properties.load(sberpayProperties.newDataInputStream())

def link = properties.getProperty('sPayUrl')
def login = properties.getProperty('sPayUsername')
def pass = properties.getProperty('sPayPassword')

allprojects {
    repositories {
        maven {
            name = "GitHubPackages"
            url = uri(link)
            credentials {
                username = login
                password = pass
            }
        }
    }
}
```

Либо же, можно сразу указать в `maven` секретные данные. Если ваше приложение находится в контроле версий
(например, Github), убедитесь, что репозиторий приватный. Так как бандл и данные для его получения не могут быть
опубликованы по требованию разработчиков Сбера.

Для работы с SberPay SDK рекомендуется версия Android SDK не ниже 24. Для версий ниже методы `initSberPay`,
`isReadyForSPaySdk` и `payWithBankInvoiceId` вернут ошибку.

```
android {
    defaultConfig {
        minSdkVersion 24
    }
}
```

Чтобы повысить шансы успешной оплаты, нужно добавить разрешения к геолокации в `AndroidManifest` вашего приложения:

```
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_UPDATES" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

Для работы с сервисом SberPay в релизе, если у вас включена обфускация необходимо добавить proguard. В
`android/app/build.gradle` по-умолчанию `shrinkResources` и `minifyEnabled` не указаны:

```
android {
    ...
    buildTypes {
        release {
            // shrinkResources и minifyEnabled не указаны, по-умолчанию true, однако лучше указать явно
            shrinkResources true
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

Теперь в `android/app/proguard-rules.pro` добавляем:

```
-keep class spay.sdk.** { *; }

-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

```

Если вам не нужна обфускация, тогда `shrinkResources` и `minifyEnabled` в `android/app/build.gradle` должны быть
`false`:

```
android {
    ...
    buildTypes {
        release {
            shrinkResources false
            minifyEnabled false
        }
    }
}
```

### iOS

Для работы с SberPay SDK рекомендуется версия iOS не ниже 13. Для версий ниже, методы `initSberPay`, `isReadyForSPaySdk`
и `payWithBankInvoiceId` вернут ошибку. Установить минимальную версию можно, выбрав в таргете нужную версию из
настроек Minimum deployments.

Далее следует объявить обратный диплинк с приложения Сбербанка в ваше приложение. Поэтому в `info.plist` отдельно
прописывается диплинк формата `<вашасхема>://spay`. Этот диплинк затем нужно передать разработчикам SDK, чтобы они
авторизовали переход с приложения в Сбербанк (Сбол) и обратно:

```
	<key>CFBundleURLTypes</key>
	<array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>spay</string>
            <key>CFBundleURLSchemes</key>
            <array>
            <string>вашасхема</string>
            </array>
        </dict>
    </array>
```

Также, как и в Android-части, нужно добавить несколько разрешений для повышения шансов успешной оплаты:

```
    <key>DTXAutoStart</key>
    <string>false</string>
    <key>LSApplicationQueriesSchemes</key>
    <array>
       <string>sbolidexternallogin</string>
        <string>sberbankidexternallogin</string>
    </array>
    <key>NSAppTransportSecurity</key>
      <dict>
         <key>NSExceptionDomains</key>
         <dict>
            <key>gate1.spaymentsplus.ru</key>
            <dict>
               <key>NSExceptionAllowsInsecureHTTPLoads</key>
               <true/>
            </dict>
            <key>ift.gate2.spaymentsplus.ru</key>
            <dict>
               <key>NSExceptionAllowsInsecureHTTPLoads</key>
               <true/>
            </dict>
            <key>cms-res.online.sberbank.ru</key>
               <dict>
                   <key>NSExceptionAllowsInsecureHTTPLoads</key>
                   <true/>
               </dict>
         </dict>
      </dict>
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>Данные Bluetooth собираются и отправляются на сервер для безопасного проведения оплаты</string>
    <key>NSBluetoothPeripheralUsageDescription</key>
    <string>Данные Bluetooth собираются и отправляются на сервер для безопасного проведения оплаты</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Данные локации необходимы для безопасного проведения оплаты</string>
```

Также необходимо добавить в Capabilities проекта Access wi-fi information.
Для этого необходимо выбрать: Ваш таргет → Signing & Capabilities → +Capability → Access wi-fi information.

### Если Android SDK ниже 24 или iOS ниже 13

<p align="center">
    <img src="appDemoNotAvailable.png" width="360" height="800"/>
</p>

### Регистрация заказа в шлюзе Сбера

После внедрения на платформы плагин готов к использованию. В `example/lib/main.dart` есть пример реализации.

Для регистрации заказа в шлюзе Сбера должен использоваться ваш бекенд, который во время оформления заказа пошлет запрос
в Сбер:

POST https://3dsec.sberbank.ru/payment/rest/register.do

Где [register.do - одностадийная оплата](https://securepayments.sberbank.ru/wiki/doku.php/start).

Тело:

```
{
  "userName": "testUserName", // логин ЛК Сбера, выдается по договору
  "password": "testPassword", // пароль ЛК Сбера, выдается по договору 
  "orderNumber": "e2574f1785324f1592d9029cb05adbbd", // уникальный номер заказа
  "amount": 19900, // сумма к оплате в копейках
  "returnUrl": "sbersdk://spay", // диплинк на приложение, возвращает к СДК
  "jsonParams": {
    "app2app": true, // Если true, в ответе придет sbolBankInvoiceId
    "app.osType" : "android", // Тип ОС (можно всегда запрашивать с таким)
    "app.deepLink": "sbersdk://spay" // диплинк на приложение, возвращает к СДК
  }
}
```

Пример ответа:

```
{
    "orderId": "1a8fb4ab-fe19-7372-94b6-2deb29335df0",
    "formUrl": "https://secure-payment-gateway.ru/payment/merchants/sbersafe_sberid/payment_ru.html?mdOrder=1a8fb4ab-fe19-7372-94b6-2deb29335df0",
    "externalParams": {
        "sbolInactive": "false",
        "sbolBankInvoiceId": "72e48b040afb4483b0a8c13c77e7e6f2",
        "sbolDeepLink": "sberpay://invoicing/v2?bankInvoiceId=72e48b040afb4483b0a8c13c77e7e6f2&operationType=app2app"
    }
}
```

Мобильное приложение должно получать от бекенда `sbolBankInvoiceId` для совершения оплаты по кнопке SberPay SDK.
Коллбеками, которые Сбер будет отсылать вашему бекенду о состоянии оплаты будет понятно оплачен заказ или нет. На один
заказ приходит только один `sbolBankInvoiceId`, если он применялся, то повторно использоваться не может.

<p align="center">
    <img src="appDemoWithBank.gif" width="360" height="800"/>
</p>


Авторы: [@artembark](https://github.com/artembark), [@petrovyuri](https://github.com/petrovyuri),
[@RonFall](https://github.com/RonFall)