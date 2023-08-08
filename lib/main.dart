import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
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
        title: 'Viamlabs Remote Control',
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
  var webRTC = false;
  final dialOptions = DialOptions();
  late Future robotFut;
  var _isLoggedIn = false;
  var _isLoading = false;
  late RobotClient _robot;
  late ResourceName baseName;
  late Base _base;
  late Iterable<Camera> _cameras;

  void login(String location, String secret) {
    _isLoggedIn = true;
    _isLoading = true;
    notifyListeners();

    if (!webRTC) {
      dialOptions.insecure = true;
      dialOptions.authEntity = 'pi-main.t7do9d9645.viam.cloud';
      dialOptions.webRtcOptions = DialWebRtcOptions();
      dialOptions.webRtcOptions!.disable = true;
    }
    dialOptions.credentials = Credentials.locationSecret(secret);
    /*
    else {
      robotFut = RobotClient.atAddress(
        location,
        RobotClientOptions.withLocationSecret(secret),
      );
    }*/
    robotFut = RobotClient.atAddress(
        location, RobotClientOptions.withDialOptions(dialOptions));
    robotFut.then((value) {
      _robot = value;

      var baseName = _robot.resourceNames.firstWhere(
          (element) => element.subtype == Base.subtype.resourceSubtype);
      _base = Base.fromRobot(_robot, baseName.name);

      _cameras = _robot.resourceNames
          .where((element) => element.subtype == Camera.subtype.resourceSubtype)
          .map((e) => Camera.fromRobot(_robot, e.name));

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Viamlabs Remote Control'),
      ),
      body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  !appState._isLoggedIn
                      ? const LoginPage()
                      : appState._isLoading
                          ? Center(child: PlatformCircularProgressIndicator())
                          : ViamBaseScreen(
                              base: appState._base,
                              cameras: appState._cameras,
                              robotClient: appState._robot,
                            ),
                ]),
          )),
      floatingActionButton: appState._isLoggedIn
          ? FloatingActionButton(
              onPressed: () {
                appState.logout();
              },
              tooltip: 'Logout',
              child: const Icon(Icons.exit_to_app),
            )
          : Container(),
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
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    appState.login(
                        locationController.text, secretController.text);
                  }
                },
                child: const Text('Login'),
              ),
            ),
          ],
        ));
  }
}
