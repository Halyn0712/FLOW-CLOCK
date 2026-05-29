# Flow Clock — Agent 编码规则

## 项目定位

- **产品名**：Flow Clock（自律心流闹钟）
- **目标平台**：Android APK（不上架应用商城，本地安装）
- **核心机制**：微启动 → 心流块 → 起身提醒 → 电子植物奖励

## 技术栈（暂定）

| 层级 | 选择 | 理由 |
|------|------|------|
| 框架 | Flutter 3.x | 单代码库、APK 打包成熟、UI 动画友好（植物生长） |
| 状态管理 | Riverpod | 轻量、可测试 |
| 本地存储 | Hive / shared_preferences | 会话记录、植物状态、设置 |
| 后台计时 | flutter_local_notifications + android_alarm_manager_plus | 锁屏/后台可靠提醒 |
| 植物插画 | flutter_svg + `assets/plants/week/` 7 日轮换 | 见 `docs/ui-design.md` |
| 最低 SDK | Android 8.0 (API 26) | 覆盖绝大多数设备 |

> 若后续需要更深度系统集成（专注模式、Usage Stats），可迁移 Kotlin 原生模块。

## 代码规范

1. **目录结构**
   ```
   lib/
     main.dart
     app/           # 路由、主题
     features/      # timer, garden, settings, stats, share, rewards
     core/          # 常量、工具、通知服务
     models/        # 数据模型
     widgets/       # 通用组件
   ```

2. **命名**：文件名 snake_case，类名 PascalCase，常量 UPPER_SNAKE_CASE
3. **注释**：只注释非显而易见的业务逻辑（计时阶段转换、奖励计算规则）
4. **最小改动原则**：每次 PR/提交只做一件事，不附带无关重构
5. **中文 UI 文案**放在 `lib/l10n/` 或集中常量文件，方便后续国际化

## 不可妥协的产品规则（编码时必须遵守）

- **宽松原则**：仪式阶段无声、无自动跳转；用户手动进入心流
- 每日目标默认 **8 块 / 8 小时**，DailyTree 在 k=8 满冠，k=4 仅为半日里程碑
- 完成完整 Cycle 才给 **+1 Sunlight**；k=4 额外触发半日冠动画
- 一级/二级兑换：**连续收货** 2/5 天（k=8 + 用户点击确认收货），兑换后 R1/R2 清空需重填；不收货不计入
- 用户主动放弃时 **不惩罚**（不扣已有植物，最多不增长）
- 后台计时必须可靠：App 被杀后重启应能恢复当前会话状态
- 不收集用户隐私数据，全部本地存储

## 文档同步

修改功能或架构后，同步更新：
- `SOP.md` — 产品流程与开发 SOP
- `docs/CHANGELOG.md` — 版本变更（有代码后启用）

## 构建 APK

```bash
flutter build apk --release
# 输出：build/app/outputs/flutter-apk/app-release.apk
```

`.vscode/launch.json` 中应包含 `flutter run` 与 `flutter build apk` 任务。
