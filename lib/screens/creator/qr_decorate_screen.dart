import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/qr_create_data.dart';
import '../../models/qr_decoration_settings.dart';
import 'color_selector.dart';
import 'qr_decorate_result_screen.dart';
import 'package:flutter/cupertino.dart';
//import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class QrDecorateScreen extends StatefulWidget {
  final QrCreateData qrData;

  const QrDecorateScreen({super.key, required this.qrData});

  @override
  State<QrDecorateScreen> createState() => _QrDecorateScreenState();
}

class _QrDecorateScreenState extends State<QrDecorateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Color foregroundColor = Colors.black;
  Color backgroundColor = Colors.white;

  String selectedPixelShape = 'square';
  String backgroundStyle = "normal";

  IconData? centerIcon;
  //String? centerText;
  IconData? _selectedIcon;
  Color selectedIconColor = Colors.black;
  Color selectedIconBackgroundColor = Colors.white;
  MemoryImage? _embeddedIconImage;
  File? _selectedImage;

  String? topText;
  String? bottomText;
  late TextEditingController _topTextController;
  late TextEditingController _bottomTextController;
  String _tempTopText = "";
  String _tempBottomText = "";
  TextStyle topLabelStyle = const TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontFamily: 'Roboto',
  );
  TextStyle bottomLabelStyle = const TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontFamily: 'Roboto',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _topTextController = TextEditingController(text: topText ?? "");
    _bottomTextController = TextEditingController(text: bottomText ?? "");

    _tempTopText = topText ?? "";
    _tempBottomText = bottomText ?? "";
  }

  @override
  void dispose() {
    _tabController.dispose();
    _topTextController.dispose();
    _bottomTextController.dispose();
    super.dispose();
  }

  final List<Tab> _tabs = const [
    Tab(text: "コード"),
    Tab(text: "背景"),
    Tab(text: "アイコン"), //元"中央"
    Tab(text: "ラベル"), //元"文字"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QRコードをデコ"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 「生成」ボタンの処理
              _onSave();
            },
            child: const Text("保存", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Center(child: _buildQrPreview()),
          const SizedBox(height: 8),

          // 上段のカテゴリタブ（コード・背景・中央・文字）
          TabBar(
            controller: _tabController,
            tabs: _tabs,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),

          // タブビュー
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCodeTab(),
                _buildBackgroundTab(),
                _buildIconTab(),
                _buildLabelTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    final settings = QrDecorationSettings(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      pixelShape: selectedPixelShape,
      backgroundStyle: backgroundStyle,
      centerIcon: centerIcon,
      embeddedIcon: _embeddedIconImage,
      iconColor: selectedIconColor,
      iconBackgroundColor: selectedIconBackgroundColor,
      embeddedImage: _selectedImage,
      topText: topText,
      bottomText: bottomText,
      topLabelStyle: topLabelStyle,
      bottomLabelStyle: bottomLabelStyle,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => QrDecorateResultScreen(
              qrData: widget.qrData,
              decorationSettings: settings,
            ),
      ),
    );
  }

  Widget _buildQrPreview() {
    BoxDecoration decoration;

    if (backgroundStyle == 'transparent') {
      decoration = const BoxDecoration(color: Colors.transparent);
    } else if (backgroundStyle == 'rounded') {
      decoration = BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      );
    } else if (backgroundStyle == 'gradient') {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    } else {
      decoration = BoxDecoration(color: backgroundColor);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade300, Colors.grey.shade400],
          stops: [0.67, 1.0],
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 上部ラベル
            if (topText != null && topText!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(topText!, style: topLabelStyle),
              ),

            // QRコード本体
            Container(
              decoration: decoration,
              padding: const EdgeInsets.all(16),
              child: QrImageView(
                data: widget.qrData.content,
                version: QrVersions.auto,
                size: 180,
                foregroundColor: foregroundColor,
                backgroundColor: Colors.transparent,
                embeddedImage: _embeddedIconImage,
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(48, 48),
                ),
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
            ),

            // 下部ラベル
            if (bottomText != null && bottomText!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(bottomText!, style: bottomLabelStyle),
              ),
          ],
        ),
      ),
    );
  }

  //コード部分のタブ
  Widget _buildCodeTab() {
    final subTabs = const [
      Tab(text: "色"),
      Tab(text: "ピクセル形"),
      Tab(text: "目の形"),
    ];

    return DefaultTabController(
      length: subTabs.length,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TabBar(
            tabs: subTabs,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildColorSettings(),
                _buildPixelShapeSettings(),
                _buildEyeShapeSettings(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSettings() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ColorSelector(
        title: "",
        selectedColor: foregroundColor,
        onColorSelected: (color) {
          setState(() {
            foregroundColor = color;
          });
        },
      ),
    );
  }

  Widget _buildPixelShapeSettings() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ピクセルの形（仮）"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text("丸"),
                selected: selectedPixelShape == 'circle',
                onSelected: (_) {
                  setState(() {
                    selectedPixelShape = 'circle';
                  });
                },
              ),
              ChoiceChip(
                label: const Text("四角"),
                selected: selectedPixelShape == 'square',
                onSelected: (_) {
                  setState(() {
                    selectedPixelShape = 'square';
                  });
                },
              ),
              ChoiceChip(
                label: const Text("ダイヤ"),
                selected: selectedPixelShape == 'diamond',
                onSelected: (_) {
                  setState(() {
                    selectedPixelShape = 'diamond';
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEyeShapeSettings() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("目の形（仮）"),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(label: const Text("標準"), selected: true),
              ChoiceChip(label: const Text("丸型"), selected: false),
              ChoiceChip(label: const Text("フレーム"), selected: false),
            ],
          ),
        ],
      ),
    );
  }

  //背景部分のタブ
  Widget _buildBackgroundTab() {
    final subTabs = const [Tab(text: "色"), Tab(text: "スタイル")];

    return DefaultTabController(
      length: subTabs.length,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TabBar(
            tabs: subTabs,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBackgroundColorSettings(),
                _buildBackgroundStyleSettings(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundColorSettings() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ColorSelector(
        title: "",
        selectedColor: backgroundColor,
        onColorSelected: (newColor) {
          setState(() {
            backgroundColor = newColor;
          });
        },
      ),
    );
  }

  Widget _buildBackgroundStyleSettings() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("背景スタイルを選択"),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text("通常"),
                selected: backgroundStyle == "normal",
                onSelected: (_) {
                  setState(() => backgroundStyle = "normal");
                },
              ),
              ChoiceChip(
                label: const Text("丸形"),
                selected: backgroundStyle == "rounded",
                onSelected: (_) {
                  setState(() => backgroundStyle = "rounded");
                },
              ),
              ChoiceChip(
                label: const Text("透過"),
                selected: backgroundStyle == "transparent",
                onSelected: (_) {
                  setState(() => backgroundStyle = "transparent");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  //中央部分のタブ
  /*Widget _buildCenterTab() {
    return const Center(child: Text("中央の画像・文字（未実装）"));
  }*/
  Widget _buildIconTab() {
    final subTabs = const [
      Tab(text: "アイコン"),
      Tab(text: "色"),
      Tab(text: "画像（未実装）"),
    ];

    return DefaultTabController(
      length: subTabs.length,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TabBar(
            tabs: subTabs,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildIconSelection(),
                _buildIconColorSelection(),
                _buildImageSelection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children:
          availableIcons.map((iconData) {
            final isSelected = _selectedIcon == iconData;
            return GestureDetector(
              onTap: () {
                _onIconSelected(isSelected ? null : iconData);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  //color: selectedIconBackgroundColor,
                  color:
                      isSelected
                          ? Colors.blueAccent.withOpacity(0.2)
                          : Colors.transparent,
                  border: Border.all(
                    color:
                        isSelected ? Colors.blueAccent : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  iconData,
                  size: 36,
                  color: Colors.black /*selectedIconColor*/,
                ),
              ),
            );
          }).toList(),
    );
  }

  final List<IconData> availableIcons = [
    CupertinoIcons.heart,
    CupertinoIcons.star,
    CupertinoIcons.camera,
    CupertinoIcons.person,
    CupertinoIcons.phone,
    CupertinoIcons.mail,
    CupertinoIcons.home,
    CupertinoIcons.cart,
    CupertinoIcons.location,
    CupertinoIcons.settings,
    CupertinoIcons.wifi,
    CupertinoIcons.wifi_exclamationmark,
    CupertinoIcons.link,
    CupertinoIcons.globe,
    CupertinoIcons.cloud,
    CupertinoIcons.share,

    // … 必要に応じて追加
  ];

  Future<MemoryImage?> _iconToImageProvider(
    IconData iconData,
    Color iconColor,
    Color backgroundColor,
    double size,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final radius = size / 2;

    // 1. 背景（白円）を描画
    final Paint bgPaint = Paint()..color = backgroundColor;
    canvas.drawCircle(Offset(radius, radius), radius, bgPaint);

    // 2. アイコンを描画
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: size * 0.6, // 少し小さめにして中心に配置
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          color: iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final offset = Offset(
      radius - textPainter.width / 2,
      radius - textPainter.height / 2,
    );

    textPainter.paint(canvas, offset);

    // 3. 画像化
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) return null;
    return MemoryImage(byteData.buffer.asUint8List());
  }

  Future<void> _onIconSelected(IconData? iconData) async {
    if (iconData == null) {
      setState(() {
        _selectedIcon = null;
        _embeddedIconImage = null;
      });
      return;
    }

    final image = await _iconToImageProvider(
      iconData,
      selectedIconColor,
      selectedIconBackgroundColor,
      48,
    );

    setState(() {
      _selectedIcon = iconData;
      _embeddedIconImage = image;
    });
  }

  Widget _buildIconColorSelection() {
    final subTabs = const [Tab(text: "アイコン色"), Tab(text: "背景色")];

    return DefaultTabController(
      length: subTabs.length,
      child: Column(
        children: [
          TabBar(
            tabs: subTabs,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ColorSelector(
                    title: "",
                    selectedColor: selectedIconColor,
                    onColorSelected: (color) {
                      setState(() {
                        selectedIconColor = color;
                        _updateEmbeddedIcon();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ColorSelector(
                    title: "",
                    selectedColor: selectedIconBackgroundColor,
                    onColorSelected: (color) {
                      setState(() {
                        selectedIconBackgroundColor = color;
                        _updateEmbeddedIcon();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateEmbeddedIcon() async {
    if (_selectedIcon == null) return;

    final image = await _iconToImageProvider(
      _selectedIcon!,
      selectedIconColor,
      selectedIconBackgroundColor,
      48,
    );

    if (!mounted) return;

    setState(() {
      _embeddedIconImage = image;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Widget _buildImageSelection() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(onPressed: _pickImage, child: const Text('画像を選択')),
          const SizedBox(height: 16),
          if (_selectedImage != null)
            Image.file(
              _selectedImage!,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            )
          else
            const Text('画像が選択されていません。'),
        ],
      ),
    );
  }

  //上下文字のタブ
  Widget _buildLabelTab() {
    final subTabs = const [Tab(text: "上部ラベル"), Tab(text: "下部ラベル")];

    return DefaultTabController(
      length: subTabs.length,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TabBar(
            tabs: subTabs,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: TabBarView(
              children: [_buildTopLabelInput(), _buildBottomLabelInput()],
            ),
          ),
        ],
      ),
    );
  }

  final availableFonts = [
    'Noto Sans JP',
    'Roboto',
    'Arial',
    'Times New Roman',
    'Courier New',
  ];

  Widget _buildTopLabelInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ① テキスト入力
          const Text("上部に表示するテキスト（最大20文字）"),
          TextField(
            controller: _topTextController,
            maxLength: 20,
            onChanged: (value) {
              _tempTopText = value;
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    topText = _tempTopText;
                  });
                },
                child: const Text('入力'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    topText = null;
                    _tempTopText = "";
                    _topTextController.clear();
                  });
                },
                child: const Text('削除'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ② フォント選択
          const Text("フォント"),
          DropdownButton<String>(
            value: topLabelStyle.fontFamily,
            isExpanded: true,
            items:
                availableFonts.map((font) {
                  return DropdownMenuItem(
                    value: font,
                    child: Text(font, style: TextStyle(fontFamily: font)),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                topLabelStyle = topLabelStyle.copyWith(fontFamily: value);
              });
            },
          ),

          const SizedBox(height: 24),

          // ③ 文字サイズ
          const Text("文字サイズ"),
          Slider(
            value: topLabelStyle.fontSize ?? 16,
            min: 8,
            max: 32,
            divisions: 24,
            label: "${(topLabelStyle.fontSize ?? 16).round()}",
            onChanged: (value) {
              setState(() {
                topLabelStyle = topLabelStyle.copyWith(fontSize: value);
              });
            },
          ),

          const SizedBox(height: 24),

          // ④ 色
          const Text("文字色"),
          ColorSelector(
            title: "",
            selectedColor: topLabelStyle.color ?? Colors.black,
            onColorSelected: (color) {
              setState(() {
                topLabelStyle = topLabelStyle.copyWith(color: color);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomLabelInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("下部に表示するテキスト（最大20文字）"),
            TextField(
              controller: _bottomTextController,
              maxLength: 20,
              onChanged: (value) {
                _tempBottomText = value;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      bottomText = _tempBottomText;
                    });
                  },
                  child: const Text('入力'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      bottomText = null;
                      _tempBottomText = "";
                      _bottomTextController.clear();
                    });
                  },
                  child: const Text('削除'),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text("フォント"),
            DropdownButton<String>(
              value: bottomLabelStyle.fontFamily ?? availableFonts.first,
              onChanged: (String? newFont) {
                setState(() {
                  bottomLabelStyle = bottomLabelStyle.copyWith(
                    fontFamily: newFont,
                  );
                });
              },
              items:
                  availableFonts
                      .map(
                        (font) =>
                            DropdownMenuItem(value: font, child: Text(font)),
                      )
                      .toList(),
            ),

            const SizedBox(height: 24),
            const Text("文字サイズ"),
            Slider(
              value: bottomLabelStyle.fontSize ?? 16,
              min: 8,
              max: 32,
              divisions: 24,
              label: "${(bottomLabelStyle.fontSize ?? 16).round()}",
              onChanged: (value) {
                setState(() {
                  bottomLabelStyle = bottomLabelStyle.copyWith(fontSize: value);
                });
              },
            ),

            const SizedBox(height: 24),
            const Text("文字色"),
            ColorSelector(
              title: "",
              selectedColor: bottomLabelStyle.color ?? Colors.black,
              onColorSelected: (color) {
                setState(() {
                  bottomLabelStyle = bottomLabelStyle.copyWith(color: color);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
