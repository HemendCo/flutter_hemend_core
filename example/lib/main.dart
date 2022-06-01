import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hemend/crash_handler/crash_handler.dart';
import 'package:hemend/debug/runtime_calculator.dart';
import 'package:hemend/extensions/list_verification_tools.dart';
import 'package:hemend/task_manager/command_query/command_query.dart';
import 'package:hemend/ui_related/pre_built_widgets/future_builder.dart';

void main() {
  CrashHandler.register();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {
    runCommandsWithTrace().then((value) => print(internalResultTable));
  }

  Future<List<Widget>> runCommandsWithTrace() async {
    print('is performance : $kProfileMode');
    final runtimeResult = await RuntimeCalculator().calculateFor(() => viewCommandParser());
    log(runtimeResult.left.toString());
    return runtimeResult.right;
  }

  Future<List<Widget>> viewCommandParser() async {
    // testChecker();

    final query = [
      {
        'command': 'ContainerGenerator',
        'resultTag': 't0',
        'params': [
          {
            'name': 'width',
            'value': '150',
          },
          {
            'name': 'height',
            'value': '50',
          },
          {
            'name': 'decoration',
            'value': 'basic',
            'isFromResults': true,
          },
          {
            'name': 'alignment',
            'value': '0,0',
          }
        ]
      },
      {
        'command': 'ContainerGenerator',
        'resultTag': 't1',
        'params': [
          {
            'name': 'width',
            'value': '150',
          },
          {
            'name': 'height',
            'value': '50',
          },
          {
            'name': 'decoration',
            'value': 'master',
            'isFromResults': true,
          },
          {
            'name': 'alignment',
            'value': '0,0',
          }
        ]
      },
      {
        'command': 'ContainerGenerator',
        'resultTag': 't2',
        'params': [
          {
            'name': 'width',
            'value': '150',
          },
          {
            'name': 'height',
            'value': '50',
          },
          {
            'name': 'decoration',
            'value': 'master',
            'isFromResults': true,
          },
          {
            'name': 'alignment',
            'value': '0,0',
          }
        ]
      },
      ...List.generate(
        10,
        (index) => {
          'command': 'TextView',
          'resultTag': 'TextViewTest$index#Widget',
          'params': [
            {
              'name': 'text',
              'value': 'test text $index',
            },
            {
              'name': 'builder',
              'value': 't${(index % 2).toInt()}',
              'isFromResults': true,
            }
          ]
        },
      )
    ];
    final result = <Widget>[];
    final parser = CommandQueryParser(commands: commandMap);
    await parser.parsAndRunFromJson([
      {
        'command': 'DecorationGenerator',
        'resultTag': 'basic',
        'params': [
          {
            'name': 'color',
            'value': '0xFFA03F3F',
          },
          {
            'name': 'borderRadius',
            'value': '15',
          },
          {
            'name': 'border',
            'value': '0xFF34C517,2',
          },
        ],
      },
      {
        'command': 'DecorationGenerator',
        'resultTag': 'master',
        'params': [
          {
            'name': 'color',
            'value': '0xFF34C517',
          },
          {
            'name': 'borderRadius',
            'value': '15',
          },
          {
            'name': 'border',
            'value': '0xFFA03F3F,2',
          },
        ],
      },
      {
        'command': 'DecorationGenerator',
        'resultTag': 'master',
        'params': [
          {
            'name': 'color',
            'value': '0xFF34C517',
          },
          {
            'name': 'borderRadius',
            'value': '15',
          },
          {
            'name': 'border',
            'value': '0xFFA03F3F,2',
          },
        ],
      },
    ]);
    final parsResult = await parser.parsAndRunFromJson(
      query,
    );

    for (final item in parsResult.entries
        .where(
          (element) => element.key.endsWith(
            '#Widget',
          ),
        )
        .map(
          (e) => e.value,
        )) {
      if (item is Widget) {
        result.add(item);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: BuildInFuture<List<Widget>>(
          itemFromFuture: runCommandsWithTrace(),
          childInFuture: (_, items, rebuilder) => ListView.builder(
            itemCount: items!.length,
            itemBuilder: (context, index) => items[index],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

InstructionSet commandMap = InstructionSet(const [
  CommandModel(
    command: 'ContainerGenerator',
    commandRunner: containerGenerator,
    forcedParams: [
      'width',
      'height',
      'decoration',
    ],
    optionalParams: [
      'margin',
      'padding',
      'alignment',
      'transform',
    ],
  ),
  CommandModel(
    command: 'TextView',
    optionalParams: [],
    forcedParams: ['text', 'builder'],
    commandRunner: textViewGenerator,
  ),
  CommandModel(
    command: 'DecorationGenerator',
    optionalParams: ['color', 'borderRadius', 'shape', 'border'],
    forcedParams: [],
    commandRunner: decoration,
  ),
]);

typedef WidgetGenerator = Widget Function(Widget child);
BoxDecoration decoration(Map<String, ParamsModel> params, Map<String, dynamic> results) {
  BorderRadius borderRadius = BorderRadius.zero;
  if (params['borderRadius'] != null) {
    borderRadius = BorderRadius.circular(double.parse(params['borderRadius']!.value));
  }

  BoxShape shape = BoxShape.rectangle;
  if (params['shape'].toString() == 'circle') {
    shape = BoxShape.circle;
  }

  Border? border = params['border']?.extractValue<Border>(mappers: mappers, results: results);

  return BoxDecoration(
    // backgroundBlendMode: ,
    border: border,
    borderRadius: borderRadius,
    // boxShadow: ,
    color: params['color']?.extractValue<Color>(mappers: mappers, results: results),
    // gradient: ,
    // image: ,
    shape: shape,
  );
}

WidgetGenerator containerGenerator(Map<String, ParamsModel> params, Map<String, dynamic> results) {
  Alignment? alignment;
  if (params['alignment'] != null) {
    alignment = alignmentFromString(params['alignment']!.value);
  }

  EdgeInsets? margin;
  if (params['margin'] != null) {
    margin = edgeInsetsFromString(params['margin']!.value.toString());
  }

  EdgeInsets? padding;
  if (params['padding'] != null) {
    padding = edgeInsetsFromString(params['padding']!.value.toString());
  }

  return (Widget child) => Container(
        alignment: alignment,
        width: params['width']!.extractValue<double>(mappers: mappers, results: results),
        height: double.parse(params['height']!.value),
        decoration: params['decoration']!.extractValue<BoxDecoration>(mappers: mappers, results: results),
        margin: margin,
        padding: padding,
        child: child,
      );
}

EdgeInsets edgeInsetsFromString(String edgeParams) {
  final sliced = edgeParams.split(',');
  final padding = EdgeInsets.fromLTRB(
    double.parse(sliced[0]),
    double.parse(sliced[1]),
    double.parse(sliced[2]),
    double.parse(sliced[3]),
  );
  return padding;
}

Widget textViewGenerator(Map<String, ParamsModel> params, Map<String, dynamic> results) {
  final textParams = params['text']!.extractValue<String>(mappers: mappers, results: results);
  final builder = params['builder']!.extractValue<WidgetGenerator>(mappers: mappers, results: results);
  // final Widget Function(Widget child) containerGenerator = results['TextViewContainerGenerator']!;

  return builder(TextField(
    onChanged: (value) {
      internalResultTable[textParams] = value;
    },
  ));
}

Alignment alignmentFromString(String align) {
  final alignArray = align.split(',');
  alignArray.breakOnLengthMismatch([2]);
  return Alignment(double.parse(alignArray[0]), double.parse(alignArray[1]));
}

extension AlignmentTools on Alignment {
  String toAlignString() {
    return '$x,$y';
  }
}

Map<Type, StringValueParser> mappers = {
  String: StringValueParser<String>(
    toBaseCaster: (p0) => p0,
    toDestinationCaster: (p0) => p0,
  ),
  double: StringValueParser<double>(
    toBaseCaster: (p0) => p0.toString(),
    toDestinationCaster: (p0) => double.parse(p0),
  ),
  Color: StringValueParser<Color>(
    toBaseCaster: (p0) => p0.value.toString(),
    toDestinationCaster: (p0) => Color(int.parse(p0)),
  ),
  BorderRadius: StringValueParser<BorderRadius>(
    toBaseCaster: (p0) => p0.topLeft.x.toString(),
    toDestinationCaster: (p0) => BorderRadius.circular(double.parse(p0)),
  ),
  EdgeInsets: StringValueParser<EdgeInsets>(
    toBaseCaster: (p0) {
      return '${p0.left},${p0.top},${p0.right},${p0.bottom},';
    },
    toDestinationCaster: (p0) => edgeInsetsFromString(p0),
  ),
  Alignment: StringValueParser<Alignment>(
    toBaseCaster: (p0) => '${p0.x},${p0.y}',
    toDestinationCaster: (p0) => alignmentFromString(p0),
  ),
  Border: StringValueParser<Border>(
    toBaseCaster: (p0) => '${p0.bottom.color.value},${p0.bottom.width}',
    toDestinationCaster: (p0) {
      final sliced = p0.split(',');
      sliced.breakOnLengthMismatch([2]);
      final color = Color(int.parse(sliced[0]));
      final width = double.parse(sliced[1]);

      return Border.all(
        color: color,
        width: width,
        style: BorderStyle.solid,
      );
    },
  ),
};
Map<String, String> internalResultTable = {};
