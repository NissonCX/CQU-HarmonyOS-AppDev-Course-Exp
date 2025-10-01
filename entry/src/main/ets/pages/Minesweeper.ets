// Minesweeper.ets
import { promptAction } from '@kit.ArkUI'; // 导入用于显示对话框的工具
import router from '@ohos.router';
import { Cell } from '../model/Cell'

// 定义扫雷游戏组件
@Entry
  // 使用@Entry装饰器声明这是一个入口组件
@Component
  // 使用@Component装饰器声明这是一个组件
struct MineSweeper {
  @State private gameBoard: Cell[][] = []; // 游戏面板数据
  @State private mineCount: number = 10; // 地雷总数
  @State private revealedCells: Set<string> = new Set(); // 已经揭示的方块集合
  @State private flaggedCells: Set<string> = new Set(); // 标记为地雷的方块集合
  @State private cellSize: number = 60; // 缩小方块大小
  @State private cellMargin: number = 1; // 缩小方块边距
  @State private currentTime: number = 0; // 当前游戏时间（秒）
  @State private isFlagMode: boolean = false; // 是否为标记模式
  private startTime: number = Date.now(); // 游戏开始时间
  @State private isGameOver: boolean = false; // 游戏结束标志
  private timerId: number = -1; // 定时器ID

  // 当组件即将显示时调用此方法
  aboutToAppear(): void {
    this.initializeGame(); // 初始化游戏
  }

  // 组件销毁时清除定时器
  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  // 初始化游戏
  private initializeGame() {
    // 清除之前的定时器
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }

    this.isGameOver = false; // 设置游戏未结束
    this.isFlagMode = false; // 重置为揭开模式
    this.startTime = Date.now(); // 重置游戏开始时间
    this.currentTime = 0; // 重置当前时间
    this.revealedCells.clear(); // 清空已揭示的方块集合
    this.flaggedCells.clear(); // 清空标记为地雷的方块集合

    // 启动计时器
    this.timerId = setInterval(() => {
      if (!this.isGameOver) {
        this.currentTime = Math.floor((Date.now() - this.startTime) / 1000);
      }
    }, 1000);

    this.generateBoard(); // 生成新的游戏面板
  }

  // 切换操作模式
  private toggleMode() {
    if (this.isGameOver) return;
    this.isFlagMode = !this.isFlagMode;
  }

  // 生成游戏面板
  private generateBoard() {
    this.gameBoard = []; // 清空游戏面板
    for (let i = 0; i < 10; i++) { // 循环创建10行
      this.gameBoard.push([]); // 每行初始化为空数组
      for (let j = 0; j < 10; j++) { // 循环创建10列
        this.gameBoard[i].push(new Cell(i, j)); // 为每个位置创建一个新方块
      }
    }
    this.placeMines(); // 随机放置地雷
    this.calculateNumbers(); // 计算每个方块周围的地雷数量
  }

  // 随机放置地雷
  private placeMines() {
    let placed = 0; // 已放置的地雷数量
    while (placed < this.mineCount) { // 当已放置的地雷少于设定数量时继续放置
      let x = Math.floor(Math.random() * 10); // 随机选择一行
      let y = Math.floor(Math.random() * 10); // 随机选择一列
      if (!this.gameBoard[x][y].hasMine) { // 如果该位置还没有地雷
        this.gameBoard[x][y].hasMine = true; // 在该位置放置地雷
        placed++; // 地雷计数加1
      }
    }
  }

  // 计算每个方块周围的地雷数量
  private calculateNumbers() {
    for (let i = 0; i < 10; i++) { // 遍历每一行
      for (let j = 0; j < 10; j++) { // 遍历每一列
        if (!this.gameBoard[i][j].hasMine) { // 如果当前方块不是地雷
          this.gameBoard[i][j].neighborMines = this.countNeighborMines(i, j); // 计算并设置周围地雷数量
          this.gameBoard[i][j].value = this.gameBoard[i][j].neighborMines.toString(); // 将数量转换为字符串
        } else {
          this.gameBoard[i][j].value = '💣'; // 如果是地雷，则设置值为炸弹emoji
        }
      }
    }
  }

  // 计算给定坐标周围地雷的数量
  private countNeighborMines(row: number, col: number): number {
    let count = 0; // 周围地雷计数
    for (let dx = -1; dx <= 1; dx++) { // 遍历上下左右及对角线方向
      for (let dy = -1; dy <= 1; dy++) {
        if (dx === 0 && dy === 0) { // 跳过当前位置
          continue;
        }
        let newRow = row + dx, newCol = col + dy; // 新的行列坐标
        if (newRow >= 0 && newRow < 10 && newCol >= 0 && newCol < 10 &&
        this.gameBoard[newRow][newCol].hasMine) { // 如果新位置有效且是地雷
          count++; // 地雷计数加1
        }
      }
    }
    return count; // 返回地雷计数
  }

  // 揭示方块
  private revealCell(row: number, col: number) {
    if (this.isGameOver || this.revealedCells.has(`${row},${col}`)) { // 如果游戏结束或者该方块已经被揭示
      return; // 不执行任何操作
    }
    const key = `${row},${col}`; // 创建方块唯一标识
    this.revealedCells.add(key); // 添加到已揭示的方块集合
    if (this.gameBoard[row][col].hasMine) { // 如果揭示的方块是地雷
      this.showGameOverDialog(); // 显示游戏结束对话框
    } else {
      if (this.gameBoard[row][col].neighborMines === 0) { // 如果揭示的方块周围没有地雷
        for (let dx = -1; dx <= 1; dx++) { // 自动揭示周围所有方块
          for (let dy = -1; dy <= 1; dy++) {
            if (dx === 0 && dy === 0) { // 跳过当前位置
              continue;
            }
            let newRow = row + dx, newCol = col + dy;
            if (newRow >= 0 && newRow < 10 && newCol >= 0 && newCol < 10) { // 如果新位置有效
              this.revealCell(newRow, newCol); // 递归揭示相邻方块
            }
          }
        }
      }
    }
    if (this.isVictory()) { // 如果游戏胜利
      this.showVictoryDialog(); // 显示胜利对话框
    }
  }

  // 标记方块
  private flagCell(row: number, col: number) {
    if (this.isGameOver || this.revealedCells.has(`${row},${col}`)) {
      return;
    }

    const cell = this.gameBoard[row][col];
    cell.isFlag = !cell.isFlag;
  }

  // 处理方块点击事件
  private handleCellClick(row: number, col: number) {
    if (this.isFlagMode) {
      this.flagCell(row, col);
    } else {
      this.revealCell(row, col);
    }
  }

  // 显示游戏结束对话框
  private showGameOverDialog() {
    this.isGameOver = true; // 设置游戏结束
    // 清除定时器
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }

    promptAction.showDialog({
      // 显示对话框
      title: '游戏结束: 游戏失败！', // 对话框标题
      buttons: [{ text: '重新开始', color: '#007DFF' }] // 对话框按钮
    }).then(() => { // 点击按钮后执行
      this.initializeGame(); // 重新开始游戏
    });
  }

  // 显示胜利对话框
  private showVictoryDialog() {
    this.isGameOver = true; // 设置游戏结束
    // 清除定时器
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }

    promptAction.showDialog({
      // 显示对话框
      title: '恭喜你，游戏胜利！', // 对话框标题
      message: `用时：${((Date.now() - this.startTime) / 1000).toFixed(3)}秒`, // 对话框消息
      buttons: [{ text: '重新开始', color: '#007DFF' }] // 对话框按钮
    }).then(() => { // 点击按钮后执行
      this.initializeGame(); // 重新开始游戏
    });
  }

  // 判断游戏是否胜利
  private isVictory(): boolean {
    let revealedNonMineCount = 0; // 非地雷方块的揭示数量
    for (let i = 0; i < this.gameBoard.length; i++) { // 遍历每一行
      for (let j = 0; j < this.gameBoard[i].length; j++) { // 遍历每一列
        if (this.revealedCells.has(`${i},${j}`)) { // 如果方块已被揭示
          revealedNonMineCount++; // 非地雷方块的揭示数量加1
        }
      }
    }
    return revealedNonMineCount == 90; // 如果非地雷方块全部揭示，则游戏胜利
  }

  // 决定是否显示方块值
  private isShowValue(cell: Cell): string {
    if (this.isGameOver) { // 如果游戏结束
      return cell.value === '0' ? '' : cell.value; // 显示方块值，除非是0
    } else {
      if (this.revealedCells.has(`${cell.row},${cell.column}`)) { // 如果方块已被揭示
        return cell.value === '0' ? '' : cell.value; // 显示方块值，除非是0
      } else {
        return ''; // 否则不显示值
      }
    }
  }

  // 构建用户界面
  build() {
    Column() {
      // 顶部标题区域
      Column() {
        Text(' 🚩扫雷💥 ')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .fontColor('#1a1a1a')
          .margin({ top: 20 })

        Text('点击揭开模式切换为标记模式')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ top: 6 })

        // 时间显示
        Row() {
          Text('⏱')
            .fontSize(18)
          Text(`${this.currentTime.toString().padStart(3, '0')}s`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ left: 10 })
        }
        .padding({ left: 20, right: 20, top: 10, bottom: 10 })
        .backgroundColor('#FFFFFF')
        .borderRadius(18)
        .shadow({
          radius: 6,
          color: '#333333',
          offsetX: 2,
          offsetY: 2
        })
        .margin({ top: 15, bottom: 5 })
        .alignSelf(ItemAlign.Center)
      }
      .margin({ top: 20 })

      // 游戏主区域
      Column() {
        // 游戏面板
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.gameBoard, (row: Cell[], rowIndex: number) => {
            ForEach(row, (cell: Cell, colIndex: number) => {
              Stack() {
                // 格子背景
                Rect()
                  .width(`${this.cellSize}lpx`)
                  .height(`${this.cellSize}lpx`)
                  .margin(`${this.cellMargin}lpx`)
                  .fill(this.revealedCells.has(`${rowIndex},${colIndex}`) ?
                    (this.isShowValue(cell) === '💣' ? '#FF4D4D' : '#FFFFFF') : '#5CACEE')
                  .strokeWidth(1)
                  .stroke('#4A90E2')
                  .radius(6)
                  .shadow({
                    radius: 3,
                    color: '#00000020',
                    offsetX: 1,
                    offsetY: 1
                  })

                // 格子内容
                Text(this.isShowValue(cell))
                  .width(`${this.cellSize}lpx`)
                  .height(`${this.cellSize}lpx`)
                  .margin(`${this.cellMargin}lpx`)
                  .fontSize(`${this.cellSize / 2 + 2}lpx`)
                  .textAlign(TextAlign.Center)
                  .fontColor(this.revealedCells.has(`${rowIndex},${colIndex}`) ?
                    (this.isShowValue(cell) === '💣' ? '#FFFFFF' : '#333333') :
                    '#FFFFFF')
                  .fontWeight(FontWeight.Bold)

                // 标记旗帜
                Text(`${cell.isFlag && !this.revealedCells.has(`${rowIndex},${colIndex}`) ? '🚩' : ''}`)
                  .width(`${this.cellSize}lpx`)
                  .height(`${this.cellSize}lpx`)
                  .margin(`${this.cellMargin}lpx`)
                  .fontSize(`${this.cellSize / 2 + 2}lpx`)
                  .textAlign(TextAlign.Center)
                  .fontColor('#E53935')
                  .visibility(cell.isFlag && !this.revealedCells.has(`${rowIndex},${colIndex}`) && !this.isGameOver ?
                  Visibility.Visible : Visibility.None)
              }
              .onClick(() => this.handleCellClick(rowIndex, colIndex))
            });
          });
        }
        .width(`${(this.cellSize + this.cellMargin * 2) * 10}lpx`)
        .margin({ top: 15 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)

      // 控制按钮区域
      Column() {
        // 模式切换按钮
        Button(`${this.isFlagMode ? ' 标记模式🚩' : ' 揭开模式👆'}`)
          .fontColor(Color.Black)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .width(200)
          .height(50)
          .backgroundColor('#FFFFFF')
          .borderRadius(14)
          .shadow({
            radius: 6,
            color: '#333333',
            offsetX: 2,
            offsetY: 2
          })
          .onClick(() => this.toggleMode())
          .margin({ top: 10, bottom: 10 })

        // 重新开始按钮
        Button('重新开始🔃')
          .fontColor(Color.Black)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .width(200)
          .height(50)
          .backgroundColor('#FFFFFF')
          .borderRadius(14)
          .shadow({
            radius: 6,
            color: '#333333',
            offsetX: 2,
            offsetY: 2
          })
          .margin({ bottom: 10 })
          .onClick(() => {
            promptAction.showDialog({
              title: '确认重新开始',
              message: '确定要重新开始游戏吗？当前游戏进度将会丢失。',
              buttons: [
                {
                  text: '确定',
                  color: '#007DFF'
                },
                {
                  text: '取消',
                  color: '#999999'
                }
              ]
            }).then((result) => {
              if (result.index == 0) {
                // 用户点击"确定"
                this.initializeGame();
              }
              // 用户点击"取消"或其他情况，不执行任何操作
            });
          })

      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // 底部信息区域
      Column() {
        Text('扫雷是一个经典的游戏，考验你的逻辑推理能力')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ bottom: 8 })

        Text('🎯 逻辑推理 | ⏱️ 挑战速度')
          .fontSize(11)
          .fontColor('#bbbbbb')
          .margin({ bottom: 4 })

        Text('制作人：Nisson_CX')
          .fontSize(11)
          .fontColor('#cccccc')
          .margin({ bottom: 15 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
