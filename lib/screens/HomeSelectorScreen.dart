import 'package:conectaflutter/screens/User/UserLoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:conectaflutter/screens/Company/CompanyLoginScreen.dart';
import 'package:conectaflutter/screens/User/UserRegisterScreen.dart';
import 'package:conectaflutter/screens/Company/CompanyRegisterScreen.dart';

class HomeSelectorScreen extends StatelessWidget {
  const HomeSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final volunteerColor = const Color(0xFF1A73E8);
    final companyPrimary = Colors.deepPurple.shade600;
    final companySecondary = Colors.deepPurple.shade100;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          "Conecta",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // =======================
              //   COLUMNA VOLUNTARIO
              // =======================
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.volunteer_activism,
                        size: 60,
                        color: volunteerColor,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Voluntarios",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Ayuda, participa y forma parte del cambio.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 35),
                      _primaryButton(
                        color: volunteerColor,
                        label: "Ingresar como Voluntario",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserLoginScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _secondaryButton(
                        color: volunteerColor,
                        label: "Registrarme",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserRegisterScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // =======================
              //     COLUMNA EMPRESA
              // =======================
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  color: companySecondary,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.business_center,
                        size: 60,
                        color: companyPrimary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Empresas",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: companyPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Construí impacto social corporativo con tus programas.",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 16,
                          color: companyPrimary.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 35),
                      _primaryInvertedButton(
                        color: companyPrimary,
                        textColor: Colors.white,
                        label: "Ingresar como Empresa",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CompanyLoginScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _secondaryInvertedButton(
                        borderColor: companyPrimary,
                        textColor: companyPrimary,
                        label: "Registrarnos",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CompanyRegisterScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================
  //     BOTONES VOLUNTARIOS
  // ============================

  Widget _primaryButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 260,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 260,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 1.6),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }

  // ============================
  //       BOTONES EMPRESA
  // ============================

  Widget _primaryInvertedButton({
    required Color color,
    required Color textColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 260,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _secondaryInvertedButton({
    required Color borderColor,
    required Color textColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 260,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor, width: 1.6),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
