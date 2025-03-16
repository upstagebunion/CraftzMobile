import 'package:flutter/material.dart';
import '../../../services/auth_login.dart';

class LoginScreen extends StatefulWidget{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _login() async {
    String email = _emailController.text.replaceAll(' ', '');
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    ApiService ap = ApiService();
    

    try {
      await ap.login(email: email, password: password);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
      );
    }

    setState(() {
      _isLoading = false;
    });

  }

  @override
  Widget build(BuildContext context){
    double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesion'),
        backgroundColor: color.primary,
        foregroundColor: color.onPrimary,
        titleTextStyle: theme.textTheme.headlineMedium,
        ),
      body: Container(
        width: screenWidth,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:screenWidth * .8,
              margin: EdgeInsets.only(bottom: 20.0),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enableSuggestions: true,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: color.primary, width:2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: color.secondary, width:2),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 20),
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            Container(
              width:screenWidth * .8,
              margin: EdgeInsets.only(top: 20.0),
              child: TextFormField(
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                autocorrect: false,
                enableSuggestions: false,
                obscureText: _isPasswordVisible? false : true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(icon: Icon(_isPasswordVisible? Icons.visibility : Icons.visibility_off,
                    color: color.primary,
                    ),
                    onPressed: (){
                      setState((){
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Iniciar sesión'),
                  ),
          ],
        ),
      ),
    );
  }

}