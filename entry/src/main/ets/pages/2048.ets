@Entry
@Component
struct Game2048 {
  build() {
    Column() {
      Text('2048游戏')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 100 })

      Text('游戏开发中...')
        .fontSize(20)
        .fontColor('#666')
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0')
  }
}
