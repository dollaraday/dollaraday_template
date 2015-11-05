class SwapDonorSubscriberAssociations < ActiveRecord::Migration
  def up
    add_column :donors, :subscriber_id, :integer

    ActiveRecord::Base.connection.execute %Q!
      UPDATE donors d
      INNER JOIN subscribers s
        ON s.donor_id = d.id
      SET d.subscriber_id = s.id
    !

    remove_column :subscribers, :donor_id
  end

  def down
  end
end
