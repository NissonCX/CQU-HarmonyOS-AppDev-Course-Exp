/**
 * 滑动拼图游戏记录数据模型
 * 
 * @author Nisson_CX
 */

export class SlidingPuzzleRecord {
  id: string;           // 记录唯一标识
  time: number;         // 完成时间（秒）
  moves: number;        // 移动步数
  timestamp: number;    // 时间戳
  isWin: boolean;       // 是否胜利
  imageSize: number;    // 图像尺寸 (如 3 表示 3x3)
  
  constructor(id: string, time: number, moves: number, timestamp: number, isWin: boolean, imageSize: number) {
    this.id = id;
    this.time = time;
    this.moves = moves;
    this.timestamp = timestamp;
    this.isWin = isWin;
    this.imageSize = imageSize;
  }
}