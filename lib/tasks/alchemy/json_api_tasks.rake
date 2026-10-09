# frozen_string_literal: true

namespace :alchemy do
  namespace :json_api do
    desc "Generate TypeScript types from the element and page layout definitions. Set OUTPUT to change the file path."
    task generate_types: :environment do
      require "alchemy/json_api/typescript_generator"

      output = Pathname.new(ENV.fetch("OUTPUT", Rails.root.join("app/javascript/types/alchemy.d.ts")))
      FileUtils.mkdir_p(output.dirname)
      File.write(output, Alchemy::JsonApi::TypescriptGenerator.new.generate)
      puts "Generated TypeScript types in #{output}"
    end
  end
end
