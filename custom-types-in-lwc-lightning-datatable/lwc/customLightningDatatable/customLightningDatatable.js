import LightningDatatable from 'lightning/datatable'
import customTypeA from './templates/customTypeA'
import customTypeB from './templates/customTypeB'

export default class CustomLightningDatatable extends LightningDatatable {
  static customTypes = {
    customTypeA: {
      template: customTypeA,
      typeAttributes: ['customValueA'],
    },
    customTypeB: {
      template: customTypeB,
      typeAttributes: [],
    },
  }
}
