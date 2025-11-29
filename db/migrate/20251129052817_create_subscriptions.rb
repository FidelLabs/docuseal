class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :account, null: false, foreign_key: true
      t.string :stripe_subscription_id
      t.string :stripe_customer_id
      t.string :plan_type # 'pro' or 'enterprise'

      t.timestamps
    end

    add_index :subscriptions, :stripe_subscription_id, unique: true
    add_index :subscriptions, :stripe_customer_id, unique: true
    add_index :subscriptions, :plan_type
  end
end
