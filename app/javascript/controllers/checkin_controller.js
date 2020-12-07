// Visit The Stimulus Handbook for more details 
// https://stimulusjs.org/handbook/introduction
// 
// This example controller works with specially annotated HTML like:
//
// <div data-controller="hello">
//   <h1 data-target="hello.output"></h1>
// </div>

import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "schedule", "weekday", "label" ]

  connect() {
  	this.setSchedule()
  	this.setLabel()
  }

  setSchedule() {
  	var $this = this
    if (this.scheduleTarget.value == "daily") {
    	$this.weekdayTarget.multiple = true
    } else {
    	$this.weekdayTarget.multiple = false
    }
    this.setLabel()
  }

  setLabel() {
  	var $this = this
    if ($this.scheduleTarget.value == "daily") {
    	$this.labelTarget.textContent = "At which days of the week?"

    } else if ($this.scheduleTarget.value == "weekly") {
    	$this.labelTarget.textContent = "At which day of the week?"

    } else if ($this.scheduleTarget.value == "two_weeks") {
    	$this.labelTarget.textContent = "At which day of the week?"
    	
    } else if ($this.scheduleTarget.value == "monthly") {
    	$this.labelTarget.textContent = "At the first .. of the month"
    }
  }
}
