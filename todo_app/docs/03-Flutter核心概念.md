# 第三章：Flutter 核心概念

在正式开始编写待办事项应用之前，我们需要理解 Flutter 的三个核心概念。这些概念是 Flutter 的基石，理解它们将帮助你更好地开发 Flutter 应用。

## 3.1 Widget（组件）

### 什么是 Widget？

**Widget 是 Flutter 中一切的基础。** 在 Flutter 中，几乎所有东西都是 Widget。

想象一下你在搭积木：
- 每一块积木就是一个 Widget
- 你可以把小块积木组合成大的结构
- 整个应用就是一堆 Widget 组成的树

### Widget 类比

```
网页开发    →   HTML 元素（div, span, button）
Android    →   View（TextView, Button, ImageView）
iOS        →   UIView（UILabel, UIButton, UIImageView）
Flutter    →   Widget（Text, ElevatedButton, Image）
```

### Widget 的类型

Flutter 中有两种主要的 Widget 类型：

#### 1. StatelessWidget（无状态组件）

**特点：** 一旦创建，就不会改变。

**什么时候用：** 显示静态内容，比如标题、图标、纯展示的文字。

```dart
// 这是一个简单的 StatelessWidget
import 'package:flutter/material.dart';

class HelloWidget extends StatelessWidget {
  const HelloWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('你好，Flutter！');
  }
}
```

#### 2. StatefulWidget（有状态组件）

**特点：** 可以改变自己的状态，界面会随之更新。

**什么时候用：** 需要交互的组件，比如按钮、输入框、计数器。

```dart
// 这是一个简单的 StatefulWidget
import 'package:flutter/material.dart';

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;  // 状态变量

  void _increment() {
    setState(() {   // 调用 setState 会触发界面重绘
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('点击次数: $_count'),
        ElevatedButton(
          onPressed: _increment,
          child: const Text('点击我'),
        ),
      ],
    );
  }
}
```

### 常用 Widget 速查表

| Widget | 作用 | 类比 |
|--------|------|------|
| `Text` | 显示文字 | `<span>` |
| `Container` | 容器，可以设置宽高、背景、边距 | `<div>` |
| `Row` | 水平排列子组件 | `flex-direction: row` |
| `Column` | 垂直排列子组件 | `flex-direction: column` |
| `Stack` | 层叠排列子组件 | `position: absolute` |
| `ListView` | 滚动列表 | `<ul>` |
| `Image` | 显示图片 | `<img>` |
| `Icon` | 显示图标 | 字体图标 |
| `ElevatedButton` | 凸起按钮 | `<button>` |
| `TextField` | 文本输入框 | `<input>` |
| `Scaffold` | 页面基本结构（AppBar + Body + FAB） | 页面布局 |
| `AppBar` | 顶部导航栏 | `<header>` |

### Widget 组合示例

```dart
class MyCard extends StatelessWidget {
  const MyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(                    // 外层容器
      padding: const EdgeInsets.all(16), // 内边距
      decoration: BoxDecoration(         // 装饰
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(                     // 垂直排列
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star, color: Colors.yellow),
          const SizedBox(height: 8),     // 间距
          const Text(
            '标题',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text('这是描述文字'),
          const SizedBox(height: 16),
          Row(                           // 水平排列
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('确定'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

效果：

```
┌─────────────────────┐
│ ⭐                  │
│                     │
│ 标题                │
│ 这是描述文字        │
│                     │
│        [取消] [确定]│
└─────────────────────┘
```

## 3.2 State（状态）

### 什么是 State？

**State 是 Widget 的数据。** 当 State 改变时，Widget 会重新构建（rebuild），界面就会更新。

### 状态管理的两种方式

#### 1. 局部状态（Local State）

只在单个 Widget 内部使用，用 `setState()` 管理。

```dart
class LikeButton extends StatefulWidget {
  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _isLiked = false;  // 局部状态
  int _likeCount = 0;

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? Colors.red : null,
          ),
          onPressed: _toggleLike,
        ),
        Text('$_likeCount'),
      ],
    );
  }
}
```

#### 2. 全局状态（Global State）

需要在多个 Widget 之间共享的状态，使用 Provider、Riverpod、Bloc 等状态管理方案。

在我们的待办事项应用中，任务列表需要在多个页面共享，所以使用 **Provider** 来管理。

### setState() 的工作原理

```dart
setState(() {
  // 1. 在这里修改状态变量
  _count++;
});
// 2. 自动调用 build() 方法重建界面
```

**重要：** 只能在 StatefulWidget 的 State 类中调用 `setState()`。

## 3.3 Build 方法

### 什么是 Build 方法？

每个 Widget 都必须实现 `build()` 方法。这个方法描述了 Widget 的 UI 结构。

```dart
@override
Widget build(BuildContext context) {
  // 返回一个 Widget 树
  return SomeWidget(
    child: AnotherWidget(
      child: Text('Hello'),
    ),
  );
}
```

### BuildContext 是什么？

`BuildContext` 表示 Widget 在树中的位置。你可以用它来获取主题、媒体查询等信息。

```dart
@override
Widget build(BuildContext context) {
  // 获取当前主题
  final theme = Theme.of(context);
  
  // 获取屏幕尺寸
  final size = MediaQuery.of(context).size;
  
  // 获取颜色方案
  final colorScheme = theme.colorScheme;
  
  return Text(
    'Hello',
    style: TextStyle(color: colorScheme.primary),
  );
}
```

### Build 方法的执行时机

1. **Widget 第一次创建时**
2. **调用 setState() 后**
3. **父 Widget 重建时**
4. **依赖的数据变化时**

### 构建优化

`build()` 方法可能会被频繁调用，所以应该：

✅ **应该做的：**
- 保持 build 方法简单
- 将复杂计算移到 build 之外
- 使用 const 构造函数

❌ **不应该做的：**
- 在 build 中做耗时操作
- 在 build 中创建大量对象
- 在 build 中调用 setState()

```dart
// ❌ 不好的做法
@override
Widget build(BuildContext context) {
  // 每次 build 都会重新计算
  final expensiveResult = doExpensiveCalculation();
  
  return Text(expensiveResult);
}

// ✅ 好的做法
class _MyWidgetState extends State<MyWidget> {
  String? _expensiveResult;
  
  @override
  void initState() {
    super.initState();
    // 只在初始化时计算一次
    _expensiveResult = doExpensiveCalculation();
  }
  
  @override
  Widget build(BuildContext context) {
    return Text(_expensiveResult ?? '');
  }
}
```

## 3.4 Widget 树、元素树和渲染树

Flutter 有三棵树，作为初学者了解即可：

```
Widget 树（你的代码）    Element 树（中间层）    Render 树（实际绘制）

    MyApp                   Element                RenderView
      |                        |                       |
   Scaffold                ScaffoldElement        RenderScaffold
      |                        |                       |
   AppBar                  AppBarElement          RenderAppBar
      |                        |                       |
   Text("Hi")              TextElement            RenderParagraph
```

**你只需要关心 Widget 树**，Flutter 会自动处理其他两棵树。

## 3.5 小结

| 概念 | 一句话解释 |
|------|-----------|
| Widget | 构建 UI 的基本单元，一切皆为 Widget |
| State | Widget 的数据，改变会触发界面更新 |
| Build | 描述 Widget 外观的方法 |

记住这张图：

```
用户操作 → 修改 State → 调用 setState() → 重建 Widget → 更新界面
```

---

**下一步**：[第四章：项目结构解析](./04-项目结构解析.md)
