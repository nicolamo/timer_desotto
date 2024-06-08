import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Screen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimerScreen(mode: 'Tabata')),
                );
              },
              child: Text('Tabata'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimerScreen(mode: 'Emom')),
                );
              },
              child: Text('Emom'),
            ),
          ],
        ),
      ),
    );
  }
}

class TimerScreen extends StatefulWidget {
  final String mode;

  const TimerScreen({super.key, required this.mode});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int workSeconds = 0;
  int restSeconds = 0;
  int seriesCount = 1;
  int currentSeconds = 0;
  int currentSeries = 1;
  Timer? timer;
  bool isWorking = true; // true means working, false means resting
  bool isRunning = false;

  final TextEditingController workController = TextEditingController();
  final TextEditingController restController = TextEditingController();
  final TextEditingController seriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.mode == 'Tabata') {
      workSeconds = 20;
      restSeconds = 10;
      seriesCount = 8;
    } else if (widget.mode == 'Emom') {
      workSeconds = 60;
      restSeconds = 0;
    }
    currentSeconds = workSeconds;
    workController.text = workSeconds.toString();
    restController.text = restSeconds.toString();
    seriesController.text = seriesCount.toString();
  }

  void startStopTimer() {
    if (isRunning) {
      stopTimer();
    } else {
      startTimer();
    }
  }

  void startTimer() {
    stopTimer(); // Ensure any previous timer is stopped
    isRunning = true;
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        if (currentSeconds > 0) {
          currentSeconds--;
        } else {
          if (widget.mode == 'Tabata') {
            if (isWorking) {
              isWorking = false;
              currentSeconds = restSeconds;
            } else {
              currentSeries++;
              if (currentSeries > seriesCount) {
                stopTimer();
                return;
              }
              isWorking = true;
              currentSeconds = workSeconds;
            }
          } else if (widget.mode == 'Emom') {
            currentSeconds = workSeconds;
          }
        }
      });
    });
  }

  void stopTimer() {
    isRunning = false;
    timer?.cancel();
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      currentSeconds = workSeconds;
      currentSeries = 1;
      isWorking = true;
    });
  }

  @override
  void dispose() {
    workController.dispose();
    restController.dispose();
    seriesController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode + ' Timer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.mode == 'Tabata') ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: workController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Work time (seconds)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    workSeconds = int.tryParse(value) ?? workSeconds;
                    if (isWorking) {
                      resetTimer();
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: restController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Rest time (seconds)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    restSeconds = int.tryParse(value) ?? restSeconds;
                    if (!isWorking) {
                      resetTimer();
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: seriesController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Number of series',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    seriesCount = int.tryParse(value) ?? seriesCount;
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
            Text(
              widget.mode == 'Tabata' ? (isWorking ? 'Work Time' : 'Rest Time') : 'Emom Timer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (widget.mode == 'Tabata') ...[
              Text(
                'Series: $currentSeries/$seriesCount',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
            ],
            Text(
              '$currentSeconds',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: startStopTimer,
              child: Text(isRunning ? 'Stop Timer' : 'Start Timer'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: resetTimer,
              child: Text('Reset Timer'),
            ),
          ],
        ),
      ),
    );
  }
}
