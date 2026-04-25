下面是一版可以直接交给开发的「大字 Big Text」SwiftUI 技术方案 + 组件规格文档。它按你图里的结构组织，目标是：**MVP 极简、可开发、边界清楚，不提前产品膨胀。**

# 「大字」SwiftUI 技术方案 + 组件规格文档 v0.1

## 1. 项目概述

「大字」是一款极简 iOS 小工具。用户输入一段文字后，App 将文字以横屏全屏方式尽可能放大显示，方便在嘈杂、远距离、需要安静提示或临时举牌的场景中使用。

产品核心不是“文字编辑”，而是“快速展示”。因此 v1 不提供字体、颜色、字号、主题、历史库等配置，只保留一个额外能力：**摇动两下切换闪动效果**。

核心路径：

用户打开 App → 输入文字 → 点击显示 → 横屏全屏大字 → 摇两下开启 / 关闭闪动 → 点击返回编辑。

产品原则：

**越少越好。输入、展示、提醒，除此之外都不做。**

## 2. MVP 功能范围

v1 必须包含：

| 功能   | 说明                    |
| ---- | --------------------- |
| 文本输入 | 用户输入字、词、短句或句子         |
| 一键展示 | 点击“显示”进入全屏展示          |
| 横屏展示 | 展示页以横屏体验为主            |
| 自动放大 | 根据屏幕和文本长度自动计算最大字号     |
| 全屏沉浸 | 隐藏导航栏、状态栏，黑底白字        |
| 点击返回 | 展示页轻点屏幕出现返回入口         |
| 摇动两下 | 切换闪动模式开 / 关           |
| 闪动效果 | 慢速、短促、克制，不做高频频闪       |
| 防止锁屏 | 展示页保持屏幕常亮，退出后恢复       |
| 上次文本 | 自动恢复上一次输入内容           |
| 首次提示 | 第一次进入展示页显示“摇两下开启闪动”提示 |

v1 不做：

字体选择、颜色选择、字号滑块、主题、收藏、模板、复杂历史记录、跑马灯、语音输入、图片导出、iCloud 同步、账号系统、分享社区。

## 3. 技术架构

推荐技术栈：

| 层     | 技术                                                  |
| ----- | --------------------------------------------------- |
| UI    | SwiftUI                                             |
| 横竖屏控制 | SwiftUI + 少量 UIKit                                  |
| 动作检测  | Core Motion / CMMotionManager                       |
| 本地状态  | UserDefaults / @AppStorage                          |
| 防锁屏   | UIApplication.shared.isIdleTimerDisabled            |
| 动画    | SwiftUI Animation                                   |
| 可访问性  | SwiftUI accessibilityReduceMotion / UIAccessibility |

Apple 官方文档中，SwiftUI 提供声明式 UI 结构；横竖屏支持可以通过 Info.plist 的 `UISupportedInterfaceOrientations` 和 UIKit 的 view controller orientation 能力控制；Core Motion 用于读取设备运动传感器数据；展示页保持常亮可通过 `isIdleTimerDisabled` 实现。([Apple Developer][1])

推荐架构：

```text
BigTextApp
 └── AppRootView
      ├── EditorView
      │    ├── BigTextInput
      │    └── PrimaryActionButton
      │
      └── DisplayView
           ├── AutoFitTextView
           ├── FlashOverlay
           ├── DisplayHintToast
           └── BackControlOverlay

Services
 ├── ShakeDetector
 ├── OrientationController
 ├── IdleTimerController
 └── TextFitEngine

Data
 └── AppSettingsStore
      ├── lastText
      └── hasSeenShakeHint
```

我建议保持 MVVM-lite，不要过度工程化。这个 App 很小，不需要复杂 Repository、Coordinator 或依赖注入框架。

## 4. 设计规格

整体视觉方向：

黑底白字，极简，接近“电子纸牌 / 临时字幕牌”的感觉。不要装饰，不要图标堆叠，不要拟物，不要复杂品牌色。品牌感来自名字「大字」和极端克制的交互。

### 4.1 编辑页

编辑页目标：让用户快速输入并进入展示。

布局：

```text
┌────────────────────┐
│ 大字                │
│                    │
│ [ 输入内容区域      ] │
│                    │
│ 显示                │
└────────────────────┘
```

规格：

| 项   | 规格                         |
| --- | -------------------------- |
| 背景  | 近黑色                        |
| 标题  | “大字”                       |
| 输入框 | 大面积、多行、无边框或极弱边框            |
| 按钮  | 只有一个主按钮：“显示”               |
| 清空  | 可选，放在输入框右上角，v1 可以先不做       |
| 空状态 | 输入框 placeholder：“输入要展示的文字” |
| 键盘  | 默认系统键盘                     |
| 方向  | 竖屏友好                       |

交互：

输入为空时，“显示”按钮禁用。
输入非空时，“显示”按钮可用。
用户再次打开 App 时，恢复上一次输入内容。

### 4.2 展示页

展示页目标：让文字在横屏下最大、最清楚、最稳定。

布局：

```text
┌────────────────────────────────────┐
│                                    │
│              我到了                │
│                                    │
└────────────────────────────────────┘
```

规格：

| 项   | 规格                      |
| --- | ----------------------- |
| 背景  | #000000                 |
| 文字  | #FFFFFF                 |
| 对齐  | 水平垂直居中                  |
| 字重  | Heavy / Black           |
| 行距  | 紧凑但不碰撞                  |
| 安全区 | 尊重刘海、圆角和 Home Indicator |
| 控件  | 默认隐藏                    |
| 返回  | 点击屏幕后淡入，2 秒后淡出          |
| 常亮  | 展示页进入时开启，退出时关闭          |

展示页应尽量横屏。技术实现上有两种路线：

第一种，MVP 推荐：App 支持竖屏和横屏，展示页在竖屏时显示“请横过手机”的极简提示，用户旋转后进入最佳展示状态。这种实现最稳、审核风险最低、用户也容易理解。

第二种，进阶：展示页尝试强制横屏，需要 UIKit 层配合控制 supported orientations。由于 SwiftUI 自身不是为逐页面强制方向设计的，这部分建议用 UIKit bridge 实现，不建议在 MVP 里过度折腾。Apple 的方向控制机制本质上仍依赖 App 和 View Controller 所声明的 supported orientations。([Apple Developer][2])

## 5. Design Tokens

虽然用户不可配置，但内部仍需要固定 tokens，保证界面一致。

```text
Color
- appBackground: #050505
- surface: #111111
- textPrimary: #FFFFFF
- textSecondary: rgba(255,255,255,0.55)
- textDisabled: rgba(255,255,255,0.28)
- controlBackground: rgba(255,255,255,0.10)
- controlBackgroundPressed: rgba(255,255,255,0.16)

Typography
- appTitle: system rounded / semibold / 28
- inputText: system / regular / 28
- buttonText: system / semibold / 20
- displayText: system / black / auto-fit
- hintText: system / medium / 15

Spacing
- pagePadding: 24
- inputPadding: 20
- buttonHeight: 56
- cornerRadius: 20
- overlayPadding: 18

Animation
- overlayFade: 0.18s
- flashPulse: 0.35s per pulse
- flashRepeat: 2 pulses
```

说明：用户看不到这些配置，也不能改。tokens 是开发内部的一致性约束。

## 6. 屏幕清单

### Screen 1：EditorView

用途：输入文字。

状态：

| 状态       | 说明                       |
| -------- | ------------------------ |
| Empty    | 没有文字，显示 placeholder，按钮禁用 |
| Editing  | 正在输入，按钮可用                |
| Restored | 打开 App 后恢复上次文本           |
| Too Long | 文本过长时轻提示，不阻止展示           |

建议极长文本判断：

超过 80 个中文字符或 120 个英文字符时，显示一行弱提示：“文字较长，展示时会自动缩小。”

### Screen 2：DisplayView

用途：全屏大字展示。

状态：

| 状态              | 说明                        |
| --------------- | ------------------------- |
| Normal          | 黑底白字                      |
| ControlsVisible | 点击屏幕后显示返回控件               |
| FlashingOn      | 闪动模式已开启                   |
| FlashingOff     | 闪动模式已关闭                   |
| PortraitHint    | 如果当前竖屏，提示横过手机             |
| ReduceMotion    | 系统开启减少动态效果时，禁用强闪动，使用更温和提示 |

### Screen 3：FirstUseHint

不是独立页面，只是展示页中的临时提示。

文案：

“摇两下开启闪动”

出现规则：

第一次进入展示页显示 1.5 秒。之后不再显示。

## 7. 组件规格

### 7.1 AppRootView

职责：

管理编辑页与展示页的切换。

状态：

```swift
enum AppMode {
    case editing
    case displaying
}
```

输入：

| 属性    | 类型               | 说明   |
| ----- | ---------------- | ---- |
| store | AppSettingsStore | 本地设置 |
| mode  | AppMode          | 当前模式 |

输出：

切换展示、返回编辑。

### 7.2 EditorView

职责：

承载文本输入和“显示”按钮。

属性：

| 名称     | 类型              | 说明     |
| ------ | --------------- | ------ |
| text   | Binding<String> | 当前输入文本 |
| onShow | () -> Void      | 进入展示页  |

规则：

文本 trim 后为空，按钮不可点击。
每次输入变化后，保存到 lastText。
输入框应自动 focus，可选；如果影响启动稳定性，可以 v1.1 再做。

### 7.3 BigTextInput

职责：

极简多行输入框。

规格：

| 项           | 说明         |
| ----------- | ---------- |
| 最小高度        | 屏幕高度约 45%  |
| 字号          | 28         |
| 背景          | 深灰或透明      |
| 光标          | 白色         |
| Placeholder | “输入要展示的文字” |

### 7.4 PrimaryActionButton

职责：

唯一主操作按钮。

状态：

| 状态       | 视觉         |
| -------- | ---------- |
| Enabled  | 白底黑字       |
| Disabled | 半透明白底、灰字   |
| Pressed  | 轻微缩放或透明度变化 |

### 7.5 DisplayView

职责：

全屏展示文本，管理展示状态。

属性：

| 名称              | 类型         | 说明     |
| --------------- | ---------- | ------ |
| text            | String     | 要展示的文字 |
| isFlashing      | Bool       | 是否闪动   |
| controlsVisible | Bool       | 控件是否显示 |
| onBack          | () -> Void | 返回编辑   |

生命周期：

进入时开启 idle timer disabled。
退出时恢复 idle timer。
开始监听 shake。
退出时停止监听 shake。
Apple 文档也提醒，只有在确实需要持续显示内容的 App 中才应禁用 idle timer；本 App 的展示页符合这个使用场景，但应该只在展示页开启。([Apple Developer][3])

### 7.6 AutoFitTextView

职责：

根据容器尺寸自动计算最大字号。

输入：

| 名称            | 类型     | 说明            |
| ------------- | ------ | ------------- |
| text          | String | 展示文本          |
| availableSize | CGSize | 可用区域          |
| maxLines      | Int    | 最大行数，建议 3 到 5 |

策略：

优先让短文本单行显示。
中等文本允许换行。
长文本逐步缩小字号。
字号设置上下限，避免过大或过小。

建议字号范围：

```text
minFontSize: 36
maxFontSize: 320
```

算法建议：

使用二分查找计算可容纳的最大字号。
每次用目标字号测量文本 bounding size。
如果超出容器，缩小；否则放大。
最终取可容纳的最大值。

### 7.7 ShakeDetector

职责：

检测“双次摇动”并触发闪动开关。

推荐使用 Core Motion 的 `CMMotionManager`，因为单纯系统 shake gesture 不容易稳定表达“两下”的业务语义；Core Motion 官方文档说明它可以读取设备运动和传感器数据，`CMMotionManager` 用于启动设备运动服务。([Apple Developer][4])

规则建议：

| 项               | 建议                            |
| --------------- | ----------------------------- |
| 采样间隔            | 1/30 秒                        |
| shake 阈值        | acceleration magnitude > 2.2g |
| double shake 窗口 | 0.7 秒内两次                      |
| 冷却时间            | 1.0 秒                         |
| 触发反馈            | 轻微 haptic，可选                  |

伪逻辑：

```text
检测到一次明显摇动
如果距离上一次摇动 < 0.7s，则触发 toggleFlash
触发后进入 1s cooldown
否则记录为 firstShake
```

### 7.8 FlashOverlay

职责：

实现闪动视觉效果。

重要约束：

不要做高频闪烁。WCAG 对闪烁内容有“三次闪烁”相关限制；SwiftUI 也提供 `accessibilityReduceMotion` 环境值，系统开启减少动态效果时应避免强运动动画。([Apple Developer][5])

效果建议：

不是疯狂频闪，而是“注意力脉冲”。

```text
Normal:
黑底白字

Flash:
白底黑字 → 黑底白字 → 白底黑字 → 黑底白字
总时长约 0.8s
之后保持 isFlashing = true，但不持续高频闪
```

这里我建议把“闪动模式”设计成：开启后，每隔 2.5 秒做一次两段式慢速脉冲；关闭后停止。这样有提示效果，但不会变成刺眼的频闪。

如果系统开启 Reduce Motion：

不要反复闪动。改成一次轻微亮度变化，或者只显示一个很小的 “闪动已开启” 状态提示。

### 7.9 DisplayHintToast

职责：

显示一次性提示。

文案：

| 场景      | 文案        |
| ------- | --------- |
| 首次进入展示页 | 摇两下开启闪动   |
| 闪动开启    | 闪动已开启     |
| 闪动关闭    | 闪动已关闭     |
| 竖屏状态    | 横过手机展示更清楚 |

规格：

黑底时使用半透明白色胶囊，不要打扰主体文字。

### 7.10 BackControlOverlay

职责：

展示页返回入口。

交互：

轻点屏幕显示。
2 秒无操作自动隐藏。
按钮位置建议左上角，避开主体文字。

文案：

“返回”

不要使用复杂 toolbar。

## 8. SwiftUI 代码结构建议

目录结构：

```text
BigText/
 ├── BigTextApp.swift
 ├── AppRootView.swift
 │
 ├── Features/
 │    ├── Editor/
 │    │    ├── EditorView.swift
 │    │    ├── BigTextInput.swift
 │    │    └── PrimaryActionButton.swift
 │    │
 │    └── Display/
 │         ├── DisplayView.swift
 │         ├── AutoFitTextView.swift
 │         ├── FlashOverlay.swift
 │         ├── DisplayHintToast.swift
 │         └── BackControlOverlay.swift
 │
 ├── Services/
 │    ├── ShakeDetector.swift
 │    ├── TextFitEngine.swift
 │    ├── IdleTimerController.swift
 │    └── OrientationController.swift
 │
 ├── Data/
 │    └── AppSettingsStore.swift
 │
 └── Design/
      ├── BigTextColors.swift
      ├── BigTextTypography.swift
      └── BigTextSpacing.swift
```

### 8.1 AppSettingsStore

```swift
import SwiftUI

@MainActor
final class AppSettingsStore: ObservableObject {
    @AppStorage("lastText") var lastText: String = ""
    @AppStorage("hasSeenShakeHint") var hasSeenShakeHint: Bool = false
}
```

### 8.2 IdleTimerController

```swift
import UIKit

enum IdleTimerController {
    static func setDisabled(_ disabled: Bool) {
        UIApplication.shared.isIdleTimerDisabled = disabled
    }
}
```

### 8.3 ShakeDetector 接口

```swift
import Foundation

@MainActor
final class ShakeDetector: ObservableObject {
    var onDoubleShake: (() -> Void)?

    func start() {
    }

    func stop() {
    }
}
```

实现细节放到开发阶段完成。这里建议先写单元可测的检测逻辑，把 Core Motion 数据输入和 double-shake 判断拆开。

### 8.4 TextFitEngine 接口

```swift
import CoreGraphics

struct TextFitEngine {
    func bestFontSize(
        text: String,
        availableSize: CGSize,
        minFontSize: CGFloat,
        maxFontSize: CGFloat,
        maxLines: Int
    ) -> CGFloat {
        return minFontSize
    }
}
```

MVP 可以先用 SwiftUI `minimumScaleFactor` 做第一版，但如果要体验稳定，建议后续实现真实测量 + 二分查找。因为这个 App 的核心体验就是“字到底能不能尽可能大”。

## 9. 数据层

只使用本地轻量状态。

| Key              | 类型     | 说明       |
| ---------------- | ------ | -------- |
| lastText         | String | 上一次输入文本  |
| hasSeenShakeHint | Bool   | 是否看过摇动提示 |

不需要数据库。
不需要 iCloud。
不需要账号。
不需要网络权限。
不需要分析埋点。

## 10. 第三方依赖

v1 建议：**零第三方依赖。**

原因：

这个 App 的功能非常小，SwiftUI、UIKit、Core Motion 已经足够。引入三方库会增加包体、维护成本和审核不确定性。

系统框架：

| Framework  | 用途                |
| ---------- | ----------------- |
| SwiftUI    | UI                |
| UIKit      | idle timer、方向控制补充 |
| CoreMotion | 摇动检测              |
| Combine    | 可选，用于状态流          |

## 11. MVP 里程碑

### Milestone 1：基础可用

目标：能输入、能展示、能返回。

交付：

| 项             | 状态 |
| ------------- | -- |
| EditorView    | 完成 |
| DisplayView   | 完成 |
| 黑底白字全屏        | 完成 |
| 自动恢复 lastText | 完成 |
| 点击返回          | 完成 |

### Milestone 2：展示体验打磨

目标：让展示页真正好用。

交付：

| 项     | 状态 |
| ----- | -- |
| 横屏适配  | 完成 |
| 自动字号  | 完成 |
| 安全区适配 | 完成 |
| 防止锁屏  | 完成 |
| 竖屏提示  | 完成 |

### Milestone 3：摇动和闪动

目标：完成唯一增强功能。

交付：

| 项                    | 状态 |
| -------------------- | -- |
| Core Motion shake 检测 | 完成 |
| 双摇触发                 | 完成 |
| 闪动开关                 | 完成 |
| 首次提示                 | 完成 |
| Reduce Motion 适配     | 完成 |

### Milestone 4：上架前 polish

目标：可提交 TestFlight。

交付：

| 项             | 状态 |
| ------------- | -- |
| App Icon      | 完成 |
| Launch Screen | 完成 |
| 空状态文案         | 完成 |
| 长文本提示         | 完成 |
| 真机测试          | 完成 |
| App Store 截图  | 完成 |

## 12. 验收清单

### 功能验收

| 验收项   | 通过标准       |
| ----- | ---------- |
| 输入为空  | 显示按钮不可用    |
| 输入短词  | 横屏后文字尽可能大  |
| 输入长句  | 自动换行并完整显示  |
| 点击展示  | 进入全屏黑底白字   |
| 点击屏幕  | 返回按钮淡入     |
| 点击返回  | 回到编辑页，内容保留 |
| 进入展示页 | 屏幕不自动锁定    |
| 退出展示页 | 恢复系统锁屏行为   |
| 摇动两下  | 闪动开启       |
| 再摇两下  | 闪动关闭       |
| 首次进入  | 显示摇动提示     |
| 第二次进入 | 不再重复显示首次提示 |

### 视觉验收

| 验收项 | 通过标准            |
| --- | --------------- |
| 编辑页 | 只有输入和显示按钮，无多余设置 |
| 展示页 | 主体只有文字          |
| 控件  | 默认隐藏，不干扰阅读      |
| 字体  | 粗、大、清楚          |
| 背景  | 纯黑或近黑           |
| 动画  | 克制，不刺眼          |

### 可访问性验收

| 验收项           | 通过标准            |
| ------------- | --------------- |
| Reduce Motion | 开启后不做强烈闪动       |
| Dynamic Type  | 编辑页可基本适配系统字体    |
| VoiceOver     | 输入框和按钮有清晰标签     |
| 闪动频率          | 不做高频频闪          |
| 横屏提示          | 竖屏时用户知道如何获得最佳展示 |

### 真机测试清单

至少测试：

| 设备               | 重点        |
| ---------------- | --------- |
| 小屏 iPhone        | 字号计算、按钮布局 |
| 大屏 iPhone        | 横屏展示效果    |
| 带刘海设备            | 安全区       |
| iOS 深色模式         | 保持一致      |
| Reduce Motion 开启 | 闪动替代效果    |
| 长文本              | 自动缩放和换行   |
| 单个大字             | 是否足够震撼    |
| 英文长词             | 是否溢出      |
| 中英文混排            | 换行是否自然    |

## 13. 开发建议结论

这个 App 不应该从“功能完整”角度开发，而应该从“体验完整”角度开发。

优先级应该是：

第一，输入到展示的路径极快。
第二，横屏展示的字足够大。
第三，摇两下开关闪动稳定。
第四，界面没有任何多余东西。

我建议第一版就叫：

**大字 — Big Text**

App Store 副标题可以是：

**输入一句话，全屏放大给别人看。**

最终交付目标不是做一个“文字工具箱”，而是做一个用户一打开就明白、三秒内完成使用的小工具。

[1]: https://developer.apple.com/documentation/swiftui?utm_source=chatgpt.com "SwiftUI | Apple Developer Documentation"
[2]: https://developer.apple.com/documentation/bundleresources/information-property-list/uisupportedinterfaceorientations?utm_source=chatgpt.com "UISupportedInterfaceOrientations"
[3]: https://developer.apple.com/documentation/uikit/uiapplication/isidletimerdisabled?utm_source=chatgpt.com "isIdleTimerDisabled | Apple Developer Documentation"
[4]: https://developer.apple.com/documentation/coremotion/?utm_source=chatgpt.com "Core Motion | Apple Developer Documentation"
[5]: https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion?utm_source=chatgpt.com "accessibilityReduceMotion | Apple Developer Documentation"
