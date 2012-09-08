Postalist
=========

We don't make forms, we just handle them for you.

What?
-----

Postalist takes an http POST from anywhere, and if it knows the referrer (that is, has any configuration files for it), it does something with the posted fields.

### Like what?

Right now, the only thing it can do is send an email somewhere. It should be easy to add handlers for submitting data to various APIs (syslog, Google Spreadsheet, Twitter, or...such). However, the goal is to keep things simplistic, and do no heavy lifting. Just send an email (and/or other notification), and forward the user on to the configured 'success' page.

Why?
----

Sometimes we just need a static site—such as one would build with Jekyll, Octopress, or just Notepad. But even on the staticest of static sites, we often end up wanting a contact form. Postalist provides a place for that form to post, without resorting to all the bells and whistles of a form service (such as the excellent Wufu Forms, etc.).

How?
----

1. Clone this repository

2. Add a settings directory for your contact page. The directory should mirror the form’s url, with the following modifications:

   * Remove http:// or https://
   * Remove www. subdomain, if present
   * Replace all dots (.) with underscores (_)

   For example, https://www.example.com/my/contact/form.php needs a settings directory named settings/example_com/my/contact/form_php`

3. Under this directory, create a settings.yml file, containing the following settings for starters:

   ```yaml
   on_success: 'http://example.com/url/for/redirect/after/post'
   mail:
     from: webform@example.com
     to: recipient@example.com
     subject: "Message posted on {{referer}} from {{ip}}"
   ```

4. Configure the form page:

   In the form element, add the attribute `data-postalist`, as in

   ```html
   <form data-postalist>
     ...
   </form>
   ```

   Then append the following to the page body (or header):

   ```html
   <script>
     (function(d) {
       var s = d.createElement('script'), s2 = d.getElementsByTagName('script')[0];
       s.src = '/token/' + Date.now() + '.js';
       s2.parentNode.insertBefore(s, s2);
     })(document);
   </script>
   ```
