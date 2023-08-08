import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:viam_sdk/viam_sdk.dart';
import 'package:viam_sdk/widgets.dart';

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
        title: 'Viam Remote Control',
        theme: ThemeData(
          fontFamily: 'RobotoMono',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var _isLoggedIn = false;
  var _isLoading = false;
  late RobotClient _robot;
  late ResourceName baseName;
  late ResourceName cameraName;

  void login(String location, String secret) {
    _isLoggedIn = true;
    _isLoading = true;
    notifyListeners();

    final robotFut = RobotClient.atAddress(
      location,
      RobotClientOptions.withLocationSecret(secret),
    );

    robotFut.then((value) {
      _robot = value;
      // Print the available resources
      //print(_robot.resourceNames);
      final components = _robot.resourceNames
          .where((element) => element.type == resourceTypeComponent);

      for (ResourceName component in components) {
        if (component.subtype == Camera.subtype.resourceSubtype) {
          cameraName = component;
        }
      }
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
    });
  }

  void logout() {
    _robot.close().then((value) {
      _isLoggedIn = false;
      notifyListeners();
    });
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viam Remote Control'),
      ),
      body: SafeArea(
        child: Center(
          child: !appState._isLoggedIn
              ? const LoginPage()
              : appState._isLoading
                  ? PlatformCircularProgressIndicator()
                  : Column(
                      children: [
                        ViamBaseScreen(
                          base: Base.fromRobot(appState._robot,
                              'viam_base'), // TODO: Make 'viam_base' dynamic
                          cameras: appState._robot.resourceNames
                              .where((element) =>
                                  element.subtype ==
                                  Camera.subtype.resourceSubtype)
                              .map((e) =>
                                  Camera.fromRobot(appState._robot, e.name)),
                          robotClient: appState._robot,
                        ),
                      ],
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appState.logout();
        },
        tooltip: 'Logout',
        child: const Icon(Icons.exit_to_app),
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
