/**
 * 24点游戏 - 核心逻辑处理
 * 
 * @author Nisson_CX
 */

import { Card, Suit } from '../model/Card';

export class Game24Logic {
  /**
   * 生成一副完整的扑克牌（不包括大小王）
   * @returns 扑克牌数组
   */
  static createDeck(): Card[] {
    const deck: Card[] = [];
    // 四种花色
    const suits = [Suit.HEART, Suit.DIAMOND, Suit.CLUB, Suit.SPADE];
    
    // 每种花色13张牌 (A, 2-10, J, Q, K)
    for (let suit of suits) {
      for (let rank = 1; rank <= 13; rank++) {
        deck.push(new Card(suit, rank));
      }
    }
    
    return deck;
  }
  
  /**
   * 随机抽取4张不重复的牌
   * @returns 4张随机牌的数组
   */
  static dealFourCards(): Card[] {
    const deck = Game24Logic.createDeck();
    const cards: Card[] = [];
    
    // Fisher-Yates 洗牌算法，随机抽取4张牌
    for (let i = 0; i < 4; i++) {
      const randomIndex = Math.floor(Math.random() * (deck.length - i));
      cards.push(deck[randomIndex]);
      // 将选中的牌与末尾的牌交换，确保不重复
      if (randomIndex !== deck.length - 1 - i) {
        deck[randomIndex] = deck[deck.length - 1 - i];
      }
    }
    
    return cards;
  }
  
  /**
   * 检查给定的4个数字是否能通过基本运算得到24
   * 使用递归方法尝试所有可能的运算组合
   * @param numbers 4个数字
   * @returns 是否能组成24点
   */
  static canMake24(numbers: number[]): boolean {
    // 基本情况：只有一个数字时，检查是否等于24
    if (numbers.length === 1) {
      // 使用误差范围比较浮点数
      return Math.abs(numbers[0] - 24) < 1e-6;
    }
    
    // 递归情况：选择两个数字进行运算
    for (let i = 0; i < numbers.length; i++) {
      for (let j = i + 1; j < numbers.length; j++) {
        const a = numbers[i];
        const b = numbers[j];
        // 剩余的数字
        const remaining = numbers.filter((_, index) => index !== i && index !== j);
        
        // 尝试所有可能的运算 (+, -, *, /)
        const results: number[] = [
          a + b,    // 加法
          a - b,    // 减法1
          b - a,    // 减法2
          a * b,    // 乘法
        ];
        
        // 除法需要检查分母不为0
        if (Math.abs(b) > 1e-6) results.push(a / b);
        if (Math.abs(a) > 1e-6) results.push(b / a);
        
        // 对每种运算结果递归检查
        for (const result of results) {
          if (Game24Logic.canMake24([result, ...remaining])) {
            return true;
          }
        }
      }
    }
    
    return false;
  }
  
  /**
   * 获取所有可能的解法
   * @param numbers 4个数字
   * @returns 所有可能的解法表达式数组
   */
  static getAllSolutions(numbers: number[]): string[] {
    const solutions: string[] = [];
    Game24Logic.findSolutionsRecursive(numbers, solutions, []);
    // 去重
    const uniqueSolutions: string[] = [];
    const solutionSet = new Set(solutions);
    solutionSet.forEach(solution => uniqueSolutions.push(solution));
    return uniqueSolutions;
  }
  
  /**
   * 递归查找所有解法
   * @param numbers 当前数字数组
   * @param solutions 存储解法的数组
   * @param expressions 当前表达式栈
   */
  private static findSolutionsRecursive(numbers: number[], solutions: string[], expressions: string[]): void {
    // 基本情况：只有一个数字时，检查是否等于24
    if (numbers.length === 1) {
      if (Math.abs(numbers[0] - 24) < 1e-6) {
        solutions.push(expressions[0]);
      }
      return;
    }
    
    // 递归情况：选择两个数字进行运算
    for (let i = 0; i < numbers.length; i++) {
      for (let j = i + 1; j < numbers.length; j++) {
        const a = numbers[i];
        const b = numbers[j];
        const exprA = expressions[i] || a.toString();
        const exprB = expressions[j] || b.toString();
        
        // 剩余的数字和表达式
        const remainingNumbers = numbers.filter((_, index) => index !== i && index !== j);
        const remainingExpressions = expressions.filter((_, index) => index !== i && index !== j);
        
        // 尝试所有可能的运算 (+, -, *, /)
        interface Operation {
          result: number;
          expression: string;
        }
        
        const operations: Operation[] = [
          { result: a + b, expression: `(${exprA}+${exprB})` },
          { result: a - b, expression: `(${exprA}-${exprB})` },
          { result: b - a, expression: `(${exprB}-${exprA})` },
          { result: a * b, expression: `(${exprA}*${exprB})` },
        ];
        
        // 除法需要检查分母不为0
        if (Math.abs(b) > 1e-6) operations.push({ result: a / b, expression: `(${exprA}/${exprB})` });
        if (Math.abs(a) > 1e-6) operations.push({ result: b / a, expression: `(${exprB}/${exprA})` });
        
        // 对每种运算结果递归检查
        for (const operation of operations) {
          Game24Logic.findSolutionsRecursive(
            [operation.result, ...remainingNumbers],
            solutions,
            [operation.expression, ...remainingExpressions]
          );
        }
      }
    }
  }
  
  /**
   * 获取一个可解的24点题目
   * @param maxAttempts 最大尝试次数
   * @returns 可解的4张牌，如果超过最大尝试次数则返回null
   */
  static getSolvablePuzzle(maxAttempts: number = 100): Card[] | null {
    for (let i = 0; i < maxAttempts; i++) {
      const cards = Game24Logic.dealFourCards();
      const numbers = cards.map(card => card.getRankValue());
      
      if (Game24Logic.canMake24(numbers)) {
        return cards;
      }
    }
    
    return null;
  }
  
  /**
   * 验证用户输入的表达式是否正确
   * @param expression 用户输入的表达式
   * @param cards 当前的4张牌
   * @returns 验证结果对象
   */
  static validateExpression(expression: string, cards: Card[]): ValidationResult {
    // 实际验证逻辑已移至ExpressionEvaluator中实现
    // 这里保留此方法以保持接口一致性
    const result: ValidationResult = {
      isValid: false,
      message: "验证功能已迁移至ExpressionEvaluator"
    };
    return result;
  }
}

/**
 * 表达式验证结果接口
 */
interface ValidationResult {
  isValid: boolean;
  result?: number;
  message?: string;
}
