import router from '@ohos.router';
import { ThemeManager } from '../model/ThemeManager';
import { ThemeType, ThemeColors } from '../model/Theme';
import { PuzzlePiece } from '../model/PuzzlePiece';

@Entry
@Component
struct SlidingPuzzle {
  @State puzzlePieces: PuzzlePiece[] = []; // 拼图块数组
  @State moves: number = 0; // 移动次数
  @State currentTime: number = 0; // 游戏时间（秒）
  @State isGameFinished: boolean = false; // 游戏是否完成
  @State currentTheme: ThemeType = ThemeManager.getInstance().getCurrentTheme();
  @State themeColors: ThemeColors = ThemeManager.getInstance().getCurrentColors();
  
  private timerId: number = -1; // 定时器ID
  private startTime: number = Date.now(); // 游戏开始时间
  private readonly gridSize: number = 4; // 网格大小 (4x4)
  
  // 组件加载时初始化游戏和添加主题监听器
  aboutToAppear(): void {
    this.initializeGame();
    
    // 添加主题监听器
    ThemeManager.getInstance().addThemeChangeListener((theme: ThemeType, colors: ThemeColors) => {
      this.currentTheme = theme;
      this.themeColors = colors;
    });
  }
  
  // 组件销毁时清除定时器和移除主题监听器
  aboutToDisappear(): void {
    // 清除定时器
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }
  
  // 初始化游戏
  private initializeGame(): void {
    // 清除之前的定时器
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    
    // 重置游戏状态
    this.moves = 0;
    this.currentTime = 0;
    this.isGameFinished = false;
    
    // 生成拼图块
    this.generatePuzzle();
    
    // 打乱拼图
    this.shufflePuzzle();
    
    // 启动计时器
    this.startTime = Date.now();
    this.timerId = setInterval(() => {
      if (!this.isGameFinished) {
        this.currentTime = Math.floor((Date.now() - this.startTime) / 1000);
      }
    }, 1000);
  }
  
  // 生成拼图
  private generatePuzzle(): void {
    this.puzzlePieces = [];
    
    // 创建标准排列的拼图块
    for (let row = 0; row < this.gridSize; row++) {
      for (let col = 0; col < this.gridSize; col++) {
        const id = row * this.gridSize + col + 1;
        // 最后一个块是空块
        const isEmpty = (row === this.gridSize - 1 && col === this.gridSize - 1);
        if (!isEmpty) {
          this.puzzlePieces.push(new PuzzlePiece(id, row, col, row, col));
        } else {
          // 添加空块
          this.puzzlePieces.push(new PuzzlePiece(0, row, col, row, col, true));
        }
      }
    }
  }
  
  // 打乱拼图
  private shufflePuzzle(): void {
    // 进行1000次随机移动来打乱拼图
    for (let i = 0; i < 1000; i++) {
      const emptyPiece = this.getEmptyPiece();
      const movablePieces = this.getMovablePieces(emptyPiece);
      
      if (movablePieces.length > 0) {
        const randomIndex = Math.floor(Math.random() * movablePieces.length);
        const pieceToMove = movablePieces[randomIndex];
        this.swapPieces(pieceToMove, emptyPiece);
      }
    }
    
    // 重置移动次数和时间
    this.moves = 0;
    this.currentTime = 0;
    this.isGameFinished = false;
  }
  
  // 获取空块
  private getEmptyPiece(): PuzzlePiece {
    return this.puzzlePieces.find(piece => piece.isEmpty)!;
  }
  
  // 获取可以移动的块
  private getMovablePieces(emptyPiece: PuzzlePiece): PuzzlePiece[] {
    const movablePieces: PuzzlePiece[] = [];
    
    // 检查四个方向的相邻块
    const directions = [
      [-1, 0], // 上
      [1, 0],  // 下
      [0, -1], // 左
      [0, 1]   // 右
    ];
    
    for (const dir of directions) {
      const targetRow = emptyPiece.row + dir[0];
      const targetCol = emptyPiece.col + dir[1];
      
      // 检查目标位置是否在网格范围内
      if (targetRow >= 0 && targetRow < this.gridSize && targetCol >= 0 && targetCol < this.gridSize) {
        const piece = this.puzzlePieces.find(p => p.row === targetRow && p.col === targetCol);
        if (piece) {
          movablePieces.push(piece);
        }
      }
    }
    
    return movablePieces;
  }
  
  // 交换两个块的位置
  private swapPieces(piece1: PuzzlePiece, piece2: PuzzlePiece): void {
    const tempRow = piece1.row;
    const tempCol = piece1.col;
    
    piece1.row = piece2.row;
    piece1.col = piece2.col;
    
    piece2.row = tempRow;
    piece2.col = tempCol;
  }
  
  // 处理拼图块点击事件
  private handlePieceClick(clickedPiece: PuzzlePiece): void {
    if (this.isGameFinished) return;
    
    const emptyPiece = this.getEmptyPiece();
    
    // 检查点击的块是否可以移动（与空块相邻）
    const isAdjacent = 
      (Math.abs(clickedPiece.row - emptyPiece.row) === 1 && clickedPiece.col === emptyPiece.col) ||
      (Math.abs(clickedPiece.col - emptyPiece.col) === 1 && clickedPiece.row === emptyPiece.row);
    
    if (isAdjacent) {
      this.swapPieces(clickedPiece, emptyPiece);
      this.moves++;
      
      // 检查游戏是否完成
      if (this.isPuzzleSolved()) {
        this.finishGame();
      }
    }
  }
  
  // 检查拼图是否已解决
  private isPuzzleSolved(): boolean {
    // 检查除了空块外的所有块是否都在正确位置
    return this.puzzlePieces.every(piece => 
      piece.isEmpty || (piece.row === piece.correctRow && piece.col === piece.correctCol)
    );
  }
  
  // 完成游戏
  private finishGame(): void {
    this.isGameFinished = true;
    
    // 清除定时器
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }
  
  // 格式化时间显示
  private formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }
  
  build() {
    Column() {
      // 顶部标题区域
      Row() {
        Column() {
          Text('🧩 拼图华容道 🧠')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .fontColor(this.themeColors.primaryText)
            .margin({ top: 20 })

          Text('移动方块使其按数字顺序排列')
            .fontSize(14)
            .fontColor(this.themeColors.secondaryText)
            .margin({ top: 6 })

          // 游戏信息显示
          Row() {
            // 步数显示
            Row() {
              Text('👣')
                .fontSize(16)
                .fontColor(this.themeColors.buttonText)
              Text(`${this.moves}`)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeColors.buttonText)
                .margin({ left: 4 })
            }
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.themeColors.cardBackground)
            .borderRadius(12)
            .border({ width: 1, color: this.themeColors.cardBorder })
            .shadow({
              radius: 6,
              color: this.themeColors.cardShadow,
              offsetX: 2,
              offsetY: 2
            })
            .margin({ right: 12 })

            // 时间显示
            Row() {
              Text('⏱')
                .fontSize(16)
                .fontColor(this.themeColors.buttonText)
              Text(`${this.formatTime(this.currentTime)}`)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeColors.buttonText)
                .margin({ left: 4 })
            }
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.themeColors.cardBackground)
            .borderRadius(12)
            .border({ width: 1, color: this.themeColors.cardBorder })
            .shadow({
              radius: 6,
              color: this.themeColors.cardShadow,
              offsetX: 2,
              offsetY: 2
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ top: 12 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        
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
          .margin({ top: 20, right: 20 })
          .onClick(() => {
            router.back();
          })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 游戏主区域
      Column() {
        // 拼图网格
        Grid() {
          ForEach(this.puzzlePieces, (piece: PuzzlePiece) => {
            GridItem() {
              Stack() {
                // 方块背景
                Rect()
                  .width('100%')
                  .height('100%')
                  .fill(piece.isEmpty ? 
                    this.themeColors.background : 
                    (piece.isCorrectPosition() ? 
                      this.themeColors.successColor : 
                      this.themeColors.gameCellBackground))
                  .strokeWidth(1)
                  .stroke(this.themeColors.gameCellBorder)
                  .radius(8)
                  .shadow({
                    radius: 4,
                    color: this.themeColors.cardShadow,
                    offsetX: 2,
                    offsetY: 2
                  })

                // 方块内容
                Text(piece.getDisplayText())
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(piece.isEmpty ? 
                    this.themeColors.background : 
                    (piece.isCorrectPosition() ? 
                      '#FFFFFF' : 
                      this.themeColors.buttonText))
                  .textAlign(TextAlign.Center)
              }
              .width('100%')
              .height('100%')
              .onClick(() => this.handlePieceClick(piece))
            }
          }, (item: PuzzlePiece) => item.id.toString())
        }
        .width(300)
        .height(300)
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr 1fr')
        .columnsGap(4)
        .rowsGap(4)
        .borderRadius(8)
        .margin({ top: 20 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .layoutWeight(1)

      // 控制按钮区域
      Column({ space: 16 }) {
        // 重新开始按钮
        Button('🔄 重新开始')
          .fontColor(this.themeColors.buttonText)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .width(200)
          .height(50)
          .backgroundColor(this.themeColors.buttonBackground)
          .borderRadius(14)
          .border({ width: 1, color: this.themeColors.buttonBorder })
          .shadow({
            radius: 8,
            color: this.themeColors.cardShadow,
            offsetX: 2,
            offsetY: 2
          })
          .onClick(() => this.initializeGame())

        // 游戏完成提示
        if (this.isGameFinished) {
          Text('🎉 恭喜完成拼图！ 🎉')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeColors.successColor)
            .textAlign(TextAlign.Center)
            .margin({ top: 10 })
          
          Text(`用时: ${this.formatTime(this.currentTime)}  步数: ${this.moves}`)
            .fontSize(14)
            .fontColor(this.themeColors.secondaryText)
            .textAlign(TextAlign.Center)
            .margin({ top: 4 })
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 30 })

      // 底部信息区域
      Column() {
        Text('🎯 拼图华容道考验你的逻辑思维能力')
          .fontSize(12)
          .fontColor(this.themeColors.tertiaryText)
          .margin({ bottom: 6 })

        Text('🧩 逻辑推理 · ⏱️ 挑战速度')
          .fontSize(11)
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