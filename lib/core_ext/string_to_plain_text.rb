class String
  # naively converts simple html into plain text.
  def to_plain_text
    # remove leading whitespace and line breaks. these are meaningless in html.
    text = self.gsub(/^\s+/, '').gsub(/[\n\r]/, ' ').gsub(/ {2,}/, ' ').gsub(/> +</, '><')
    # convert header tags
    text = text.gsub(%r(<h([0-9])[^>]*>(.*?)</h[0-9]>)i) { |s|
      title = $2.to_plain_text
      marker = ($1.to_i == 1) ? '=' : '-'
      title + "\n" + marker*title.length + "\n\n"
    # paragraphs
    }.gsub(%r(<p[^>]*>(.*?)</p>)i) { |s|
      $1.to_plain_text + "\n\n"
    # divs
    }.gsub(%r(<div[^>]*>(.*?)</div>)i) { |s|
      $1.to_plain_text + "\n\n"
    # line breaks
    }.gsub(%r(<br[/ ]*>)i) { |s|
      "\n"
    # ordered lists
    }.gsub(%r(<ol[^>]*>(.*?)</ol>)i) { |s|
      i = 0
      $1.to_plain_text.gsub("{B}") { |li| "#{i += 1}." } + "\n\n"
    # unordered lists
    }.gsub(%r(<ul[^>]*>(.*?)</ul>)i) { |s|
      $1.to_plain_text.gsub("{B}", '*') + "\n\n"
    # list items
    }.gsub(%r(<li[^>]*>(.*?)</li>)i) { |s|
      "{B} " + $1.to_plain_text + "\n"
    # links
    }.gsub(%r(<a[^>]*>(.*?)</a>)mi) { |s|
      inner = $1.to_plain_text
      url = s.match(/href=['"]([^'"]*)['"]/).try(:[], 1)
      inner.length > 0 ?
        ((url && url != inner) ? "#{inner} (#{url})" : inner) :
        ''
    # italic!
    }.gsub(%r(<i[^>]*>(.*?)</i>)i) { |s|
      "*" + $1.to_plain_text + "*"
    # bold!
    }.gsub(%r(<b[^>]*>(.*?)</b>)i) { |s|
      "**" + $1.to_plain_text + "**"
    # horizontal rules
    }.gsub(%r(<hr[/ ]*>)i) { |s|
      "\n\n" + ('-' * 25) + "\n\n"
    # table rows
    }.gsub(%r(<tr[^>]*>(.*?)</tr>)i) { |s|
      $1.to_plain_text + "\n"
    # &nbsp;
    }.gsub('&nbsp;', ' ')

    HTML::FullSanitizer.new.sanitize(text).strip.html_safe
  end
end
