class CreateAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :accounts do |t|
      t.string :email
      t.string :nombreCompleto
      t.string :age
      t.string :nombreUsuario
      t.string :country
      t.string :password

      t.timestamps
    end
  end
end
