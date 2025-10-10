import { Card } from '../model/Card';
import { Game24Logic } from '../model/Game24Logic';
import { ExpressionEvaluator } from '../utils/ExpressionEvaluator';
import { promptAction } from '@kit.ArkUI'; // 导入用于显示弹窗的工具
import { ThemeManager } from '../model/ThemeManager';
import { ThemeType, ThemeColors } from '../model/Theme';
import router from '@ohos.router';

// 定义简单表达式验证结果接口
interface SimpleEvaluationResult {
  isValid: boolean;
  value?: number;
  message?: string;
}

@Entry
@Component
struct Game24Points {
  @State cards: Card[] = [];                 // 当前4张牌
  @State inputExpression: string = '';       // 用户输入的表达式
  @State gameMessage: string = '请使用这4张牌的点数，通过加减乘除运算得出24';  // 游戏提示信息
  @State showMessage: boolean = true;        // 是否显示消息
  @State isCorrect: boolean = false;         // 答案是否正确
  @State gameFinished: boolean = false;      // 游戏是否结束
  @State hasSolution: boolean = false;       // 当前题目是否有解（仅用于验证玩家判断）
  @State playerJudgment: string = '';        // 玩家对是否有解的判断 ('unsolvable' | 'solved' | '')
  @State solutions: string[] = [];           // 题目解法
  @State currentTime: number = 0;            // 当前游戏时间（秒）
  @State showSolutions: boolean = false;     // 是否显示参考答案
  private startTime: number = Date.now();    // 游戏开始时间
  private timerId: number = -1;              // 定时器ID
  
  // 主题相关状态
  @State private currentTheme: ThemeType = ThemeManager.getInstance().getCurrentTheme();
  @State private themeColors: ThemeColors = ThemeManager.getInstance().getCurrentColors();
  
  // 页面加载时初始化游戏
  aboutToAppear(): void {
    this.startNewGame();
    
    // 添加主题监听器
    ThemeManager.getInstance().addThemeChangeListener((theme: ThemeType, colors: ThemeColors) => {
      this.currentTheme = theme;
      this.themeColors = colors;
    });
  }
  
  // 组件销毁时清除定时器
  aboutToDisappear(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }
  
  // 开始新游戏
  startNewGame() {
    // 清除之前的定时器
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    
    // 重置游戏时间
    this.startTime = Date.now();
    this.currentTime = 0;
    
    // 启动计时器
    this.timerId = setInterval(() => {
      if (!this.gameFinished) {
        this.currentTime = Math.floor((Date.now() - this.startTime) / 1000);
      }
    }, 1000);
    
    // 获取一个随机题目（不检查是否有解）
    this.cards = Game24Logic.dealFourCards();
    
    // 检查题目是否有解（仅用于后续验证玩家判断）
    const cardNumbers = this.cards.map(card => card.getRankValue());
    this.hasSolution = Game24Logic.canMake24(cardNumbers);
    
    // 获取所有解法
    this.solutions = Game24Logic.getAllSolutions(cardNumbers);
    
    // 重置状态
    this.inputExpression = '';
    this.gameMessage = '请使用这4张牌的点数，通过加减乘除运算得出24';
    this.showMessage = true;
    this.isCorrect = false;
    this.gameFinished = false;
    this.playerJudgment = '';
  }
  
  // 处理输入表达式变化
  private onExpressionChange(value: string): void {
    this.inputExpression = value;
  }
  
  // 玩家点击无解按钮
  markAsUnsolvable() {
    this.playerJudgment = 'unsolvable';
    
    // 清除定时器
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    
    // 检查玩家判断是否正确
    if (!this.hasSolution) {
      // 当玩家判断正确且题目确实无解时，显示类似正确答案的提示
      this.gameMessage = `🎉 恭喜！判断正确。这组牌确实无解。用时: ${this.currentTime}秒`;
      this.isCorrect = true;
    } else {
      // 当玩家判断错误时，显示题目的解法
      const firstSolution = this.solutions.length > 0 ? this.solutions[0] : "无解法";
      this.gameMessage = `❌ 判断错误！这组牌其实有解: ${firstSolution}`;
      this.isCorrect = false;
    }
    this.showMessage = true;
    this.gameFinished = true;
  }
  
  // 提交答案 - 新思路实现
  submitAnswer() {
    // 玩家提交表达式，表示认为有解
    this.playerJudgment = 'solved';
    
    if (!this.inputExpression) {
      this.gameMessage = '请输入表达式';
      this.showMessage = true;
      return;
    }
    
    // 使用新的解析方法验证表达式
    const result = Game24Points.parseAndEvaluate(this.inputExpression, this.cards);
    
    if (!result.isValid) {
      this.gameMessage = result.message || '表达式无效';
      this.showMessage = true;
      this.isCorrect = false;
      this.gameFinished = true;
      return;
    }
    
    // 清除定时器
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    
    if (Math.abs(result.value! - 24) < 1e-6) {
      this.gameMessage = `🎉 恭喜！答案正确。${this.inputExpression} = ${result.value} 用时: ${this.currentTime}秒`;
      this.showMessage = true;
      this.isCorrect = true;
      this.gameFinished = true;
    } else {
      this.gameMessage = `❌ 答案错误。${this.inputExpression} = ${result.value} ≠ 24`;
      this.showMessage = true;
      this.isCorrect = false;
      this.gameFinished = true;
    }
  }
  
  // 解析并计算用户输入的表达式
  static parseAndEvaluate(expression: string, cards: Card[]): SimpleEvaluationResult {
    try {
      // 预处理表达式
      let processedExpr = expression.replace(/\s/g, ''); // 移除空格
      
      // 替换特殊符号
      processedExpr = processedExpr.replace(/×/g, '*');
      processedExpr = processedExpr.replace(/÷/g, '/');
      processedExpr = processedExpr.replace(/−/g, '-');
      processedExpr = processedExpr.replace(/﹣/g, '-');
      processedExpr = processedExpr.replace(/·/g, '*');
      
      // 检查是否包含非法字符
      if (!/^[\d+\-*/().]+$/.test(processedExpr)) {
        const result: SimpleEvaluationResult = { isValid: false, message: "表达式包含非法字符" };
        return result;
      }
      
      // 检查括号是否匹配
      if (!Game24Points.checkParentheses(processedExpr)) {
        const result: SimpleEvaluationResult = { isValid: false, message: "括号不匹配" };
        return result;
      }
      
      // 提取数字
      const numbers = Game24Points.extractNumbersFromExpression(processedExpr);
      
      // 检查是否正好有4个数字
      if (numbers.length !== 4) {
        const result: SimpleEvaluationResult = { isValid: false, message: `表达式应包含4个数字，但找到了${numbers.length}个` };
        return result;
      }
      
      // 检查数字是否与卡牌匹配
      const cardValues = cards.map(card => card.getRankValue()).sort();
      const exprNumbers = [...numbers].sort();
      
      for (let i = 0; i < 4; i++) {
        if (exprNumbers[i] !== cardValues[i]) {
          const result: SimpleEvaluationResult = { isValid: false, message: `使用的数字与卡牌不匹配` };
          return result;
        }
      }
      
      // 计算表达式结果
      const value = Game24Points.calculate(processedExpr);
      
      const result: SimpleEvaluationResult = { isValid: true, value: value };
      return result;
    } catch (error) {
      const result: SimpleEvaluationResult = { 
        isValid: false, 
        message: "表达式格式错误: " + (error instanceof Error ? error.message : String(error)) 
      };
      return result;
    }
  }
  
  // 从表达式中提取数字
  static extractNumbersFromExpression(expression: string): number[] {
    const numbers: number[] = [];
    let i = 0;
    
    while (i < expression.length) {
      // 跳过操作符和括号
      if ('+-*/()'.includes(expression[i])) {
        i++;
        continue;
      }
      
      // 提取数字
      if (/\d/.test(expression[i])) {
        let numStr = '';
        while (i < expression.length && /\d/.test(expression[i])) {
          numStr += expression[i];
          i++;
        }
        const num = parseInt(numStr, 10);
        if (num >= 1 && num <= 13) {
          numbers.push(num);
        }
      } else {
        i++;
      }
    }
    
    return numbers;
  }
  
  // 计算表达式结果 - 自定义解析实现
  evaluateExpression(expression: string): number {
    // 先验证表达式格式
    if (!expression || typeof expression !== 'string') {
      throw new Error("无效的表达式");
    }
    
    // 确保表达式只包含允许的字符
    if (!/^[\d+\-*/().]+$/.test(expression)) {
      throw new Error("表达式包含非法字符");
    }
    
    // 检查括号是否匹配
    if (!Game24Points.checkParentheses(expression)) {
      throw new Error("括号不匹配");
    }
    
    // 安全计算表达式
    return Game24Points.calculate(expression);
  }
  
  // 检查括号是否匹配
  static checkParentheses(expression: string): boolean {
    let count: number = 0;
    for (let i: number = 0; i < expression.length; i++) {
      if (expression[i] === '(') {
        count++;
      } else if (expression[i] === ')') {
        count--;
        if (count < 0) {
          return false;
        }
      }
    }
    return count === 0;
  }
  
  // 递归计算表达式
  static calculate(expr: string): number {
    // 移除空格
    expr = expr.replace(/\s/g, '');
    
    if (expr.length === 0) {
      throw new Error("空表达式");
    }
    
    // 处理括号
    while (expr.includes('(')) {
      const lastOpenParen: number = expr.lastIndexOf('(');
      const firstCloseParenAfter: number = expr.indexOf(')', lastOpenParen);
      
      if (firstCloseParenAfter === -1) {
        throw new Error("括号不匹配");
      }
      
      const innerExpr: string = expr.substring(lastOpenParen + 1, firstCloseParenAfter);
      const innerResult: number = Game24Points.calculate(innerExpr);
      expr = expr.substring(0, lastOpenParen) + innerResult.toString() + expr.substring(firstCloseParenAfter + 1);
    }
    
    // 处理乘法和除法
    while (expr.includes('*') || expr.includes('/')) {
      const mulIndex: number = expr.indexOf('*');
      const divIndex: number = expr.indexOf('/');
      
      let operatorIndex: number;
      let operator: string;
      
      if (mulIndex !== -1 && (divIndex === -1 || mulIndex < divIndex)) {
        operatorIndex = mulIndex;
        operator = '*';
      } else if (divIndex !== -1) {
        operatorIndex = divIndex;
        operator = '/';
      } else {
        break;
      }
      
      // 获取操作符前的数字
      let leftStart: number = operatorIndex - 1;
      while (leftStart >= 0 && (/\d/.test(expr[leftStart]) || expr[leftStart] === '.' || expr[leftStart] === '-')) {
        if (expr[leftStart] === '-' && leftStart > 0 && !'0123456789.'.includes(expr[leftStart - 1])) {
          break;
        }
        leftStart--;
      }
      leftStart++;
      
      // 获取操作符后的数字
      let rightEnd: number = operatorIndex + 1;
      if (rightEnd < expr.length && expr[rightEnd] === '-') {
        rightEnd++;
      }
      while (rightEnd < expr.length && (/\d/.test(expr[rightEnd]) || expr[rightEnd] === '.')) {
        rightEnd++;
      }
      
      const leftNum: number = parseFloat(expr.substring(leftStart, operatorIndex));
      const rightNum: number = parseFloat(expr.substring(operatorIndex + 1, rightEnd));
      
      if (isNaN(leftNum) || isNaN(rightNum)) {
        throw new Error("无效数字");
      }
      
      let result: number;
      if (operator === '*') {
        result = leftNum * rightNum;
      } else {
        if (Math.abs(rightNum) < 1e-10) {
          throw new Error("除数不能为零");
        }
        result = leftNum / rightNum;
      }
      
      expr = expr.substring(0, leftStart) + result.toString() + expr.substring(rightEnd);
    }
    
    // 处理加法和减法
    // 先处理第一个数字可能为负数的情况
    let startIndex: number = 0;
    if (expr[0] === '-') {
      startIndex = 1;
    }
    
    while (expr.includes('+') || expr.indexOf('-', startIndex) !== -1) {
      const addIndex: number = expr.indexOf('+', startIndex);
      const subIndex: number = expr.indexOf('-', startIndex);
      
      let operatorIndex: number;
      let operator: string;
      
      if (addIndex !== -1 && (subIndex === -1 || addIndex < subIndex)) {
        operatorIndex = addIndex;
        operator = '+';
      } else if (subIndex !== -1 && subIndex >= startIndex) {
        operatorIndex = subIndex;
        operator = '-';
      } else {
        break;
      }
      
      // 获取操作符前的数字
      let leftStart: number = operatorIndex - 1;
      while (leftStart >= 0 && (/\d/.test(expr[leftStart]) || expr[leftStart] === '.' || expr[leftStart] === '-')) {
        if (expr[leftStart] === '-' && leftStart > 0 && !'0123456789.'.includes(expr[leftStart - 1])) {
          break;
        }
        leftStart--;
      }
      leftStart++;
      
      // 获取操作符后的数字
      let rightEnd: number = operatorIndex + 1;
      if (rightEnd < expr.length && expr[rightEnd] === '-') {
        rightEnd++;
      }
      while (rightEnd < expr.length && (/\d/.test(expr[rightEnd]) || expr[rightEnd] === '.')) {
        rightEnd++;
      }
      
      const leftNum: number = parseFloat(expr.substring(leftStart, operatorIndex));
      const rightNum: number = parseFloat(expr.substring(operatorIndex + 1, rightEnd));
      
      if (isNaN(leftNum) || isNaN(rightNum)) {
        throw new Error("无效数字");
      }
      
      let result: number;
      if (operator === '+') {
        result = leftNum + rightNum;
      } else {
        result = leftNum - rightNum;
      }
      
      expr = expr.substring(0, leftStart) + result.toString() + expr.substring(rightEnd);
    }
    
    const finalResult: number = parseFloat(expr);
    if (isNaN(finalResult)) {
      throw new Error("计算结果无效");
    }
    
    return finalResult;
  }
  
  // 显示解法弹窗
  showSolutionsDialog() {
    this.showSolutions = true;
  }
  
  // 隐藏解法
  hideSolutionsDialog() {
    this.showSolutions = false;
  }

  build() {
    Column() {
      // 标题区域 - 居中对称布局
      Column() {
        Row() {
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
            .onClick(() => {
              router.back();
            })
          
          // 标题区域
          Column() {
            Text('🃏 24点游戏 🧮')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Center)
              .fontColor(this.themeColors.primaryText)

            Text('使用4张牌通过运算得到24')
              .fontSize(14)
              .fontColor(this.themeColors.secondaryText)
              .margin({ top: 6 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          
          // 占位符保持对称
          Column()
            .width(40)
            .height(40)
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
        .margin({ top: 20, bottom: 20 })

        // 时间显示 - 居中
        Row() {
          Text('⏱ 时间')
            .fontSize(14)
            .fontColor(this.themeColors.secondaryText)
            .margin({ right: 8 })
          
          Text(`${this.currentTime.toString().padStart(3, '0')}s`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeColors.buttonText)
        }
        .padding({ left: 20, right: 20, top: 12, bottom: 12 })
        .backgroundColor(this.themeColors.cardBackground)
        .borderRadius(20)
        .border({ width: 1, color: this.themeColors.cardBorder })
        .shadow({
          radius: 6,
          color: this.themeColors.cardShadow,
          offsetX: 2,
          offsetY: 2
        })
        .alignSelf(ItemAlign.Center)
        .margin({ bottom: 20 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // 卡牌显示区域
      Row() {
        ForEach(this.cards, (card: Card, index: number) => {
          Image($r('app.media.' + card.getResourceName()))
            .width(80)
            .height(110)
            .margin({ left: 5, right: 5 })
            .borderRadius(8)
            .shadow({
              radius: 6,
              color: '#333333',
              offsetX: 2,
              offsetY: 2
            })
        }, (item: Card) => item.getResourceName())
      }
      .margin({ top: 20, bottom: 30 })
      .alignItems(VerticalAlign.Center)
      
      // 输入区域
      Column() {
        Text('🔢 请输入运算表达式:')
          .fontSize(16)
          .margin({ bottom: 15 })
          .fontColor(this.themeColors.primaryText)
        
        // 提示信息
        Row() {
          Text(this.gameMessage)
            .fontSize(14)
            .fontColor(this.isCorrect ? this.themeColors.successColor : this.themeColors.errorColor)
            .textAlign(TextAlign.Center)
            .width('80%')
            .padding(15)
            .backgroundColor(this.themeColors.cardBackground)
            .borderRadius(12)
            .shadow({
              radius: 6,
              color: this.themeColors.cardShadow,
              offsetX: 2,
              offsetY: 2
            })
            .visibility(this.showMessage ? Visibility.Visible : Visibility.Hidden)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ bottom: 20 })
        
        TextInput({ placeholder: '📌 例如: (5-1)*(6/2)', text: this.inputExpression })
          .onChange((value: string) => this.onExpressionChange(value))
          .width('80%')
          .height(50)
          .margin({ bottom: 30, top: 10 })
          .enabled(!this.gameFinished)
          .backgroundColor(this.themeColors.inputBackground)
          .borderRadius(12)
          .shadow({
            radius: 6,
            color: this.themeColors.cardShadow,
            offsetX: 2,
            offsetY: 2
          })
          .placeholderColor(this.themeColors.secondaryText)
          .fontColor(this.themeColors.inputText)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      
      // 参考答案显示区域
      if (this.showSolutions && this.gameFinished) {
        Column() {
          Row() {
            Text('📋 参考答案')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeColors.primaryText)
            
            Button('退出')
              .width(60)
              .height(40)
              .fontSize(16)
              .fontColor(this.themeColors.buttonText)
              .backgroundColor(this.themeColors.buttonBackground)
              .borderRadius(20)
              .border({ width: 1, color: this.themeColors.buttonBorder })
              .onClick(() => {
                this.hideSolutionsDialog();
              })
              .margin({ left: 10 })
          }
          .width('90%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          
          Scroll() {
            Column() {
              ForEach(this.solutions, (solution: string, index: number) => {
                Row() {
                  Text(`${index + 1}. ${solution}`)
                    .fontSize(16)
                    .fontColor(this.themeColors.primaryText)
                    .textAlign(TextAlign.Start)
                    .width('100%')
                }
                .width('100%')
                .padding(10)
                .backgroundColor(this.themeColors.cardBackground)
                .borderRadius(10)
                .margin({ bottom: 10 })
              })
              
              if (this.solutions.length === 0) {
                Text('这道题无解')
                  .fontSize(16)
                  .fontColor(this.themeColors.primaryText)
                  .padding(10)
                  .backgroundColor(this.themeColors.cardBackground)
                  .borderRadius(10)
                  .width('100%')
                  .textAlign(TextAlign.Center)
              }
            }
            .width('90%')
            .padding({ top: 10, bottom: 10 })
          }
          .layoutWeight(1)
          .width('100%')
        }
        .width('100%')
        .height(300)
        .padding(20)
        .backgroundColor(this.themeColors.cardBackground)
        .borderRadius(20)
        .border({ width: 1, color: this.themeColors.cardBorder })
        .shadow({
          radius: 8,
          color: this.themeColors.cardShadow,
          offsetX: 2,
          offsetY: 2
        })
        .margin({ bottom: 20 })
      }
      
      // 按钮区域
      Column() {
        Row({ space: 16 }) {
          Button('🔄 重新开始')
            .width(150)
            .height(50)
            .fontSize(16)
            .backgroundColor(this.themeColors.buttonBackground)
            .fontColor(this.themeColors.buttonText)
            .borderRadius(14)
            .border({ width: 1, color: this.themeColors.buttonBorder })
            .shadow({
              radius: 8,
              color: this.themeColors.cardShadow,
              offsetX: 2,
              offsetY: 2
            })
            .onClick(() => {
              this.startNewGame();
              this.hideSolutionsDialog();
            })
          
          Button('❓ 无解')
            .width(150)
            .height(50)
            .fontSize(16)
            .backgroundColor(this.themeColors.buttonBackground)
            .fontColor(this.themeColors.buttonText)
            .borderRadius(14)
            .border({ width: 1, color: this.themeColors.buttonBorder })
            .shadow({
              radius: 8,
              color: this.themeColors.cardShadow,
              offsetX: 2,
              offsetY: 2
            })
            .enabled(!this.gameFinished)
            .onClick(() => {
              this.markAsUnsolvable();
            })
        }
        .margin({ bottom: 15 })
        .justifyContent(FlexAlign.Center)
        
        // 查看答案按钮（仅在游戏结束后显示）
        if (this.gameFinished && !this.showSolutions) {
          Button('👀 查看答案')
            .width(316)
            .height(50)
            .fontSize(16)
            .backgroundColor(this.themeColors.buttonBackground)
            .fontColor(this.themeColors.buttonText)
            .borderRadius(14)
            .border({ width: 1, color: this.themeColors.buttonBorder })
            .shadow({
              radius: 8,
              color: this.themeColors.cardShadow,
              offsetX: 2,
              offsetY: 2
            })
            .margin({ bottom: 15 })
            .onClick(() => {
              this.showSolutionsDialog();
            })
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.End)
      .padding({ bottom: 30 })
      
      // 底部信息区域 - 居中布局
      Column() {
        Text('🎯 24点游戏考验你的数学运算能力')
          .fontSize(12)
          .fontColor(this.themeColors.tertiaryText)
          .margin({ bottom: 6 })

        Text('🧮 数学运算 · ⏱️ 逻辑挑战')
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
      .padding({ bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeColors.background)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}