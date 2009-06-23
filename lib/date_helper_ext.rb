module ActionView
  module Helpers
    module DateHelper
      def select_year_with_suffix(date, options = {})
        select_year_without_suffix(date, options) + " 年 "
      end

      def select_month_with_suffix(date, options = {})
        select_month_without_suffix(date, options) + " 月 "
      end

      def select_day_with_suffix(date, options = {})
        select_day_without_suffix(date, options) + " 日 "
      end

      alias_method_chain :select_year, :suffix
      alias_method_chain :select_month, :suffix
      alias_method_chain :select_day, :suffix
    end
  end
end
