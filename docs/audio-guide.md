# Flow Clock — 音频资源指南

> 最后更新：2026-05-29

## 设计原则

| 阶段 | 是否播放提示音 | 原因 |
|------|--------------|------|
| 仪式（微启动 / 桥接 / 轻过渡 / 午后重启） | **否** | 无声衔接心流，你自己决定何时进入 |
| 心流块结束 | **是** | 像闹钟，提醒起身 |
| 块间休息结束 | **是** | 不同音色，提醒回到工作 |
| 半日锚点结束 | **是** | 温和提醒「下午开始了」 |
| 8h 收工 | **是** | 圆满仪式感 |

---

## 已内置音频（`assets/audio/`）

| 文件名 | 用途 | 来源 | 许可 |
|--------|------|------|------|
| `flow_end.wav` | 心流 1h 结束 · 起身提醒 | [Mixkit #2869 Bell notification](https://mixkit.co/free-sound-effects/bell/) | Mixkit License（免费商用，无需署名） |
| `break_end.wav` | 休息结束 · 回到工作 | [Mixkit #3109 Relaxing bell chime](https://mixkit.co/free-sound-effects/bell/) | 同上 |
| `halfday_end.wav` | 半日锚点结束 · 下午开始 | [Mixkit #937 Happy bells notification](https://mixkit.co/free-sound-effects/notification/) | 同上 |
| `day_complete.wav` | 8h 满冠收工 | [Mixkit #2019 Achievement bell](https://mixkit.co/free-sound-effects/bell/) | 同上 |

### 音色特征（便于区分）

- **flow_end** — 清晰单音 bell，像传统闹钟，够响但不刺耳
- **break_end** — 柔和 chime，像风铃，比 flow_end 轻
- **halfday_end** — 双音 happy bells，有「中场切换」感
- **day_complete** — 成就 bell，略长，有收工仪式感

---

## 备选替换音源（CC0 / 免费商用）

若内置音效不满意，可从以下站点替换（设置页「自定义音效」V1 功能）：

| 站点 | 推荐搜索词 | 许可 |
|------|-----------|------|
| [Mixkit](https://mixkit.co/free-sound-effects/bell/) | bell notification, relaxing chime | Mixkit License |
| [Pixabay](https://pixabay.com/sound-effects/search/notification/) | notification ping, bell ring | Pixabay Content License |
| [Freesound](https://freesound.org/search/?q=chime&f=license:%22Creative+Commons+0%22) | chime, gentle bell | CC0 |

### Freesound CC0 备选

- [bells tinkling end](https://freesound.org/people/soundofsong/sounds/640717/) — 3.5s，轻柔
- [D# and F chime](https://freesound.org/people/Sadiquecat/sounds/845146/) — 5s，类似航空 ding

---

## Flutter 集成（开发参考）

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/audio/flow_end.wav
    - assets/audio/break_end.wav
    - assets/audio/halfday_end.wav
    - assets/audio/day_complete.wav
```

```dart
enum AlarmSound {
  flowEnd,      // 心流结束
  breakEnd,     // 休息结束
  halfdayEnd,   // 半日锚点结束
  dayComplete,  // 收工
  // ritual 阶段无对应项 — 故意不播放
}
```

后台闹钟使用 `flutter_local_notifications` + `audioplayers`，锁屏时通过 Notification channel 播放对应 wav。
