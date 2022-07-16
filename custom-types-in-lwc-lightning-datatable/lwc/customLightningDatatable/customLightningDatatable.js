import LightningDatatable from 'lightning/datatable'
import customTypeA from './customTypeA'
import customTypeB from './customTypeB'

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
