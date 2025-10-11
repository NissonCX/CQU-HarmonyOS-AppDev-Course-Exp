// MinesweeperStorage.ets
import dataPreferences from '@ohos.data.preferences';
import { MinesweeperRecordData } from '../model/MinesweeperRecord';
import { common } from '@kit.AbilityKit';

export class MinesweeperStorage {
  private static instance: MinesweeperStorage | null = null;
  private preferences: dataPreferences.Preferences | null = null;
  private static readonly PREFERENCES_NAME = 'minesweeper_records';
  private static readonly RECORDS_KEY = 'records';

  private constructor() { }

  static getInstance(): MinesweeperStorage {
    if (!MinesweeperStorage.instance) {
      MinesweeperStorage.instance = new MinesweeperStorage();
    }
    return MinesweeperStorage.instance;
  }

  async initialize(context: common.Context): Promise<void> {
    if (!this.preferences) {
      this.preferences = await dataPreferences.getPreferences(context, MinesweeperStorage.PREFERENCES_NAME);
    }
  }

  async saveRecord(record: MinesweeperRecordData): Promise<void> {
    if (!this.preferences) {
      throw new Error('Storage not initialized');
    }

    try {
      // 获取现有记录
      let records: MinesweeperRecordData[] = await this.getRecords();
      
      // 添加新记录
      records.push(record);
      
      // 保存到preferences
      const recordsStr = JSON.stringify(records);
      await this.preferences.put(MinesweeperStorage.RECORDS_KEY, recordsStr);
      await this.preferences.flush();
    } catch (e) {
      console.error('保存扫雷记录失败:', e);
    }
  }

  async getRecords(): Promise<MinesweeperRecordData[]> {
    if (!this.preferences) {
      throw new Error('Storage not initialized');
    }

    try {
      const recordsStr = await this.preferences.get(MinesweeperStorage.RECORDS_KEY, '[]') as string;
      if (recordsStr) {
        return JSON.parse(recordsStr) as MinesweeperRecordData[];
      }
      return [];
    } catch (e) {
      console.error('获取扫雷记录失败:', e);
      return [];
    }
  }

  async clearRecords(): Promise<void> {
    if (!this.preferences) {
      throw new Error('Storage not initialized');
    }

    try {
      await this.preferences.delete(MinesweeperStorage.RECORDS_KEY);
      await this.preferences.flush();
    } catch (e) {
      console.error('清除扫雷记录失败:', e);
    }
  }
}