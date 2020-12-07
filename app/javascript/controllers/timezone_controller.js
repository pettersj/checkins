import { Controller } from "stimulus"
import jstz from 'jstz'

export default class extends Controller {
  static targets = [ "select" ]
  

  connect() {
    let array = this.findTimeZone().split('/')
    let name = array[array.length - 1] // removes Europe or Asia or..
    this.selectTarget.value = name
  }

  findTimeZone() {
    const oldIntl = window.Intl
    try {
      window.Intl = undefined
      const tz = jstz.determine().name()
      window.Intl = oldIntl
      return tz
    } catch (e) {
      // sometimes (on android) you can't override intl
      return jstz.determine().name()
    }
  }
}
