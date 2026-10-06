import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import 'package:hijri/hijri.dart';

void main() {
  runApp(const SalatWatchApp());
}

class SalatWatchApp extends StatelessWidget {
  const SalatWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SalatWatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D5C36)),
        fontFamily: 'NotoNastaliq',
      ),
      home: const SalatWatchHome(),
    );
  }
}

class SalatWatchHome extends StatefulWidget {
  const SalatWatchHome({super.key});
  @override
  State<SalatWatchHome> createState() => _SalatWatchHomeState();
}

class _SalatWatchHomeState extends State<SalatWatchHome> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  late HijriCalendar _hijri;

  @override
  void initState() {
    super.initState();
    _hijri = HijriCalendar.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
        _hijri = HijriCalendar.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  PrayerTimes getPrayerTimes() {
    final coords = Coordinates(34.0, 73.0); // Besham area default
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;
    return PrayerTimes.today(coords, params);
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm:ss a').format(_now);
    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'en').format(_now);
    final prayerTimes = getPrayerTimes();

    final prayers = [
      {'name': 'فجر', 'time': prayerTimes.fajr},
      {'name': 'ظہر', 'time': prayerTimes.dhuhr},
      {'name': 'عصر', 'time': prayerTimes.asr},
      {'name': 'مغرب', 'time': prayerTimes.maghrib},
      {'name': 'عشاء', 'time': prayerTimes.isha},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF061A12),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D5C36),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'صلوٰۃ واچ - SalatWatch',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                // Digital Clock
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF122E22), Color(0xFF1A4D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        timeStr,
                        style: const TextStyle(
                          color: Color(0xFF7CFFB2),
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(dateStr, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(
                        '${_hijri.hDay} ${_hijri.longMonthName} ${_hijri.hYear} ھ',
                        style: const TextStyle(color: Color(0xFFFFD86B), fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Prayer Times Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: prayers.length,
                  itemBuilder: (context, i) {
                    final p = prayers[i];
                    final t = p['time'] as DateTime;
                    final isNext = _now.isBefore(t) && (i==0 || _now.isAfter(prayers[i-1]['time'] as DateTime));
                    return Container(
                      decoration: BoxDecoration(
                        color: isNext ? const Color(0xFF0D5C36) : const Color(0xFF11261C),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isNext ? const Color(0xFF7CFFB2) : Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(p['name'] as String, style: TextStyle(color: isNext ? Colors.white : Colors.white70, fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(DateFormat('hh:mm a').format(t), style: TextStyle(color: isNext ? const Color(0xFF7CFFB2) : Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text('مقام: بیشام، خیبر پختونخوا - Hanafi, Karachi Method', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
