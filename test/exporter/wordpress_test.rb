require './test/helper.rb'

class ExporterWordpressTest < Test::Unit::TestCase
  def test_export
    @wordpress_xml = File.open('./test/fixtures/wordpress.xml').read
    @doc = BlogConverter::Importer::Wordpress.import @wordpress_xml
    @xml = BlogConverter::Exporter::Wordpress.export @doc
    puts @xml
    @new_doc = BlogConverter::Importer::Wordpress.import @xml
    assert_equal @doc.articles.count, @new_doc.articles.count
    assert_equal @doc.articles.first.categories, @new_doc.articles.first.categories
    assert_equal @doc.articles.first.tags, @new_doc.articles.first.tags
    assert_equal @doc.articles.first.comments.count, @new_doc.articles.first.comments.count
  end
end
