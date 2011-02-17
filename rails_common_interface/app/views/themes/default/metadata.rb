base = "/common_interface"

m = {
  :logo => "<a href='/'>BOS Tec</a>" 
}

m[:homepage_html] = <<HTML
<p>The Terminator (1984) <a href='#'>More at IMDbPro</a></p>
<p>In the Year of Darkness, 2029, the rulers of this planet devised the ultimate plan. They would reshape the Future by changing the Past. The plan required something that felt no pity. No pain. No fear. Something unstoppable. They created 'THE TERMINATOR'</p>
<p>The thing that won't die, in the nightmare that won't end. A human-looking, apparently unstoppable cyborg is sent from the future to kill Sarah Connor; Kyle Reese is sent to stop it.</p>
<p>Your future is in his hands.</p>
HTML

m[:style_html] = <<HTML
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

<img src="#{base}/images/img1_thumb.jpg">

<p>Curabitur faucibus risus quis lectus. <a href="#">Donec vehicula</a>. Pellentesque nec, lectus. Nullam dictum sem. Phasellus varius. Vestibulum in felis in mauris consequat molestie</p>

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