import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatGenieHomeScreen extends StatelessWidget {
  StatGenieHomeScreen({super.key});

  final GlobalKey _featuresKey = GlobalKey();

  void _scrollToFeatures(BuildContext context) {
    final ctx = _featuresKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      endDrawer: const _StatGenieDrawer(),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: _StatGenieAppBar(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 34,
                        color: Colors.white,
                      ),
                      children: const [
                        TextSpan(text: "Transform"),
                        TextSpan(text: "Data", style: TextStyle(color: Colors.deepPurpleAccent)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Into Actionable Insights",
                    style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 28),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/upload-dashboard');
                        },
                        child: const Text('Try Free trial'),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.deepPurpleAccent),
                          foregroundColor: Colors.deepPurpleAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _scrollToFeatures(context),
                        child: const Text('Scroll to Explore'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 38),
                  // Dashboard mock image holder (replace asset path if needed)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      color: Colors.white10,
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: 220,
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/hero.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.dashboard, color: Colors.white54, size: 48),
                            SizedBox(height: 10),
                            Text('Add assets/hero.png', style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // FEATURES
            Container(
              key: _featuresKey,
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 38),
              child: Column(
                children: [
                  Text("Features", style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 26)),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      alignment: WrapAlignment.center,
                      children: const [
                        _FeatureCard(icon: Icons.pie_chart_rounded, title: 'KPI\nGeneration', color: Colors.orangeAccent),
                        _FeatureCard(icon: Icons.show_chart_rounded, title: 'Dynamic\nVisuals', color: Colors.deepPurpleAccent),
                        _FeatureCard(icon: Icons.auto_graph_rounded, title: 'Summaries', color: Colors.lightBlue),
                        _FeatureCard(icon: Icons.bar_chart_rounded, title: 'AI Story', color: Colors.teal),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _bullet('AI-Powered Data Analysis'),
                        _bullet('KPI Generation'),
                        _bullet('Dynamic Visualizations'),
                        _bullet('Comprehensive Summaries'),
                        _bullet('Intelligent Data Storytelling'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 38),
                  Text("How It Works!", style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 30, color: Colors.black)),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _HowStep(no: '01', title: 'Upload Your Data', detail: 'Upload CSV/Excel/JSON. We detect structure automatically.'),
                        SizedBox(height: 18),
                        _HowStep(no: '02', title: 'Automatic Analysis', detail: 'AI finds KPIs, relationships, and patterns.'),
                        SizedBox(height: 18),
                        _HowStep(no: '03', title: 'Dashboard Generation', detail: 'Visualizations, KPIs, and data story tailored for your dataset.'),
                        SizedBox(height: 18),
                        _HowStep(no: '04', title: 'Explore & Share', detail: 'Interact, customize, and share insights.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // FOOTER (dark)
                  Container(
                    width: double.infinity,
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/Logo.png', width: 32, height: 32, errorBuilder: (_, __, ___) => const SizedBox()),
                            const SizedBox(width: 8),
                            Text('StatGenie',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 21,
                                  color: Colors.white,
                                )),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Transforming raw data into actionable insights with AI analytics.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(color: Colors.white60, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 18,
                          alignment: WrapAlignment.center,
                          children: const [
                            _FooterLink('Home'),
                            _FooterLink('How It Works'),
                            _FooterLink('Dashboard'),
                            _FooterLink('Testimonials'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('© 2025 StatGenie. All rights reserved.', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white38)),
                      ],
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
}

class _StatGenieAppBar extends StatelessWidget {
  const _StatGenieAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 10),
          Image.asset('assets/Logo.png', width: 30, height: 30, errorBuilder: (_, __, ___) => const SizedBox(width: 30, height: 30)),
          const SizedBox(width: 8),
          Text('StatGenie',
              style: GoogleFonts.montserrat(
                color: Colors.deepPurpleAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              )),
        ],
      ),
      actions: [
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
          ),
        ),
      ],
    );
  }
}

class _StatGenieDrawer extends StatelessWidget {
  const _StatGenieDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: Image.asset('assets/Logo.png', width: 28, height: 28, errorBuilder: (_, __, ___) => const Icon(Icons.bar_chart, color: Colors.white)),
              title: Text('StatGenie',
                  style: GoogleFonts.montserrat(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold)),
            ),
            const Divider(color: Colors.white12),
            _drawerItem(context, Icons.home, 'Home', () {
              Navigator.pop(context);
            }),
            _drawerItem(context, Icons.dashboard, 'Upload Dashboard', () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/upload-dashboard');
            }),
            _drawerItem(context, Icons.info, 'How It Works', () {
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const _FeatureCard({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 104,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: color.withOpacity(0.14), blurRadius: 14, spreadRadius: 2, offset: const Offset(0, 6))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 38, color: color),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

Widget _bullet(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.deepPurpleAccent, size: 18),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.montserrat(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

class _HowStep extends StatelessWidget {
  final String no;
  final String title;
  final String detail;
  const _HowStep({required this.no, required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(no, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.deepPurpleAccent)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 2),
              Text(detail, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  const _FooterLink(this.label);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: Text(label, style: const TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.w600)),
    );
  }
}