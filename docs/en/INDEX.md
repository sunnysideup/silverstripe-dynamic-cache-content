# td;dr

How this work...

## server side

### identify personalised and universal data

1. Identify any personalised data in your html templates.
   If it is specific to that page - then don't cache the page (outside of the scope here).
   If it is personalised but the same throughout the site then follow steps below.
   (e.g. `Welcome back User` - shown on the header on every page)

2. Identify parts that are the same on every page (e.g. footer / header)

3. Replace the personalised data in the template with the non-personalised version - e.g. `Click here to login`.
   This is the content you would expect, for example, Google to index.

4. For the universal data (e.g. footer), also remove this from the your templates.
   Again, we make sure it has a good selector (e.g. "footer", "#menu")

5. You can now start to setup methods that return arrays of `selector` keys and their personalised values / universal values.
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
            '#main' => 'Hello World'
        ];
    }
}

```

## client side

At the bottom of your page.ss file add:

```ss
<% include Sunnysideup/DynamicCacheContent/ApplyJs %>
```

This will include a small bit of JS that applies the universal and local content.
