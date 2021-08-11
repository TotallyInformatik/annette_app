import 'dart:ui';
import 'package:annette_app/timetable/timetableTab.dart';
import 'package:annette_app/vertretung/vertretungsTab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_actions/quick_actions.dart';
import 'homeworkTab.dart';
import 'settingsTab.dart';
import '2addDialog.dart';
import 'dart:async';

/// Diese Klasse gibt das Scaffold-Widget mit der Menüleiste am Boden zurück und ruft die
/// entsprechenden Tabs auf, also quasi die "Standard-Benutzeroberfläche" die erscheint,
/// wenn man die App öffnet.
class NavigationController extends StatefulWidget {
  NavigationController({Key? key}) : super(key: key);

  @override
  NavigationControllerState createState() => NavigationControllerState();
}

class NavigationControllerState extends State<NavigationController> {
  int tabIndex = 0;
  final GlobalKey<HomeworkTabState> homeworkTabAccess =
      GlobalKey<HomeworkTabState>();





  /// Diese Methode sorgt dafür, dass bei erstmaligem Starten der App
  /// ein Leitfaden angezeigt wird. In der Datei "data.txt" ist gespeichert (0 oder 1),
  /// ob der Leitfaden angezeigt werden muss.
  /// Die Textdatei wird ausgelesen und dann bei Bedarf der Leitfaden angezeigt.
  /// Wenn der Leitfaden zurückgibt, dass dieser erfolgreich beendet wurde,
  /// wird 1 in die Datei geschrieben, sodass der Leitfaden beim nächsten Starten
  /// nicht wieder angezeigt wird.
  ///
  /// Quellen zum schreiben von .txt Dateien:
  /// https://flutter.dev/docs/cookbook/persistence/reading-writing-files
  /// https://www.kindacode.com/article/flutter-how-to-read-and-write-text-files/

  /// Initialisieren
  @override
  void initState() {
    super.initState();

    ///Homescreen Quickactions
    final QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      print(shortcutType);

      ///Homescreen Quickaction "Stundenplan"
      if (shortcutType == 'timetable') {
        print('timetable');
        setState(() {
          tabIndex = 2;
        });
      }

      ///Homescreen Quickaction "Neue newHomework"
      if (shortcutType == 'newHomework') {
        print('newHomework');
        new Future.delayed(Duration.zero, () {
          showNewHomeworkDialog();
        });
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
          type: 'newHomework',
          localizedTitle: 'Neue Hausaufgabe',
          icon: 'icon_add'),
      const ShortcutItem(
          type: 'timetable', localizedTitle: 'Stundenplan', icon: 'icon_plan'),
    ]);
  }

  /// Anzeige des Scaffolds mit "bottomNavigationBar". Je nach dem welcher Tab in der Menüleiste
  /// ausgewählt ist, wird der entsprechende Tab angezeigt.
  /// Der "floatingActionButton" öffnet den Dialog zum Hinzufügen von Hausaufgaben.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (tabIndex == 0)
            ? Text('Vertretungsplan')
            : (tabIndex == 1)
                ? Text('Hausaufgaben')
                : (tabIndex == 2)
                    ? Text('Stundenplan')
                    : Text('Sonstiges'),
      ),
      body: (tabIndex == 0)
          ? VertretungsTab()
          : (tabIndex == 1)
              ? HomeworkTab(
                  key: homeworkTabAccess,
                )
              : (tabIndex == 2)
                  ? TimetableTab()
                  : SettingsTab(),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        child: Icon(Icons.add),
        onPressed: () {
          showNewHomeworkDialog();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: bottomBar(),
    );
  }

  /// Öffnet das Dialogfenster zum Erstellen einer neuen Hausaufgabe
  void showNewHomeworkDialog() {
    if (MediaQuery.of(context).size.width > 5000) {
      showDialog(

        context: context,
        barrierDismissible: true,
        useSafeArea: true,
        builder: (context) {
          return Dialog(

            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 550,
              ),
              height: 660,
              child: AddDialog(
                onTaskCreated: (newTask) {
                  if (tabIndex == 1) {
                    homeworkTabAccess.currentState!.insertTask(newTask);
                  }
                },
              ),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: (MediaQuery.of(context).size.height < 758)
              ? 638
              : MediaQuery.of(context).size.height - 120,

          decoration: new BoxDecoration(
            color: (Theme.of(context).brightness == Brightness.dark)
                ? /*Color.fromRGBO(50, 50, 50, 1)*/ Color.fromRGBO(
                    40, 40, 40, 1)
                : Color.fromRGBO(248, 248, 253, 1),
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0),
            ),
          ),
          child: AddDialog(
            onTaskCreated: (newTask) {
              if (tabIndex == 1) {
                homeworkTabAccess.currentState!.insertTask(newTask);
              }
            },
          ),
        ),
      );
    }
  }

  Widget bottomBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          label: 'Vertretung',
          icon: Icon(CupertinoIcons.rectangle_grid_1x2),
          //icon: Icon(Icons.list),
        ),
        BottomNavigationBarItem(
          label: 'Hausaufgaben',
          icon: Icon(CupertinoIcons.square_list),
          //icon: Icon(Icons.list),
        ),
        BottomNavigationBarItem(
          label: 'Stundenplan',
          icon: Icon(CupertinoIcons.calendar),
          //icon: Icon(Icons.date_range_rounded),
        ),
        BottomNavigationBarItem(
          label: 'Sonstiges',
          icon: Icon(CupertinoIcons.ellipsis),
          //icon: Icon(Icons.more_horiz_rounded),
        ),
      ],
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        setState(() {
          tabIndex = index;
        });
      },
      currentIndex: tabIndex,
    );
  }
}

Widget bottomBarItem(
    {required IconData icon, required String text, required int index}) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        Text(text),
      ],
    ),
  );
}
