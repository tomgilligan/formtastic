module Formtastic
  module Inputs
    # Outputs a country select input, wrapping around a regular country_select helper.
    # Rails doesn't come with a `country_select` helper by default any more, so you'll need to do
    # one of the following:
    #
    # * install the [country-select](https://github.com/jamesds/country-select) gem
    # * install the no longer maintained [official Rails plugin](http://github.com/rails/iso-3166-country-select)
    # * install any other country_select plugin that behaves in a similar way
    # * roll your own `country_select` helper with the same args and options as the Rails one
    #
    # By default, Formtastic includes a handful of English-speaking countries as "priority
    # counties", which can be set in the `priority_countries` configuration array in the
    # formtastic.rb initializer to suit your market and user base (see README for more info on
    # configuration). Additionally, it is possible to set the :priority_countries on a per-input
    # basis through the `:priority_countries` option. These priority countries will be passed down
    # to the `country_select` helper of your choice, and may or may not be used by the helper.
    #
    # @example Basic example with full form context using `priority_countries` from config
    #
    #   <%= semantic_form_for @user do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :nationality, :as => :country %>
    #     <% end %>
    #   <% end %>
    #
    #   <li class='country'>
    #     <label for="user_nationality">Country</label>
    #     <select id="user_nationality" name="user[nationality]">
    #       <option value="...">...</option>
    #       # ...
    #   </li>
    #
    # @example `:priority_countries` set on a specific input
    #
    #   <%= semantic_form_for @user do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :nationality, :as => :country, :priority_countries => ["Australia", "New Zealand"] %>
    #     <% end %>
    #   <% end %>
    #
    #   <li class='country'>
    #     <label for="user_nationality">Country</label>
    #     <select id="user_nationality" name="user[nationality]">
    #       <option value="...">...</option>
    #       # ...
    #   </li>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documentation of all possible options.
    class CountryInput 
      include Base

      def to_html
        raise "To use the :country input, please install a country_select plugin, like this one: https://github.com/stefanpenner/country_select" unless builder.respond_to?(:country_select)
        input_wrapping do
          label_html <<
          country_select_helper
        end
      end

      def country_select_helper
        prioritity_countries_as_argument? ? 
          country_select_helper_with_priority_countries_as_argument :
          country_select_helper_with_priority_countries_as_option
      end

      def country_select_helper_with_priority_countries_as_argument
        builder.country_select(method, priority_countries, input_options, input_html_options)
      end

      def country_select_helper_with_priority_countries_as_option
        builder.country_select(method, input_options_with_priority_countries, input_html_options)
      end
      
      def priority_countries
        options[:priority_countries] || builder.priority_countries
      end

      # TODO: Version 2 of stefanpenner/country_select deviates from the original arguments structure
      # we've supported. Leaving this true uses the older API, but provides developers with a simple
      # hook they can override if they want to use the newer API.
      #
      # Ideally, we'd find a way to detect or configure what API to use. Here's what I've considered
      # so far:
      #
      # * a configuration value at the Formtastic level (urgh)
      # * detection based on the arity of the helper method (doesn't work, they're both `-2`)
      # * detection based on CountrySelect::VERSION (too specific to only one plugin)
      def prioritity_countries_as_argument?
        true
      end

      def input_options_with_priority_countries
        input_options.merge(:priority_countries => priority_countries)
      end

    end
  end
end
