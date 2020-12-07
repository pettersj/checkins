import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ 'target' ]

  connect() {
  	var stripe_pk = document.querySelector("meta[name='stripe-public-key']").getAttribute('content')
    window.stripe = Stripe(stripe_pk);

    window.elements = stripe.elements();

    window.account_id = document.querySelector("input[name='account_id']").value; 

    window.$this = this
    // let customer_id = document.querySelector("meta[name='customer_id']").getAttribute('content')

    window.style = {
      base: {
        color: "#32325d",
        fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
        fontSmoothing: "antialiased",
        fontSize: "16px",
        "::placeholder": {
          color: "#aab7c4"
        }
      },
      invalid: {
        color: "#fa755a",
        iconColor: "#fa755a"
      }
    };

    window.card = elements.create("card", { style: style });
    card.mount("#card-element");
    card.on('change', $this.showCardError);
    
    window.form = document.getElementById('subscription-form');

    // let subscriptionStatus = $this.getSubscriptionStatus

    // if (subscriptionStatus == "active") {
    //   document.getElementById('success').textContent = "active"
    // } else {
    //   document.getElementById('success').textContent = subscriptionStatus
    // }

    form.addEventListener('submit', function (ev) {
      ev.preventDefault();

      // If a previous payment was attempted, get the latest invoice
      const latestInvoicePaymentIntentStatus = localStorage.getItem(
        'latestInvoicePaymentIntentStatus'
      );

      if (latestInvoicePaymentIntentStatus === 'requires_payment_method') {
        const invoiceId = localStorage.getItem('latestInvoiceId');
        const isPaymentRetry = true;
        // create new payment method & retry payment on invoice with new payment method
        $this.createPaymentMethod({
          card,
          isPaymentRetry,
          invoiceId
        });
      } else {
        // create new payment method & create subscription
       $this.createPaymentMethod({ card });
      // }
    	}
    });
  }

  async getSubscriptionStatus() {
    let response = await fetch(`/stripe/subscription_status?account_id=${account_id}`)
    let result = await response.json() 
    console.log(result)
    return result
  }


  showCardError(event) {
    console.log('showCardError', event)
    let displayError = document.getElementById('card-errors');
    if (event.error) {
      displayError.textContent = event.error.message;
      document.getElementById('form-submit').disabled = false;
      document.getElementById('form-submit').textContent = "Submit";
    } else {
      displayError.textContent = "";
    }
  }

  displayError(event) {
    let displayError = document.getElementById('card-errors');
    if (event.error) {
      displayError.textContent = event.error.message;
      document.getElementById('form-submit').disabled = false;
      document.getElementById('form-submit').textContent = "Submit";
    } else {
      displayError.textContent = "";
    }
  }

  createPaymentMethod({ card, isPaymentRetry, invoiceId }) {
    // Set up payment method for recurring usage
    let billingName = document.querySelector('#name').value;
    let email = document.querySelector('#email').value;
    // let line1 =  document.querySelector('#line1').value;
    // let line2 =  document.querySelector('#line2').value;
    // let country =  document.querySelector('#country').value;
    // let city =  document.querySelector('#city').value;
    // let postalCode =  document.querySelector('#postalCode').value;
    // let state =  document.querySelector('#state').value;

    stripe
      .createPaymentMethod({
        type: 'card',
        card: card,
        billing_details: {
          name: billingName,
          email: email
        },
      })
      .then((result) => {
        if (result.error) {
          $this.displayError(result);
        } else {
          if (isPaymentRetry) {
            // Update the payment method and retry invoice payment
            this.retryInvoiceWithNewPaymentMethod({
              // customerId: customerId,
              paymentMethodId: result.paymentMethod.id,
              invoiceId: invoiceId,
              // priceId: priceId,
            });
          } else {
            // Create the subscription
            $this.createSubscription({
              // customerId: customerId,
              paymentMethodId: result.paymentMethod.id,
              // priceId: priceId,
            });
          }
        }
      });
    }


  createSubscription({ paymentMethodId }) {
    let email = document.querySelector('#email').value;
  	
    return (
      fetch(`/stripe/create_subscription`, {
        method: 'post',
        headers: {
          'Content-type': 'application/json',
        },
        body: JSON.stringify({
          account_id: account_id,
          paymentMethodId: paymentMethodId,
          email: email,
          authenticity_token: document.querySelector('input[name="authenticity_token"]').value
          // priceId: priceId,
        }),
      })
        .then((response) => {
          return response.json();
        })
        // If the card is declined, display an error to the user.
        .then((result) => {
          if (result.error) {
            // The card had an error when trying to attach it to a customer.
            throw result;
          }
          return result;
        })
        // Normalize the result to contain the object returned by Stripe.
        // Add the additional details we need.
        .then((result) => {
          return {
            paymentMethodId: paymentMethodId,
            priceId: result.subscription.items.data[0].price.id,
            subscription: result.subscription,
          };
        })
        // Some payment methods require a customer to be on session
        // to complete the payment process. Check the status of the
        // payment intent to handle these actions.
        .then($this.handlePaymentThatRequiresCustomerAction)
        // If attaching this card to a Customer object succeeds,
        // but attempts to charge the customer fail, you
        // get a requires_payment_method error.
        .then($this.handleRequiresPaymentMethod)
        // No more actions required. Provision your service for the user.
        .then($this.onSubscriptionComplete)
        .catch((error) => {
          // An error has happened. Display the failure to the user here.
          // We utilize the HTML element we created.
          $this.showCardError(error);
        })
    );
  }

  // onSubscriptionComplete(result) {
  //   console.log(result)
  //   // Payment was successful.
  //     location.reload();
    
  //   if (result.subscription.status === 'active') {
  //     location.reload();
  //     // Change your UI to show a success message to your customer.
  //     // Call your backend to grant access to your service based on
  //     // `result.subscription.items.data[0].price.product` the customer subscribed to.
  //   }
  // }

  handlePaymentThatRequiresCustomerAction({subscription, invoice, priceId, paymentMethodId, isRetry}) {
	  let setupIntent = subscription.pending_setup_intent;

	  if (setupIntent && setupIntent.status === 'requires_action')
	  {
	    return stripe
	      .confirmCardSetup(setupIntent.client_secret, {
	        payment_method: paymentMethodId,
	      })
	      .then((result) => {
	        if (result.error) {
	          // start code flow to handle updating the payment details
	          // Display error message in your UI.
	          // The card was declined (i.e. insufficient funds, card has expired, etc)
	          throw result;
	        } else {
	          if (result.setupIntent.status === 'succeeded') {
	            // There's a risk of the customer closing the window before callback
	            // execution. To handle this case, set up a webhook endpoint and
	            // listen to setup_intent.succeeded.
	            return {
	              priceId: priceId,
	              subscription: subscription,
	              invoice: invoice,
	              paymentMethodId: paymentMethodId,
	            };
	          }
	        }
	      });
	  }
	  else {
	    // No customer action needed
	    return { subscription, priceId, paymentMethodId };
	  }
  }

  handleRequiresPaymentMethod({ subscription,  paymentMethodId, priceId,}) {
    if (subscription.status === 'active' || subscription.status === "trialing") {
      // subscription is active, no customer actions required.
      return { subscription, priceId, paymentMethodId };
    } else if (  subscription.latest_invoice.payment_intent.status === 'requires_payment_method' ) {
      // NO SETUPINTET ON SUCCESS -- CHECK!!
      // Using localStorage to store the state of the retry here
      // (feel free to replace with what you prefer)
      // Store the latest invoice ID and status
      localStorage.setItem('latestInvoiceId', subscription.latest_invoice.id);
      localStorage.setItem(
        'latestInvoicePaymentIntentStatus',
        subscription.pending_setup_intent.status
      );
      throw { error: { message: 'Your card was declined.' } };
    } else {
      return { subscription, priceId, paymentMethodId };
    }
  }



  retryInvoiceWithNewPaymentMethod({customerId, paymentMethodId, invoiceId, priceId}) {
    return (
      fetch(`/stripe/retry_invoice?account_id=${account_id}`, {
        method: 'post',
        headers: {
          'Content-type': 'application/json',
        },
        body: JSON.stringify({
          customerId: customerId,
          paymentMethodId: paymentMethodId,
          invoiceId: invoiceId,
          authenticity_token: document.querySelector('input[name="authenticity_token"]').value
        }),
      })
        .then((response) => {
          return response.json();
        })
        // If the card is declined, display an error to the user.
        .then((result) => {
          if (result.error) {
            console.log(result.error)
            // The card had an error when trying to attach it to a customer.
            throw result;
          }
          return result;
        })
        // Normalize the result to contain the object returned by Stripe.
        // Add the additional details we need.
        .then((result) => {
          return {
            // Use the Stripe 'object' property on the
            // returned result to understand what object is returned.
            invoice: result,
            subscription: result,
            paymentMethodId: paymentMethodId,
            priceId: priceId,
            isRetry: true,
          };
        })
        // Some payment methods require a customer to be on session
        // to complete the payment process. Check the status of the
        // payment intent to handle these actions.
        .then($this.handlePaymentThatRequiresCustomerAction)
        // No more actions required. Provision your service for the user.
        .then($this.onSubscriptionComplete)
        .catch((error) => {
          console.log(error)
          // An error has happened. Display the failure to the user here.
          // We utilize the HTML element we created.
          $this.displayError(error);
        })
    );
  }

  cancelSubscription() {
    return fetch(`/stripe/cancel_subscription`, {
      method: 'post',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        subscriptionId: subscriptionId,
        authenticity_token: document.querySelector('input[name="authenticity_token"]').value
      }),
    })
      .then(response => {
        return response.json();
      })
      .then(cancelSubscriptionResponse => {
        // Display to the user that the subscription has been cancelled.
      });
  }

	onSubscriptionComplete(result) {
	  // Payment was successful.

	  if (result.subscription.status === 'active' || result.subscription.status === 'trialing') {
	  	console.log(result.subscription)
	  	console.log(result)
    	let displaySuccess = document.getElementById('subscription-success');

      displaySuccess.textContent = "All Set!"


	    return fetch(`/stripe/finalize_subscription`, {
	      method: 'post',
	      headers: {
	        'Content-Type': 'application/json',
	      },
	      body: JSON.stringify({
	        subscription_id: result.subscription.id,
	        account_id: account_id,
	        authenticity_token: document.querySelector('input[name="authenticity_token"]').value
	      }),
	    }).then(response => {
        return response.json();
      }).then(data => {
        $this.clearCache();
      	location.href = data.url
      })


	    // Change your UI to show a success message to your customer.
	    // Call your backend to grant access to your service based on
	    // `result.subscription.items.data[0].price.product` the customer subscribed to.
	  }
	}

  clearCache() {
    localStorage.clear();
  }

  disconnect() {
    // document.getElementsByTagName('trix-toolbar')[0].removeEventListener("select", this.showToolbar);
  }
}
