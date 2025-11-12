import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { CommonConstants as Common } from './CommonConstants';

@CustomDialog
export default struct ImagePicker {
  @Link index: number;
  @State selected: number = Common.ZERO;
  private  imagesData: Array<Resource> = [];
  public controller: CustomDialogController;

  aboutToAppear() {
    this.selected = this.index;
  }

  build() {
    Column() {
      List({ space: Common.LIST_SPACE }) {
        ForEach(this.imagesData, (item: Resource, index) => {
          ListItem() {
            Stack({ alignContent: Alignment.TopEnd }) {
              Image(item)
                .width($r('app.float.image_width'))
                .height($r('app.float.image_height'))
                .margin(30)
                .borderRadius(Common.BORDER_RADIUS)
              Radio({ value: Common.RADIO_VALUE, group: Common.RADIO_GROUP })
                .id(`radio${this.selected + Common.ONE}_${index + Common.ONE}`)
                .checked(index === this.selected ? true : false)
                .onChange(() => {
                  this.selected = index;
                })
            }
          }
        }, (item: Resource) => JSON.stringify(item))
      }
      .borderRadius(Common.BORDER_RADIUS)
      .width(Common.LIST_WIDTH)
      .height($r('app.float.list_height'))
      .listDirection(Axis.Horizontal)
      Row() {
        Button($r('app.string.cancel'))
          .id(Common.CANCEL_BUTTON)
          .margin({ right: Common.BUTTON_MARGIN })
          .onClick(() => {
            this.controller.close();
          })
        Button($r('app.string.submit'))
          .id(Common.CONFIRM_BUTTON)
          .onClick(() => {
            this.index = this.selected;
          })
      }
      .margin({ bottom: $r('app.float.margin_bottom') })
    }
    .width(Common.FULL_WIDTH)
    .borderRadius(Common.BORDER_RADIUS)
  }
}

