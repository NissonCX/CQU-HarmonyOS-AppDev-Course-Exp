/**
 * 主题管理 - 明暗主题切换
 * 
 * @author Nisson_CX
 */

/**
 * 主题类型枚举
 */
export enum ThemeType {
  LIGHT = 'light',
  DARK = 'dark'
}

/**
 * 主题颜色配置接口
 */
export interface ThemeColors {
  // 背景色
  background: string;
  surface: string;
  
  // 文字颜色
  primaryText: string;
  secondaryText: string;
  tertiaryText: string;
  
  // 按钮颜色
  buttonBackground: string;
  buttonText: string;
  buttonBorder: string;
  
  // 卡片颜色
  cardBackground: string;
  cardBorder: string;
  cardShadow: string;
  
  // 游戏特定颜色
  gameCellBackground: string;
  gameCellRevealed: string;
  gameCellMine: string;
  gameCellBorder: string;
  
  // 状态颜色
  successColor: string;
  errorColor: string;
  warningColor: string;
  
  // 输入框颜色
  inputBackground: string;
  inputBorder: string;
  inputText: string;
}

/**
 * 主题配置类
 */
export class ThemeConfig {
  // 浅色主题配置
  static readonly LIGHT_THEME: ThemeColors = {
    // 背景色
    background: '#f5f7fa',
    surface: '#ffffff',
    
    // 文字颜色
    primaryText: '#2c3e50',
    secondaryText: '#5a6c7d',
    tertiaryText: '#95a5a6',
    
    // 按钮颜色
    buttonBackground: '#ffffff',
    buttonText: '#2c3e50',
    buttonBorder: '#d1d8e0',
    
    // 卡片颜色
    cardBackground: '#ffffff',
    cardBorder: '#e8ecf0',
    cardShadow: '#00000015',
    
    // 游戏特定颜色
    gameCellBackground: '#3498db',
    gameCellRevealed: '#ffffff',
    gameCellMine: '#e74c3c',
    gameCellBorder: '#2980b9',
    
    // 状态颜色
    successColor: '#27ae60',
    errorColor: '#e74c3c',
    warningColor: '#f39c12',
    
    // 输入框颜色
    inputBackground: '#ffffff',
    inputBorder: '#d1d8e0',
    inputText: '#2c3e50'
  };
  
  // 深色主题配置
  static readonly DARK_THEME: ThemeColors = {
    // 背景色
    background: '#0d1117',
    surface: '#161b22',
    
    // 文字颜色
    primaryText: '#f0f6fc',
    secondaryText: '#c9d1d9',
    tertiaryText: '#8b949e',
    
    // 按钮颜色
    buttonBackground: '#21262d',
    buttonText: '#f0f6fc',
    buttonBorder: '#30363d',
    
    // 卡片颜色
    cardBackground: '#161b22',
    cardBorder: '#30363d',
    cardShadow: '#00000030',
    
    // 游戏特定颜色
    gameCellBackground: '#2d333b',         // 未揭开格子背景色 (更深一些)
    gameCellRevealed: '#1e2329',           // 已揭开格子背景色 (更亮一些)
    gameCellMine: '#da3633',               // 地雷格子背景色
    gameCellBorder: '#454d56',             // 格子边框颜色
    
    // 状态颜色
    successColor: '#3fb950',
    errorColor: '#f85149',
    warningColor: '#d29922',
    
    // 输入框颜色
    inputBackground: '#21262d',
    inputBorder: '#30363d',
    inputText: '#f0f6fc'
  };
  
  /**
   * 根据主题类型获取颜色配置
   * @param themeType 主题类型
   * @returns 对应的颜色配置
   */
  static getColors(themeType: ThemeType): ThemeColors {
    return themeType === ThemeType.LIGHT ? ThemeConfig.LIGHT_THEME : ThemeConfig.DARK_THEME;
  }
  
  /**
   * 获取主题对应的图标
   * @param themeType 主题类型
   * @returns 主题图标
   */
  static getThemeIcon(themeType: ThemeType): string {
    return themeType === ThemeType.LIGHT ? '🌙' : '☀️';
  }
  
  /**
   * 获取主题对应的描述
   * @param themeType 主题类型
   * @returns 主题描述
   */
  static getThemeDescription(themeType: ThemeType): string {
    return themeType === ThemeType.LIGHT ? '浅色主题' : '深色主题';
  }
}
