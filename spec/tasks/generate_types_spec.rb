# frozen_string_literal: true

require "rails_helper"
require "rake"

RSpec.describe "alchemy:json_api:generate_types" do
  let(:output_file) { Rails.root.join("tmp", "types", "alchemy.d.ts") }

  before(:all) { Rails.application.load_tasks unless Rake::Task.task_defined?("alchemy:json_api:generate_types") }

  before { FileUtils.rm_rf(output_file.dirname) }
  after { FileUtils.rm_rf(output_file.dirname) }

  around do |example|
    ENV["OUTPUT"] = output_file.to_s
    example.run
  ensure
    ENV.delete("OUTPUT")
    Rake::Task["alchemy:json_api:generate_types"].reenable
  end

  it "writes the types into the OUTPUT file" do
    expect { Rake::Task["alchemy:json_api:generate_types"].invoke }.to output(/#{output_file}/).to_stdout
    expect(output_file.read).to include("export type AlchemyPage =")
  end
end
