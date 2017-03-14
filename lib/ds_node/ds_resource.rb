require "active_record"

module DSNode
  module DSResource
    class PreventDestroyLast < StandardError; end

    class RecognizedFileTypeValidator < ActiveModel::EachValidator
      def validate_each record, attr, values
        [values].flatten.each do |value|
          if value and !image?(value) and !video?(value)
            record.errors.add attr, "must be a recognized file type."
            return
          end
        end
      end

      private

      def image? value
        `identify -format '%w %h' #{value.path} 2>&1` && $?.success?
      end

      def video? value
        `mplayer -vc null -vo null -ao null -identify #{value.path} 2>&1 | grep 'VIDEO:  [[]'` && $?.success?
      end
    end

    module ClassMethods
      def ds_resource name, options = {}
        path = options.delete(:path) || ""
        should_validate = options.fetch(:validate, true)

        belongs_to name, options.reverse_merge({
          class_name: "DSNode::Resource",
          dependent: :destroy,
          required: false,
        })

        inquirer_accessor = :"#{name}?"
        define_method inquirer_accessor do
          send(name).present?
        end

        writer_accessor = :"#{name}_file"
        attr_accessor writer_accessor
        validates writer_accessor, recognized_file_type: true if should_validate

        destroy_accessor = :"destroy_#{name}"
        attr_accessor destroy_accessor

        after_save do
          if file = send(writer_accessor)
            send :"build_#{name}", path: path, file: file
            send :"#{writer_accessor}=", nil
            save
          end
        end

        after_save do
          if send(destroy_accessor).to_i == 1
            send(name).try(:destroy)
            send :"#{name}=", nil
            send :"#{destroy_accessor}=", nil
            save
          end
        end
      end

      def has_many_ds_resources name, options = {}
        single_name = options.key?(:single_name) ? options.delete(:single_name) : name.to_s.singularize.to_sym
        prevent_destroy_last = options.key?(:prevent_destroy_last) ? options.delete(:prevent_destroy_last) : false

        has_many name, options

        validates :"new_#{single_name}_files", recognized_file_type: true

        attr_accessor :"new_#{single_name}_files", :"destroy_#{single_name}_ids"

        after_save do
          if send(:"new_#{single_name}_files").present?
            Array(send(:"new_#{single_name}_files")).each do |file|
              send(name).create! file: file
            end
            send :"new_#{single_name}_files=", nil
          end
        end

        after_save do
          if send(:"destroy_#{single_name}_ids").present?
            (send(:"destroy_#{single_name}_ids") || []).each do |id|
              raise PreventDestroyLast if prevent_destroy_last && send(name).count == 1
              send(name).destroy(id)
            end
            send :"destroy_#{single_name}_ids=", nil
          end
        end
      end
    end

    private

    def self.included base
      base.extend ClassMethods
    end
  end
end
