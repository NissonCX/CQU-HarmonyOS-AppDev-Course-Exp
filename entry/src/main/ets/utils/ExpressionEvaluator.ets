/**
 * 24点游戏 - 表达式计算器
 * 用于解析和计算用户输入的数学表达式
 * 
 * @author Nisson_CX
 */

import { Card } from '../model/Card';

/**
 * 表达式验证结果接口
 */
interface EvaluationResult {
  isValid: boolean;
  result?: number;
  message?: string;
  usedNumbers?: number[];
}

export class ExpressionEvaluator {
  /**
   * 验证表达式是否合法并计算结果
   * @param expression 用户输入的表达式
   * @param cards 当前的4张牌
   * @returns 验证结果对象
   */
  static evaluate(expression: string, cards: Card[]): EvaluationResult {
    try {
      // 预处理表达式，适配多种输入方式
      let processedExpression = expression;
      
      // 移除空格和制表符
      processedExpression = processedExpression.replace(/\s/g, '');
      
      // 检查表达式是否为空
      if (!processedExpression) {
        const result: EvaluationResult = {
          isValid: false,
          message: "表达式不能为空"
        };
        return result;
      }
      
      // 适配多种乘法符号
      processedExpression = processedExpression.replace(/×/g, '*');
      processedExpression = processedExpression.replace(/·/g, '*');
      
      // 适配多种除法符号
      processedExpression = processedExpression.replace(/÷/g, '/');
      
      // 适配多种减法符号
      processedExpression = processedExpression.replace(/−/g, '-'); // 全角减号
      processedExpression = processedExpression.replace(/﹣/g, '-'); // 小减号
      
      // 验证表达式中的字符是否合法
      if (!/^[\d+\-*/().]+$/.test(processedExpression)) {
        const result: EvaluationResult = {
          isValid: false,
          message: "表达式包含非法字符"
        };
        return result;
      }
      
      // 提取表达式中的数字
      const usedNumbers = ExpressionEvaluator.extractNumbers(processedExpression);
      
      // 检查是否提取到数字
      if (usedNumbers.length === 0) {
        const result: EvaluationResult = {
          isValid: false,
          message: "表达式中未找到有效数字"
        };
        return result;
      }
      
      // 获取卡牌数值
      const cardValues = cards.map(card => card.getRankValue());
      
      // 验证使用的数字是否与发牌一致（考虑所有可能的排列组合）
      if (!ExpressionEvaluator.validateNumbers(usedNumbers, cardValues)) {
        const result: EvaluationResult = {
          isValid: false,
          message: `使用的数字${usedNumbers.join(',')}与发牌${cardValues.join(',')}不匹配`,
          usedNumbers: usedNumbers
        };
        return result;
      }
      
      // 计算表达式结果
      const result = ExpressionEvaluator.calculateExpression(processedExpression);
      
      const evalResult: EvaluationResult = {
        isValid: true,
        result: result,
        usedNumbers: usedNumbers
      };
      return evalResult;
    } catch (error) {
      const result: EvaluationResult = {
        isValid: false,
        message: "表达式格式错误: " + (error instanceof Error ? error.message : String(error))
      };
      return result;
    }
  }
  
  /**
   * 验证使用的数字是否与发牌一致
   * @param usedNumbers 表达式中使用的数字
   * @param cardValues 卡牌数值
   * @returns 是否匹配
   */
  private static validateNumbers(usedNumbers: number[], cardValues: number[]): boolean {
    // 必须使用4个数字
    if (usedNumbers.length !== 4) {
      return false;
    }
    
    // 创建副本进行排序和比较
    const usedCopy = [...usedNumbers].sort((a, b) => a - b);
    const cardCopy = [...cardValues].sort((a, b) => a - b);
    
    // 逐个比较排序后的数组
    for (let i = 0; i < usedCopy.length; i++) {
      if (usedCopy[i] !== cardCopy[i]) {
        return false;
      }
    }
    
    return true;
  }
  
  /**
   * 从表达式中提取数字（改进版）
   * @param expression 数学表达式
   * @returns 表达式中包含的数字数组
   */
  private static extractNumbers(expression: string): number[] {
    // 使用正则表达式精确匹配1-13的数字
    const regex = /\d+/g;
    const matches = expression.match(regex);
    
    if (!matches) {
      return [];
    }
    
    // 转换为数字并过滤
    const numbers = matches
      .map(str => {
        const num = parseInt(str, 10);
        // 确保数字在扑克牌范围内 (1-13)
        return (num >= 1 && num <= 13) ? num : -1;
      })
      .filter(num => num !== -1); // 过滤掉无效数字
    
    return numbers;
  }
  
  /**
   * 计算数学表达式的结果（安全版）
   * @param expression 数学表达式字符串
   * @returns 计算结果
   */
  private static calculateExpression(expression: string): number {
    try {
      // 验证表达式格式
      if (!expression || typeof expression !== 'string') {
        throw new Error("Invalid expression");
      }
      
      // 确保表达式只包含允许的字符
      if (!/^[\d+\-*/().]+$/.test(expression)) {
        throw new Error("Expression contains invalid characters");
      }
      
      // 验证括号匹配
      if (!ExpressionEvaluator.checkParentheses(expression)) {
        throw new Error("Mismatched parentheses");
      }
      
      // 安全计算表达式
      // 使用 new Function 而不是 eval 更安全
      const func = new Function('"use strict"; return (' + expression + ')');
      const result = func() as number;
      
      // 验证结果
      if (typeof result !== 'number' || !isFinite(result)) {
        throw new Error("Invalid calculation result");
      }
      
      // 保留小数点后6位
      return Math.round(result * 1000000) / 1000000;
    } catch (error) {
      if (error instanceof Error) {
        throw new Error("无法计算表达式: " + error.message);
      } else {
        throw new Error("无法计算表达式: 未知错误");
      }
    }
  }
  
  /**
   * 检查括号是否匹配
   * @param expression 表达式
   * @returns 是否匹配
   */
  private static checkParentheses(expression: string): boolean {
    let count = 0;
    for (let i = 0; i < expression.length; i++) {
      if (expression[i] === '(') {
        count++;
      } else if (expression[i] === ')') {
        count--;
        if (count < 0) {
          return false; // 右括号多于左括号
        }
      }
    }
    return count === 0; // 左右括号数量必须相等
  }
  
  /**
   * 格式化数字为扑克牌显示值
   * @param num 数字
   * @returns 扑克牌显示值 (A, 2-10, J, Q, K)
   */
  static formatAsCardValue(num: number): string {
    switch (num) {
      case 1: return 'A';
      case 11: return 'J';
      case 12: return 'Q';
      case 13: return 'K';
      default: return num.toString();
    }
  }
}