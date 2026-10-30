import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Lista con los datos de las 3 plantillas
  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Bienvenido a Grupo Electron 465 C.A.',
      'subtitle': 'Tu aliado financiero de confianza. Descubre todo lo que tenemos para ti.',
      'icon': '🏢', // Puedes cambiar esto por un Image.asset luego
    },
    {
      'title': 'Solicita tu crédito en simples pasos',
      'subtitle': 'Proceso 100% digital, rápido y seguro. Sin complicaciones.',
      'icon': '💳',
    },
    {
      'title': 'Crea tu historial crediticio',
      'subtitle': 'Avanza en niveles y crece con nosotros como un equipo.',
      'icon': '📈',
    },
  ];

  // Función para finalizar el onboarding y guardar que ya lo vio
  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true); // Guarda en memoria que ya lo vio

    if (mounted) {
      context.go('/login'); // Lo enviamos al Login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F), // Fondo azul oscuro corporativo
      body: SafeArea(
        child: Column(
          children: [
            // Botón de Saltar (arriba a la derecha)
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text('Saltar', style: TextStyle(color: Colors.white70, fontSize: 16)),
              ),
            ),

            // El carrusel de plantillas
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _onboardingData[index]['icon']!,
                          style: const TextStyle(fontSize: 100),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _onboardingData[index]['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _onboardingData[index]['subtitle']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicadores (los puntitos) y Botón de Siguiente
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Puntitos indicadores
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => buildDot(index, context),
                    ),
                  ),

                  // Botón de Siguiente / Comenzar
                  FloatingActionButton(
                    backgroundColor: const Color(0xFF2196F3),
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _finishOnboarding(); // Si es la última, finaliza
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: Icon(
                      _currentPage == _onboardingData.length - 1
                          ? Icons.check
                          : Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para dibujar los puntitos
  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: _currentPage == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFF2196F3) : Colors.white30,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}