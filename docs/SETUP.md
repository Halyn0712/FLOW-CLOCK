# Flow Clock — 开发环境安装

## 1. 安装 Flutter

```bash
# 若未安装
git clone https://github.com/flutter/flutter.git -b stable --depth 1 ~/flutter
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
flutter doctor
```

## 2. 运行项目

```bash
cd "d:\zxl project\Flow Clock"
flutter pub get
flutter run          # 真机或模拟器
flutter build apk --release
```

APK 输出：`build/app/outputs/flutter-apk/app-release.apk`

## 3. VS Code / Cursor

使用 `.vscode/launch.json` 中的 **Flow Clock · Run** 配置。

Git 日常流程与版本标签见 [`docs/GIT.md`](./GIT.md)。

## 3.1 Git 远程仓库

- 地址：<https://github.com/Halyn0712/FLOW-CLOCK>
- 主分支：`main`
- 收工前：`git add .` → `git commit -m "说明"` → `git push`

## 4. 当前 MVP 功能

- 首页节奏盘（7 日植物轮换 + 莫兰迪色）
- 仪式 / 心流 / 休息 / 半日锚点计时
- 仪式无声，心流/休息/半日/收工有闹钟
- 确认收货（k=8 满冠）
- 一级/二级兑换奖励
- 设置（半日锚点 15~90 min）

## 5. 待完成

- [x] 分享卡 share_plus
- [x] 月历视图（月网格 + 单日详情）
- [x] DailyTree 生长动画（k=0~8）
- [x] 后台精确闹钟（杀进程/锁屏恢复）
- [x] 月历历史日分享
- [x] 月末森林长图分享
- [x] 分享卡多皮肤（简约/森林/深色）

## 6. 发布 v0.6.0 APK

### 6.1 构建

```bash
cd "d:\zxl project\Flow Clock"
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

输出路径：

```
build/app/outputs/flutter-apk/app-release.apk
```

也可在 Cursor 中运行任务 **Flow Clock · Build APK**（见 `.vscode/tasks.json`）。

### 6.2 安装到手机

1. 用数据线连接 Android 手机，开启「USB 调试」
2. 执行：

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

或把 `app-release.apk` 复制到手机，文件管理器里点击安装（需允许「未知来源」）。

### 6.3 打 Git 标签（版本里程碑）

```bash
git add .
git commit -m "release: v0.6.0 MVP"
git push

git tag -a v0.6.0 -m "v0.6.0: 分享、月历、DailyTree、后台闹钟"
git push origin v0.6.0
```

详见 [`docs/GIT.md`](./GIT.md)。
