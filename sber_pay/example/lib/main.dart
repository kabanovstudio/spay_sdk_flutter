import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sber_pay/sber_pay.dart';

/// Необходимо указать по данным из договора
const _apiKey = '';
const _merchantLogin = '';

/// Диплинк на переход в приложение
const _redirectUri = 'sbersdk://spay';

void main() => runApp(const SberPayExampleApp());

class SberPayExampleApp extends StatefulWidget {
  const SberPayExampleApp({super.key});

  @override
  State<SberPayExampleApp> createState() => _SberPayExampleAppState();
}

class _SberPayExampleAppState extends State<SberPayExampleApp> {
  late final TextEditingController _invoiceIdController;
  late final TextEditingController _orderNumberController;
  late String _paymentStatus;
  late bool _isPluginLoading;
  late bool _isAppReadyForPay;
  late bool _isPluginInitialized;
  late SberPayEnv _selectedInitType;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _invoiceIdController = TextEditingController();
    _orderNumberController = TextEditingController();
    _paymentStatus = '';
    _selectedInitType = SberPayEnv.sandboxWithoutBankApp;
    _isPluginLoading = false;
    _isAppReadyForPay = false;
    _isPluginInitialized = false;
    _color = Colors.grey;
    _readyForPay();
  }

  Future<void> _readyForPay() async {
    setState(() => _isPluginLoading = true);

    try {
      _isPluginInitialized = await SberPayPlugin.initSberPay(
        initConfig: SberPayInitConfig(env: _selectedInitType),
      );
    } catch (e) {
      _isPluginInitialized = false;
    }

    if (mounted) setState(() {});

    try {
      _isAppReadyForPay = await SberPayPlugin.isReadyForSPaySdk();
    } catch (e) {
      _isAppReadyForPay = false;
    }
    if (mounted) setState(() => _isPluginLoading = false);
  }

  void _setEnv(SberPayEnv env) {
    _selectedInitType = env;
    _paymentStatus = '';
    _color = Colors.grey;
    _readyForPay();
  }

  @override
  void dispose() {
    _invoiceIdController.dispose();
    _orderNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF21A038)),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SberPay plugin example'),
          backgroundColor: const Color(0xFF21A038),
          centerTitle: true,
        ),
        body: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Table(
                        border: TableBorder.all(),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          _tableRowWrapper(
                            'Тип запуска',
                            Column(
                              children: [
                                ChoiceChip(
                                  label: const Text('Прод'),
                                  selected:
                                      _selectedInitType == SberPayEnv.prod,
                                  onSelected: (_) => _setEnv(SberPayEnv.prod),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ChoiceChip(
                                  label: const Text('Песочница/Банк'),
                                  selected: _selectedInitType ==
                                      SberPayEnv.sandboxRealBankApp,
                                  onSelected: (_) => _setEnv(
                                    SberPayEnv.sandboxRealBankApp,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ChoiceChip(
                                  label: const Text('Песочница'),
                                  selected: _selectedInitType ==
                                      SberPayEnv.sandboxWithoutBankApp,
                                  onSelected: (_) => _setEnv(
                                    SberPayEnv.sandboxWithoutBankApp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _tableRowWrapper(
                            'Плагин проинициализирован',
                            Text(_isPluginLoading
                                ? 'Загрузка'
                                : _isPluginInitialized
                                    ? "ДА"
                                    : "НЕТ"),
                          ),
                          _tableRowWrapper(
                            'Оплата доступна',
                            Text(_isPluginLoading
                                ? 'Загрузка'
                                : _isAppReadyForPay
                                    ? "ДА"
                                    : "НЕТ"),
                          ),
                          _tableRowWrapper(
                            'Статус операции оплаты',
                            SizedBox(
                              height: 80,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: _color,
                                    radius: 10.0,
                                  ),
                                  Flexible(
                                    child: Text(
                                      _paymentStatus.isEmpty
                                          ? "Оплата не производилась"
                                          : _paymentStatus,
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ]),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _invoiceIdController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Введите bankInvoiceID',
                          suffixIcon: GestureDetector(
                            onTap: () {
                              _invoiceIdController.clear();
                              _color = Colors.grey;
                              setState(() => _paymentStatus = '');
                            },
                            child: const Icon(Icons.close, size: 32),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _orderNumberController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Введите orderNumber',
                          suffixIcon: GestureDetector(
                            onTap: () {
                              _orderNumberController.clear();
                            },
                            child: const Icon(Icons.close, size: 32),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Builder(
                        builder: (context) {
                          if (_isPluginLoading) {
                            return Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF21A038),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }

                          if (_isPluginInitialized) {
                            return SberPayButton(
                              onPressed: () async {
                                if (_apiKey.isEmpty || _merchantLogin.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Не заданы apiKey и/или merchantLogin',
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }
                                if (_invoiceIdController.text.trim().isEmpty ||
                                    _orderNumberController.text
                                        .trim()
                                        .isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Введите bankInvoiceID и/или orderNumber',
                                      ),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  try {
                                    final result = await SberPayPlugin
                                        .payWithBankInvoiceId(
                                      paymentConfig: SberPayPaymentConfig(
                                        apiKey: _apiKey,
                                        merchantLogin: _merchantLogin,
                                        bankInvoiceId:
                                            _invoiceIdController.text,
                                        redirectUri: _redirectUri,
                                        orderNumber:
                                            _orderNumberController.text,
                                      ),
                                    );
                                    switch (result) {
                                      case SberPayPaymentStatus.success:
                                        _color = Colors.green;
                                        _paymentStatus =
                                            'Оплата прошла успешно';
                                        break;
                                      case SberPayPaymentStatus.processing:
                                        _color = Colors.yellow;
                                        _paymentStatus =
                                            'Необходимо проверить статус оплаты';
                                        break;
                                      case SberPayPaymentStatus.cancel:
                                        _color = Colors.blue;
                                        _paymentStatus =
                                            'Пользователь отменил оплату';
                                        break;
                                      case SberPayPaymentStatus.unknown:
                                        _color = Colors.purple;
                                        _paymentStatus =
                                            'Неизвестное состояние';
                                    }
                                    setState(() {});
                                  } on PlatformException catch (e) {
                                    setState(
                                      () {
                                        _color = Colors.red;
                                        _paymentStatus = e.details ?? '';
                                      },
                                    );
                                  }
                                }
                              },
                            );
                          }

                          return Container(
                            padding: EdgeInsets.all(8),
                            constraints: BoxConstraints(minHeight: 40),
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Версия вашей ОС не поддерживается SberPay',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  TableRow _tableRowWrapper(String title, Widget secondChild) {
    return TableRow(
      children: [
        TableCell(child: Text(title, textAlign: TextAlign.center)),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(child: secondChild),
        ),
      ],
    );
  }
}
