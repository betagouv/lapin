class MoveUserAndRdvNotesToUserNotes < ActiveRecord::Migration[6.0]
  MESSAGE = "*attention cette note note est plus ancienne que la date affichée*   ".freeze

  def up
    create_table :user_notes do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :organisation, null: false, foreign_key: true
      t.belongs_to :agent, null: true, foreign_key: true
      t.text :text
      t.timestamps
    end

    rename_column :rdvs, :notes, :old_notes
    rename_column :user_profiles, :notes, :old_notes

    UserProfile.where.not(old_notes: ["", nil]).each { migrate_user_profile_notes(_1) }
    Rdv.where.not(old_notes: ["", nil]).each { migrate_rdv_notes(_1) }
  end

  def down
    drop_table :user_notes
    rename_column :rdvs, :old_notes, :notes
    rename_column :user_profiles, :old_notes, :notes
  end

  private

  def migrate_user_profile_notes(user_profile)
    UserNote.create!(
      user: user_profile.user,
      organisation: user_profile.organisation,
      agent: nil,
      text: MESSAGE + user_profile.old_notes
    )
  end

  def migrate_rdv_notes(rdv)
    target_user = rdv.users.responsible.first || rdv.users.first
    raise unless target_user.present?

    UserNote.create!(
      user: target_user,
      organisation: rdv.organisation,
      agent: nil,
      text: MESSAGE + rdv.old_notes
    )
  end
end
