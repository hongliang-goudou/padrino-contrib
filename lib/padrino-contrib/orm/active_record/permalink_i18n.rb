module Padrino
  module Contrib
    module Orm
      module ActiveRecord
        ##
        # This module extend ActiveRecord.
        #
        # You need to to your model a column called +:permalink+
        #
        # then use +has_permalink :title like:
        #
        #   class Page < ActiveRecord::Base
        #     has_permalink :page, :langs => [:en, :fr, :de]
        #   end
        #
        module PermalinkI18n
          module ClassMethods
            def has_permalink(field, options={})
              include InstanceMethods
              @_permalink_field = field
              @_permalink_langs = options.delete(:langs)
              before_save :generate_permalinks
              permalink_langs.each do |lang|
                validates_uniqueness_of :"#{field}_#{lang}", options
              end
            end

            def permalink_for(name)
              name = Iconv.iconv('ascii//translit//IGNORE', 'utf-8', name).to_s
              name.gsub!(/\W+/, ' ') # non-words to space
              name.strip!
              name.downcase!
              name.gsub!(/\s+/, '-') # all spaces to dashes
              name
            end

            def permalink_field
              @_permalink_field
            end

            def permalink_langs
              @_permalink_langs
            end
          end

          module InstanceMethods
            def to_param
              permalink
            end

            protected
              def generate_permalinks
                self.class.permalink_langs.each do |lang|
                  self.send(:"permalink_#{lang}=", self.class.permalink_for(read_attribute(:"#{self.class.permalink_field}_#{lang}")))
                end
              end
          end # InstanceMethods
        end # PemalinkI18n
      end # Ar
    end # Orm
  end # Contrib
end # Padrino
::ActiveRecord::Base.extend(Padrino::Contrib::Orm::ActiveRecord::PermalinkI18n::ClassMethods)
