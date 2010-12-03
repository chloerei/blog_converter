require './test/helper.rb'

class ExporterBlogbusTest < Test::Unit::TestCase
  def test_export
    @blogbus_xml = File.open('./test/fixtures/blogbus.xml').read
    @doc = BlogConverter::Importer::Blogbus.import @blogbus_xml
    @xml = BlogConverter::Exporter::Blogbus.export @doc
    @new_doc = BlogConverter::Importer::Blogbus.import @xml
    assert_equal @doc.articles.count, @new_doc.articles.count
    assert_equal @doc.articles.first.categories, @new_doc.articles.first.categories
    assert_equal @doc.articles.first.tags, @new_doc.articles.first.tags
    assert_equal @doc.articles.first.comments.count, @new_doc.articles.first.comments.count
  end
end
