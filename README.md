# HarmonyOS 经典小游戏合集 🎮

<p align="center">
  <img src="entry/src/main/resources/base/media/ControllerIcon.png" width="150" alt="游戏合集图标" />
</p>

<p align="center">
  <a href="https://gitee.com/NissonCX/CQU-ArkTS-Course-Exp">
    <img src="https://gitee.com/NissonCX/CQU-ArkTS-Course-Exp/badge/star.svg?theme=dark" alt="Gitee stars">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/github/license/NissonCX/CQU-ArkTS-Course-Exp" alt="License">
  </a>
  <a href="https://github.com/NissonCX/CQU-ArkTS-Course-Exp">
    <img src="https://img.shields.io/github/languages/code-size/NissonCX/CQU-ArkTS-Course-Exp" alt="Code size">
  </a>
</p>

> 基于 HarmonyOS 和 ArkTS 开发的经典益智游戏合集，包含扫雷、24点、2048 等多种趣味游戏

## 📋 目录

- [项目简介](#项目简介)
- [游戏特色](#游戏特色)
- [技术架构](#技术架构)
- [快速开始](#快速开始)
- [项目结构](#项目结构)
- [核心功能详解](#核心功能详解)
- [开发规范](#开发规范)
- [未来规划](#未来规划)
- [许可证](#许可证)
- [作者](#作者)

## 项目简介

本项目是基于华为 HarmonyOS 平台开发的经典小游戏合集，采用 ArkTS 语言进行开发。项目旨在提供多种经典益智游戏，帮助用户在闲暇时光锻炼逻辑思维能力和数学计算能力。

目前包含的游戏：
- 扫雷游戏 (Minesweeper) - ✅ 已完成
- 24点游戏 (24 Points) - 🚧 开发中
- 2048游戏 - 🚧 开发中

## 游戏特色

### 🧩 扫雷游戏 (Minesweeper)

一款经典的逻辑推理游戏，玩家需要根据数字提示找出所有地雷的位置。

主要功能：
- 10x10 的游戏网格布局，共10个随机分布的地雷
- 双模式操作：揭开模式 / 标记模式
- 左键点击揭开方块，右键点击标记地雷
- 智能展开：点击空白区域可自动展开周围区域
- 实时计时功能，记录您的挑战时间
- 胜负判断与游戏结果提示
- 重新开始功能

### 🃏 24点游戏 (24 Points)

一款经典的数学计算游戏，通过四则运算使四个数字的结果等于24。

当前状态：开发中...

### 🔢 2048游戏

一款风靡全球的数字合成游戏，通过滑动合并相同数字方块。

当前状态：开发中...

## 技术架构

### 开发技术栈

- **编程语言**: ArkTS (Ark TypeScript)
- **开发框架**: HarmonyOS API
- **构建工具**: DevEco Studio
- **UI 框架**: ArkUI
- **状态管理**: @State、@ObservedV2、@Trace 等装饰器

### 核心技术点

1. **响应式 UI 设计**：使用 ArkUI 构建流畅的用户界面
2. **状态管理**：利用 ArkTS 的状态管理机制实现复杂交互
3. **面向对象设计**：通过类封装游戏逻辑和数据模型
4. **路由导航**：实现页面间跳转与参数传递
5. **事件处理**：处理用户交互事件如点击、长按等

### 项目关键类

- [Cell](file://D:\AAA_NissonCX\code\MineSweeperDemo1\entry\src\main\ets\model\Cell.ets): 扫雷游戏中单个格子的数据模型
- [MineSweeper](file://D:\AAA_NissonCX\code\MineSweeperDemo1\entry\src\main\ets\pages\Minesweeper.ets): 扫雷游戏主界面与核心逻辑
- [Index](file://D:\AAA_NissonCX\code\MineSweeperDemo1\entry\src\main\ets\pages\Index.ets): 应用主页，展示游戏列表
- [Game24Points](file://D:\AAA_NissonCX\code\MineSweeperDemo1\entry\src\main\ets\pages\24Points.ets): 24点游戏界面（开发中）
- [Game2048](file://D:\AAA_NissonCX\code\MineSweeperDemo1\entry\src\main\ets\pages\2048.ets): 2048游戏界面（开发中）

## 快速开始

### 环境准备

- 安装 [DevEco Studio 5.1.1.840](https://developer.harmonyos.com/cn/develop/deveco-studio) 或更高版本
- 配置 HarmonyOS SDK
- 准备支持 HarmonyOS 的设备或模拟器

### 运行项目

1. 克隆项目到本地：
   ```bash
   git clone git@gitee.com:NissonCX/CQU-ArkTS-Course-Exp.git
   ```

2. 使用 DevEco Studio 打开项目

3. 同步项目依赖：
   ```bash
   # 在 DevEco Studio 中执行同步操作
   ```

4. 编译并运行项目：
   - 连接设备或启动模拟器
   - 点击 Run 按钮运行应用

## 项目结构

```
.
├── AppScope                      # 全局资源目录
│   └── resources                 # 全局资源文件
├── entry                         # 主模块目录
│   ├── src                       # 源代码目录
│   │   ├── main                  # 主代码目录
│   │   │   ├── ets               # ArkTS 代码
│   │   │   │   ├── entryability  # 应用生命周期管理
│   │   │   │   ├── model         # 数据模型
│   │   │   │   └── pages         # 页面组件
│   │   │   └── resources         # 模块资源
│   │   └── ohosTest              # 测试代码
│   └── build-profile.json5       # 模块配置文件
├── hvigor                       # 构建脚本
├── build-profile.json5          # 项目配置文件
├── hvigorfile.ts                # 项目级构建脚本
├── oh-package.json5             # 项目依赖配置
└── README.md                    # 项目说明文档
```

### 核心页面

- [`Index.ets`](entry/src/main/ets/pages/Index.ets) - 应用主页，展示游戏列表
- [`Minesweeper.ets`](entry/src/main/ets/pages/Minesweeper.ets) - 扫雷游戏主页面
- [`24Points.ets`](entry/src/main/ets/pages/24Points.ets) - 24点游戏页面（开发中）
- [`2048.ets`](entry/src/main/ets/pages/2048.ets) - 2048游戏页面（开发中）

### 数据模型

- [`Cell.ets`](entry/src/main/ets/model/Cell.ets) - 扫雷游戏单元格数据模型

## 核心功能详解

### 扫雷游戏实现细节

扫雷游戏是本项目的核心功能，具有完整的逻辑和美观的界面设计：

1. **游戏初始化**
   - 自动生成10x10的游戏网格
   - 随机分布10个地雷
   - 计算每个格子周围的地雷数量

2. **游戏交互**
   - 双模式操作：揭开模式 / 标记模式
   - 左键点击揭开格子
   - 右键点击标记/取消标记地雷
   - 智能展开功能：点击空白格子时自动展开周围区域

3. **游戏状态管理**
   - 实时计时功能，精确到秒
   - 胜负判断机制
   - 游戏结束对话框显示
   - 重新开始功能

4. **UI设计亮点**
   - 使用 emoji 图标增强视觉效果（🚩💣⏱）
   - 现代化的卡片式设计
   - 精心调配的配色方案，提升视觉体验
   - 响应式布局适配不同屏幕尺寸

### 界面设计规范

- 使用现代化的卡片式界面设计
- 采用 emoji 图标替代部分文字标识，增强视觉表现力
- 拉长计时部分，突出时间信息
- 使用具有视觉冲击力的配色方案，追求专业和美观的界面

## 开发规范

### 代码规范

- 遵循 HarmonyOS 开发规范
- 保持代码风格一致
- 添加必要的注释说明
- 确保提交信息清晰明确

### Git 提交规范

- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

## 未来规划

- [ ] 完善 24点游戏功能
- [ ] 完善 2048游戏功能
- [ ] 增加游戏难度选择
- [ ] 添加游戏音效
- [ ] 增加排行榜功能
- [ ] 支持多语言
- [ ] 优化UI/UX设计

## 许可证

本项目采用 MIT 许可证，详情请参阅 [LICENSE](LICENSE) 文件。

## 作者

**Nisson_CX**

- Gitee: [@NissonCX](https://gitee.com/NissonCX)

---

<p align="center">Made with ❤️ by Nisson_CX | 重庆大学ArkTS课程实验项目</p>