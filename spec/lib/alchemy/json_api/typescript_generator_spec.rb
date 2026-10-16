# frozen_string_literal: true

require "rails_helper"
require "alchemy/json_api/typescript_generator"

RSpec.describe Alchemy::JsonApi::TypescriptGenerator do
  subject(:output) { described_class.new.generate }

  it "exports a union of all element names" do
    expect(output).to include(
      'export type AlchemyElementName = "header" | "headline" | "article" | "text" | "search" | "news" | ' \
      '"download" | "bild" | "contactform" | "all_you_can_eat" | "erb_element" | "slide" | "slider" | ' \
      '"gallery" | "gallery_picture" | "right_column" | "left_column" | "erb_cell" | "old"'
    )
  end

  it "exports a union of all page layouts" do
    expect(output).to include(
      'export type AlchemyPageLayout = "index" | "readonly" | "standard" | "everything" | "news" | ' \
      '"contact" | "footer" | "erb_layout"'
    )
  end

  it "exports an interface per element with its ingredients narrowed by role" do
    expect(output).to include(<<~TS)
      export interface AlchemyArticleElement extends AlchemyElementBase {
        name: "article"
        ingredients: Array<
          | (AlchemyIngredientText & { role: "intro" })
          | (AlchemyIngredientText & { role: "headline" })
          | (AlchemyIngredientPicture & { role: "image" })
          | (AlchemyIngredientRichtext & { role: "text" })
        > | null
        nested_elements: never[]
      }
    TS
  end

  it "narrows nested elements to the nestable elements" do
    expect(output).to include(<<~TS)
      export interface AlchemySliderElement extends AlchemyElementBase {
        name: "slider"
        ingredients: never[] | null
        nested_elements: Array<AlchemySlideElement>
      }
    TS
  end

  it "exports an element base interface with the shared element attributes" do
    expect(output).to include(<<~TS)
      export interface AlchemyElementBase {
        id: string
        fixed: boolean
        position: number
        created_at: string
        updated_at: string
        deprecated: boolean
      }
    TS
  end

  it "exports an interface per page layout with its elements split into fixed and non-fixed" do
    expect(output).to include(<<~TS)
      export interface AlchemyEverythingPage extends AlchemyPageBase {
        page_layout: "everything"
        elements: Array<AlchemyTextElement | AlchemyAllYouCanEatElement | AlchemyGalleryElement>
        fixed_elements: Array<AlchemyRightColumnElement | AlchemyLeftColumnElement>
      }
    TS
  end

  it "exports a page base interface with the shared page attributes and relationships" do
    expect(output).to include(<<~TS)
      export interface AlchemyPageBase {
        id: string
        name: string
        urlname: string
        url_path: string
        language_code: string
        created_at: string
        updated_at: string
        restricted: boolean
        legacy_urls: string[]
        title: string | null
        meta_keywords: string | null
        meta_description: string | null
        language: AlchemyLanguage | null
        ancestors: AlchemyPage[] | null
        all_elements: AlchemyElement[]
      }
    TS
  end

  it "exports unions of all element and page interfaces" do
    expect(output).to include("export type AlchemyElement = AlchemyHeaderElement | AlchemyHeadlineElement | AlchemyArticleElement")
    expect(output).to include("export type AlchemyPage = AlchemyIndexPage | AlchemyReadonlyPage | AlchemyStandardPage")
  end

  it "marks conditionally serialized attributes as optional" do
    expect(output).to include("  image_dimensions?: { width: number; height: number }\n")
    expect(output).to include("  alt_text: string | null\n")
  end

  it "types ingredient values by ingredient type" do
    expect(output).to match(/export interface AlchemyIngredientBoolean \{\n  id: string\n  role: string\n  value: boolean \| null\n/)
  end

  it "types relationships of ingredients" do
    expect(output).to match(/export interface AlchemyIngredientPage \{\n(  .+\n)*  page: AlchemyPage \| null\n\}/)
  end

  it "exports language and node interfaces" do
    expect(output).to include(<<~TS)
      export interface AlchemyNode {
        id: string
        name: string
        link_url: string | null
        link_title: string | null
        link_nofollow: boolean | null
        parent: AlchemyNode | null
        page?: AlchemyPage | null
        children: AlchemyNode[] | null
      }
    TS
    expect(output).to include("  pages: AlchemyPage[] | null\n  root_page: AlchemyPage | null\n")
  end

  context "with relationships" do
    let(:serializer) do
      Class.new(Alchemy::JsonApi::BaseSerializer) do
        set_type :thing
        has_many :pages, serializer: Alchemy::JsonApi::PageSerializer
        has_many :lazy_pages, record_type: :page, serializer: Alchemy::JsonApi::PageSerializer, lazy_load_data: true
        belongs_to :language, serializer: Alchemy::JsonApi::LanguageSerializer
        belongs_to :conditional_language, record_type: :language, serializer: Alchemy::JsonApi::LanguageSerializer, if: -> { true }
        belongs_to :lazy_conditional_language, record_type: :language, serializer: Alchemy::JsonApi::LanguageSerializer, if: -> { true }, lazy_load_data: true
      end
    end

    before { stub_const("Alchemy::JsonApi::LanguageSerializer", serializer) }

    it "types them as nullable only if the deserializer can return null" do
      expect(output).to include(<<~TS)
        export interface AlchemyLanguage {
          id: string
          pages: AlchemyPage[]
          lazy_pages: AlchemyPage[] | null
          language: AlchemyLanguage | null
          conditional_language?: AlchemyLanguage
          lazy_conditional_language?: AlchemyLanguage | null
        }
      TS
    end
  end

  context "with select ingredients" do
    before do
      allow(Alchemy::PageDefinition).to receive(:all).and_return([])
      allow(Alchemy::ElementDefinition).to receive(:all).and_return([
        Alchemy::ElementDefinition.new(
          name: "selects",
          ingredients: [
            {role: "plain", type: "Select", settings: {select_values: ["A", "B"]}},
            {role: "pairs", type: "Select", settings: {select_values: [["Label A", "a"], ["Label B", 2]]}},
            {role: "grouped", type: "Select", settings: {select_values: {"Group" => ["x", ["Label Y", "y"]]}}},
            {role: "multiple", type: "Select", settings: {select_values: ["A", "B"], multiple: true}},
            {role: "none", type: "Select"}
          ]
        )
      ])
    end

    it "narrows the value to the select values" do
      expect(output).to include(<<~TS)
        export interface AlchemySelectsElement extends AlchemyElementBase {
          name: "selects"
          ingredients: Array<
            | (AlchemyIngredientSelect & { role: "plain"; value: "A" | "B" | null })
            | (AlchemyIngredientSelect & { role: "pairs"; value: "a" | "2" | null })
            | (AlchemyIngredientSelect & { role: "grouped"; value: "x" | "y" | null })
            | (AlchemyIngredientSelect & { role: "multiple"; value: Array<"A" | "B"> })
            | (AlchemyIngredientSelect & { role: "none" })
          > | null
          nested_elements: never[]
        }
      TS
    end
  end

  context "with an ingredient type without serializer" do
    before do
      allow(Alchemy::PageDefinition).to receive(:all).and_return([])
      allow(Alchemy::ElementDefinition).to receive(:all).and_return([
        Alchemy::ElementDefinition.new(name: "counter", ingredients: [{role: "count", type: "Number"}])
      ])
    end

    it "falls back to the base ingredient attributes" do
      expect(output).to include(<<~TS)
        export interface AlchemyIngredientNumber {
          id: string
          role: string
          value: unknown
          created_at: string
          updated_at: string
          deprecated: boolean
        }
      TS
    end
  end

  context "with a page layout referencing an undefined element" do
    before do
      allow(Alchemy::ElementDefinition).to receive(:all).and_return([])
      allow(Alchemy::PageDefinition).to receive(:all).and_return([
        Alchemy::PageDefinition.new(name: "orphan", elements: ["missing"])
      ])
    end

    it "skips the undefined element" do
      expect(output).to include("  elements: never[]\n  fixed_elements: never[]\n")
      expect(output).to include("export type AlchemyElement = never\n")
    end
  end

  context "with element names resulting in the same type name" do
    before do
      allow(Alchemy::PageDefinition).to receive(:all).and_return([])
      allow(Alchemy::ElementDefinition).to receive(:all).and_return([
        Alchemy::ElementDefinition.new(name: "foo_bar"),
        Alchemy::ElementDefinition.new(name: "foo-bar")
      ])
    end

    it "raises an error" do
      expect { output }.to raise_error(
        described_class::TypeNameCollisionError,
        "Element definitions foo_bar, foo-bar would all generate the TypeScript type AlchemyFooBarElement. Please rename them."
      )
    end
  end

  context "with page layout names resulting in the same type name" do
    before do
      allow(Alchemy::ElementDefinition).to receive(:all).and_return([])
      allow(Alchemy::PageDefinition).to receive(:all).and_return([
        Alchemy::PageDefinition.new(name: "standard"),
        Alchemy::PageDefinition.new(name: "standard")
      ])
    end

    it "raises an error" do
      expect { output }.to raise_error(
        described_class::TypeNameCollisionError,
        "Page layout definitions standard, standard would all generate the TypeScript type AlchemyStandardPage. Please rename them."
      )
    end
  end

  context "with a key transform" do
    before do
      stub_const(
        "Alchemy::JsonApi::IngredientTextSerializer",
        Class.new(Alchemy::JsonApi::BaseSerializer) do
          set_key_transform :dash
          include Alchemy::JsonApi::IngredientSerializer

          attributes :link_title

          typelize(value: "string | null", link_title: "string | null")
        end
      )
    end

    it "uses the transformed keys and quotes them if necessary" do
      expect(output).to include(<<~TS)
        export interface AlchemyIngredientText {
          id: string
          role: string
          value: string | null
          "created-at": string
          "updated-at": string
          deprecated: boolean
          "link-title": string | null
        }
      TS
    end
  end
end
