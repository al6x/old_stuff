require 'spec_helper'

describe "UrlHelper" do
  isolate :conveyors, :router, before: :all

  before :all do
    rad.web
    rad.reset :conveyors

    class MockRouter < Rad::Router
      def build_url_path path, params
        path = if params.blank?
          path
        else
          path + '?' + params.to_a.collect{|a, b| "#{a}=#{b}"}.join("&")
        end

        "build_url: #{path}"
      end

      def build_url_class klass, method, params
        path = "#{klass}.#{method}"
        build_url_path path, params
      end
    end

    MOCK_ROUTER = MockRouter.new :class

    class MockUrlHelperContext < TestTemplateContext
      inherit Rad::ViewRoutingHelper

      def build_url *args

        opt = args.extract_options!
        format = opt[:format]
        args << opt

        # url = args.inspect.gsub('"', "'")
        url = MOCK_ROUTER.build_url *args

        # url = "build_url: #{args.to_s}"
        url.marks.format = format
        url
      end
    end
  end

  after :all do
    remove_constants :MOCK_ROUTER, :MockRouter, :MockUrlHelperContext
  end

  before do
    @t = MockUrlHelperContext.new
  end

  if String.method_defined? :to_xhtml
    describe "link_to" do
      it "should works with build_url attributes" do
        @t.link_to('Book', Object, :method, {format: 'html'}, class: 'highlight').to_xhtml('a').
          to_fuzzy_hash.should == {class: "highlight", href: "build_url: Object.method?format=html", content: 'Book'}

        @t.link_to(Object, :method, {format: 'html'}, class: 'highlight'){'Book'}.to_xhtml('a').
          to_fuzzy_hash.should == {class: "highlight", href: "build_url: Object.method?format=html", content: 'Book'}

        @t.link_to('Book', :method).to_xhtml('a').
          to_fuzzy_hash.should == {href: "build_url: .method", content: 'Book'}
      end

      it "should works with build_url_path attributes" do
        @t.link_to('Book', '/some_book', class: 'highlight').to_xhtml('a').
          to_fuzzy_hash.should == {class: "highlight", href: "/some_book", content: 'Book'}

        @t.link_to('/some_book', class: 'highlight'){'Book'}.to_xhtml('a').
          to_fuzzy_hash.should == {class: "highlight", href: "/some_book", content: 'Book'}

        @t.link_to('/some_book'){'Book'}.to_xhtml('a').
          to_fuzzy_hash.should == {href: "/some_book", content: 'Book'}
      end

      it "links for 'js', 'json' formats should be automatically became remote" do
        @t.link_to('Book', @t.build_url('/some_book', format: 'json')).to_xhtml('a').to_fuzzy_hash.should == {
          href: '#', content: 'Book',
          'data-action' => 'build_url: /some_book?format=json', 'data-method' => 'post', 'data-remote' => 'true'
        }

        @t.link_to('Book', :method, format: 'js').to_xhtml('a').to_fuzzy_hash.should == {
          href: '#', content: 'Book',
          'data-action' => 'build_url: .method?format=js', 'data-method' => 'post', 'data-remote' => 'true'
        }

        @t.link_to('Book', :method, {format: 'js'}, class: 'highlight').to_xhtml('a').to_fuzzy_hash.should == {
          href: '#', content: 'Book', class: 'highlight',
          'data-action' => 'build_url: .method?format=js', 'data-method' => 'post', 'data-remote' => 'true'
        }
      end

      it "confirm" do
        attrs = @t.link_to('Book', '/some_book', confirm: 'Are you shure?').to_xhtml('a')
        attrs.should_not include('data-remote')
        attrs.should_not include('data-action')
        attrs.should_not include('data-method')
        attrs.to_fuzzy_hash.should == {
          href: "/some_book", content: 'Book',
          'data-confirm' => "Are you shure?"
        }
      end

      it "POST method" do
        attrs = @t.link_to('Book', '/some_book', method: :post).to_xhtml('a')
        attrs.should_not include('data-remote')
        attrs.to_fuzzy_hash.should == {
          href: "#", content: 'Book',
          'data-action' => '/some_book', 'data-method' => 'post'
        }
      end

      it "remote" do
        @t.link_to('Book', '/some_book', remote: true).to_xhtml('a').to_fuzzy_hash.should == {
          href: "#", content: 'Book',
          'data-action' => '/some_book', 'data-method' => 'post', 'data-remote' => 'true'
        }
      end

      it ":back" do
        env = Object.new
        env.stub(:[]).and_return('/go_back')
        request = Object.new
        request.stub(:env).and_return(env)
        workspace = Object.new
        workspace.stub(:request).and_return(request)
        @t.stub(:workspace).and_return(workspace)

        @t.link_to('Book', :back).to_xhtml('a').to_fuzzy_hash.should == {href: "/go_back", content: 'Book'}
        @t.link_to('Book', :back, class: '_some_js_mark').to_xhtml('a').
          to_fuzzy_hash.should == {href: "/go_back", class: '_some_js_mark', content: 'Book'}
      end

      it "#" do
        @t.link_to('Book', '#').to_xhtml('a').to_fuzzy_hash.should == {href: "#", content: 'Book'}
      end
    end
  else
    warn "WARN: skipping spec"
  end
end