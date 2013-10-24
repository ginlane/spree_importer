class Spree::ImportSourceFile < ActiveRecord::Base
  has_many :imports
  def csv?
    mime =~ /csv/
  end
end
