@ObservedV2
// 使用@ObservedV2装饰器使得类的状态可以被自动追踪
export class Cell {
  row: number; // 方块所在的行
  column: number; // 方块所在的列
  hasMine: boolean = false; // 是否有地雷，默认没有
  neighborMines: number = 0; // 周围地雷数量，默认为0
  @Trace isFlag: boolean = false; // 是否被标记为地雷，默认没有标记
  @Trace value: string; // 方块值，显示数字或“雷”

  // 构造函数，初始化方块的位置和值
  constructor(row: number, column: number) {
    this.row = row;
    this.column = column;
    this.value = ''; // 初始为空字符串
  }
}