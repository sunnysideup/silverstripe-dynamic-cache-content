# tl;dr

This is a module that, in theory, should allow you to cache your entire site on a CDN. 
Making it much faster (this is the theory and hope).
The basic idea is that each page only loads the stuff that is publicly available and unique to that page. This part is cached.

In your local storage, you have the universal content that is used on all pages (`navigation menu`) 
and user specific data (`welcome back Wendy`) and you apply that to the page on load. 
After that the page will validate this information with the server and update the page and local storage for the next page load.

You can then implement an interface (similar to the flush interface) and let any class, with this interface applied, 
provide arrays of keys (selectors) and values (html) that should be returned to do this replacement. 

Here is how to implement the module: 

## server side

### identify personalised and universal data

1. Identify any personalised data in your html templates.
   If it is specific to that page (e.g. userform) - then it is outside of the scope here. Dont cache that page.
   If it is personalised but the same throughout the site (e.g. `Welcome back User` - shown on the header on every page)
   then follow steps below.
   
3. Identify parts that are the same on every page (e.g. menu, footer)

4. Replace the personalised data in the template with the non-personalised version - e.g. `Click here to login`.
   The template should have the content you would expect, for example, Google to index. Not, `hello $CurrentUser.FirstName`.
   Keep the containing tag and note the assocated selector (e.g. `#welcome-message`, `.my-message`).

6. For the universal data (e.g. footer or menu), also remove this from the your templates.
   However, again, keep the containing tag and note the associated selector (e.g. `#footer`),

7. You can now start to setup methods that return arrays of `selector` keys and their personalised values / universal values.
   This works as follows:

### basic example

```php


class MyProvider implements SiteWideDataProviderInterface
{
    public static function resolvePersonalisedData(
        mixed $obj,
        array $args,
        array $context,
        mixed $info
    ): array
    {
        return [
            '#personal' => Security::getCurrentUser()?->getTitle(),
        ];

    }

    public static function resolveUniversalData(
        mixed $obj,
        array $args,
        array $context,
        mixed $info
    ): array
    {
        return [
            '#main' => '<p>Better content</p>',
            'footer' => '<h1>My Footer</h1>',
        ];
    }
}

```

## client side

At the bottom of your main `page.ss` file add:

```ss
<% include Sunnysideup/DynamicCacheContent/ApplyJs %>
```
This will include a small bit of JS that applies the universal and personalised content to every page as it loads.

## turn on CDN caching

You can now turn on `CDN` caching for your pages in the usual way and see if they load any faster than before. 
