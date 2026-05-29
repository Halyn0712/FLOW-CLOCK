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
cd "/home/lx/Documents/trae_projects/Flow Clock"
flutter pub get
flutter run          # 真机或模拟器
flutter build apk --release
```

APK 输出：`build/app/outputs/flutter-apk/app-release.apk`

## 3. VS Code

使用 `.vscode/launch.json` 中的 **Flow Clock · Run** 配置。

## 4. 当前 MVP 功能

- 首页节奏盘（7 日植物轮换 + 莫兰迪色）
- 仪式 / 心流 / 休息 / 半日锚点计时
- 仪式无声，心流/休息/半日/收工有闹钟
- 确认收货（k=8 满冠）
- 一级/二级兑换奖励
- 设置（半日锚点 15~90 min）

## 5. 待完成

- 分享卡 share_plus
- [x] 月历视图（月网格 + 单日详情）
- DailyTree 生长动画
