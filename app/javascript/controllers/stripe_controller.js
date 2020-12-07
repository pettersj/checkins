import { Controller } from "stimulus"

export default class extends Controller {
  // static targets = [ "schedule", "weekday", "label" ]

  connect() {
  	var stripe_pk = document.querySelector("meta[name='stripe-public-key']").getAttribute('content')
    window.stripe = Stripe(stripe_pk);

    window.priceId = 'price_1HpDIhAesjI1wm1vHPMdgFrd' // personal
    this.createCheckoutSession(priceId)
	}

	createCheckoutSession(priceId) {
		var $this = this

	  fetch("/stripe/create_checkout_session", {
	    method: "POST",
	    headers: {
	      "Content-Type": "application/json"
	    },
	    body: JSON.stringify({
	      price_id: priceId,
        authenticity_token: document.querySelector('input[name="authenticity_token"]').value,
        account_id: document.querySelector('input[name="account_id"]').value
	    })
	  })
	  .then((resp) => resp.json())
	  .then(function(data) {
	  	$this.redirectToCheckout(data);
	  })
	}


	tieredMonthly() {
		var priceId = 'price_1HoktgAesjI1wm1vmteYeMkz'
	}


	selectPersonal() {
		var $this = this
		var priceId = 'price_1HoU69AesjI1wm1vXs9bLV5P'
		this.createCheckoutSession(priceId)
	}
	
	selectTeam() {
		var $this = this
		var priceId = 'price_1HoU6LAesjI1wm1vzmsQl6mn'
		this.createCheckoutSession(priceId)
	}

	selectBusiness() {
		var $this = this
		var priceId = 'price_1HoU6bAesjI1wm1vabnQyFvX'
		this.createCheckoutSession(priceId)
	}

	redirectToCheckout(data) {
		console.log(data)
    stripe
      .redirectToCheckout({
        sessionId: data.sessionId
      })
      .then($this.handleResult);
	}

	handleResult(result) {
	  if (result.error) {
	    var displayError = document.getElementById("error-message");
	    displayError.textContent = result.error.message;
	  }
	};


}