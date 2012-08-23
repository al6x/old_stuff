describe "Localization", ->
  [old, locale] = [null, null]
  beforeEach ->
    locale = rad.locale()
    old = locale.current

  afterEach -> locale.current = old

  it "should translate messages", ->
    locale.some_lang =
      comments_count: '{{count}} comments'
    locale.current = 'some_lang'

    t('comments_count', count: 10).should be: "10 comments"