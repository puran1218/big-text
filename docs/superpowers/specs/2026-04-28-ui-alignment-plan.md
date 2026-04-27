# UI 对齐计划

**目标:** 使当前实现与设计图对齐，同时保持中英双语支持（跟随 iOS 系统语言）

**日期:** 2026-04-28

---

## 设计 vs 实现差异分析

### ✅ 已实现的功能

| 功能 | 状态 |
|------|------|
| 全屏黑底白字 | ✓ |
| 输入框 + 显示按钮 | ✓ |
| 横屏自动适配 | ✓ |
| 摇两下闪动 | ✓ |
| 屏幕常亮 | ✓ |
| 上次内容恢复 | ✓ |
| 点击显示控制 | ✓ |
| 返回按钮 | ✓ |
| 中英双语 (iOS系统) | ✓ |

### ❌ 待修复的差异

| # | 差异 | 设计要求 | 当前实现 |
|---|------|----------|----------|
| 1 | **字数统计显示** | 输入框底部显示 "X/200" | 缺失 |
| 2 | **字数限制** | 最多200字符 | 无限制 |
| 3 | **应用标题区域** | "大字" + "Big Text" | 只有 "Big Text" |
| 4 | **按钮文字** | "显示" / "Show" (双语) | "Show" (未本地化) |
| 5 | **输入占位符** | 双语占位符 | "Enter text to display" |
| 6 | **横屏提示** | 双语提示 | "Turn phone for better display" |
| 7 | **摇动提示** | 双语提示 | "Shake twice to toggle flash" |

---

## 实施计划

### 阶段 1: 字数统计和限制 (P0)

**文件:** `BigText/Features/Editor/BigTextInput.swift`

**改动:**
- 添加字数统计显示 (X/200)
- 限制最大输入200字符
- 字数接近限制时变色提示
- 超过限制时截断或禁用按钮

**本地化键 (需添加到 Localizable.xcstrings):**
- `editor.characterCount` = "%d/200"
- `editor.characterLimit` = "200"

---

### 阶段 2: 完善本地化字符串 (P0)

**文件:** `Localizable.xcstrings`

**需要添加/更新的键:**

| 键 | 英文 | 中文 |
|---|------|------|
| `app.title` | Big Text | 大字 |
| `app.subtitle` | Type one line. Show it big. | 输入一句话，全屏放大给别人看 |
| `editor.showButton` | Show | 显示 |
| `editor.placeholder` | Enter text to display | 输入要显示的文字 |
| `display.landscapeHint` | Turn phone for better display | 横过手机，文字更大 |
| `display.shakeHint` | Shake twice to toggle flash | 摇两下切换闪动 |
| `display.tapToShowControls` | Tap to show controls | 轻点屏幕显示控制 |
| `display.backButton` | Back | 返回 |

**需要更新的文件:**
- `EditorView.swift` - 更新标题区域
- `BigTextInput.swift` - 使用本地化占位符
- `PrimaryActionButton.swift` - 使用本地化按钮文字
- `DisplayView.swift` - 使用本地化提示文字
- `DisplayHintToast.swift` - 使用本地化提示
- `BackControlOverlay.swift` - 使用本地化返回按钮

---

### 阶段 3: 应用标题区域优化 (P1)

**文件:** `BigText/Features/Editor/EditorView.swift`

**改动:**
- 主标题: "大字" / "Big Text" (根据系统语言显示主标题)
- 副标题: "Big Text" / "大字" (对应语言的副标题)
- 标语: "Type one line. Show it big." / "输入一句话，全屏放大给别人看"
- 布局调整为垂直排列，居中对齐或左对齐

**设计参考:**
```
┌─────────────────────┐
│ 大字                 │  ← 主标题 (大号)
│ Big Text             │  ← 副标题 (中号)
│ 输入一句话，全屏放大   │  ← 标语 (小号，灰色)
│ [输入框]             │
│ [显示]               │
└─────────────────────┘
```

---

### 阶段 4: 提示样式优化 (P2)

**文件:** `BigText/Features/Display/DisplayHintToast.swift`

**改动:**
- 确保提示在底部显示
- 2秒后自动淡出
- 半透明深色背景

---

## 技术细节

### 字数限制实现

```swift
// BigTextInput.swift 添加
private let maxCharacters = 200
private var characterCount: Int { text.count }

var body: some View {
    VStack {
        ZStack(alignment: .topLeading) {
            // 现有输入框
        }
        .frame(minHeight: 300)
        .background(BigTextColors.surface)
        .cornerRadius(BigTextSpacing.cornerRadius)

        // 字数统计
        HStack {
            Spacer()
            Text("editor.characterCount", bundle: .main)
                .font(.caption)
                .foregroundStyle(characterCount > maxCharacters * 9 / 10 ? .red : .secondary)
        }
        .padding(.horizontal, BigTextSpacing.inputPadding)
    }
}
```

### 本地化字符串格式

Localizable.xcstrings 使用 String Catalog 格式:
```json
{
  "sourceLanguage" : "en",
  "strings" : {
    "app.title" : {
      "localizations" : {
        "en" : { "stringUnit" : { "state" : "translated", "value" : "Big Text" } },
        "zh-Hans" : { "stringUnit" : { "state" : "translated", "value" : "大字" } }
      }
    }
  }
}
```

---

## 验收标准

完成后的应用应该:
1. ✓ 显示字数统计 "X/200"
2. ✓ 输入限制在200字符以内
3. ✓ 根据iOS系统语言显示对应的界面文字
4. ✓ 应用标题包含主标题、副标题和标语
5. ✓ 所有提示文字使用本地化字符串
6. ✓ 现有测试全部通过

---

## 执行顺序

1. **阶段 1:** 字数统计和限制
2. **阶段 2:** 完善本地化字符串
3. **阶段 3:** 应用标题区域优化
4. **阶段 4:** 提示样式优化 (可选)
5. **测试验证:** 运行全部测试，手动验证中英双语切换
