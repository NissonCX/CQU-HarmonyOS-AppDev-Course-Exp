/**
 * 拼图华容道 - 拼图块数据模型
 * 
 * @author Nisson_CX
 */

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