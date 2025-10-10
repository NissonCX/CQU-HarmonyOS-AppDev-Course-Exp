import router from '@ohos.router';
import { ThemeManager } from '../model/ThemeManager';
import { ThemeType, ThemeColors } from '../model/Theme';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State currentTheme: ThemeType = ThemeManager.getInstance().getCurrentTheme();
  @State themeColors: ThemeColors = ThemeManager.getInstance().getCurrentColors();
  
  // 组件加载时添加主题监听器
  aboutToAppear(): void {
    ThemeManager.getInstance().addThemeChangeListener((theme: ThemeType, colors: ThemeColors) => {
      this.currentTheme = theme;
      this.themeColors = colors;
    });
  }
  
  // 组件销毁时移除主题监听器
  aboutToDisappear(): void {
    // 注意：在实际应用中，应该保存监听器的引用以便移除
    // 这里为了简化，暂时不实现移除逻辑
  }
  
  // 切换主题
  private toggleTheme(): void {
    ThemeManager.getInstance().toggleTheme();
  }

  build() {
    Column() {
      // 顶部标题区域 - 居中对称布局
      Column() {
        Text('🕹️ 经典小游戏合集 🎮')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .fontColor(this.themeColors.primaryText)

        Text('享受经典，挑战智慧')
          .fontSize(16)
          .fontColor(this.themeColors.secondaryText)
          .margin({ top: 8 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ top: 60, bottom: 40 })
      
      // 主题切换按钮 - 居中位置
      Row() {
        Text('🎨 主题')
          .fontSize(14)
          .fontColor(this.themeColors.secondaryText)
          .margin({ right: 10 })
        
        Button(ThemeManager.getInstance().getCurrentTheme() === ThemeType.LIGHT ? '☀️ ' : '🌙 ')
          .width(80)
          .height(36)
          .backgroundColor(this.themeColors.buttonBackground)
          .fontColor(this.themeColors.buttonText)
          .borderRadius(18)
          .border({ width: 1, color: this.themeColors.buttonBorder })
          .shadow({
            radius: 4,
            color: this.themeColors.cardShadow,
            offsetX: 1,
            offsetY: 1
          })
          .onClick(() => this.toggleTheme())
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 30 })

      // 游戏按钮区域 - 居中对称布局
      Column({ space: 16 }) {
        // 扫雷游戏按钮
        Button() {
          Column() {
            Text('🚩 扫雷游戏 💣')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeColors.buttonText)
              .margin({ bottom: 8 })
            
            Text('逻辑推理，挑战速度')
              .fontSize(14)
              .fontColor(this.themeColors.secondaryText)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .width(280)
        .height(70)
        .backgroundColor(this.themeColors.cardBackground)
        .borderRadius(16)
        .border({ width: 1, color: this.themeColors.cardBorder })
        .shadow({
          radius: 8,
          color: this.themeColors.cardShadow,
          offsetX: 2,
          offsetY: 2
        })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/Minesweeper'
          });
        })

        // 24点游戏按钮
        Button() {
          Column() {
            Text('🃏 24点游戏 🧮')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeColors.buttonText)
              .margin({ bottom: 8 })
            
            Text('数学运算，逻辑挑战')
              .fontSize(14)
              .fontColor(this.themeColors.secondaryText)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .width(280)
        .height(70)
        .backgroundColor(this.themeColors.cardBackground)
        .borderRadius(16)
        .border({ width: 1, color: this.themeColors.cardBorder })
        .shadow({
          radius: 8,
          color: this.themeColors.cardShadow,
          offsetX: 2,
          offsetY: 2
        })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/24Points'
          });
        })

        // 拼图华容道按钮
        Button() {
          Column() {
            Text('🧩 拼图华容道 🧠')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeColors.buttonText)
              .margin({ bottom: 8 })
            
            Text('逻辑推理，空间想象')
              .fontSize(14)
              .fontColor(this.themeColors.secondaryText)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .width(280)
        .height(70)
        .backgroundColor(this.themeColors.cardBackground)
        .borderRadius(16)
        .border({ width: 1, color: this.themeColors.cardBorder })
        .shadow({
          radius: 8,
          color: this.themeColors.cardShadow,
          offsetX: 2,
          offsetY: 2
        })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/SlidingPuzzle'
          });
        })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)

      // 底部信息区域 - 居中布局
      Column() {
        Text('🎯 选择一个游戏开始挑战吧！ 🎯')
          .fontSize(14)
          .fontColor(this.themeColors.tertiaryText)
          .margin({ bottom: 8 })

        Text('🧠 智力挑战 · ⏱️ 休闲娱乐')
          .fontSize(12)
          .fontColor(this.themeColors.tertiaryText)
          .margin({ bottom: 8 })

        Text('👨‍💻 制作人：Nisson_CX')
          .fontSize(12)
          .fontColor(this.themeColors.tertiaryText)
          .margin({ bottom: 30 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.background)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}