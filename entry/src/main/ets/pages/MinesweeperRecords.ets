// MinesweeperRecords.ets
import { router } from '@kit.ArkUI';
import { ThemeManager } from '../model/ThemeManager';
import { ThemeType, ThemeColors } from '../model/Theme';
import { MinesweeperRecord, MinesweeperRecordData, PlayerLevel, getPlayerLevel } from '../model/MinesweeperRecord';
import { MinesweeperStorage } from '../utils/MinesweeperStorage';

@Entry
@Component
struct MinesweeperRecords {
  @State private records: MinesweeperRecord[] = [];
  @State private currentTheme: ThemeType = ThemeManager.getInstance().getCurrentTheme();
  @State private themeColors: ThemeColors = ThemeManager.getInstance().getCurrentColors();
  @State private playerLevel: PlayerLevel | null = PlayerLevel.BEGINNER;
  
  aboutToAppear(): void {
    // 从本地存储或其他方式加载记录
    this.loadRecords();
    
    // 添加主题监听器
    ThemeManager.getInstance().addThemeChangeListener((theme: ThemeType, colors: ThemeColors) => {
      this.currentTheme = theme;
      this.themeColors = colors;
    });
  }
  
  private async loadRecords(): Promise<void> {
    // 从本地存储加载记录（示例实现，实际项目中可能需要使用持久化存储）
    try {
      const storage = MinesweeperStorage.getInstance();
      const recordsData: MinesweeperRecordData[] = await storage.getRecords();
      this.records = recordsData.map((item) => {
        const record = new MinesweeperRecord(item.time, item.isWin);
        record.id = item.id;
        record.timestamp = item.timestamp;
        return record;
      });
      this.updatePlayerLevel();
    } catch (e) {
      console.error('加载扫雷记录失败:', e);
      this.records = [];
    }
  }
  
  private updatePlayerLevel(): void {
    const level = getPlayerLevel(this.records.filter(r => r.isWin).length);
    this.playerLevel = level || PlayerLevel.BEGINNER;
  }
  
  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }
  
  build() {
    Column() {
      // 标题区域
      Column() {
        Row() {
          // 返回按钮
          Button('←')
            .width(40)
            .height(40)
            .backgroundColor(this.themeColors.buttonBackground)
            .fontColor(this.themeColors.buttonText)
            .borderRadius(20)
            .border({ width: 1, color: this.themeColors.buttonBorder })
            .shadow({
              radius: 4,
              color: this.themeColors.cardShadow,
              offsetX: 1,
              offsetY: 1
            })
            .onClick(() => {
              router.back();
            })
          
          // 标题区域
          Column() {
            Text('🏆 扫雷战绩')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .fontColor(this.themeColors.primaryText)
            
            if (this.playerLevel) {
              Text(`当前等级: ${this.playerLevel}`)
                .fontSize(16)
                .fontColor(this.themeColors.secondaryText)
                .margin({ top: 6 })
            } else {
              Text('当前等级: 无')
                .fontSize(16)
                .fontColor(this.themeColors.secondaryText)
                .margin({ top: 6 })
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          
          // 占位符保持对称
          Column()
            .width(40)
            .height(40)
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
        .margin({ top: 20, bottom: 20 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      
      // 统计信息
      Row() {
        Column() {
          Text(`${this.records.length}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeColors.primaryText)
          Text('总游戏次数')
            .fontSize(14)
            .fontColor(this.themeColors.secondaryText)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        
        Column() {
          Text(`${this.records.length >= 1 ? Math.min(...this.records.filter(r => r.isWin).map(r => r.time)) : 0}s`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeColors.primaryText)
          Text('最佳成绩')
            .fontSize(14)
            .fontColor(this.themeColors.secondaryText)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        
        Column() {
          Text(`${this.records.length > 0 ? Math.round((this.records.filter(r => r.isWin).length / this.records.length) * 100) : 0}%`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeColors.primaryText)
          Text('胜利率')
            .fontSize(14)
            .fontColor(this.themeColors.secondaryText)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .padding({ left: 20, right: 20, top: 16, bottom: 16 })
      .backgroundColor(this.themeColors.cardBackground)
      .borderRadius(20)
      .border({ width: 1, color: this.themeColors.cardBorder })
      .shadow({
        radius: 6,
        color: this.themeColors.cardShadow,
        offsetX: 2,
        offsetY: 2
      })
      .margin({ left: 20, right: 20, bottom: 20 })
      
      // 记录列表
      Column() {
        Text('📋 历史记录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeColors.primaryText)
          .alignSelf(ItemAlign.Start)
          .margin({ left: 20, bottom: 10 })
        
        if (this.records.length > 0) {
          Scroll() {
            Column() {
              ForEach(this.records.slice().reverse(), (record: MinesweeperRecord, index: number) => {
                Row() {
                  Text(`${index + 1}`)
                    .fontSize(16)
                    .fontColor(this.themeColors.secondaryText)
                    .width(30)
                  
                  Text(`${record.isWin ? '🎉' : '💀'} ${record.time}秒`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeColors.primaryText)
                    .layoutWeight(1)
                    .textAlign(TextAlign.Start)
                  
                  Text(this.formatTime(record.timestamp))
                    .fontSize(14)
                    .fontColor(this.themeColors.secondaryText)
                }
                .width('100%')
                .padding({ left: 20, right: 20, top: 12, bottom: 12 })
                .backgroundColor(this.themeColors.cardBackground)
                .borderRadius(12)
                .border({ width: 1, color: this.themeColors.cardBorder })
                .shadow({
                  radius: 4,
                  color: this.themeColors.cardShadow,
                  offsetX: 1,
                  offsetY: 1
                })
                .margin({ left: 20, right: 20, bottom: 10 })
              })
            }
            .width('100%')
          }
          .layoutWeight(1)
        } else {
          Column() {
            Text('暂无记录')
              .fontSize(16)
              .fontColor(this.themeColors.secondaryText)
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .layoutWeight(1)
      
      // 底部信息
      Column() {
        Text('🎯 继续努力，挑战更高难度！')
          .fontSize(12)
          .fontColor(this.themeColors.tertiaryText)
          .margin({ bottom: 6 })
        
        Text('👨‍💻 制作人：Nisson_CX')
          .fontSize(11)
          .fontColor(this.themeColors.tertiaryText)
          .margin({ bottom: 20 })
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