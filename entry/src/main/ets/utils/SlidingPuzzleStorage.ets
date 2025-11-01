import { SlidingPuzzleRecord } from '../model/SlidingPuzzleRecord';
import dataPreferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';

/**
 * 滑动拼图游戏存储管理类
 * 用于处理游戏记录的保存和读取
 */
export class SlidingPuzzleStorage {
  private static instance: SlidingPuzzleStorage | null = null;
  private preferences: dataPreferences.Preferences | null = null;
  private static readonly PREFERENCES_NAME = 'SlidingPuzzleRecords';
  private static readonly RECORDS_KEY = 'records';
  private static readonly MAX_RECORDS: number = 20; // 最多保存20条记录

  private constructor() {
  }

  /**
   * 获取单例实例
   */
  static getInstance(): SlidingPuzzleStorage {
    if (SlidingPuzzleStorage.instance == null) {
      SlidingPuzzleStorage.instance = new SlidingPuzzleStorage();
    }
    return SlidingPuzzleStorage.instance as SlidingPuzzleStorage;
  }

  async initialize(context: common.Context): Promise<void> {
    if (!this.preferences) {
      this.preferences = await dataPreferences.getPreferences(context, SlidingPuzzleStorage.PREFERENCES_NAME);
    }
  }

  /**
   * 保存游戏记录
   * @param record 游戏记录
   */
  async saveRecord(record: SlidingPuzzleRecord): Promise<void> {
    if (!this.preferences) {
      throw new Error('Storage not initialized');
    }

    try {
      // 获取现有记录
      let records: SlidingPuzzleRecord[] = await this.getRecords();
      
      // 添加新记录
      records.unshift(record);
      
      // 限制记录数量
      if (records.length > SlidingPuzzleStorage.MAX_RECORDS) {
        records = records.slice(0, SlidingPuzzleStorage.MAX_RECORDS);
      }
      
      // 保存到preferences
      await this.preferences.put(SlidingPuzzleStorage.RECORDS_KEY, JSON.stringify(records));
      await this.preferences.flush();
    } catch (err) {
      console.error('保存滑动拼图记录失败:', err);
    }
  }

  /**
   * 获取游戏记录
   */
  async getRecords(): Promise<SlidingPuzzleRecord[]> {
    if (!this.preferences) {
      throw new Error('Storage not initialized');
    }

    try {
      const recordsStr: string = await this.preferences.get(SlidingPuzzleStorage.RECORDS_KEY, '[]') as string;
      const records: SlidingPuzzleRecord[] = JSON.parse(recordsStr) as SlidingPuzzleRecord[];
      return records;
    } catch (err) {
      console.error('获取滑动拼图记录失败:', err);
      return [];
    }
  }

  /**
   * 清除所有记录
   */
  async clearRecords(): Promise<void> {
    if (!this.preferences) {
      throw new Error('Storage not initialized');
    }

    try {
      await this.preferences.put(SlidingPuzzleStorage.RECORDS_KEY, '[]');
      await this.preferences.flush();
    } catch (err) {
      console.error('清除滑动拼图记录失败:', err);
    }
  }
}