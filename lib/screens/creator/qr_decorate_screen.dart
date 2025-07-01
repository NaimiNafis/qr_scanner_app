import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/qr_create_data.dart';
import 'color_selector.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

class QrDecorateScreen extends StatefulWidget {
  final QrCreateData qrData;

  const QrDecorateScreen({Key? key, required this.qrData}) : super(key: key);

  @override
  State<QrDecorateScreen> createState() => _QrDecorateScreenState();
}

class _QrDecorateScreenState extends State<QrDecorateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Color foregroundColor = Colors.black;
  Color backgroundColor = Colors.white;

  String backgroundStyle = "normal";

  IconData? centerIcon = null;
  String? centerText = null;
  IconPickerIcon? _selectedIcon;

  String? topText;
  String? bottomText;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              Navigator.pop(context);
            },
            child: const Text("生成", style: TextStyle(color: Colors.white)),
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
          colors: [
            Colors.grey.shade300, // 上部
            Colors.grey.shade400, // 下部
          ],
          stops: [0.67, 1.0],
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: decoration,
              padding: const EdgeInsets.all(16),
              child: QrImageView(
                data: widget.qrData.content,
                version: QrVersions.auto,
                size: 180,
                foregroundColor: foregroundColor,
                backgroundColor: Colors.transparent,
              ),
            ),
            if (_selectedIcon != null)
              Icon(
                _selectedIcon!.data,
                size: 64, // 必要に応じて調整
                color: foregroundColor,
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
        children: [
          const Text("ピクセルの形（仮）"),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(label: const Text("丸"), selected: true),
              ChoiceChip(label: const Text("四角"), selected: false),
              ChoiceChip(label: const Text("ダイヤ"), selected: false),
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
      //Tab(text: "画像（未実装）"),
      Tab(text: "テキスト"),
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
                //_buildImageComingSoon(),
                _buildCenterTextInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: _pickIcon, // タブを開いたときに即ピッカーを呼ぶ
          icon: Icon(_selectedIcon?.data ?? Icons.add),
          label: const Text("アイコンを選ぶ"),
        ),
      ),
    );
  }

  Future<void> _pickIcon() async {
    IconPickerIcon? pickedIcon = await showIconPicker(context);

    if (pickedIcon != null) {
      // アイコンが選ばれた場合の処理
      setState(() {
        _selectedIcon = pickedIcon;
      });
    }
  }

  /*
Widget _buildImageComingSoon() {
  return const Center(
    child: Text(
      "この機能は今後追加予定です",
      style: TextStyle(color: Colors.grey),
    ),
  );
}
*/

  Widget _buildCenterTextInput() {
    final controller = TextEditingController(text: centerText ?? "");

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("中央に表示するテキスト（最大10文字）"),
          TextField(
            controller: controller,
            maxLength: 10,
            onChanged: (value) {
              setState(() {
                centerText = value;
                centerIcon = null;
                //centerImage = null;
              });
            },
          ),
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

  Widget _buildTopLabelInput() {
    final controller = TextEditingController(text: topText ?? "");

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("上部に表示するテキスト（最大20文字）"),
          TextField(
            controller: controller,
            maxLength: 20,
            onChanged: (value) {
              setState(() => topText = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomLabelInput() {
    final controller = TextEditingController(text: bottomText ?? "");

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("下部に表示するテキスト（最大20文字）"),
          TextField(
            controller: controller,
            maxLength: 20,
            onChanged: (value) {
              setState(() => bottomText = value);
            },
          ),
        ],
      ),
    );
  }

  Future<Color?> pickColor(Color current) async {
    return showDialog<Color>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("色を選択（仮）"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, Colors.red),
                  child: const Text("赤"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, Colors.green),
                  child: const Text("緑"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, Colors.blue),
                  child: const Text("青"),
                ),
              ],
            ),
          ),
    );
  }
}
