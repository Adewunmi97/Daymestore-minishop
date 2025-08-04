document.addEventListener("turbo:load", function () {
  const container = document.getElementById("paypal-button-container");
  
  if (container && window.paypal) {
    const price = container.dataset.price;
    console.log("PayPal price from dataset:", price);

    // Prevent multiple renders
    if (container.hasChildNodes()) return;

    paypal.Buttons({
      createOrder: function (data, actions) {
        return actions.order.create({
          purchase_units: [{
            amount: {
              value: price
            }
          }]
        });
      },
      onApprove: function (data, actions) {
        return actions.order.capture().then(function (details) {
          alert("Transaction completed by " + details.payer.name.given_name + "!");
        });
      }
    }).render("#paypal-button-container");
  }
});
