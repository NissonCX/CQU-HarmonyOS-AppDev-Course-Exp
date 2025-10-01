/**
 * 24点游戏 - 扑克牌数据模型
 * 
 * @author Nisson_CX
 */

/**
 * 花色枚举
 */
export enum Suit {
  HEART = 'Heart',      // 红桃
  DIAMOND = 'Diamond',  // 方块
  CLUB = 'Club',        // 梅花
  SPADE = 'Spade'       // 黑桃
}

/**
 * 扑克牌类
 */
export class Card {
  suit: Suit;           // 花色
  rank: number;         // 点数 (A=1, J=11, Q=12, K=13)
  
  constructor(suit: Suit, rank: number) {
    this.suit = suit;
    this.rank = rank;
  }
  
  /**
   * 获取卡牌的资源名称
   * @returns 资源名称，如 'HeartA', 'Diamond10' 等
   */
  getResourceName(): string {
    let rankStr = '';
    switch (this.rank) {
      case 1:
        rankStr = 'A';
        break;
      case 11:
        rankStr = 'J';
        break;
      case 12:
        rankStr = 'Q';
        break;
      case 13:
        rankStr = 'K';
        break;
      default:
        rankStr = this.rank.toString();
    }
    // 确保首字母大写，与资源文件名匹配
    return this.suit.charAt(0).toUpperCase() + this.suit.slice(1) + rankStr;
  }
  
  /**
   * 获取卡牌的点数值
   * @returns 点数值
   */
  getRankValue(): number {
    return this.rank;
  }
  
  /**
   * 获取卡牌的显示文本
   * @returns 显示文本
   */
  getDisplayText(): string {
    switch (this.rank) {
      case 1:
        return 'A';
      case 11:
        return 'J';
      case 12:
        return 'Q';
      case 13:
        return 'K';
      default:
        return this.rank.toString();
    }
  }
}