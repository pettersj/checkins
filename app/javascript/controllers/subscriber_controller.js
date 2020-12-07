import { Controller } from "stimulus"

export default class extends Controller {
  // static targets = [ "schedule", "weekday", "label" ]


  subscribe() {
    var subscriber_id = this.data.get("subscriber-id")
    var account_id = this.data.get("account-id")
    var checkin_id = this.data.get("checkin-id")
    var member_id = this.data.get("member-id")

    var data = new FormData;
    data.append("subscriber[account_id]", account_id);
    data.append("subscriber[check_in_id]", checkin_id);
    data.append("subscriber[member_id]", member_id);

    Rails.ajax({
      url: `/${account_id}/check_ins/${checkin_id}/subscribers/`,
      type: "post",
      dataType: 'script',
      data: data
    })
  }

  unsubscribe() {
    var subscriber_id = this.data.get("subscriber-id")
    var account_id = this.data.get("account-id")
    var checkin_id = this.data.get("checkin-id")

    Rails.ajax({
      url: `/${account_id}/check_ins/${checkin_id}/subscribers/${subscriber_id}`,
      type: "delete",
      dataType: 'script'
    })
  }
}
