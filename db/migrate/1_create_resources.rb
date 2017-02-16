class CreateResources < ActiveRecord::Migration[5.0]
  def change
    create_table "resources", primary_key: "resourcesid" do |t|
      t.string   "resourcestype"
      t.decimal  "resourcesduration", precision: 10, default: 0
      t.integer  "resourceswidth", default: 0
      t.integer  "resourcesheight", default: 0
      t.string   "resourcesfilename"
      t.string   "resourcesoriginalfilename"
      t.string   "resourcespath"
      t.integer  "resourcesthumbid"
      t.string   "resourceshash"
      t.integer  "resourcesparentid", default: 0
      t.integer  "resourcesparentindex", default: 0
      t.datetime "created_at",                               null: false
      t.datetime "updated_at",                               null: false
    end
  end
end
