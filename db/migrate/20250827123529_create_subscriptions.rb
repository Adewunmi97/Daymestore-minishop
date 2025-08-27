class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :paypal_subscription_id
      t.string :plan_id
      t.string :status
      t.datetime :start_time

      t.timestamps
    end
  end
end
