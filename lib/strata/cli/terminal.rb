require "tty-spinner"
require "pastel"
require "terminal-table"
require "io/console"

module Strata
  module CLI
    module Terminal
      # Shows a loader while running IO tasks
      def with_spinner(message = "Loading...",
        success_message: "Done!",
        failed_message: "Failed!!",
        clear: false,
        message_color: :yellow,
        spinner_color: :red,
        format: :dots,
        &block)
        pastel = Pastel.new

        colored_message = pastel.send(message_color, message)
        colored_spinner = "[#{pastel.send(spinner_color, " :spinner ")}]"

        spinner = TTY::Spinner.new("#{colored_spinner} #{colored_message}",
          success_mark: pastel.green("✔"),
          format: format,
          clear: clear)
        spinner.auto_spin

        begin
          result = yield
          spinner.success(pastel.green(success_message))
          result
        rescue => e
          spinner.error(pastel.red(failed_message))
          raise e
        end
      end

      def print_table(data, headers: nil, color: :magenta)
        if data.empty?
          say ::Terminal::Table.new, color
          return
        end

        terminal_width = begin
          IO.console.winsize[1]
        rescue
          80
        end

        actual_headers = headers || (0...data.first.length).map { |i| "Col#{i + 1}" }

        # Calculate actual width needed for each column
        column_widths = []
        actual_headers.each_with_index do |header, i|
          header_width = header.to_s.length
          data_width = data.map { |row| row[i].to_s.length }.max || 0
          column_widths << [header_width, data_width].max
        end

        # Table overhead: 4 for outer borders + 3 per column separator
        table_overhead = 2 + (column_widths.length - 1) * 1
        # Add 2 chars padding per column (space on each side)
        total_padding = column_widths.length * 2

        # Find how many columns fit
        fitted_cols = 0
        running_width = table_overhead + total_padding

        column_widths.each_with_index do |width, i|
          if running_width + width <= terminal_width
            running_width += width
            fitted_cols += 1
          else
            break
          end
        end

        # Ensure at least one column
        fitted_cols = [fitted_cols, 1].max

        # Create the table
        limited_headers = actual_headers.first(fitted_cols)
        limited_data = data.map { |row| row.first(fitted_cols) }

        table = ::Terminal::Table.new do |t|
          t.style = {border: :unicode}
          t.headings = limited_headers
          limited_data.each { |row| t.add_row(row) }
        end

        say table, color
        if fitted_cols < actual_headers.length
          truncated = actual_headers.length - fitted_cols
          say "(Showing #{fitted_cols}/#{actual_headers.length} columns - #{truncated} truncated)", :cyan
        end
      end
    end
  end
end
