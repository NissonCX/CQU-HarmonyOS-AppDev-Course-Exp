import router from '@ohos.router';
import { ThemeManager } from '../model/ThemeManager';
import { ThemeType, ThemeColors } from '../model/Theme';
import { PuzzlePiece } from '../model/PuzzlePiece';
import { SlidingPuzzleRecord } from '../model/SlidingPuzzleRecord';
import { SlidingPuzzleStorage } from '../utils/SlidingPuzzleStorage';
import promptAction from '@ohos.promptAction';
import { common } from '@kit.AbilityKit';

/**
 * 图像信息接口
 */
interface ImageInfo {
  name: string;
  displayName: string;
}

/**
 * 缩放比例接口
 */
interface Scale {
  x: number;
  y: number;
}

/**
 * 位置坐标接口
 */
interface Position {
  x: string;
  y: string;
}

interface GlobalThisContext {
  getContext: () => common.Context;
}

@Entry
@Component
struct SlidingPuzzle {

  @State puzzlePieces: PuzzlePiece[] = []; // 拼图块数组
  @State moves: number = 0; // 移动次数
  @State currentTime: number = 0; // 游戏时间（秒）
  @State isGameFinished: boolean = false; // 游戏是否完成
  @State currentTheme: ThemeType = ThemeManager.getInstance().getCurrentTheme();
  @State themeColors: ThemeColors = ThemeManager.getInstance().getCurrentColors();
  @State selectedImage: string = 'ClubA'; // 选中的图像
  @State showImageSelector: boolean = false; // 是否显示图像选择器
  @State showRecords: boolean = false; // 是否显示历史记录
  @State gameRecords: SlidingPuzzleRecord[] = []; // 游戏记录列表
  @State clickedPieceId: number = -1; // 当前点击的拼图块ID
  @State lastMoveTime: number = 0; // 上次移动时间
  private timerId: number = -1; // 定时器ID
  private startTime: number = Date.now(); // 游戏开始时间
  private readonly gridSize: number = 3; // 网格大小 (3x3)
  // 图像列表 - 使用五张拼图照片资源
  private imageList: Array<ImageInfo> = [
    { name: 'album1', displayName: '自然风光' },
    { name: 'album2', displayName: '城市建筑' },
    { name: 'album3', displayName: '抽象艺术' },
    { name: 'album4', displayName: '几何图案' },
    { name: 'album5', displayName: '经典名画' }
  ]

  // 组件加载时初始化游戏和添加主题监听器
  aboutToAppear(): void {
    // 初始化存储
    try {
      const context = (globalThis as GlobalThisContext).getContext();
      SlidingPuzzleStorage.getInstance().initialize(context);
    } catch (err) {
      console.error('初始化存储失败:', err);
    }

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
      [1, 0], // 下
      [0, -1], // 左
      [0, 1]// 右
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
    if (this.isGameFinished) {
      return;
    }

    const emptyPiece = this.getEmptyPiece();

    // 检查点击的块是否可以移动（与空块相邻）
    const isAdjacent =
      (Math.abs(clickedPiece.row - emptyPiece.row) === 1 && clickedPiece.col === emptyPiece.col) ||
        (Math.abs(clickedPiece.col - emptyPiece.col) === 1 && clickedPiece.row === emptyPiece.row);

    // 设置点击反馈
    this.clickedPieceId = clickedPiece.id;
    this.lastMoveTime = Date.now();

    if (isAdjacent) {
      // 添加点击反馈效果
      this.swapPieces(clickedPiece, emptyPiece);
      this.moves++;

      // 检查游戏是否完成
      if (this.isPuzzleSolved()) {
        this.finishGame();
      }
    }

    // 300毫秒后清除点击效果
    setTimeout(() => {
      if (Date.now() - this.lastMoveTime >= 300) {
        this.clickedPieceId = -1;
      }
    }, 300);
  }

  // 检查拼图是否已解决
  private isPuzzleSolved(): boolean {
    // 检查除了空块外的所有块是否都在正确位置
    return this.puzzlePieces.every(piece =>
    piece.isEmpty || (piece.row === piece.correctRow && piece.col === piece.correctCol)
    );
  }

  // 完成游戏
  private async finishGame(): Promise<void> {
    this.isGameFinished = true;

    // 清除定时器
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }

    // 保存游戏记录
    const record = new SlidingPuzzleRecord(
      Date.now().toString() + Math.random().toString(36).substr(2, 5),
      this.currentTime,
      this.moves,
      Date.now(),
      true,
      this.gridSize
    );

    const storage = SlidingPuzzleStorage.getInstance();
    await storage.saveRecord(record);

    // 显示完成提示
    promptAction.showToast({
      message: `恭喜完成！用时${this.formatTime(this.currentTime)}，步数${this.moves}`,
      duration: 3000
    });
  }

  // 格式化时间显示
  private formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  // 切换图像选择器显示状态
  private toggleImageSelector(): void {
    this.showImageSelector = !this.showImageSelector;
  }

  // 选择图像
  private selectImage(imageName: string): void {
    this.selectedImage = imageName;
    this.showImageSelector = false;
    this.initializeGame();
  }

  // 显示历史记录
  private async toggleRecords(): Promise<void> {
    this.showRecords = !this.showRecords;

    if (this.showRecords) {
      // 加载游戏记录
      const storage = SlidingPuzzleStorage.getInstance();
      this.gameRecords = await storage.getRecords();
    }
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

          Text('移动方块使其恢复完整图像')
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
            .padding({
              left: 16,
              right: 16,
              top: 8,
              bottom: 8
            })
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
            .padding({
              left: 16,
              right: 16,
              top: 8,
              bottom: 8
            })
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

      // 图像选择区域
      Row() {
        Text(`🖼️ 当前图像: ${this.imageList.find(img => img.name === this.selectedImage)?.displayName ||
        this.selectedImage}`)
          .fontSize(14)
          .fontColor(this.themeColors.secondaryText)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('🔄 更换图像')
          .width(100)
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
          .margin({ right: 20 })
          .onClick(() => this.toggleImageSelector())
      }
      .width('100%')
      .margin({ bottom: 10 })

      // 图像选择器弹窗
      if (this.showImageSelector) {
        Column() {
          Text('选择图像')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeColors.primaryText)
            .margin({ bottom: 10 })

          ForEach(this.imageList, (image: ImageInfo) => {
            Button(image.displayName)
              .width('80%')
              .height(40)
              .backgroundColor(this.selectedImage === image.name ?
                this.themeColors.successColor : this.themeColors.buttonBackground)
              .fontColor(this.themeColors.buttonText)
              .borderRadius(8)
              .border({ width: 1, color: this.themeColors.buttonBorder })
              .margin({ bottom: 8 })
              .onClick(() => this.selectImage(image.name))
          })

          Button('❌ 关闭')
            .width(100)
            .height(40)
            .backgroundColor(this.themeColors.buttonBackground)
            .fontColor(this.themeColors.buttonText)
            .borderRadius(8)
            .border({ width: 1, color: this.themeColors.buttonBorder })
            .margin({ top: 10 })
            .onClick(() => this.toggleImageSelector())
        }
        .width('90%')
        .padding(20)
        .backgroundColor(this.themeColors.cardBackground)
        .borderRadius(16)
        .border({ width: 1, color: this.themeColors.cardBorder })
        .shadow({
          radius: 8,
          color: this.themeColors.cardShadow,
          offsetX: 2,
          offsetY: 2
        })
        .position({ x: '5%', y: '30%' } as Position)
        .zIndex(10)
      }

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

                // 方块内容 - 显示图像部分或数字
                if (!piece.isEmpty) {
                  Stack() {
                    // 拼图块图像部分 - 显示图像的正确部分
                    Image($r(`app.media.${this.selectedImage}`))
                      .objectFit(ImageFit.Cover)
                      .width(piece.getImageSize(this.gridSize))
                      .height(piece.getImageSize(this.gridSize))
                      .position(piece.getImageOffset(this.gridSize))
                      .borderRadius(8)
                    
                    // 拼图块边框和点击效果
                    Rect()
                      .width('100%')
                      .height('100%')
                      .fill('#00000000')
                      .strokeWidth(this.clickedPieceId === piece.id ? 3 : 1)
                      .stroke(this.clickedPieceId === piece.id ? this.themeColors.successColor : this.themeColors.gameCellBorder)
                      .borderRadius(8)
                  }
                  .width('100%')
                  .height('100%')
                  .clip(true)
                  .scale(this.clickedPieceId === piece.id ? { x: 0.95, y: 0.95 } as Scale : { x: 1, y: 1 } as Scale)
                  .animation({ duration: 200, curve: Curve.EaseOut })
                } else {
                  // 空白块
                  Rect()
                    .width('100%')
                    .height('100%')
                    .fill(this.themeColors.background)
                    .strokeWidth(1)
                    .stroke(this.themeColors.gameCellBorder)
                    .borderRadius(8)
                }

                // 方块编号（调试用）
                /*Text(piece.getDisplayText())
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(piece.isEmpty ? 
                    this.themeColors.background : 
                    (piece.isCorrectPosition() ? 
                      '#FFFFFF' : 
                      this.themeColors.buttonText))
                  .textAlign(TextAlign.Center)*/
              }
              .width('100%')
              .height('100%')
              .onClick(() => this.handlePieceClick(piece))
            }
          }, (item: PuzzlePiece) => item.id.toString())
        }
        .width(300)
        .height(300)
        .columnsTemplate('1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr')
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
        Row({ space: 16 }) {
          // 重新开始按钮
          Button('🔄 重新开始')
            .fontColor(this.themeColors.buttonText)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .width(140)
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

          // 历史记录按钮
          Button('📊 历史记录')
            .fontColor(this.themeColors.buttonText)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .width(140)
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
            .onClick(() => this.toggleRecords())
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

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

      // 历史记录弹窗
      if (this.showRecords) {
        Column() {
          Text('📋 历史记录')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeColors.primaryText)
            .margin({ bottom: 10 })

          // 历史记录列表
          if (this.gameRecords.length > 0) {
            ForEach(this.gameRecords, (record: SlidingPuzzleRecord, index: number) => {
              Row() {
                Text(`${index + 1}. ${this.formatTime(record.time)} | ${record.moves}步`)
                  .fontSize(14)
                  .fontColor(this.themeColors.primaryText)
                Text(`${new Date(record.timestamp).toLocaleDateString()}`)
                  .fontSize(12)
                  .fontColor(this.themeColors.secondaryText)
                  .layoutWeight(1)
                  .textAlign(TextAlign.End)
              }
              .width('100%')
              .padding({ top: 4, bottom: 4 })
            })
          } else {
            Text('暂无游戏记录')
              .fontSize(14)
              .fontColor(this.themeColors.secondaryText)
          }

          Button('❌ 关闭')
            .width(100)
            .height(40)
            .backgroundColor(this.themeColors.buttonBackground)
            .fontColor(this.themeColors.buttonText)
            .borderRadius(8)
            .border({ width: 1, color: this.themeColors.buttonBorder })
            .margin({ top: 10 })
            .onClick(() => this.toggleRecords())
        }
        .width('90%')
        .height('60%')
        .padding(20)
        .backgroundColor(this.themeColors.cardBackground)
        .borderRadius(16)
        .border({ width: 1, color: this.themeColors.cardBorder })
        .shadow({
          radius: 8,
          color: this.themeColors.cardShadow,
          offsetX: 2,
          offsetY: 2
        })
        .position({ x: '5%', y: '20%' } as Position)
        .zIndex(10)
      }

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