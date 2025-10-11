// MinesweeperRecord.ets
export interface MinesweeperRecordData {
  id: string;
  time: number;
  timestamp: number;
  isWin: boolean; // 是否胜利
}

export class MinesweeperRecord {
  id: string; // 记录ID
  time: number; // 游戏完成时间（秒）
  timestamp: number; // 记录时间戳
  isWin: boolean; // 是否胜利
  
  constructor(time: number, isWin: boolean = true) {
    this.id = Date.now().toString() + Math.random().toString(36).substr(2, 5);
    this.time = time;
    this.timestamp = Date.now();
    this.isWin = isWin;
  }
}

export enum PlayerLevel {
  BEGINNER = "菜鸟玩家",
  SKILLED = "优秀玩家",
  EXPERT = "骨灰级玩家"
}

export function getPlayerLevel(wins: number): PlayerLevel | null {
  if (wins >= 20) {
    return PlayerLevel.EXPERT;
  } else if (wins >= 10) {
    return PlayerLevel.SKILLED;
  } else if (wins >= 5) {
    return PlayerLevel.BEGINNER;
  } else {
    return null; // 未达到评级标准
  }
}