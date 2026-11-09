class AddAuthenticationAndUserRoles < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :password_digest, :string, null: false, default: ""
    add_column :users, :role, :string, null: false, default: "member"
    add_column :users, :contact_details, :string
    add_column :users, :bio, :string, limit: 500
    execute "UPDATE users SET role = 'moderator' WHERE is_moderator = TRUE"

    remove_column :users, :password_hash, :string
    remove_column :users, :is_moderator, :boolean, default: false, null: false

    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :user_agent
      t.string :ip_address
      t.timestamps
    end
  end

  def down
    drop_table :sessions
    add_column :users, :password_hash, :string, null: false, default: ""
    add_column :users, :is_moderator, :boolean, null: false, default: false
    execute "UPDATE users SET is_moderator = (role = 'moderator')"
    remove_column :users, :bio, :string, limit: 500
    remove_column :users, :contact_details, :string
    remove_column :users, :role, :string, default: "member", null: false
    remove_column :users, :password_digest, :string, default: "", null: false
    change_column_default :users, :password_hash, from: "", to: nil
  end
end
