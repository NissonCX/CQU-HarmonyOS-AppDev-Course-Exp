/**
 * 拼图华容道 - 拼图块数据模型
 * 
 * @author Nisson_CX
 */

/**
 * 拼图块图像位置偏移量接口
 */
interface ImageOffset {
  x: string;
  y: string;
}

/**
 * 拼图块类
 */
export class PuzzlePiece {
  id: number;           // 块的唯一标识
  row: number;          // 当前行位置
  col: number;          // 当前列位置
  correctRow: number;   // 正确的行位置
  correctCol: number;   // 正确的列位置
  isEmpty: boolean;     // 是否为空块
  
  constructor(id: number, row: number, col: number, correctRow: number, correctCol: number, isEmpty: boolean = false) {
    this.id = id;
    this.row = row;
    this.col = col;
    this.correctRow = correctRow;
    this.correctCol = correctCol;
    this.isEmpty = isEmpty;
  }
  
  /**
   * 获取拼图块在图像中的位置偏移量
   * @param gridSize 网格大小
   * @returns 位置偏移量对象
   */
  getImageOffset(gridSize: number): ImageOffset {
    if (this.isEmpty) {
      return { x: '0%', y: '0%' };
    }
    
    // 计算拼图块在完整图像中的位置
    // 对于3x3网格，每个拼图块显示图像的1/3部分
    // 使用当前行列位置，因为拼图块移动后需要显示当前位置对应的图像部分
    const xOffset = -this.col * (100 / gridSize);
    const yOffset = -this.row * (100 / gridSize);
    
    return { 
      x: xOffset + '%', 
      y: yOffset + '%' 
    };
  }
  
  /**
   * 获取拼图块的图像尺寸
   * @param gridSize 网格大小
   * @returns 图像尺寸
   */
  getImageSize(gridSize: number): string {
    return (gridSize * 100) + '%';
  }
  
  /**
   * 检查拼图块是否在正确位置
   * @returns 是否在正确位置
   */
  isCorrectPosition(): boolean {
    return this.row === this.correctRow && this.col === this.correctCol;
  }
  
  /**
   * 获取显示文本
   * @returns 显示文本
   */
  getDisplayText(): string {
    if (this.isEmpty) {
      return '';
    }
    return this.id.toString();
  }
}