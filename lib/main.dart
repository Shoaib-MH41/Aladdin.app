class AladdinApp extends StatelessWidget {
  const AladdinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aladdin App',
      themeMode: ThemeMode.system, // ✅ device کے حساب سے auto
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        brightness: Brightness.dark,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/projects': (context) => const ProjectScreen(),
        '/select': (context) => const SelectionScreen(),
        '/upload': (context) => const UploadScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
