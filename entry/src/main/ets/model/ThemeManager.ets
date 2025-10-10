/**
 * 主题管理器 - 全局主题状态管理
 * 
 * @author Nisson_CX
 */

import { ThemeType, ThemeColors, ThemeConfig } from './Theme';

/**
 * 主题管理器类
 * 使用单例模式管理全局主题状态
 */
export class ThemeManager {
  private static instance: ThemeManager;
  private currentTheme: ThemeType = ThemeType.LIGHT;
  private themeChangeListeners: ((theme: ThemeType, colors: ThemeColors) => void)[] = [];
  
  private constructor() {
    // 私有构造函数，实现单例模式
  }
  
  /**
   * 获取主题管理器实例
   * @returns ThemeManager实例
   */
  static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager();
    }
    return ThemeManager.instance;
  }
  
  /**
   * 获取当前主题
   * @returns 当前主题类型
   */
  getCurrentTheme(): ThemeType {
    return this.currentTheme;
  }
  
  /**
   * 获取当前主题的颜色配置
   * @returns 当前主题的颜色配置
   */
  getCurrentColors(): ThemeColors {
    return ThemeConfig.getColors(this.currentTheme);
  }
  
  /**
   * 切换主题
   * @param newTheme 新主题类型
   */
  switchTheme(newTheme: ThemeType): void {
    if (this.currentTheme !== newTheme) {
      this.currentTheme = newTheme;
      const colors = this.getCurrentColors();
      
      // 通知所有监听器主题已改变
      this.themeChangeListeners.forEach(listener => {
        listener(this.currentTheme, colors);
      });
    }
  }
  
  /**
   * 切换明暗主题
   */
  toggleTheme(): void {
    const newTheme = this.currentTheme === ThemeType.LIGHT ? ThemeType.DARK : ThemeType.LIGHT;
    this.switchTheme(newTheme);
  }
  
  /**
   * 添加主题变化监听器
   * @param listener 监听器函数
   */
  addThemeChangeListener(listener: (theme: ThemeType, colors: ThemeColors) => void): void {
    this.themeChangeListeners.push(listener);
  }
  
  /**
   * 移除主题变化监听器
   * @param listener 要移除的监听器函数
   */
  removeThemeChangeListener(listener: (theme: ThemeType, colors: ThemeColors) => void): void {
    const index = this.themeChangeListeners.indexOf(listener);
    if (index > -1) {
      this.themeChangeListeners.splice(index, 1);
    }
  }
  
  /**
   * 检查是否为深色主题
   * @returns 是否为深色主题
   */
  isDarkTheme(): boolean {
    return this.currentTheme === ThemeType.DARK;
  }
  
  /**
   * 检查是否为浅色主题
   * @returns 是否为浅色主题
   */
  isLightTheme(): boolean {
    return this.currentTheme === ThemeType.LIGHT;
  }
}
