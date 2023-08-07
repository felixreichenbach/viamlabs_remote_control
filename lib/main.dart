import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_viam_robot/screens/base.dart';
import 'package:provider/provider.dart';
import 'package:viam_sdk/viam_sdk.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Viam Flutter App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var _isLoggedIn = true;
  late RobotClient _robot;

  void login(String location, String secret) {
    print("inside");
    // TODO: Implement authentication

    final robotFut = RobotClient.atAddress(
      location,
      RobotClientOptions.withLocationSecret(secret),
    );
    _isLoggedIn = !_isLoggedIn;
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(),
      body: appState._isLoggedIn ? const LoginPage() : const Placeholder(),
      // TODO: Implement once authentication complete
      /*const BaseScreen(
              robot: null,
              base: null,
              cameras: null,
            ),*/
      // TODO: Remove once authentication is implemented
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appState.login("", "");
        },
        tooltip: 'Increment Counter',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final locationController =
      TextEditingController(text: dotenv.env['LOCATION']);
  final secretController = TextEditingController(text: dotenv.env['SECRET']);

  @override
  void dispose() {
    locationController.dispose();
    secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Robot Location',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the robot location!';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                controller: secretController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Location Secret',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location secret!';
                  }
                  return null;
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20)),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  appState.login(
                      locationController.text, secretController.text);
                }
              },
              child: const Text('Login'),
            ),
          ],
        ));
  }
}
