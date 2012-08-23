base = "/static/themes/simple_organization"

m = {
  logo_text: "BOS Tec",
  logo_image: %{<a href="/"><img src="#{base}/img/logo.gif" alt=""></a>}
}

m[:homepage_html] = <<HTML\
<div class="col3 left">

  <h2 class="decoration decoration-green">Mission Statement</h2>

  <p class="quiet large">What we want to achieve</p>

  <p>Vestibulum eu pellentesque ante. Sed tincidunt quam eu nisl luctus id mattis tellus rhoncus.</p>
  <p>Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae. Donec dapibus eros vitae nibh venenatis faucibus.</p>
  <p><a class="more" href="#">Learn more »</a></p>

</div>

<div class="col3-mid left">

  <h2 class="decoration decoration-orange">Next Event</h2>

  <p class="quiet large">Friday, August 18, 2009</p>

  <p><img height="80" width="240" class="bordered" alt="" src="#{base}/img/sample-event.jpg"></p>
  <p><em>Aliquam augue neque, rhoncus et dictum in, cursus eget mauris.</em></p>

</div>

<div class="col3 right">

  <h2 class="decoration decoration-blue">Follow Us</h2>

  <p class="quiet large">http://twitter.com/username</p>

  <p>Nulla mollis sollicitudin nulla et mattis.<span class="quiet">(2 hours ago)</span></p>
  <p>Torquent per conubia nostra, per inceptos himenaeos. <span class="quiet">(2 hours ago)</span></p>
  <p>In sed ante at velit hendrerit blandit a et nibh. Cras sed cursus nulla. <span class="quiet">(3 hours ago)</span></p>
  <p>Nullam vitae mi at nulla blandit. <span class="quiet">(5 hours ago)</span></p>

</div>

<div class="clearer">&nbsp;</div>



<div class="content-separator"></div>

<h2>Images in text</h2>

<p>Curabitur faucibus risus quis lectus. <a href="#">Donec vehicula</a>. Pellentesque nec, lectus. Nullam dictum sem. Phasellus varius. Vestibulum in felis in mauris consequat molestie</p>

<div class='left'>
<img height="75" width="75" alt="" src="#{base}/img/sample-thumbnail.jpg">
</div>

<p>Consectetur adipiscing elit. In nisi. Duis condimentum est nec augue blandit scelerisque. Phasellus varius. Vestibulum in felis in mauris consequat molestie. Sem nec pellentesque condimentum, turpis massa ultricies nisi, at molestie justo eros ac velit.</p>

<div class='right'>
<img height="75" width="75" alt="" src="#{base}/img/sample-thumbnail.jpg">
</div>

<p>Curabitur euismod mi ac neque. Cras vel tortor molestie <a href="#">tortor luctus</a> facilisis. Nulla a nunc. Vivamus est. Integer ac sem quis ipsum dignissim sodales. Nam pulvinar sem eu nibh. Suspendisse non nulla et ligula bibendum facilisis. Suspendisse potenti. Vivamus leo.</p>

<p>Nulla lacus tortor, ornare vitae, vulputate vitae, sed quis magna. Pellentesque urna urna, bibendum non, ornare in, sollicitudin quis, est.</p>

<div class="clearer">&nbsp;</div>

HTML

m[:style_html] = <<HTML\
<h1>Heading 1</h1>
<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>

<h2>Heading 2</h2>
<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>

<h3>Heading 3</h3>
<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>

<h4>Heading 4</h4>
<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>

<div class="content-separator"></div>

<h2>Images in text</h2>

<img height="75" width="75" src="#{base}/img/sample-thumbnail.jpg">

<p>Curabitur faucibus risus quis lectus. <a href="#">Donec vehicula</a>. Pellentesque nec, lectus. Nullam dictum sem. Phasellus varius. Vestibulum in felis in mauris consequat molestie</p>

<div class="content-separator"></div>

<div class='left'>
  <img height="75" width="75" alt="" src="#{base}/img/sample-thumbnail.jpg">
</div>

<p>Consectetur adipiscing elit. In nisi. Duis condimentum est nec augue blandit scelerisque. Phasellus varius. Vestibulum in felis in mauris consequat molestie. Sem nec pellentesque condimentum, turpis massa ultricies nisi, at molestie justo eros ac velit.</p>

<div class='right'>
  <img height="75" width="75" alt="" src="#{base}/img/sample-thumbnail.jpg">
</div>

<p>Curabitur euismod mi ac neque. Cras vel tortor molestie <a href="#">tortor luctus</a> facilisis. Nulla a nunc. Vivamus est. Integer ac sem quis ipsum dignissim sodales. Nam pulvinar sem eu nibh. Suspendisse non nulla et ligula bibendum facilisis. Suspendisse potenti. Vivamus leo.</p>

<p>Nulla lacus tortor, ornare vitae, vulputate vitae, sed quis magna. Pellentesque urna urna, bibendum non, ornare in, sollicitudin quis, est.</p>

<div class="clearer">&nbsp;</div>

<div class="content-separator"></div>

<h2>Blockquote</h2>

<blockquote>
  <p>Praesent orci nisi, interdum quis, tristique vitae, consectetur sed, arcu. Ut at sapien non dolor semper sollicitudin. Etiam semper erat quis odio. Quisque commodo suscipit velit. Nulla facilisi.</p>
  <p><cite>- Duis justo quam</cite></p>
</blockquote>

<div class="content-separator"></div>

<h2>Lists</h2>

<h3>Unsorted list</h3>
<ul>
  <li>Blandit in, interdum a</li>
  <li>Ultrices non lectus</li>
  <li>Nunc id odio</li>
  <li>Fusce ultricies</li>
</ul>

<h3>Ordered list</h3>
<ol>
  <li>Blandit in, interdum a</li>
  <li>Ultrices non lectus</li>
  <li>Nunc id odio</li>
  <li>Fusce ultricies</li>
</ol>

<h3>Definition list</h3>

<dl>
  <dt>title</dt>
  <dd>definition</dd>
  <dd>definition</dd>
  <dt>title</dt>
  <dt>title</dt>
  <dd>definition</dd>
  <dt>title</dt>
  <dd>definition</dd>
</dl>

<div class="content-separator"></div>

<h2>Tables</h2>

<h3>Data table</h3>

<table class="data-table">
  <tbody><tr>
    <th>Property 1</th>
    <th>Property 2</th>
    <th>Property 3</th>
    <th>Property 4</th>
  </tr>
  <tr class="even">
    <td>Value 1.1</td>
    <td>Value 1.2</td>
    <td>Value 1.3</td>
    <td>Value 1.4</td>
  </tr>
  <tr>
    <td>Value 2.1</td>
    <td>Value 2.2</td>
    <td>Value 2.3</td>
    <td>Value 2.4</td>
  </tr>
  <tr class="even">
    <td>Value 3.1</td>
    <td>Value 3.2</td>
    <td>Value 3.3</td>
    <td>Value 3.4</td>
  </tr>
  <tr>
    <td>Value 4.1</td>
    <td>Value 4.2</td>
    <td>Value 4.3</td>
    <td>Value 4.4</td>
  </tr>
</tbody></table>
HTML

m