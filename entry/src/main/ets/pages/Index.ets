import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Column() {
      // 顶部标题区域
      Column() {
        Text('经典小游戏')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .fontColor('#1a1a1a')

        Text('享受经典，挑战智慧')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ top: 8 })
      }
      .margin({ top: 50 })

      // 游戏按钮区域
      Column({ space: 25 }) {
        Button('扫雷 💥')
          .fontColor(Color.Black)
          .width(280)
          .height(60)
          .fontSize(22)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({
            radius: 6,
            color: '#333333',
            offsetX: 2,
            offsetY: 2
          })
          .onClick(() => {
            // 跳转到扫雷游戏页面
            router.pushUrl({
              url: 'pages/Minesweeper'
            });
          })

        Button('24点 🃏')
          .fontColor(Color.Black)
          .width(280)
          .height(60)
          .fontSize(22)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({
            radius: 6,
            color: '#333333',
            offsetX: 2,
            offsetY: 2
          })
          .onClick(() => {
            // 24点
            router.pushUrl({
              url: 'pages/24Points'
            });
          })

        Button('2048 🔢')
          .fontColor(Color.Black)
          .width(280)
          .height(60)
          .fontSize(22)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({
            radius: 6,
            color: '#333333',
            offsetX: 2,
            offsetY: 2
          })
          .onClick(() => {
            // 跳转到2048游戏页面
            router.pushUrl({
              url: 'pages/2048'
            });
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)

      // 底部信息区域
      Column() {
        Text('选择一个游戏开始挑战吧！')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 10 })

        Text('🎮 智力挑战 | ⏱️ 休闲娱乐')
          .fontSize(12)
          .fontColor('#bbbbbb')
          .margin({ bottom: 5 })

        Text('制作人：Nisson_CX')
          .fontSize(12)
          .fontColor('#cccccc')
          .margin({ bottom: 20 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
