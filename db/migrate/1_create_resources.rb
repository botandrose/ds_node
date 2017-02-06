class CreateResources < ActiveRecord::Migration[5.0]
  def change
    create_table "resources", primary_key: "resourcesid" do |t|
      t.string   "resourcestype"
      t.decimal  "resourcesduration",         precision: 10
      t.integer  "resourceswidth"
      t.integer  "resourcesheight"
      t.string   "resourcesfilename"
      t.string   "resourcesoriginalfilename"
      t.string   "resourcespath"
      t.integer  "resourcesthumbid"
      t.string   "resourceshash"
      t.integer  "resourcesparentid"
      t.integer  "resourcesparentindex"
      t.datetime "created_at",                               null: false
      t.datetime "updated_at",                               null: false
    end
  end
end
