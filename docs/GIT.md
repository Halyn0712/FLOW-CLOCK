# Flow Clock — Git 版本管理规范

> 适用：单人开发、主分支 `main`、远程 [Halyn0712/FLOW-CLOCK](https://github.com/Halyn0712/FLOW-CLOCK)

---

## 1. 核心原则

| 概念 | 作用 | Flow Clock 怎么用 |
|------|------|-------------------|
| **提交 (Commit)** | 记录每一次改动，= 版本 | **每天都用**，改完就提交 |
| **分支 (Branch)** | 并行开发线 | **偶尔用**，大功能或实验时 |
| **标签 (Tag)** | 标记里程碑 | **打 APK 或功能闭环时**打 `v0.x.y` |

**不需要每天新建分支。** 版本靠「提交」区分，不靠「日历」。

---

## 2. 日常节奏（推荐）

### 每天收工前

1. 改了多少就提交多少（可以一天多次）
2. `git push` 推到 GitHub（云端备份）
3. 工作区干净：`git status` 显示 `nothing to commit`

### 一次提交只做一件事

与 `agent-coding-rules.md` 一致：修计时器就只提交计时器相关文件，不要混进无关重构。

### Cursor 操作

```
更改里点 + 暂存 → 写说明 → 提交 → 图形区点云↑推送
```

---

## 3. 提交说明格式

```
<类型>: <一句话说明>
```

### 类型前缀

| 前缀 | 何时用 | 示例 |
|------|--------|------|
| `feat:` | 新功能 | `feat: 月历视图单日详情` |
| `fix:` | 修 bug | `fix: 心流结束闹钟未响` |
| `docs:` | 只改文档 | `docs: 更新 SOP 收货规则` |
| `refactor:` | 重构，不改行为 | `refactor: 拆分 storage_service` |
| `test:` | 测试 | `test: ritual_utils 边界用例` |
| `chore:` | 构建/配置 | `chore: 更新 pubspec 依赖` |

### 好的例子

```
feat: 首页节奏盘显示今日 k 与动量 M
fix: App 被杀后恢复当前 Cycle 状态
docs: CHANGELOG 记录 v0.2.0 分享卡
```

### 避免

```
更新
改了一下
fix bug
```

---

## 4. 什么时候开分支？

**默认：直接在 `main` 上提交。**

仅在以下情况新建分支：

| 场景 | 分支名示例 | 做完后 |
|------|-----------|--------|
| 大功能，跨多天 | `feature/share-card` | 合并回 `main` |
| 试验性改动，可能废弃 | `experiment/new-timer-ui` | 满意则合并，否则删分支 |
| 紧急修线上 APK 问题 | `hotfix/notification-crash` | 合并回 `main` |

```bash
git checkout -b feature/share-card   # 新建并切换
# ... 开发、多次 commit ...
git checkout main
git merge feature/share-card
git push
```

单人项目不必强求分支；**提交频率和说明清晰**比开分支更重要。

---

## 5. 版本号与标签 (Tag)

采用 **语义化版本** `v主.次.修订`：

| 段 | 何时 +1 | 例子 |
|----|---------|------|
| **修订** `0.1.0 → 0.1.1` | 小修小补、bug 修复 | 闹钟不响、UI 错位 |
| **次版本** `0.1.x → 0.2.0` | 新功能可用、里程碑完成 | 分享卡、DailyTree 动画 |
| **主版本** `0.x → 1.0.0` | 产品可长期日常使用（未来） | 功能完整、稳定 APK |

当前基线见 `docs/CHANGELOG.md`（**v0.1.0** = MVP）。

### 什么时候打 Tag？

满足 **任意一条** 即可打标签：

1. 打了 **release APK** 并打算自己用这一版
2. **一个功能闭环**（如「分享卡」从开发到可测）
3. **CHANGELOG** 里写了新版本条目

### 打标签步骤

```bash
# 1. 确认 main 已提交且已 push
git status
git push

# 2. 打标签（附说明）
git tag -a v0.2.0 -m "v0.2.0: 分享卡 + 月历优化"

# 3. 推送标签到 GitHub
git push origin v0.2.0
```

### 发布 APK 检查清单

- [ ] `flutter test` 通过（如有相关测试）
- [ ] `flutter build apk --release` 成功
- [ ] `docs/CHANGELOG.md` 已写新版本
- [ ] `git tag` + `git push origin <tag>`

---

## 6. 文档同步

| 改了什么 | 同步更新 |
|----------|----------|
| 功能 / 行为 | `SOP.md` |
| 对外版本说明 | `docs/CHANGELOG.md` |
| 技术约定 | `agent-coding-rules.md` |

功能提交时，**CHANGELOG 可与 tag 一起更新**，不必每个 commit 都改 CHANGELOG。

---

## 7. 常用命令速查

```bash
git status                  # 当前改了什么
git log --oneline -10       # 最近 10 次版本
git add .                   # 暂存全部改动
git commit -m "feat: ..."   # 提交
git push                    # 上传
git tag -l                  # 列出所有标签
```

### 只看某个文件的历史

```bash
git log --oneline -- lib/features/timer/timer_screen.dart
```

### 误改后恢复单个文件到上一版

```bash
git checkout HEAD -- lib/features/timer/timer_screen.dart
```

---

## 8. 一周示例（单人 main 流）

| 天 | 操作 |
|----|------|
| 周一 | `feat: 分享卡布局` → commit → push |
| 周二 | `feat: 分享卡导出图片` → commit → push |
| 周三 | `fix: 分享卡文字截断` → commit → push |
| 周四 | 继续小改，2～3 次 commit |
| 周五 | 更新 CHANGELOG → `v0.2.0` tag → 打 APK → push + push tag |

全程只在 `main` 上操作即可，**不必每天开分支**。
