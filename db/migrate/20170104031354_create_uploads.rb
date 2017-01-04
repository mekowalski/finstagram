class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :photo
    end
  end
end
