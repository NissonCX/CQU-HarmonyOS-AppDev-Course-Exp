import EachLevel from "../model/LevelModel";

class LevelData {
  initialLevel: Array<EachLevel> = []

  constructor() {
    this.populateData();
  }

  private populateData(): void {
    //为了测试方便，前六关可以直接进入
    this.initialLevel.push(new EachLevel(1, $r(`app.media.album1`), 2, 2, 3, 2))
    this.initialLevel.push(new EachLevel(2, $r(`app.media.album2`), 2, 2, 3, 2))
    this.initialLevel.push(new EachLevel(3, $r(`app.media.album3`), 2, 3, 2, 2))
    this.initialLevel.push(new EachLevel(4, $r(`app.media.album4`), 2, 3, 1, 2))
    this.initialLevel.push(new EachLevel(5, $r(`app.media.album5`), 2, 2, 0, 1))
    this.initialLevel.push(new EachLevel(6, $r(`app.media.album1`), 2, 2, 0, 0))
    //后六关则需要打通前置关卡集齐对应星数后才能进入
    this.initialLevel.push(new EachLevel(7, $r(`app.media.album2`), 3, 4, 0, 0))
    this.initialLevel.push(new EachLevel(8, $r(`app.media.album3`), 4, 3, 0, 0))
    this.initialLevel.push(new EachLevel(9, $r(`app.media.album4`), 4, 4, 0, 0))
    this.initialLevel.push(new EachLevel(10, $r(`app.media.album5`), 5, 5, 0, 0))
    this.initialLevel.push(new EachLevel(11, $r(`app.media.album1`), 5, 6, 0, 0))
    this.initialLevel.push(new EachLevel(12, $r(`app.media.album2`), 6, 6, 0, 0))
  }

  public getLevelData(): Array<EachLevel> {
    return this.initialLevel;
  }
}

export let levelData = new LevelData();

